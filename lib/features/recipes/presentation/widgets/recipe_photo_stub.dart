import 'package:flutter/material.dart';

Widget buildRecipePhoto(String path, {required BoxFit fit}) {
  return _PhotoFallback(path: path);
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
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
}
