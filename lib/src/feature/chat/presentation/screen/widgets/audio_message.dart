import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/audio_waveform.dart';

/// A voice-note bubble with a play/pause control, a progress waveform, and a
/// duration label. Playback is driven by [just_audio]; the source URL is set
/// lazily on first play and the player is disposed with the widget.
class AudioMessage extends StatefulWidget {
  const AudioMessage({super.key, required this.message});

  final ChatMessage message;

  @override
  State<AudioMessage> createState() => _AudioMessageState();
}

class _AudioMessageState extends State<AudioMessage> {
  final AudioPlayer _player = AudioPlayer();

  double _progress = 0;
  bool _playing = false;
  bool _sourceLoaded = false;
  Duration _total = Duration.zero;

  @override
  void initState() {
    super.initState();
    _total = Duration(milliseconds: widget.message.firstMedia?.durationMs ?? 0);

    _player.positionStream.listen((Duration position) {
      if (!mounted) return;
      final Duration duration = _player.duration ?? _total;
      final double fraction = duration.inMilliseconds == 0
          ? 0
          : position.inMilliseconds / duration.inMilliseconds;
      setState(() => _progress = fraction.clamp(0.0, 1.0));
    });

    _player.durationStream.listen((Duration? duration) {
      if (!mounted || duration == null) return;
      setState(() => _total = duration);
    });

    _player.playerStateStream.listen((PlayerState state) {
      if (!mounted) return;
      if (state.processingState == ProcessingState.completed) {
        _player.pause();
        _player.seek(Duration.zero);
        setState(() {
          _playing = false;
          _progress = 0;
        });
        return;
      }
      setState(() => _playing = state.playing);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final String? url = widget.message.firstMedia?.url;
    final String? localPath = widget.message.firstMedia?.localPath;
    if (url == null && localPath == null) return;

    try {
      if (!_sourceLoaded) {
        if (url != null) {
          await _player.setUrl(url);
        } else {
          await _player.setFilePath(localPath!);
        }
        if (!mounted) return;
        _sourceLoaded = true;
      }
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _playing = false);
    }
  }

  String _formatDuration() {
    final int totalMs = _total.inMilliseconds == 0
        ? (widget.message.firstMedia?.durationMs ?? 0)
        : _total.inMilliseconds;
    final int totalSeconds = (totalMs / 1000).round();
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bool mine = widget.message.isMine;
    final Color foreground = mine ? Colors.black : Colors.white;

    return Container(
      constraints: const BoxConstraints(minWidth: 158),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: mine ? DSColor.primary : DSColor.card,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(mine ? 18 : 5),
          bottomRight: Radius.circular(mine ? 5 : 18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: mine
                    ? Colors.black.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.10),
              ),
              child: Icon(
                _playing ? Icons.pause : Icons.play_arrow,
                size: 18,
                color: foreground,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AudioWaveform(
              barCount: 22,
              progress: _progress,
              barColor: mine
                  ? Colors.black.withValues(alpha: 0.32)
                  : Colors.white.withValues(alpha: 0.35),
              accent: mine ? Colors.black : DSColor.primary,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatDuration(),
            style: TextStyle(
              fontFamily: dsFontFamily,
              fontSize: 11,
              fontWeight: DSFontWeight.semiBold,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              color: foreground.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
