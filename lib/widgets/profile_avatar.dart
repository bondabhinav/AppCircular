import 'package:cached_network_image/cached_network_image.dart';
import 'package:flexischool/utils/image_url.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final Color iconColor;

  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.radius,
    this.iconColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final fallback = _FallbackProfileAvatar(
      radius: radius,
      iconColor: iconColor,
    );

    if (!hasUsableImageValue(imageUrl)) {
      return fallback;
    }

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, _) => fallback,
          errorWidget: (_, _, _) => fallback,
        ),
      ),
    );
  }
}

class _FallbackProfileAvatar extends StatelessWidget {
  final double radius;
  final Color iconColor;

  const _FallbackProfileAvatar({required this.radius, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      child: Icon(Icons.account_circle, color: iconColor, size: radius * 2),
    );
  }
}
