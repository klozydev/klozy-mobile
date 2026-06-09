import 'package:flutter/material.dart';
import 'package:klozy/src/design/components/ds_dashed_circle_painter.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';

/// 96px circular avatar picker — dashed placeholder when empty, image when set,
/// with a gold camera badge. Mirrors the prototype `AvatarUploader`.
class DSAvatarUploader extends StatelessWidget {
  final ImageProvider? image;
  final VoidCallback onTap;
  final double size;

  const DSAvatarUploader({
    super.key,
    required this.onTap,
    this.image,
    this.size = 96,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            if (image != null)
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: image!, fit: BoxFit.cover),
                ),
              )
            else
              CustomPaint(
                painter: const DSDashedCirclePainter(
                  color: DSColor.onSurface24,
                ),
                child: Container(
                  width: size,
                  height: size,
                  decoration: const BoxDecoration(
                    color: DSColor.card,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 40,
                    color: DSColor.onSurface35,
                  ),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: DSColor.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: DSColor.surface, width: 2.5),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 15,
                  color: DSColor.surface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
