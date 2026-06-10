// ignore_for_file: depend_on_referenced_packages
// Flutter imports:

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Package imports:
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' as dz;
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:core_kosmos/core_kosmos.dart';
import 'package:kosmos_chat/backend/kosmos_chat_backend.dart';
import 'package:kosmos_chat/backend/provider/tchat_user_data.dart';
import 'package:kosmos_chat/frontend/theme/message_box.dart';
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';

Map<String, PlayerController> playerList = {};

// Separate widget for waveform to prevent reloading on parent setState
class WaveformPlayer extends StatefulWidget {
  final PlayerController playerController;
  final bool fromWeb;
  final bool fromMe;
  final bool isFullPlayed;
  final MessageBoxThemeData theme;
  final double width;

  const WaveformPlayer({
    Key? key,
    required this.playerController,
    required this.fromWeb,
    required this.fromMe,
    required this.isFullPlayed,
    required this.theme,
    required this.width,
  }) : super(key: key);

  @override
  State<WaveformPlayer> createState() => _WaveformPlayerState();
}

class _WaveformPlayerState extends State<WaveformPlayer> {
  @override
  Widget build(BuildContext context) {
    return (!widget.fromWeb)
        ? AudioFileWaveforms(
            animationDuration: const Duration(milliseconds: 500),
            playerWaveStyle: PlayerWaveStyle(
              fixedWaveColor: widget.fromMe
                  ? (widget.theme.meAudioBackTrackColor ?? Colors.white)
                  : (widget.theme.otherAudioBackTrackColor ??
                      DefaultColor.darkBlue.withOpacity(.07)),
              liveWaveColor: widget.fromMe
                  ? (widget.theme.meAudioColor ?? Colors.white)
                  : (widget.isFullPlayed)
                      ? (widget.theme.otherAudioFullReadColor ??
                          DefaultColor.darkBlue)
                      : (widget.theme.otherAudioReadColor ??
                          DefaultColor.darkBlue),
            ),
            size: Size(widget.width, formatHeight(20)),
            playerController: widget.playerController,
            waveformType: WaveformType.fitWidth,
          )
        : AudioFileWaveforms(
            // Generate placeholder waveform data for better appearance
            waveformData:
                List.generate(30, (index) => index % 2 == 0 ? 0.01 : 0),
            animationDuration: const Duration(milliseconds: 500),
            playerWaveStyle: PlayerWaveStyle(
              fixedWaveColor: widget.fromMe
                  ? (widget.theme.meAudioBackTrackColor ?? Colors.white)
                  : (widget.theme.otherAudioBackTrackColor ??
                      DefaultColor.darkBlue.withOpacity(.07)),
              liveWaveColor: widget.fromMe
                  ? (widget.theme.meAudioColor ?? Colors.white)
                  : (widget.isFullPlayed)
                      ? (widget.theme.otherAudioFullReadColor ??
                          DefaultColor.darkBlue)
                      : (widget.theme.otherAudioReadColor ??
                          DefaultColor.darkBlue),
            ),
            size: Size(widget.width, formatHeight(20)),
            playerController: widget.playerController,
            waveformType: WaveformType.fitWidth,
          );
  }
}

final audioProvider =
    FutureProvider.family<dz.Tuple2<Duration, PlayerController>, MediaModel>(
        (ref, item) async {
  try {
    PlayerController player = PlayerController();
    final path = await ImageFileController.downloadFileAndSaveLocally(
        Uri.parse(item.mediaUrl!), item.mediaRelativePath!);
    if (path == null) {
      return dz.Tuple2<Duration, PlayerController>(
          const Duration(seconds: 0), player);
    }

    await player.preparePlayer(
      path: path,
      noOfSamples: 30,
    );

    return dz.Tuple2<Duration, PlayerController>(
        Duration(milliseconds: await player.getDuration()), player);
  } catch (e) {
    printExcept(e);
    return dz.Tuple2<Duration, PlayerController>(
        const Duration(seconds: 0), PlayerController());
  }
});

class CustomVoiceTrack extends StatefulHookConsumerWidget {
  final String audioSrc;
  final MessageModel message;
  final TchatModel tchat;

  final MessageBoxThemeData theme;

  const CustomVoiceTrack({
    super.key,
    required this.audioSrc,
    required this.message,
    required this.tchat,
    required this.theme,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CustomVoiceTrackState();
}

class _CustomVoiceTrackState extends ConsumerState<CustomVoiceTrack> {
  late final bool fromMe =
      widget.message.senderId == FirebaseAuth.instance.currentUser!.uid;
  late final SocialUser? sender = ref
      .read(tchatUserListProvider)
      .userList
      .firstWhereOrNull((e) => e.id == widget.message.senderId);

  PlayerState? status;

  bool? isPlaying;
  bool hasWaveformData = false; // Track whether waveform data is available

  late bool isAlreadyPlayer =
      (widget.message.metadata["playedBy"] as List<dynamic>?)
              ?.contains(FirebaseAuth.instance.currentUser!.uid) ??
          false;
  late bool isFullPlayed =
      (widget.message.metadata["fullReadBy"] as List<dynamic>?)
              ?.contains(FirebaseAuth.instance.currentUser!.uid) ??
          false;

  @override
  void initState() {
    super.initState();
    // Set up listeners later when the player is initialized
  }

  @override
  dispose() {
    // player?.stopPlayer();
    // player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(audioProvider(widget.message.media!.first)).when(
      data: (data) {
        if (widget.message.id != null) {
          playerList[widget.message.id!] = data.value2;
        }
        // Check if waveform data is already available

        data.value2.onCompletion.listen((event) async {
          if (isFullPlayed) return;

          execAfterBuild(() {
            isFullPlayed = true;
            if (mounted) {
              setState(() {});
            }
          });
          await FirebaseFirestore.instance
              .collection("tchat")
              .doc(widget.tchat.id!)
              .collection("messages")
              .doc(widget.message.id)
              .update({
            "metadata.fullReadBy":
                FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
          });
        });
        data.value2.onPlayerStateChanged.listen((event) {
          if (isPlaying == false && event == PlayerState.playing) {
            execAfterBuild(() {
              isPlaying = true;
              if (mounted) setState(() {});
            });
          } else if (isPlaying == true) {
            execAfterBuild(() {
              isPlaying = false;
              if (mounted) setState(() {});
            });
          }
        });
        if (data.value1 == const Duration(seconds: 0)) {
          return Text("<<Voice>>",
              style: fromMe
                  ? widget.theme.meMessageTextStyle
                  : widget.theme.otherMessageTextStyle);
        }

        isPlaying = data.value2.playerState == PlayerState.playing;

        return Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (fromMe) ...[
              _buildImageSender(),
              sw(14),
            ],
            _buildPlayer(context, data.value2, data.value1),
            if (!fromMe) ...[
              sw(14),
              _buildImageSender(),
            ],
          ],
        );
      },
      error: (_, __) {
        return Text("<<Voice>>",
            style: fromMe
                ? widget.theme.meMessageTextStyle
                : widget.theme.otherMessageTextStyle);
      },
      loading: () {
        return Text("<<Voice>>",
            style: fromMe
                ? widget.theme.meMessageTextStyle
                : widget.theme.otherMessageTextStyle);
      },
    );
  }

  Widget _buildImageSender() {
    return Container(
      width: formatWidth(44),
      height: formatWidth(44),
      decoration:
          const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: sender!.userProfileImage?.compressedUrl != null ||
              sender!.userProfileImage?.url != null ||
              sender!.profileImage != null
          ? CachedNetworkImage(
              imageUrl: sender!.userProfileImage?.compressedUrl ??
                  sender!.userProfileImage?.url ??
                  sender!.profileImage!,
              fit: BoxFit.cover,
              placeholder: (_, __) {
                return Image.asset(
                  "assets/images/img_user_profil.png",
                  fit: BoxFit.cover,
                );
              },
              errorWidget: (_, __, ___) {
                return Image.asset(
                  "assets/images/img_user_profil.png",
                  fit: BoxFit.cover,
                );
              },
            )
          : Image.asset(
              "assets/images/img_user_profil.png",
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _buildPlayer(
      BuildContext context, PlayerController player, Duration duration) {
    double w = MediaQuery.of(context).size.width * .42 -
        (widget.tchat.isGroup ? formatWidth(28) : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () async {
            if (!isAlreadyPlayer) {
              setState(() {
                isFullPlayed = true;
              });
              FirebaseFirestore.instance
                  .collection("tchat")
                  .doc(widget.tchat.id!)
                  .collection("messages")
                  .doc(widget.message.id)
                  .update({
                "metadata.playedBy": FieldValue.arrayUnion(
                    [FirebaseAuth.instance.currentUser!.uid]),
              });
            }
            if (isPlaying == true) {
              await player.pausePlayer();
              return;
            }
            for (final e in playerList.values) {
              if (e.playerState == PlayerState.playing) {
                await e.pausePlayer();
              }
            }
            player.setFinishMode(finishMode: FinishMode.pause);

            player.startPlayer(forceRefresh: true);
          },
          child: widget.theme.messageAudioControl
                  ?.call(fromMe, isPlaying ?? false) ??
              SvgPicture.asset(
                "assets/svg/ic_${isPlaying == true ? "pause" : "play"}.svg",
                package: "kosmos_chat",
                color: fromMe
                    ? (widget.theme.meAudioColor ?? Colors.white)
                    : (isFullPlayed
                        ? widget.theme.otherAudioColor
                        : isAlreadyPlayer
                            ? widget.theme.otherAudioFullReadColor
                            : widget.theme.otherAudioReadColor),
                width: formatWidth(23),
              ),
        ),
        sw(7.5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sh(11),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                sw(9.5),
                // Use the separate waveform widget with its own lifecycle
                // This prevents reloading on every setState in the parent
                WaveformPlayer(
                  // Use a key with the message ID to ensure stability
                  key: widget.message.id != null
                      ? ValueKey(widget.message.id)
                      : null,
                  playerController: player,
                  fromWeb: widget.message.fromWeb,
                  fromMe: fromMe,
                  isFullPlayed: isFullPlayed,
                  theme: widget.theme,
                  width: w,
                ),
              ],
            ),
            Text(
              "${duration.inMinutes}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}",
              style: fromMe
                  ? widget.theme.meAudioTrackTextStyle
                  : widget.theme.otherAudioTrackTextStyle,
            )
          ],
        ),
      ],
    );
  }
}
