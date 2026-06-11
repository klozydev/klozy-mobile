// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:io';

import 'package:core_kosmos/core_kosmos.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart' as dz;
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kosmos_chat/frontend/page/camera_page.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:mime/mime.dart';



abstract class PickImageController {
  static Future<MultiPickedAsset?> getImageFromCamera(BuildContext context) async {
    if (Platform.isAndroid) {
      bool isEnabled = await ImageFileController.permissionIsEnbled(context,
          source: ImageSource.camera, assetType: RequestType.all);
      if (!isEnabled) return null;
      // Use Camerawesome CameraPage on Android without explicit permission handling
      final res = await Navigator.push<Map<String, dynamic>?>(
        context,
        MaterialPageRoute(builder: (_) => const CameraPage()),
      );
      if (res == null) return null;
      try {
        final String path = res['path'] as String;
        final String type = res['type'] as String;

        // Ensure the captured file exists and is fully written (size stable)
        final File f = File(path);
        int tries = 15; // ~1.5s max
        int lastSize = -1;
        while (tries-- > 0) {
          if (await f.exists()) {
            final sz = await f.length();
            if (sz > 0 && sz == lastSize) break;
            lastSize = sz;
          }
          await Future.delayed(const Duration(milliseconds: 100));
        }
        if (type == 'image') {
          final String title = path.split('/').last;
          AssetEntity asset =  await PhotoManager.editor
              .saveImageWithPath(path, title: title);
          return MultiPickedAsset(file: File(path), type: PickedAssetType.image, thumbnail: null);
        } else {
          final String title = path.split('/').last;
          AssetEntity asset = await PhotoManager.editor.saveVideo(File(path), title: title);
          return MultiPickedAsset(file: File(path), type: PickedAssetType.video, thumbnail: await  asset.thumbnailData);
        }
      } catch (e) {
        printExcept(e);
        return null;
      }
    } else {
      // Keep WeChat camera on non-Android platforms
      PermissionStatus ps = await Permission.camera.status;
      if (ps.isDenied) {
        ps = await Permission.camera.request();
        return null;
      }
      if (ps.isGranted) {
        final AssetEntity? entity = await CameraPicker.pickFromCamera(
          context,
          pickerConfig: const CameraPickerConfig(
            enableRecording: true,
            enableAudio: true,
            maximumRecordingDuration: Duration(seconds: 120),
            textDelegate: KosmosCameraDelegate(),
          ),
        );
        if(entity==null) return null;
        return MultiPickedAsset(
          mimeType: entity.mimeType,
          mediaWidth: entity.width.toDouble(),
          mediaHeight: entity.height.toDouble(),
          
          type: entity.type==AssetType.image? PickedAssetType.image : PickedAssetType.video, file:await  entity.file, thumbnail: await entity.thumbnailData);
      } else if (ps.isPermanentlyDenied) {
        final tmp = await showCupertinoDialog<bool?>(
          context: context,
          builder: (BuildContext ctx) {
            return CupertinoAlertDialog(
              title: Text('package.permission.camera.title'.tr()),
              content:
                  Text("package.permission.camera.redirect-to-settings".tr()),
              actions: [
                TextButton(
                  child: Text(
                    'package.permission.skip'.tr(),
                    style: const TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop(false);
                  },
                ),
                TextButton(
                  child: Text(
                    'package.permission.camera.button'.tr(),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () async {
                    Navigator.of(ctx).pop(true);
                  },
                ),
              ],
            );
          },
        );
        if (tmp == false) return null;
        await openAppSettings();
        return null;
      }
      return null;
    }
  }

  static Future<List<MultiPickedAsset>?> getImageFromGalery(BuildContext context,
      [int? maxAssets = 1]) async {
    if (Platform.isAndroid) {
      
      List<XFile> pickedImages = await
      ImageFileController.pickMultipleMediaFromGalleryAndroid(context,
          limit: maxAssets ?? 10);

       List<MultiPickedAsset> newMedias = [];
      for (var asset in pickedImages) {
        File? file = File(asset.path);

        Uint8List? thumbnailData;
        bool? isFileImage = _isImage(asset);
        if (isFileImage == null) return [];

        if (!isFileImage) {
          // May be null (the video_thumbnail plugin was dropped during the
          // port); MultiPickedAsset.thumbnail is nullable.
          thumbnailData = await _getVideoThumbnail(asset);
        }

        MultiPickedAsset newMedia = MultiPickedAsset(
            file: file,
            type: isFileImage ? PickedAssetType.image : PickedAssetType.video,
            
            thumbnail: thumbnailData);

        newMedias.add(newMedia);
      }
     

      return newMedias;
    }
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      final List<AssetEntity>? pickedImage = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(maxAssets: maxAssets ?? 99),
      );

      List<MultiPickedAsset> newMedias = [];
        for (AssetEntity asset in (pickedImage??[])) {
          File? file = await asset.file;
          if (file == null) continue;

          Uint8List? thumbnailData;

          if (asset.type == AssetType.video) {
            thumbnailData = (await asset.thumbnailData)!;
          }

          MultiPickedAsset newMedia = MultiPickedAsset(
              file: file,
              type: asset.type == AssetType.image
                  ? PickedAssetType.image
                  : PickedAssetType.video,
              thumbnail: thumbnailData,
              mimeType: asset.mimeType,
              mediaWidth: asset.width.toDouble(),
              mediaHeight: asset.height.toDouble());

          newMedias.add(newMedia);
        }
        return newMedias;
    } else {
      final tmp = await showCupertinoDialog<bool?>(
        context: context,
        builder: (BuildContext ctx) {
          return CupertinoAlertDialog(
            title: Text('package.permission.photos.title'.tr()),
            content:
                Text("package.permission.photos.redirect-to-settings".tr()),
            actions: [
              TextButton(
                child: Text(
                  'package.permission.skip'.tr(),
                  style: const TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
              ),
              TextButton(
                child: Text(
                  'package.permission.photos.button'.tr(),
                  textAlign: TextAlign.center,
                ),
                onPressed: () async {
                  Navigator.of(ctx).pop(true);
                },
              ),
            ],
          );
        },
      );
      if (tmp == false) return null;
      await PhotoManager.openSetting();
      return null;
    }
  }

  /// Deprecated
  static Future<List<AssetEntity>?> getImageFromGallery() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      final List<AssetPathEntity> paths =
          await PhotoManager.getAssetPathList(type: RequestType.common);
      List<AssetEntity> assets = [];

      for (final AssetPathEntity path in paths) {
        assets.addAll(await path.getAssetListPaged(page: 0, size: 1000));
      }

      return assets;
    } else {
      await PhotoManager.openSetting();
      return null;
    }
  }

  static Future<List<AssetEntity>?> pickImageFromGallery(
      BuildContext context) async {
    final assets = await getImageFromGallery();

    if (assets?.isEmpty ?? true) return null;

    final List<AssetEntity> pickedAssets = [];
    String activeCategory = "images";

    final List<dz.Tuple2<AssetEntity, Future<Uint8List?>>> imagesAssets =
        assets!
            .where((element) => element.type == AssetType.image)
            .map((e) => dz.Tuple2(e, e.thumbnailData))
            .toList();
    final List<dz.Tuple2<AssetEntity, Future<Uint8List?>>> videoAssets = assets
        .where((element) => element.type == AssetType.video)
        .map((e) => dz.Tuple2(e, e.thumbnailData))
        .toList();

    final r = await showModalBottomSheet<List<AssetEntity>>(
      context: context,
      isScrollControlled: true,
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .8),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(35), topRight: Radius.circular(35))),
      builder: (_) {
        return StatefulBuilder(
          builder: (newContext, newState) {
            return SizedBox.expand(
              child: DraggableScrollableSheet(
                initialChildSize: 1,
                minChildSize: .99,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: formatWidth(29)),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              sh(13.5),
                              Container(
                                width: formatWidth(37),
                                height: formatHeight(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              sh(29.5),
                              const Divider(),
                              sh(20),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  sw(2),
                                  InkWell(
                                    onTap: () => newState(
                                        () => activeCategory = "images"),
                                    child: Text("package.tchat.image".tr(),
                                        style: activeCategory == "images"
                                            ? DefaultAppStyle.darkBlue(
                                                16, FontWeight.w500)
                                            : DefaultAppStyle.darkGrey(
                                                16, FontWeight.w500)),
                                  ),
                                  const Spacer(),
                                  InkWell(
                                    onTap: () => newState(
                                        () => activeCategory = "videos"),
                                    child: Text("package.tchat.video".tr(),
                                        style: activeCategory == "videos"
                                            ? DefaultAppStyle.darkBlue(
                                                16, FontWeight.w500)
                                            : DefaultAppStyle.darkGrey(
                                                16, FontWeight.w500)),
                                  ),
                                  const Spacer(),
                                  Text("utils.select".tr(),
                                      style: DefaultAppStyle.darkBlue(16)),
                                  sw(5),
                                ],
                              ),
                              sh(15),
                              Expanded(
                                child: GridView.builder(
                                  controller: scrollController,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: activeCategory == "images"
                                      ? imagesAssets.length
                                      : videoAssets.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: formatWidth(21),
                                          mainAxisSpacing: formatWidth(21)),
                                  itemBuilder: (context, index) {
                                    final item = activeCategory == "images"
                                        ? imagesAssets[index]
                                        : videoAssets[index];
//                                  padding: (item == assets.last) ? EdgeInsets.only(bottom: formatHeight(120)) : EdgeInsets.zero,
                                    final indexifSelected =
                                        pickedAssets.indexWhere((element) =>
                                            element.id == item.value1.id);

                                    return GestureDetector(
                                      onTap: () {
                                        if (pickedAssets
                                            .contains(item.value1)) {
                                          pickedAssets.remove(item.value1);
                                        } else {
                                          pickedAssets.add(item.value1);
                                        }
                                        newState(() {});
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: pickedAssets
                                                    .contains(item.value1)
                                                ? DefaultColor.darkBlue
                                                : Colors.transparent,
                                            width: 4,
                                          ),
                                        ),
                                        child: Stack(
                                          clipBehavior: Clip.antiAlias,
                                          children: [
                                            Positioned.fill(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: FutureBuilder(
                                                  future: item.value2,
                                                  builder: (context, snapshot) {
                                                    return snapshot.hasData
                                                        ? Image.memory(
                                                            snapshot.data
                                                                as Uint8List,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Container();
                                                  },
                                                ),
                                              ),
                                            ),
                                            if (item.value1.type ==
                                                AssetType.video)
                                              Positioned.fill(
                                                child: Center(
                                                  child: Icon(
                                                    Icons.play_arrow_rounded,
                                                    color: Colors.white,
                                                    size: formatHeight(35),
                                                  ),
                                                ),
                                              ),
                                            if (indexifSelected != -1) ...[
                                              Positioned(
                                                top: formatWidth(9),
                                                right: formatWidth(9),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                          formatWidth(5),
                                                      vertical: formatWidth(2)),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                    color: Colors.white,
                                                  ),
                                                  child: Text(
                                                      indexifSelected
                                                          .toString(),
                                                      style: DefaultAppStyle
                                                          .darkBlue(9)),
                                                ),
                                              )
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: formatHeight(100) +
                              MediaQuery.of(context).padding.bottom,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0)
                              ],
                              stops: const [0, 1],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );

    return r;
  }

   static  bool? _isImage(XFile xfile) {
    final mimeType = lookupMimeType(xfile.path);

    if (mimeType != null && mimeType.startsWith('image/')) {
      return true;
    } else if (mimeType != null && mimeType.startsWith('video/')) {
      return false;
    } else {
      final extensionFile = _getExtension(xfile.path);
      if (["png", "jpg", "jpeg", "gif", "webp", "heic"]
          .contains(extensionFile)) {
        return true;
      } else if ([
        "mp4",
        "mov",
        "avi",
        "mkv",
        "wmv",
        "flv",
        "mpg",
        "mpeg",
        "m4v",
        "3gp",
        "3g2",
        "webm"
      ].contains(extensionFile)) {
        return false;
      } else {
        return null;
      }
    }
  }

  static String _getExtension(String filePath) {
    // No leading dot — callers compare against bare extensions ("png", "mp4").
    return filePath.split('.').last.toLowerCase();
  }

 static  Future<Uint8List?> _getVideoThumbnail(XFile videoFile) async {
    try {
      // Video poster thumbnail generation removed (video_thumbnail plugin
      // dropped — abandoned, pinned dead JCenter). Videos still send without a
      // generated poster frame.
      final Uint8List? bytes = null;

      if (bytes == null) {
        return null;
      }

      return bytes;
    } catch (e) {
      return null;
    }
  }
}
