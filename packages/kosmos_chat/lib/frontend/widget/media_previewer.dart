import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_kosmos/core_kosmos.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kosmos_chat/backend/provider/media_sender.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';
import 'package:dartz/dartz.dart' as dz;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class MediaPreviewerTchatPage extends StatefulHookConsumerWidget {
  // final AssetEntity? asset;

  /// Theme
  final String? buttonThemeName;

  const MediaPreviewerTchatPage({
    super.key,

    /// Theme
    this.buttonThemeName,
    // this.theme,
  });

  @override
  ConsumerState<MediaPreviewerTchatPage> createState() =>
      _MediaPreviewerTchatPageState();
}

class _MediaPreviewerTchatPageState
    extends ConsumerState<MediaPreviewerTchatPage> {
  final PageController _pageController = PageController();
  late final bool isSingleMedia =
      (ref.read(mediaSenderProvider).files.length == 1);
  final ScrollController _controller = ScrollController();
  late final List<dz.Either<MultiPickedAsset, Uint8List>> assets =
      ref.read(mediaSenderProvider).files;

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final KosmosButtonThemeData? themeData = loadThemeData(
      null,
      widget.buttonThemeName ?? "image_previewer_back",
      () => KosmosButtonThemeData(
          iconColor: Colors.white,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(.65),
          )),
      isDark: ref.watch(isDarkModeProvider).isDarkMode,       );
    printWarning("Single Media: ${ref.read(mediaSenderProvider).files.length}");

    if (!isSingleMedia) {
      return _listOfMedia(context);
    }

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                children: [
                  ...(assets).map((e) => _buildViewer(assetEntity: e))
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + formatWidth(4),
              left: formatWidth(15),
              child: ButtonBack(
                theme: themeData,
                size: formatWidth(30),
                padding: pwh(15, 6),
                onTap: () => AutoRouter.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewer(
      {dz.Either<MultiPickedAsset, Uint8List>? assetEntity, MediaModel? media}) {
    Widget child = const SizedBox.shrink();

    if (assetEntity != null) {
      if (assetEntity.isLeft()) {
        MultiPickedAsset asset = assetEntity.fold((l) => l, (r) => null)!;
        if (asset.type == PickedAssetType.image) {
          child = PhotoView(
            imageProvider: FileImage(asset.file!),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            initialScale: PhotoViewComputedScale.contained,
            loadingBuilder: (_, __) =>
                const Center(child: LoaderClassique(activeColor: Colors.white)),
          );
        } else if (asset.type == PickedAssetType.video) {
          child = VideoApp(file: asset.file);
        }
      } else if (assetEntity.isRight()) {
        Uint8List data = assetEntity.fold((l) => null, (r) => r)!;
        child = PhotoView(
          imageProvider: MemoryImage(data),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          initialScale: PhotoViewComputedScale.contained,
          loadingBuilder: (_, __) =>
              const Center(child: LoaderClassique(activeColor: Colors.white)),
        );
      }
    } else {
      if (media!.mediaType == AssetType.video) {
        child = VideoApp(url: media.mediaUrl!);
      } else if (media.mediaType == AssetType.image) {
        child = PhotoView(
          imageProvider: CachedNetworkImageProvider(media.mediaUrl!),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          initialScale: PhotoViewComputedScale.contained,
          loadingBuilder: (_, __) =>
              const Center(child: LoaderClassique(activeColor: Colors.white)),
        );
      }
    }

    return Container(
      child: child,
    );
  }

  Widget _listOfMedia(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(.85),
          leading: InkWell(
            onTap: () => AutoRouter.of(context).pop(),
            child: SizedBox(
              width: formatWidth(38),
              height: formatHeight(38),
              child: Icon(Icons.arrow_back_ios,
                  color: Theme.of(context).primaryColor),
            ),
          ),
        ),
        body: Scrollbar(
          controller: _controller,
          child: ListView(
            controller: _controller,
            physics: const BouncingScrollPhysics(),
            children: [
              ...(assets)
                  .map((e) => Padding(
                        padding: EdgeInsets.only(bottom: formatHeight(8)),
                        child: InkWell(
                          onTap: () {
                            // AutoRouter.of(context)
                            //     .pushWidget(MediaPreviewerPage(assets: assets));
                          },
                          child: _buildPreview(context, e),
                        ),
                      ))
                  .toList()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context, Object e) {
    if (e is AssetEntity) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: formatHeight(200),
        child: Stack(
          children: [
            Positioned.fill(
              child: FutureBuilder(
                future: e.file,
                builder: (context, snap) {
                  if (snap.data != null) {
                    return Image.file(snap.data as File, fit: BoxFit.cover);
                  }
                  return const Center(
                      child: LoaderClassique(activeColor: Colors.white));
                },
              ),
            ),
            if (e.type == AssetType.video) ...[
              Center(
                  child: Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: formatWidth(42))),
            ],
          ],
        ),
      );
    } else {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: formatHeight(200),
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: (e as MediaModel).mediaUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(
                    child: LoaderClassique(activeColor: Colors.white)),
              ),
            ),
            if ((e).mediaType == AssetType.video) ...[
              Center(
                  child: Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: formatWidth(42))),
            ],
          ],
        ),
      );
    }
  }
}
