import 'package:flutter/material.dart';

Widget buildRecipePhoto(String path, {required BoxFit fit}) {
  return Image.network(path, fit: fit, errorBuilder: _errorBuilder);
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
