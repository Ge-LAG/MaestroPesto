import 'dart:io';

import 'package:flutter/material.dart';

Widget buildRecipePhoto(String path, {required BoxFit fit}) {
  final uri = Uri.tryParse(path);
  final isRemote =
      uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https' || uri.scheme == 'data');

  if (isRemote) {
    return Image.network(path, fit: fit, errorBuilder: _errorBuilder);
  }

  final file = uri != null && uri.scheme == 'file'
      ? File.fromUri(uri)
      : File(path);
  return Image.file(file, fit: fit, errorBuilder: _errorBuilder);
}

Widget _errorBuilder(
  BuildContext context,
  Object error,
  StackTrace? stackTrace,
) {
  return ColoredBox(
    color: const Color(0xFFE9ECE4),
    child: Center(
      child: Icon(
        Icons.broken_image_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}
