import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_button_outline.dart';
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
  List<Product> _products = const <Product>[];

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final XFile? file = await ImagePicker().pickVideo(
      source: source,
      maxDuration: const Duration(seconds: 60),
    );
    if (file != null) setState(() => _videoPath = file.path);
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
        return Scaffold(
          backgroundColor: DSColor.surface,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.router.maybePop(),
            ),
            title: Text(context.l10N.reels_composer_title),
          ),
          body: _videoPath == null
              ? _pickStage(context)
              : _composeStage(context, state),
        );
      },
    );
  }

  Widget _pickStage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            context.l10N.reels_pick_title,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.headlineLarge,
              fontWeight: DSFontWeight.bold,
              color: DSColor.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10N.reels_pick_subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodyMedium,
              height: 1.46,
              color: DSColor.onSurface60,
            ),
          ),
          const SizedBox(height: 28),
          DSButtonElevated(
            text: context.l10N.reels_record_video,
            onPressed: () => _pick(ImageSource.camera),
          ),
          const SizedBox(height: 12),
          DSButtonOutline(
            text: context.l10N.reels_choose_from_gallery,
            onPressed: () => _pick(ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  Widget _composeStage(BuildContext context, ReelComposerState state) {
    final bool posting = state is ReelComposerPosting;
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
                    Container(
                      width: 78,
                      height: 104,
                      decoration: BoxDecoration(
                        color: DSColor.card,
                        borderRadius: BorderRadius.circular(
                          DSBorderRadius.image,
                        ),
                      ),
                      child: const Icon(
                        Icons.play_circle_outline,
                        color: DSColor.onSurface45,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DSTextField(
                        controller: _caption,
                        hintText: context.l10N.reels_caption_hint,
                        maxLines: 4,
                        maxLength: 300,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  context.l10N.reels_tag_items_title,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.titleLarge,
                    fontWeight: DSFontWeight.semiBold,
                    color: DSColor.onSurface,
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
                          decoration: BoxDecoration(
                            color: DSColor.card,
                            borderRadius: BorderRadius.circular(
                              DSBorderRadius.image,
                            ),
                            border: Border.all(
                              color: selected
                                  ? DSColor.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                            image: p.coverImageUrl == null
                                ? null
                                : DecorationImage(
                                    image: NetworkImage(p.coverImageUrl!),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          child: selected
                              ? const Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.check_circle,
                                      size: 18,
                                      color: DSColor.primary,
                                    ),
                                  ),
                                )
                              : null,
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
            text: context.l10N.reels_post_reel,
            isLoading: posting,
            onPressed: _post,
          ),
        ),
      ],
    );
  }

  Widget _success(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
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
                          fontSize: 24,
                          fontWeight: DSFontWeight.bold,
                          color: DSColor.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        context.l10N.reels_posted_subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: dsFontFamily,
                          fontSize: DSFontSize.bodyLarge,
                          height: 1.5,
                          color: DSColor.onSurface60,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            DSBottomBar(
              child: DSButtonElevated(
                text: context.l10N.reels_done,
                onPressed: () => context.router.maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
