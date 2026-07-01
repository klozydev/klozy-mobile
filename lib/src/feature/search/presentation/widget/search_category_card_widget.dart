import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';

/// Browse tile for a root category on the Search page. Renders the admin-set
/// [CatalogCategory.imageUrl] when present, with a bottom scrim so the label
/// stays legible. Falls back to [gradient] when no image is set, or while the
/// image loads or fails.
class SearchCategoryCardWidget extends StatelessWidget {
  const SearchCategoryCardWidget({
    required this.category,
    required this.gradient,
    required this.onTap,
    super.key,
  });

  final CatalogCategory category;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = category.imageUrl;
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(DSBorderRadius.image),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                ),
              ),
              if (hasImage)
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  // Keep the gradient visible while loading / on failure.
                  placeholder: (BuildContext context, String url) =>
                      const SizedBox.shrink(),
                  errorWidget:
                      (BuildContext context, String url, Object error) =>
                          const SizedBox.shrink(),
                ),
              if (hasImage)
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[Colors.transparent, Colors.black54],
                    ),
                  ),
                ),
              Center(
                child: Text(
                  category.label,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodyLarge,
                    fontWeight: DSFontWeight.bold,
                    color: Colors.white,
                    shadows: <Shadow>[
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 6,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
