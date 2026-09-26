// Page « Paramètres » : apparence (thème, taille du texte) et données
// (bases métier, volumes, emplacement de la base, sources).

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/app/settings/app_settings.dart';
import 'package:maestropesto/app/theme/app_theme.dart';
import 'package:maestropesto/core/database/database_bootstrap.dart';
import 'package:maestropesto/features/sources/presentation/data_sources_page.dart';

/// État de l'import des bases métier, partagé entre l'accueil (barre de
/// progression) et les paramètres.
@immutable
class MetierImportStatus {
  const MetierImportStatus({
    this.importing = false,
    this.step = 0,
    this.loaded = false,
  });

  final bool importing;

  /// Étape courante (index dans [AppServices.importPhases]).
  final int step;
  final bool loaded;

  MetierImportStatus copyWith({bool? importing, int? step, bool? loaded}) =>
      MetierImportStatus(
        importing: importing ?? this.importing,
        step: step ?? this.step,
        loaded: loaded ?? this.loaded,
      );
}

Future<void> showSettingsPage(
  BuildContext context, {
  required AppServices services,
  required ValueListenable<MetierImportStatus> importStatus,
  required VoidCallback onUpdateMetier,
}) => Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (_) => SettingsPage(
      services: services,
      importStatus: importStatus,
      onUpdateMetier: onUpdateMetier,
    ),
  ),
);

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    required this.services,
    required this.importStatus,
    required this.onUpdateMetier,
    super.key,
  });

  final AppServices services;
  final ValueListenable<MetierImportStatus> importStatus;
  final VoidCallback onUpdateMetier;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Future<DatabaseSummary> _summary = widget.services.databaseSummary();
  late bool _wasImporting = widget.importStatus.value.importing;

  @override
  void initState() {
    super.initState();
    widget.importStatus.addListener(_onImportStatus);
  }

  @override
  void dispose() {
    widget.importStatus.removeListener(_onImportStatus);
    super.dispose();
  }

  /// Fin d'un import : volumes et date de vérification à relire.
  void _onImportStatus() {
    final importing = widget.importStatus.value.importing;
    if (_wasImporting && !importing && mounted) {
      final summary = widget.services.databaseSummary();
      setState(() {
        _summary = summary;
      });
    }
    _wasImporting = importing;
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);
    final settings = widget.services.settings;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.settingsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Section(
                    icon: Icons.palette_outlined,
                    title: strings.settingsAppearance,
                    children: [
                      ListenableBuilder(
                        listenable: settings,
                        builder: (context, _) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _Field(
                              label: strings.settingsTheme,
                              child: SegmentedButton<ThemeMode>(
                                showSelectedIcon: false,
                                segments: [
                                  ButtonSegment(
                                    value: ThemeMode.system,
                                    icon: const Icon(Icons.brightness_auto),
                                    label: Text(strings.settingsThemeSystem),
                                  ),
                                  ButtonSegment(
                                    value: ThemeMode.light,
                                    icon: const Icon(Icons.light_mode_outlined),
                                    label: Text(strings.settingsThemeLight),
                                  ),
                                  ButtonSegment(
                                    value: ThemeMode.dark,
                                    icon: const Icon(Icons.dark_mode_outlined),
                                    label: Text(strings.settingsThemeDark),
                                  ),
                                ],
                                selected: {settings.themeMode},
                                onSelectionChanged: (s) =>
                                    settings.setThemeMode(s.first),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _Field(
                              label: strings.settingsTextSize,
                              child: SegmentedButton<TextSizeSetting>(
                                showSelectedIcon: false,
                                segments: [
                                  ButtonSegment(
                                    value: TextSizeSetting.standard,
                                    label: Text(strings.settingsTextStandard),
                                  ),
                                  ButtonSegment(
                                    value: TextSizeSetting.large,
                                    label: Text(strings.settingsTextLarge),
                                  ),
                                ],
                                selected: {settings.textSize},
                                onSelectionChanged: (s) =>
                                    settings.setTextSize(s.first),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    icon: Icons.storage_outlined,
                    title: strings.settingsData,
                    children: [
                      ValueListenableBuilder<MetierImportStatus>(
                        valueListenable: widget.importStatus,
                        builder: (context, status, _) => _MetierBlock(
                          status: status,
                          summary: _summary,
                          onUpdate: widget.onUpdateMetier,
                        ),
                      ),
                      const Divider(height: 28),
                      _DatabaseLocation(path: widget.services.databasePath),
                      const Divider(height: 28),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.menu_book_outlined),
                        title: Text(
                          strings.sourcesTitle,
                          style: theme.textTheme.titleMedium,
                        ),
                        subtitle: Text(strings.sourcesSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => showDataSourcesPage(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        child,
      ],
    );
  }
}

class _MetierBlock extends StatelessWidget {
  const _MetierBlock({
    required this.status,
    required this.summary,
    required this.onUpdate,
  });

  final MetierImportStatus status;
  final Future<DatabaseSummary> summary;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);
    final palette = context.palette;
    final phases = AppServices.importPhases;
    final step = status.step.clamp(0, phases.length - 1);

    final Widget stateIcon;
    final String stateLabel;
    if (status.importing) {
      stateIcon = const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
      stateLabel = strings.settingsMetierRunning(
        phases[step].$2,
        step + 1,
        phases.length,
      );
    } else if (status.loaded) {
      stateIcon = Icon(Icons.check_circle_outline, color: palette.success);
      stateLabel = strings.settingsMetierReady;
    } else {
      stateIcon = Icon(Icons.error_outline, color: palette.warn);
      stateLabel = strings.settingsMetierMissing;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            stateIcon,
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${strings.settingsMetier} : ',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: stateLabel),
                  ],
                ),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        if (status.importing) ...[
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: (step + 0.5) / phases.length,
            minHeight: 4,
          ),
        ],
        const SizedBox(height: 8),
        FutureBuilder<DatabaseSummary>(
          future: summary,
          builder: (context, snap) {
            final s = snap.data;
            if (s == null) return const SizedBox(height: 18);
            final lines = [
              strings.settingsVolumes(
                s.ingredients,
                s.recipes,
                s.schemaVersion,
              ),
              if (s.lastCheck != null)
                strings.settingsLastCheck(_formatDate(s.lastCheck!)),
            ];
            return Text(lines.join('\n'), style: theme.textTheme.bodySmall);
          },
        ),
        const SizedBox(height: 8),
        Text(strings.settingsMetierHelp, style: theme.textTheme.bodySmall),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: status.importing ? null : onUpdate,
          icon: const Icon(Icons.sync),
          label: Text(strings.settingsMetierUpdate),
        ),
      ],
    );
  }

  static String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} à '
        '${two(d.hour)}:${two(d.minute)}';
  }
}

class _DatabaseLocation extends StatelessWidget {
  const _DatabaseLocation({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);
    final path = this.path;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.settingsDbLocation,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                path ?? strings.settingsDbInMemory,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        if (path != null)
          IconButton(
            tooltip: strings.settingsCopyPath,
            icon: const Icon(Icons.copy_outlined, size: 20),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await Clipboard.setData(ClipboardData(text: path));
              messenger.showSnackBar(
                SnackBar(content: Text(strings.settingsPathCopied)),
              );
            },
          ),
      ],
    );
  }
}
