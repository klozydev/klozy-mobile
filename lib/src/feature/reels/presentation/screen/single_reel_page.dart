import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/design/components/ds_glass_button.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_page_loader_widget.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_progress_dots_widget.dart';

/// Full-screen reel viewer opened from a profile reel grid. Pages vertically
/// through that profile's reels (matching the design's swipeable viewer),
/// starting at the tapped reel. Falls back to a single reel when only [reelId]
/// is provided (e.g. a deep link).
@RoutePage()
class SingleReelPage extends StatefulWidget {
  final String reelId;

  /// Ordered reel ids for the swipeable pager. Null/empty for a single reel.
  final List<String>? reelIds;

  /// Index of [reelId] within [reelIds] — the page to open on first build.
  final int initialIndex;

  const SingleReelPage({
    @PathParam('id') required this.reelId,
    this.reelIds,
    this.initialIndex = 0,
    super.key,
  });

  @override
  State<SingleReelPage> createState() => _SingleReelPageState();
}

class _SingleReelPageState extends State<SingleReelPage> {
  late final List<String> _ids =
      (widget.reelIds != null && widget.reelIds!.isNotEmpty)
      ? widget.reelIds!
      : <String>[widget.reelId];
  late final int _start = widget.initialIndex.clamp(0, _ids.length - 1);
  late final PageController _pageController = PageController(
    initialPage: _start,
  );
  late int _index = _start;
  String? _myId;

  @override
  void initState() {
    super.initState();
    locator<MeRepository>().getMe().then((me) {
      if (mounted) setState(() => _myId = me.id);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: _ids.length,
                onPageChanged: (int i) => setState(() => _index = i),
                itemBuilder: (BuildContext context, int i) =>
                    ReelPageLoaderWidget(
                      key: ValueKey<String>(_ids[i]),
                      reelId: _ids[i],
                      isActive: i == _index,
                      myId: _myId,
                    ),
              ),
            ),
            if (_ids.length > 1)
              Positioned(
                top: MediaQuery.viewPaddingOf(context).top + 56,
                right: 14,
                child: ReelProgressDotsWidget(
                  count: _ids.length,
                  current: _index,
                ),
              ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: DSGlassButton(
                  onTap: () => context.router.maybePop(),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: DSColor.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
