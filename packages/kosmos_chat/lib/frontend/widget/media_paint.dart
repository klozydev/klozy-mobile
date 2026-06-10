// ignore_for_file: overridden_fields, use_full_hex_values_for_flutter_colors

import 'dart:io';
import 'dart:typed_data';

import 'package:core_kosmos/core_kosmos.dart';
import 'package:flutter/material.dart';
import 'package:image_painter/image_painter.dart';
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';

class MediaPaint extends ConsumerStatefulWidget {
  final File? file;
  final Uint8List? memoryImage;

  final int indexFile;
  const MediaPaint(
      {super.key, this.file, this.memoryImage, required this.indexFile});

  @override
  ConsumerState<MediaPaint> createState() => _MediaPaintState();
}

class _MediaPaintState extends ConsumerState<MediaPaint> {
  final _imageKey = GlobalKey<ImagePainterState>();
  bool _isLoading = false;

  void saveImage() async {
    setState(() {
      _isLoading = true;
    });
    final image = await _imageKey.currentState?.exportImage();
    setState(() {
      _isLoading = false;
    });
    if (image != null && mounted) {
      Navigator.pop(context, image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black, actions: [
            TextButton(
              onPressed: saveImage,
              child: Text(
                'utils.confirm'.tr(),
                style: const TextStyle(color: Colors.white),
              ),
            )
          ]),
          body: widget.file != null
              ? SafeArea(
                  child: ImagePainter.file(
                    widget.file!,
                    controlsAtTop: false,
                    initialPaintMode: PaintMode.freeStyle,
                    showControls: true,
                    key: _imageKey,
                    scalable: true,
                    textDelegate: CustomTextDelegate(),
                    initialStrokeWidth: 10,
                    controlsBackgroundColor: Colors.black,
                    initialColor: const Color(0XFF11122CC),
                  ),
                )
              : widget.memoryImage != null
                  ? SafeArea(
                      child: ImagePainter.memory(
                        widget.memoryImage!,
                        controlsAtTop: false,
                        initialPaintMode: PaintMode.freeStyle,
                        showControls: true,
                        key: _imageKey,
                        scalable: true,
                        textDelegate: CustomTextDelegate(),
                        initialStrokeWidth: 10,
                        controlsBackgroundColor: Colors.black,
                        initialColor: const Color(0XFF11122CC),
                      ),
                    )
                  : const Center(child: LoaderClassique()),
        ),
        if (_isLoading)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: LoaderClassique(),
            ),
          )
      ],
    );
  }
}

class CustomTextDelegate extends TextDelegate {
  @override
  final String noneZoom = "utils.none-zoom".tr();
  @override
  final String line = "utils.line".tr();
  @override
  final String rectangle = "utils.rectangle".tr();
  @override
  final String drawing = "utils.drawing".tr();
  @override
  final String circle = "utils.circle".tr();
  @override
  final String arrow = "utils.arrow".tr();
  @override
  final String dashLine = "utils.dash-line".tr();
  @override
  final String text = "utils.text".tr();
  @override
  final String changeMode = "utils.change-mode".tr();
  @override
  final String changeColor = "utils.change-color".tr();
  @override
  final String changeBrushSize = "utils.change-brush-size".tr();
  @override
  final String undo = "utils.undo".tr();
  @override
  final String done = "utils.done".tr();
  @override
  final String clearAllProgress = "utils.clear-all-progress".tr();
}
