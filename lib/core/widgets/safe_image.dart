import 'package:flutter/cupertino.dart';

class SafeAssetImage extends StatelessWidget {
  const SafeAssetImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 12,
  });

  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) {
          return Container(
            width: width,
            height: height,
            color: CupertinoColors.systemGrey5,
            alignment: Alignment.center,
            child: const Icon(CupertinoIcons.photo, color: CupertinoColors.systemGrey),
          );
        },
      ),
    );
  }
}
