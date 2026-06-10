import 'dart:convert';

import 'package:core_kosmos/core_kosmos.dart';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:dartz/dartz.dart' as dz;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:photo_manager/photo_manager.dart';
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';
import 'package:uuid/uuid.dart';

Future<Map<String, dynamic>?> uploadListOfAssetsAndBytesToFirebase(
    String tchatId,
    List<dz.Tuple2<String, dz.Either<MultiPickedAsset, Uint8List>>> assets) async {
  final uploadPath = "tchat/$tchatId/media";
  final List<Map<String, dynamic>> urls = [];
  try {
    for (final item in assets) {
      final fUuid = const Uuid().v1();
      final tUuid = const Uuid().v1();
      if (item.value2.isLeft()) {
        MultiPickedAsset asset = await item.value2.fold((l) => l, (r) => null)!;
        final file =  asset.file;
        if (file == null) continue;
        final url =
            await ImageFileController.uploadStandartFileToFirebaseStorage(
                file, '$uploadPath/$fUuid.${file.path.split(".").last}');
        String? urlThumb;
        Uint8List? thumbData;
        if (asset.type == PickedAssetType.video &&
            (thumbData =  asset.thumbnail) != null) {
          final tempDir = await getTemporaryDirectory();
          File file =
              await File('${tempDir.path}/thumbnail_$tUuid.png').create();
          file.writeAsBytesSync(thumbData!);

          urlThumb =
              await ImageFileController.uploadStandartFileToFirebaseStorage(
                  file, '$uploadPath/thumbnail_$tUuid');
        }
        urls.add({
          "idInMessage": item.value1,
          "videoThumbnail": urlThumb,
          "url": url,
        });
      } else if (item.value2.isRight()) {
        final Uint8List data = await item.value2.fold((l) => null, (r) => r)!;
        final tempDir = await getTemporaryDirectory();
        File file = await File('${tempDir.path}/thumbnail_$tUuid.png').create();
        file.writeAsBytesSync(data);

        final url =
            await ImageFileController.uploadStandartFileToFirebaseStorage(
                file, '$uploadPath/$fUuid.png');
        urls.add({
          "idInMessage": item.value1,
          "videoThumbnail": null,
          "url": url,
        });
      }
    }
    final Map<String, dynamic> rep = {
      "tchatId": tchatId,
      "data": urls,
    };
    return rep;
  } catch (e) {
    printExcept(e.toString());
    return null;
  }
}

@pragma('vm:entry-point')
Future<String?> uploadListOfAssetFileToFirebase(String encodedJson) async {
  try {
    final Map<String, dynamic> json = jsonDecode(encodedJson);
    final tchatId = json["tchatId"] as String;
    final List<dz.Tuple2<String, AssetEntity>> assets = [];

    for (final item in json["assets"] ?? []) {
      final asset = await AssetEntity.fromId(item["assetId"]);
      if (asset == null) continue;
      assets.add(dz.Tuple2(item["idInMessage"] as String, asset));
    }

    final List<Map<String, dynamic>> urls = [];

    final uploadPath = "tchat/$tchatId/media";

    for (final item in assets) {
      final fUuid = const Uuid().v1();
      final tUuid = const Uuid().v1();
      final file = await item.value2.file;
      if (file == null) continue;
      final url = await ImageFileController.uploadStandartFileToFirebaseStorage(
          file, '$uploadPath/$fUuid.${file.path.split(".").last}');
      String? urlThumb;
      Uint8List? thumbData;
      if (item.value2.type == AssetType.video &&
          (thumbData = await item.value2.thumbnailData) != null) {
        final tempDir = await getTemporaryDirectory();
        File file = await File('${tempDir.path}/thumbnail_$tUuid.png').create();
        file.writeAsBytesSync(thumbData!);

        urlThumb =
            await ImageFileController.uploadStandartFileToFirebaseStorage(
                file, '$uploadPath/thumbnail_$tUuid');
      }
      urls.add({
        "idInMessage": item.value1,
        "videoThumbnail": urlThumb,
        "url": url,
      });
    }

    final Map<String, dynamic> rep = {
      "tchatId": tchatId,
      "data": urls,
    };

    return jsonEncode(rep);
  } catch (e) {
    printExcept(e.toString());
    return null;
  }
}
