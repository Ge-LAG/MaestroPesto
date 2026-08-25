/// Shared toolkit for the database-metier CSV loaders (Lot B).
///
/// Provides, without any external dependency:
/// - [parseCsvLine]: a minimal RFC-4180-style CSV line parser (quotes,
///   escaped quotes, commas inside quotes);
/// - [Sha256]: a streaming SHA-256 implementation (dart:convert only);
/// - [fingerprintFile]: SHA-256 + line count of a file in one streaming pass;
/// - [CsvCells]: cell parsers (trim, empty-as-null, bool, int, double,
///   pipe-separated lists) driven by the CSV header column names;
/// - [ImportStateStore]: persistence of per-source hashes in an
///   `import_state` table created at runtime (schema files are frozen);
/// - [runCsvImport]: the generic streaming import engine used by every
///   phase loader (batches of [csvBatchSize], `INSERT OR IGNORE`,
///   parsing in a background isolate via `Isolate.run`).
library;

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:drift/drift.dart';

import '../app_database.dart';

const int csvBatchSize = 500;

List<String> parseCsvLine(String line) {
  final fields = <String>[];
  final cell = StringBuffer();
  var inQuotes = false;
  for (var i = 0; i < line.length; i++) {
    final ch = line.codeUnitAt(i);
    if (inQuotes) {
      if (ch == 0x22) {
        if (i + 1 < line.length && line.codeUnitAt(i + 1) == 0x22) {
          cell.writeCharCode(ch);
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        cell.writeCharCode(ch);
      }
    } else if (ch == 0x22) {
      inQuotes = true;
    } else if (ch == 0x2c) {
      fields.add(cell.toString());
      cell.clear();
    } else {
      cell.writeCharCode(ch);
    }
  }
  if (inQuotes) {
    throw const FormatException('unterminated quoted CSV field');
  }
  fields.add(cell.toString());
  return fields;
}

List<String> parseCsvHeader(String line) {
  final names = parseCsvLine(line);
  if (names.isNotEmpty) {
    names[0] = names[0].replaceFirst('\uFEFF', '');
  }
  return names.map((n) => n.trim()).toList();
}

Map<String, int> columnIndex(List<String> header) {
  final index = <String, int>{};
  for (var i = 0; i < header.length; i++) {
    index.putIfAbsent(header[i], () => i);
  }
  return index;
}

class CsvCells {
  final List<String> row;
  final Map<String, int> index;

  CsvCells(this.row, this.index);

  String? _raw(String column) {
    final i = index[column];
    if (i == null || i >= row.length) return null;
    final v = row[i].trim();
    return v.isEmpty ? null : v;
  }

  String? str(String column) => _raw(column);

  String reqStr(String column) {
    final v = _raw(column);
    if (v == null) {
      throw FormatException('missing required CSV column value: $column');
    }
    return v;
  }

  bool? boolOf(String column) {
    final v = _raw(column);
    if (v == null) return null;
    switch (v) {
      case 'true':
        return true;
      case 'false':
        return false;
    }
    throw FormatException('invalid boolean in CSV column $column: $v');
  }

  int? intOf(String column) {
    final v = _raw(column);
    if (v == null) return null;
    return int.parse(v);
  }

  double? dbl(String column) {
    final v = _raw(column);
    if (v == null) return null;
    return double.parse(v);
  }

  List<String>? strList(String column) {
    final v = _raw(column);
    if (v == null) return null;
    final items = v.split('|').map((s) => s.trim()).toList();
    if (items.every((s) => s.isEmpty)) return null;
    return items;
  }
}

class Sha256 {
  static const List<int> _k = [
    0x428a2f98,
    0x71374491,
    0xb5c0fbcf,
    0xe9b5dba5,
    0x3956c25b,
    0x59f111f1,
    0x923f82a4,
    0xab1c5ed5,
    0xd807aa98,
    0x12835b01,
    0x243185be,
    0x550c7dc3,
    0x72be5d74,
    0x80deb1fe,
    0x9bdc06a7,
    0xc19bf174,
    0xe49b69c1,
    0xefbe4786,
    0x0fc19dc6,
    0x240ca1cc,
    0x2de92c6f,
    0x4a7484aa,
    0x5cb0a9dc,
    0x76f988da,
    0x983e5152,
    0xa831c66d,
    0xb00327c8,
    0xbf597fc7,
    0xc6e00bf3,
    0xd5a79147,
    0x06ca6351,
    0x14292967,
    0x27b70a85,
    0x2e1b2138,
    0x4d2c6dfc,
    0x53380d13,
    0x650a7354,
    0x766a0abb,
    0x81c2c92e,
    0x92722c85,
    0xa2bfe8a1,
    0xa81a664b,
    0xc24b8b70,
    0xc76c51a3,
    0xd192e819,
    0xd6990624,
    0xf40e3585,
    0x106aa070,
    0x19a4c116,
    0x1e376c08,
    0x2748774c,
    0x34b0bcb5,
    0x391c0cb3,
    0x4ed8aa4a,
    0x5b9cca4f,
    0x682e6ff3,
    0x748f82ee,
    0x78a5636f,
    0x84c87814,
    0x8cc70208,
    0x90befffa,
    0xa4506ceb,
    0xbef9a3f7,
    0xc67178f2,
  ];

  final _h = [
    0x6a09e667,
    0xbb67ae85,
    0x3c6ef372,
    0xa54ff53a,
    0x510e527f,
    0x9b05688c,
    0x1f83d9ab,
    0x5be0cd19,
  ];
  final _block = Uint8List(64);
  int _blockLength = 0;
  int _totalLength = 0;
  bool _closed = false;

  int _rotr(int x, int n) => ((x >> n) | (x << (32 - n))) & 0xffffffff;

  void _processBlock(List<int> chunk, int start) {
    final w = List<int>.filled(64, 0);
    for (var t = 0; t < 16; t++) {
      final i = start + t * 4;
      w[t] =
          (chunk[i] << 24) |
          (chunk[i + 1] << 16) |
          (chunk[i + 2] << 8) |
          chunk[i + 3];
    }
    for (var t = 16; t < 64; t++) {
      final s0 = _rotr(w[t - 15], 7) ^ _rotr(w[t - 15], 18) ^ (w[t - 15] >> 3);
      final s1 = _rotr(w[t - 2], 17) ^ _rotr(w[t - 2], 19) ^ (w[t - 2] >> 10);
      w[t] = (w[t - 16] + s0 + w[t - 7] + s1) & 0xffffffff;
    }
    var a = _h[0];
    var b = _h[1];
    var c = _h[2];
    var d = _h[3];
    var e = _h[4];
    var f = _h[5];
    var g = _h[6];
    var h = _h[7];
    for (var t = 0; t < 64; t++) {
      final s1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
      final ch = (e & f) ^ (~e & g);
      final temp1 = (h + s1 + ch + _k[t] + w[t]) & 0xffffffff;
      final s0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
      final maj = (a & b) ^ (a & c) ^ (b & c);
      final temp2 = (s0 + maj) & 0xffffffff;
      h = g;
      g = f;
      f = e;
      e = (d + temp1) & 0xffffffff;
      d = c;
      c = b;
      b = a;
      a = (temp1 + temp2) & 0xffffffff;
    }
    _h[0] = (_h[0] + a) & 0xffffffff;
    _h[1] = (_h[1] + b) & 0xffffffff;
    _h[2] = (_h[2] + c) & 0xffffffff;
    _h[3] = (_h[3] + d) & 0xffffffff;
    _h[4] = (_h[4] + e) & 0xffffffff;
    _h[5] = (_h[5] + f) & 0xffffffff;
    _h[6] = (_h[6] + g) & 0xffffffff;
    _h[7] = (_h[7] + h) & 0xffffffff;
  }

  void add(List<int> bytes) {
    if (_closed) throw StateError('Sha256 already closed');
    _totalLength += bytes.length;
    var offset = 0;
    if (_blockLength > 0) {
      final need = 64 - _blockLength;
      final take = bytes.length < need ? bytes.length : need;
      _block.setRange(_blockLength, _blockLength + take, bytes, 0);
      _blockLength += take;
      offset = take;
      if (_blockLength == 64) {
        _processBlock(_block, 0);
        _blockLength = 0;
      }
    }
    while (offset + 64 <= bytes.length) {
      _processBlock(bytes, offset);
      offset += 64;
    }
    if (offset < bytes.length) {
      _block.setRange(0, bytes.length - offset, bytes, offset);
      _blockLength = bytes.length - offset;
    }
  }

  String digestHex() {
    if (_closed) throw StateError('Sha256 already closed');
    final bitLength = _totalLength * 8;
    add(const [0x80]);
    while (_blockLength != 56) {
      add(const [0x00]);
    }
    _closed = true;
    final tail = [
      (bitLength >> 56) & 0xff,
      (bitLength >> 48) & 0xff,
      (bitLength >> 40) & 0xff,
      (bitLength >> 32) & 0xff,
      (bitLength >> 24) & 0xff,
      (bitLength >> 16) & 0xff,
      (bitLength >> 8) & 0xff,
      bitLength & 0xff,
    ];
    _block.setRange(56, 64, tail);
    _processBlock(_block, 0);
    final out = StringBuffer();
    for (final word in _h) {
      out.write(word.toRadixString(16).padLeft(8, '0'));
    }
    return out.toString();
  }
}

class CsvFingerprint {
  final String sha256Hex;
  final int lineCount;

  const CsvFingerprint(this.sha256Hex, this.lineCount);
}

/// Resolves a CSV source path to a chunked byte stream.
///
/// Default implementation reads from the local filesystem ([File]).
/// For Flutter assets (Lot E), the `AppServices` layer passes a closure
/// over `rootBundle.load(...)` so the rest of the toolkit stays
/// platform-agnostic.
typedef CsvBytesReader = Stream<List<int>> Function(String csvPath);

Stream<List<int>> _defaultCsvBytesReader(String csvPath) {
  return File(csvPath).openRead();
}

/// Thread-local override for the CSV reader (Lot E — Flutter assets).
///
/// The 4 loaders are constructed without dependency injection (Lot B
/// choices), so this module-level variable is the cheapest way to swap
/// the file-based reader for an asset-based reader without touching
/// every loader signature. Reset to null between imports to avoid leaks
/// across concurrent calls.
CsvBytesReader? activeCsvReader;

Future<CsvFingerprint> fingerprintFile(String csvPath) async {
  final sha = Sha256();
  var lines = 0;
  var endsWithNewline = true;
  final open = activeCsvReader ?? _defaultCsvBytesReader;
  await for (final chunk in open(csvPath)) {
    sha.add(chunk);
    for (final byte in chunk) {
      if (byte == 0x0a) lines++;
      endsWithNewline = byte != 0x0a;
    }
  }
  if (endsWithNewline) lines++;
  return CsvFingerprint(sha.digestHex(), lines);
}

class ImportStateStore {
  final AppDatabase db;
  bool _ensured = false;

  ImportStateStore(this.db);

  Future<void> _ensure() async {
    if (_ensured) return;
    await db.customStatement(
      'CREATE TABLE IF NOT EXISTS import_state ('
      'source_name TEXT PRIMARY KEY, hash TEXT NOT NULL, '
      'imported_at TEXT NOT NULL)',
    );
    _ensured = true;
  }

  Future<String?> currentHash(String sourceName) async {
    await _ensure();
    final rows = await db
        .customSelect(
          'SELECT hash FROM import_state WHERE source_name = ?',
          variables: [Variable.withString(sourceName)],
        )
        .get();
    return rows.isEmpty ? null : rows.first.read<String>('hash');
  }

  Future<bool> isUnchanged(String sourceName, String hash) async {
    return await currentHash(sourceName) == hash;
  }

  Future<void> touch(String sourceName) async {
    await _ensure();
    await db.customStatement(
      'UPDATE import_state SET imported_at = ? WHERE source_name = ?',
      [_nowIso(), sourceName],
    );
  }

  Future<void> recordSuccess(String sourceName, String hash) async {
    await _ensure();
    await db.customStatement(
      'INSERT OR REPLACE INTO import_state (source_name, hash, imported_at) '
      'VALUES (?, ?, ?)',
      [sourceName, hash, _nowIso()],
    );
  }

  static String _nowIso() => DateTime.now().toUtc().toIso8601String();
}

class CsvLoadOutcome {
  final int insertedRows;
  final bool skipped;

  const CsvLoadOutcome(this.insertedRows, this.skipped);
}

Future<int> countTableRows(AppDatabase db, String tableName) async {
  final row = await db
      .customSelect('SELECT COUNT(*) AS c FROM "$tableName"')
      .getSingle();
  return row.read<int>('c');
}

typedef CsvRowParser<T> = T Function(List<String> row, List<String> header);
typedef CsvBatchInserter<T> = Future<void> Function(Batch batch, List<T> rows);

List<T> parseCsvChunk<T>(
  List<String> lines,
  List<String> header,
  CsvRowParser<T> parseRow,
) {
  return lines
      .map((line) => parseRow(parseCsvLine(line), header))
      .toList(growable: false);
}

Future<List<T>> parseCsvChunkInIsolate<T>(
  List<String> lines,
  List<String> header,
  CsvRowParser<T> parseRow,
) {
  return Isolate.run(() => parseCsvChunk(lines, header, parseRow));
}

Future<CsvLoadOutcome> runCsvImport<T>({
  required AppDatabase db,
  required String csvPath,
  required String sourceName,
  required String tableName,
  required CsvRowParser<T> parseRow,
  required CsvBatchInserter<T> insertRows,
  void Function(int rowsDone, int? rowsTotal)? onProgress,
  void Function(bool skipped)? onSkip,
}) async {
  final fingerprint = await fingerprintFile(csvPath);
  final store = ImportStateStore(db);
  if (await store.isUnchanged(sourceName, fingerprint.sha256Hex)) {
    await store.touch(sourceName);
    onSkip?.call(true);
    onProgress?.call(0, 0);
    return const CsvLoadOutcome(0, true);
  }

  final rowsBefore = await countTableRows(db, tableName);
  final declaredTotal = fingerprint.lineCount - 1;
  final rowsTotal = declaredTotal < 0 ? null : declaredTotal;

  var header = const <String>[];
  var headerRead = false;
  var rowsDone = 0;
  var pending = const <String>[];

  Future<void> flush() async {
    final lines = pending;
    final parsed = await parseCsvChunkInIsolate(lines, header, parseRow);
    await db.batch((batch) => insertRows(batch, parsed));
    rowsDone += parsed.length;
    onProgress?.call(rowsDone, rowsTotal);
  }

  final open = activeCsvReader ?? _defaultCsvBytesReader;
  await for (final line in open(
    csvPath,
  ).transform(utf8.decoder).transform(const LineSplitter())) {
    if (line.isEmpty) continue;
    if (!headerRead) {
      header = parseCsvHeader(line);
      headerRead = true;
      continue;
    }
    if (pending.isEmpty) {
      pending = [line];
    } else {
      pending.add(line);
    }
    if (pending.length >= csvBatchSize) {
      await flush();
      pending = const [];
    }
  }
  if (pending.isNotEmpty) {
    await flush();
    pending = const [];
  }
  if (!headerRead) {
    throw FormatException('CSV file has no header line: $sourceName');
  }

  final rowsAfter = await countTableRows(db, tableName);
  await store.recordSuccess(sourceName, fingerprint.sha256Hex);
  onSkip?.call(false);
  return CsvLoadOutcome(rowsAfter - rowsBefore, false);
}

bool csvListEquals(List<String>? a, List<String>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

int csvPropsHash(List<Object?> props) {
  return Object.hashAll([
    for (final p in props)
      if (p is List) Object.hashAll(p) else p,
  ]);
}

bool csvPropsEquals(List<Object?> a, List<Object?> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    final x = a[i];
    final y = b[i];
    if (x is List && y is List) {
      if (!csvListEquals(x as List<String>, y as List<String>)) return false;
    } else if (x != y) {
      return false;
    }
  }
  return true;
}

String? pipeJoin(List<String>? values) =>
    values == null || values.isEmpty ? null : values.join('|');
