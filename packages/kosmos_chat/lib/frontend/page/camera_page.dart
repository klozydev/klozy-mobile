import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool _popped = false;
  String? _lastCapturePath;
  String? _lastCaptureType; // 'image' or 'video'
  bool _checkingPerms = true;

  @override
  void initState() {
    super.initState();
    _ensurePermissions();
  }

  Future<void> _ensurePermissions() async {
    try {
      // Camera is mandatory
      final cam = await Permission.camera.request();
      if (!cam.isGranted) {
        if (mounted) Navigator.of(context).pop();
        return;
      }

      // Microphone optional; request but don't block
      await Permission.microphone.request();
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      return;
    } finally {
      if (mounted) setState(() => _checkingPerms = false);
    }
  }

  Future<String> _buildImagePath() async {
    final dir = await getTemporaryDirectory();
    final sub = Directory('${dir.path}/camerawesome');
    if (!await sub.exists()) {
      await sub.create(recursive: true);
    }
    return '${sub.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  Future<String> _buildVideoPath() async {
    final dir = await getTemporaryDirectory();
    final sub = Directory('${dir.path}/camerawesome');
    if (!await sub.exists()) {
      await sub.create(recursive: true);
    }
    return '${sub.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
  }

  void _popWithResult(Map<String, dynamic> result) {
    if (_popped) return;
    _popped = true;
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingPerms) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: CameraAwesomeBuilder.awesome(
        saveConfig: SaveConfig.photoAndVideo(
          initialCaptureMode: CaptureMode.photo,
          mirrorFrontCamera: true,
          photoPathBuilder: (sensors) async {
            final path = await _buildImagePath();
            _lastCapturePath = path;
            _lastCaptureType = 'image';
            return SingleCaptureRequest(path, sensors.first);
          },
          videoPathBuilder: (sensors) async {
            final path = await _buildVideoPath();
            _lastCapturePath = path;
            _lastCaptureType = 'video';
            return SingleCaptureRequest(path, sensors.first);
          },
        ),
        enablePhysicalButton: true,
        previewFit: CameraPreviewFit.fitWidth,
        sensorConfig: SensorConfig.single(
          aspectRatio: CameraAspectRatios.ratio_16_9,
          sensor: Sensor.position(SensorPosition.back),
          flashMode: FlashMode.auto,
          zoom: 0.0,
        ),
        onMediaCaptureEvent: (event) async {
          if (event.status == MediaCaptureStatus.success) {
            // Give encoder/preview time to release texture cleanly
            await Future.delayed(const Duration(milliseconds: 500));
            if (_lastCapturePath != null && _lastCaptureType != null) {
              _popWithResult({
                'path': _lastCapturePath!,
                'type': _lastCaptureType!,
              });
            }
          } else if (event.status == MediaCaptureStatus.failure) {
            if (mounted) Navigator.of(context).pop();
          }
        },
        progressIndicator: const Center(
          child: SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
