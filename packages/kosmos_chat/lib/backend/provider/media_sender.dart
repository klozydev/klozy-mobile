import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:ui_kosmos_v4/multiImagePicker/model/pickedAssets/multi_picked_asset.dart';
import 'package:dartz/dartz.dart' as dz;

final mediaSenderProvider = ChangeNotifierProvider<MediaSenderProvider>((ref) {
  return MediaSenderProvider();
});

class MediaSenderProvider with ChangeNotifier {
  final List<dz.Either<MultiPickedAsset, Uint8List>> _files = [];
  List<dz.Either<MultiPickedAsset, Uint8List>> get files => _files;

  void addFiles(List<dz.Either<MultiPickedAsset, Uint8List>> files) {
    _files.addAll(files);
    notifyListeners();
  }

  void updateValueWithIndex(
      int index, dz.Either<MultiPickedAsset, Uint8List> value) {
    _files[index] = value;
    notifyListeners();
  }

  void clear([bool notify = true]) {
    _files.clear();
    if (notify) notifyListeners();
  }
}
