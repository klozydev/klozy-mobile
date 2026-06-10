// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use, use_build_context_synchronously, depend_on_referenced_packages

import 'dart:io';

import 'package:core_kosmos/core_kosmos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kosmos_chat/backend/kosmos_chat_backend.dart';
import 'package:kosmos_chat/backend/provider/media_sender.dart';
import 'package:kosmos_chat/backend/provider/message_list.dart';
import 'package:kosmos_chat/frontend/utils/pick_image.dart';
import 'package:kosmos_chat/frontend/widget/media_paint.dart';
import 'package:photo_view/photo_view.dart';

import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';
import 'package:dartz/dartz.dart' as dz;
import 'package:iconsax/iconsax.dart';

class MediaPreviewerSpecialPage extends StatefulHookConsumerWidget {
  final String tchatId;

  const MediaPreviewerSpecialPage({
    super.key,
    @PathParam("tchatId") required this.tchatId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MediaPreviewerStateWidget();
}

class _MediaPreviewerStateWidget
    extends ConsumerState<MediaPreviewerSpecialPage> {
  late final PageController _pageController = PageController();
  int page = 0;
  String? _commentary;
  late final Size size = MediaQuery.of(context).size;
   Orientation ? orientation;

  @override
  void initState() {
    _pageController.addListener(() {
      if (!_pageController.hasClients) return;
      setState(() {
        page = _pageController.page?.round() ?? 0;
      });
    });
    execAfterBuild(() {
    orientation = MediaQuery.of(context).orientation;
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    if (orientation == null || orientation == Orientation.portrait) {
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    } else {
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = ref.watch(mediaSenderProvider).files;

    return Container(
      width: size.width,
      height: size.width,
      color: Colors.black,
      child: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              width: size.width,
              height: size.height,
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                children: media.map((asset) {
                  int index = media.indexOf(asset);
                  if (asset.isLeft()) {
                    MultiPickedAsset e = asset.fold((l) => l, (r) => null)!;
                    if (e.type == PickedAssetType.image) {
                      if (e.file != null) {
                        return Stack(
                          children: [
                            PhotoView(
                              imageProvider: FileImage(e.file!),
                            ),
                            Positioned(
                              top: 10,
                              right: 20,
                              child: InkWell(
                                onTap: () async {
                                  File? file = await e.file;

                                  var res = await Navigator.push<Uint8List?>(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MediaPaint(
                                                file: file!,
                                                indexFile:
                                                    media.indexOf(dz.Left(e)),
                                              )));
                                  if (res != null) {
                                    ref
                                        .read(mediaSenderProvider)
                                        .updateValueWithIndex(
                                            index, dz.Right(res));
                                  }
                                },
                                child: SizedBox(
                                  width: formatWidth(47),
                                  height: formatWidth(47),
                                  child: const Icon(Iconsax.edit_2,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return const Center(
                          child: LoaderClassique(activeColor: Colors.white));
                    } else {
                      return _playerVideo(context, e);
                    }
                  } else {
                    Uint8List e = asset.fold((l) => null, (r) => r)!;
                    return Stack(
                      children: [
                        PhotoView(
                          imageProvider: MemoryImage(e),
                        ),
                        Positioned(
                          top: 10,
                          right: 20,
                          child: InkWell(
                            onTap: () async {
                              Uint8List? res = await Navigator.push<Uint8List?>(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MediaPaint(
                                            memoryImage: e,
                                            indexFile:
                                                media.indexOf(dz.Right(e)),
                                          )));
                              if (res != null) {
                                ref
                                    .read(mediaSenderProvider)
                                    .updateValueWithIndex(index, dz.Right(res));
                              }
                            },
                            child: SizedBox(
                              width: formatWidth(47),
                              height: formatWidth(47),
                              child: const Icon(Iconsax.edit_2,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                }).toList(),
              ),
            ),
            Positioned(
              bottom: formatHeight(25),
              child: Column(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: formatWidth(27.5)),
                    width: size.width,
                    child: TextField(
                      minLines: 1,
                      maxLines: 4,
                      onChanged: (val) => _commentary = val,
                      style: DefaultAppStyle.darkBlue(14, FontWeight.w400),
                      decoration: InputDecoration(
                        hintText: "package.picker.write-message".tr(),
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: formatWidth(10),
                            vertical: formatHeight(12)),
                        hintStyle:
                            DefaultAppStyle.darkBlue(14, FontWeight.w400),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(r(24)),
                            borderSide:
                                BorderSide(width: 1, color: DefaultColor.grey)),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(r(24)),
                            borderSide:
                                BorderSide(width: 1, color: DefaultColor.grey)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(r(24)),
                            borderSide:
                                BorderSide(width: 1, color: DefaultColor.grey)),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(r(24)),
                            borderSide:
                                BorderSide(width: 1, color: DefaultColor.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(r(24)),
                            borderSide:
                                BorderSide(width: 1, color: DefaultColor.grey)),
                      ),
                    ),
                  ),
                  sh(16),
                  SizedBox(
                    width: size.width,
                    child: Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.only(left: formatWidth(27.5)),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ...media.map((asset) {
                                  final index = media.indexOf(asset);
                                  if (asset.isRight()) {
                                    final e =
                                        asset.fold((l) => null, (r) => r)!;
                                    return _showImagePreview(
                                        context, dz.Right(e), index);
                                  } else {
                                    final e =
                                        asset.fold((l) => l, (r) => null)!;

                                    return (e.type == PickedAssetType.image)
                                        ? _showImagePreview(
                                            context, dz.Left(e), index)
                                        : _showVideoPreview(context, e, index);
                                  }
                                }).toList(),
                                InkWell(
                                  onTap: () async {
                                    await _addFiles(context);
                                  },
                                  child: Container(
                                    width: formatWidth(58),
                                    height: formatWidth(58),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(.65),
                                      borderRadius: BorderRadius.circular(r(7)),
                                      border: Border.all(
                                          color: Colors.white, width: .3),
                                    ),
                                    child: const Center(
                                        child: Icon(Icons.add_rounded,
                                            color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        sw(12),
                        InkWell(
                          onTap: () async {
                            final tchat = ref
                                .read(tchatListProvider(
                                    FirebaseAuth.instance.currentUser!.uid))
                                .tchatList
                                ?.firstWhereOrNull(
                                    (element) => element.id == widget.tchatId);

                            if (tchat == null) {
                              PopupAlert.toast(context, FToast().init(context),
                                  title: "utils.error".tr(),
                                  subtitle: "utils.error-default".tr(),
                                  type: AlertType.error);

                              AutoRouter.of(context).pop();
                              return;
                            }

                            ref.read(messageListProvider).sendMediaMessage(
                                context,
                                ref,
                                tchat,
                                media,
                                _commentary?.trim());

                            if (mounted) AutoRouter.of(context).pop();
                          },
                          child: Container(
                            width: formatWidth(47),
                            height: formatWidth(47),
                            decoration: BoxDecoration(
                              color: DefaultColor.darkBlue,
                              borderRadius: BorderRadius.circular(r(7)),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                "assets/svg/ic_send.svg",
                                package: "kosmos_chat",
                                color: Colors.white,
                                width: formatWidth(16),
                              ),
                            ),
                          ),
                        ),
                        sw(27.5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: formatHeight(15),
              child: Container(
                width: size.width,
                padding: EdgeInsets.symmetric(horizontal: formatWidth(27.5)),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    InkWell(
                      onTap: () {
                        ref.read(mediaSenderProvider).clear(false);
                        AutoRouter.of(context).pop();
                      },
                      child: Container(
                        width: formatWidth(47),
                        height: formatWidth(47),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.65),
                          borderRadius: BorderRadius.circular(r(14)),
                          border: Border.all(color: Colors.white, width: .3),
                        ),
                        child: const Center(
                            child:
                                Icon(Icons.close_rounded, color: Colors.white)),
                      ),
                    ),
                    sw(6),
                    Expanded(
                      child: Center(
                        child: Text(
                          "package.picker.number-picture".plural(media.length),
                          style: DefaultAppStyle.white(16).copyWith(
                            shadows: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.8),
                                offset: const Offset(0, 1),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    sw(6),
                    SizedBox(
                      width: formatWidth(47),
                      height: formatWidth(47),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addFiles(BuildContext context) async {
    final imageSource = await pickImageSourceType(context, null);
    if (imageSource == null) return;

    if (!mounted) return;

    if (imageSource == ImageSource.camera) {
      final MultiPickedAsset? entity =
          await PickImageController.getImageFromCamera(context);
      if (entity == null) return;
      ref.read(mediaSenderProvider).addFiles([dz.Left(entity)]);
    } else {
      final asset = await PickImageController.getImageFromGalery(context, null);
      if (asset == null) return;
      ref.read(mediaSenderProvider).addFiles(
          asset.map((e) => dz.Left<MultiPickedAsset, Uint8List>(e)).toList());
    }
  }

  Widget _playerVideo(BuildContext context, MultiPickedAsset e) {
    if (e.file != null) {
      return VideoApp(file: e.file!);
    }

    return const Center(child: LoaderClassique(activeColor: Colors.white));
  }

  /// Image Box Preview.
  /// Permet de visualiser, dans la liste
  /// des médias du bas, une image.
  Widget _showImagePreview(BuildContext context,
      dz.Either<MultiPickedAsset, Uint8List> asset, int index) {
    if (asset.isLeft()) {
      MultiPickedAsset e = asset.fold((l) => l, (r) => null)!;
      return Padding(
          padding: EdgeInsets.only(right: formatWidth(3)),
          child: e.file != null
              ? InkWell(
                  onTap: () {
                    _pageController.jumpToPage(index);
                  },
                  child: Container(
                    width: formatWidth(58),
                    height: formatWidth(58),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(r(7)),
                      border: Border.all(
                        width: 3,
                        color: (index) == page
                            ? DefaultColor.darkBlue
                            : Colors.transparent,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(r(4)),
                      child: Image.file(e.file!, fit: BoxFit.cover),
                    ),
                  ),
                )
              : SizedBox(
                  width: formatWidth(58),
                  height: formatWidth(58),
                  child: const Center(child: LoaderClassique()),
                ));
    } else if (asset.isRight()) {
      Uint8List e = asset.fold((l) => null, (r) => r)!;

      return Padding(
          padding: EdgeInsets.only(right: formatWidth(3)),
          child: InkWell(
            onTap: () {
              _pageController.jumpToPage(index);
            },
            child: Container(
              width: formatWidth(58),
              height: formatWidth(58),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(r(7)),
                border: Border.all(
                  width: 3,
                  color: (index) == page
                      ? DefaultColor.darkBlue
                      : Colors.transparent,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(r(4)),
                child: Image.memory(e, fit: BoxFit.cover),
              ),
            ),
          ));
    }
    return SizedBox(
      width: formatWidth(58),
      height: formatWidth(58),
      child: const Center(child: LoaderClassique()),
    );
  }

  Widget _showVideoPreview(
      BuildContext context, MultiPickedAsset e, int index) {
    return Padding(
        padding: EdgeInsets.only(right: formatWidth(3)),
        child: e.thumbnail != null
            ? InkWell(
                onTap: () {
                  _pageController.jumpToPage(index);
                },
                child: Container(
                  width: formatWidth(58),
                  height: formatWidth(58),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(r(7)),
                    border: Border.all(
                      width: 3,
                      color: (index) == page
                          ? DefaultColor.darkBlue
                          : Colors.transparent,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(r(4)),
                          child: Image.memory(e.thumbnail!, fit: BoxFit.cover),
                        ),
                      ),
                      Center(
                          child: Icon(Icons.play_arrow_rounded,
                              color: Colors.white, size: formatWidth(28))),
                    ],
                  ),
                ),
              )
            : SizedBox(
                width: formatWidth(58),
                height: formatWidth(58),
                child: const Center(child: LoaderClassique()),
              ));
  }
}
