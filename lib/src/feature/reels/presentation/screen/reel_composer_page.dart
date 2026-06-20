import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:klozy/src/core/events/open_reels_tab_event.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_dashed_rounded_border_painter.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/feature/reels/presentation/bloc/reel_composer_bloc.dart';
import 'package:klozy/src/feature/reels/presentation/bloc/reel_composer_event.dart';
import 'package:klozy/src/feature/reels/presentation/bloc/reel_composer_state.dart';
import 'package:video_player/video_player.dart';

@RoutePage()
class ReelComposerPage extends StatefulWidget implements AutoRouteWrapper {
  const ReelComposerPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<ReelComposerBloc>(
      create: (_) =>
          locator<ReelComposerBloc>()..add(const ReelComposerStarted()),
      child: this,
    );
  }

  @override
  State<ReelComposerPage> createState() => _ReelComposerPageState();
}

class _ReelComposerPageState extends State<ReelComposerPage> {
  final TextEditingController _caption = TextEditingController();
  final Set<String> _tagged = <String>{};
  String? _videoPath;
  // Drives the picked-video first-frame preview shown in the compose stage.
  VideoPlayerController? _thumb;
  List<Product> _products = const <Product>[];

  @override
  void dispose() {
    _caption.dispose();
    _thumb?.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final XFile? file = await ImagePicker().pickVideo(
      source: source,
      maxDuration: const Duration(seconds: 60),
    );
    if (file == null) return;
    final VideoPlayerController controller = VideoPlayerController.file(
      File(file.path),
    );
    await controller.initialize();
    if (!mounted) {
      controller.dispose();
      return;
    }
    _thumb?.dispose();
    setState(() {
      _videoPath = file.path;
      _thumb = controller;
    });
  }

  // Clears the picked video and tears down its preview controller.
  void _clearVideo() {
    _thumb?.dispose();
    setState(() {
      _videoPath = null;
      _thumb = null;
    });
  }

  void _post() {
    final path = _videoPath;
    if (path == null) return;
    context.read<ReelComposerBloc>().add(
      ReelComposerSubmitted(
        videoPath: path,
        caption: _caption.text.trim().isEmpty ? null : _caption.text.trim(),
        taggedProductIds: _tagged.toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReelComposerBloc, ReelComposerState>(
      listener: (BuildContext context, ReelComposerState state) {
        if (state is ReelComposerReady) {
          _products = state.products;
          if (state.errorMessage != null) {
            context.showSnackBar(state.errorMessage!);
          }
        }
      },
      builder: (BuildContext context, ReelComposerState state) {
        if (state is ReelComposerLoading) {
          return const Scaffold(
            backgroundColor: DSColor.surface,
            body: DSLoader(),
          );
        }
        if (state is ReelComposerDone) {
          return _success(context);
        }
        if (state is ReelComposerPosting) {
          return _publishing(context);
        }
        final bool picking = _videoPath == null;
        return Scaffold(
          backgroundColor: DSColor.surface,
          appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: false,
            // Back (left) only in compose stage; rewinds to the pick stage.
            leading: picking
                ? null
                : IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: _clearVideo,
                  ),
            title: Text(
              picking
                  ? context.l10N.reels_composer_title
                  : context.l10N.reels_compose_details_title,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyLarge,
                fontWeight: DSFontWeight.semiBold,
                color: DSColor.onSurface,
              ),
            ),
            // ✕ close always top-right; abandons the whole flow.
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.close),
                color: DSColor.onSurface60,
                onPressed: () => context.router.maybePop(),
              ),
            ],
          ),
          body: picking ? _pickStage(context) : _composeStage(context, state),
        );
      },
    );
  }

  Widget _pickStage(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 4, 2, 16),
            child: Text(
              context.l10N.reels_pick_subtitle,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyMedium,
                height: 1.46,
                color: DSColor.onSurface60,
              ),
            ),
          ),
          // 9:16 record tile.
          GestureDetector(
            onTap: () => _pick(ImageSource.camera),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: CustomPaint(
                  painter: const DSDashedRoundedBorderPainter(
                    color: DSColor.onSurface24,
                    radius: DSBorderRadius.card,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(DSBorderRadius.card),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[Color(0xFF16161A), Color(0xFF0D0D10)],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: DSColor.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            size: 30,
                            color: DSColor.surface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.l10N.reels_record_video,
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: DSFontSize.bodyLarge,
                            fontWeight: DSFontWeight.semiBold,
                            color: DSColor.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10N.reels_record_hint,
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: DSFontSize.bodySmall,
                            color: DSColor.onSurface45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filled card button with leading gallery/bag icon.
          GestureDetector(
            onTap: () => _pick(ImageSource.gallery),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: DSColor.card,
                borderRadius: BorderRadius.circular(DSBorderRadius.input),
                border: Border.all(color: DSColor.onSurface10, width: 0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 18,
                    color: DSColor.onSurface75,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.l10N.reels_choose_from_gallery,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyLarge,
                      fontWeight: DSFontWeight.semiBold,
                      color: DSColor.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _composeStage(BuildContext context, ReelComposerState state) {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Picked-video first-frame preview; gradient fallback
                    // until the controller reports ready.
                    ClipRRect(
                      borderRadius: BorderRadius.circular(DSBorderRadius.image),
                      child: SizedBox(
                        width: 78,
                        height: 104,
                        child: _thumb != null && _thumb!.value.isInitialized
                            ? FittedBox(
                                fit: BoxFit.cover,
                                clipBehavior: Clip.hardEdge,
                                child: SizedBox(
                                  width: _thumb!.value.size.width,
                                  height: _thumb!.value.size.height,
                                  child: VideoPlayer(_thumb!),
                                ),
                              )
                            : const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: <Color>[
                                      Color(0xFF2A1505),
                                      Color(0xFF0E0A04),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'REEL',
                                    style: TextStyle(
                                      fontFamily: dsFontFamily,
                                      fontSize: DSFontSize.bodySmall,
                                      fontWeight: DSFontWeight.semiBold,
                                      letterSpacing: 0.5,
                                      color: DSColor.onSurface45,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6, left: 2),
                            child: Text(
                              context.l10N.reels_caption_label,
                              style: const TextStyle(
                                fontFamily: dsFontFamily,
                                fontSize: DSFontSize.bodySmall,
                                fontWeight: DSFontWeight.semiBold,
                                color: DSColor.onSurface60,
                              ),
                            ),
                          ),
                          DSTextField(
                            controller: _caption,
                            hintText: context.l10N.reels_caption_hint,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  context.l10N.reels_tag_items_title.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: 11,
                    fontWeight: DSFontWeight.semiBold,
                    letterSpacing: 0.88,
                    color: DSColor.onSurface35,
                  ),
                ),
                const SizedBox(height: 12),
                if (_products.isEmpty)
                  Text(
                    context.l10N.reels_no_listings_to_tag,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyMedium,
                      color: DSColor.onSurface45,
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 3 / 4,
                        ),
                    itemCount: _products.length,
                    itemBuilder: (BuildContext context, int i) {
                      final p = _products[i];
                      final selected = _tagged.contains(p.id);
                      return GestureDetector(
                        onTap: () => setState(
                          () => selected
                              ? _tagged.remove(p.id)
                              : _tagged.add(p.id),
                        ),
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: DSColor.card,
                            borderRadius: BorderRadius.circular(
                              DSBorderRadius.cardSmall,
                            ),
                            border: Border.all(
                              color: selected
                                  ? DSColor.primary
                                  : DSColor.onSurface10,
                              width: selected ? 1.5 : 0.5,
                            ),
                            image: p.coverImageUrl == null
                                ? null
                                : DecorationImage(
                                    image: NetworkImage(p.coverImageUrl!),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              // Price overlay along the bottom edge.
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.fromLTRB(
                                    5,
                                    12,
                                    5,
                                    4,
                                  ),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: <Color>[
                                        Color(0xD9000000),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    context.l10N.product_price_amount(
                                      p.price.toInt(),
                                    ),
                                    style: const TextStyle(
                                      fontFamily: dsFontFamily,
                                      fontSize: 9,
                                      fontWeight: DSFontWeight.semiBold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              if (selected)
                                const Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: EdgeInsets.all(5),
                                    // Accent-filled 20px disc with a surface
                                    // tick inside (matches design check2 chip).
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: DSColor.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Icon(
                                          Icons.check,
                                          size: 12,
                                          color: DSColor.surface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
        DSBottomBar(
          child: DSButtonElevated(
            text: _tagged.isEmpty
                ? context.l10N.reels_post_reel
                : context.l10N.reels_post_reel_tagged(_tagged.length),
            onPressed: _post,
          ),
        ),
      ],
    );
  }

  Widget _publishing(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: DSColor.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              context.l10N.reels_publishing,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyLarge,
                fontWeight: DSFontWeight.medium,
                color: DSColor.onSurface75,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _success(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      body: SafeArea(
        // Whole block (glow → title → subtitle → button) centered together;
        // the CTA sits inline directly under the subtitle, not pinned bottom.
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    color: DSColor.primary,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(color: Color(0x66E0CE7D), blurRadius: 46),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 44,
                    color: DSColor.surface,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  context.l10N.reels_posted_title,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: 26,
                    fontWeight: DSFontWeight.bold,
                    color: DSColor.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _tagged.isEmpty
                      ? context.l10N.reels_posted_subtitle
                      : context.l10N.reels_posted_subtitle_tagged(
                          _tagged.length,
                        ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodyLarge,
                    height: 1.5,
                    color: DSColor.onSurface60,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 200,
                  child: DSButtonElevated(
                    text: context.l10N.reels_view_in_reels,
                    onPressed: () {
                      locator<EventBus>().fire(const OpenReelsTabEvent());
                      context.router.maybePop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
