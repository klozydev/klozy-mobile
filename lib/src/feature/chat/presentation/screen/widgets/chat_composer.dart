import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_outgoing_media.dart';
import 'package:klozy/src/feature/chat/domain/entity/media_type.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/composer_bar.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/recording_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Owns the text controller and the voice recorder (a platform API kept in the
/// widget layer, per project rules). Swaps between the idle composer and the
/// recording bar, and reports results to the page via callbacks.
class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.onAttach,
    required this.onSendText,
    required this.onSendAudio,
  });

  final VoidCallback onAttach;
  final ValueChanged<String> onSendText;
  final ValueChanged<ChatOutgoingMedia> onSendAudio;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final TextEditingController _controller = TextEditingController();
  final AudioRecorder _recorder = AudioRecorder();

  bool _recording = false;
  int _elapsed = 0;
  Timer? _timer;
  String? _path;

  Future<void> _startRecording() async {
    if (!await _recorder.hasPermission()) return;
    final Directory dir = await getTemporaryDirectory();
    final String path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(), path: path);
    _path = path;
    setState(() {
      _recording = true;
      _elapsed = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += 1);
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final int seconds = _elapsed;
    final String? path = await _recorder.stop();
    if (mounted) setState(() => _recording = false);
    final String? finalPath = path ?? _path;
    if (finalPath == null) return;
    final File file = File(finalPath);
    if (!file.existsSync()) return;
    widget.onSendAudio(
      ChatOutgoingMedia(
        file: file,
        type: MediaType.audio,
        name: 'Voice message',
        durationMs: seconds * 1000,
      ),
    );
  }

  Future<void> _cancelRecording() async {
    _timer?.cancel();
    final String? path = await _recorder.stop();
    if (mounted) setState(() => _recording = false);
    final String? finalPath = path ?? _path;
    if (finalPath != null) {
      final File f = File(finalPath);
      if (f.existsSync()) {
        try {
          await f.delete();
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    _controller.dispose();
    super.dispose();
  }

  String get _elapsedLabel {
    final int m = _elapsed ~/ 60;
    final int s = _elapsed % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_recording) {
      return RecordingBar(
        elapsed: _elapsedLabel,
        onCancel: _cancelRecording,
        onStop: _stopRecording,
      );
    }
    return ComposerBar(
      controller: _controller,
      onAttach: widget.onAttach,
      onSendText: widget.onSendText,
      onStartRecording: _startRecording,
    );
  }
}
