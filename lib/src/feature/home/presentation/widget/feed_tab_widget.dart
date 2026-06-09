import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_selectable_chip.dart';
import 'package:klozy/src/design/components/shimmer_box/shimmer_box_widget.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/feature/home/presentation/bloc/feed_bloc.dart';
import 'package:klozy/src/feature/home/presentation/bloc/feed_event.dart';
import 'package:klozy/src/feature/home/presentation/bloc/feed_state.dart';
import 'package:klozy/src/feature/home/presentation/widget/product_card_widget.dart';

const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
  childAspectRatio: 0.56,
);

class FeedTabWidget extends StatefulWidget {
  const FeedTabWidget({super.key});

  @override
  State<FeedTabWidget> createState() => _FeedTabWidgetState();
}

class _FeedTabWidgetState extends State<FeedTabWidget> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 400) {
      context.read<FeedBloc>().add(const FeedLoadMore());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (BuildContext context, FeedState state) {
        return switch (state) {
          FeedLoading() => const _ShimmerGrid(),
          FeedError(:final type) => AppErrorWidget(
            type: type,
            onRetry: () => context.read<FeedBloc>().add(const FeedStarted()),
          ),
          FeedReady() => _ready(context, state),
        };
      },
    );
  }

  Widget _ready(BuildContext context, FeedReady state) {
    return CustomScrollView(
      controller: _controller,
      slivers: <Widget>[
        SliverToBoxAdapter(child: _chips(context, state)),
        if (state.items.isEmpty && state.isLoadingMore)
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: _ShimmerSliver(),
          )
        else if (state.items.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Center(
                child: Text(
                  context.l10N.home_feed_empty,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodyLarge,
                    color: DSColor.onSurface45,
                  ),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverGrid.builder(
              gridDelegate: _gridDelegate,
              itemCount: state.items.length,
              itemBuilder: (BuildContext context, int i) {
                final Product p = state.items[i];
                return ProductCardWidget(product: p);
              },
            ),
          ),
        if (state.isLoadingMore && state.items.isNotEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: DSColor.primary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _chips(BuildContext context, FeedReady state) {
    final chips = <_Chip>[
      _Chip(id: null, label: context.l10N.home_category_all),
      ...state.categories.map(
        (CatalogCategory c) => _Chip(id: c.id, label: c.label),
      ),
    ];
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int i) {
          final chip = chips[i];
          return DSSelectableChip(
            label: chip.label,
            selected: state.selectedRootId == chip.id,
            onTap: () =>
                context.read<FeedBloc>().add(FeedCategorySelected(chip.id)),
          );
        },
      ),
    );
  }
}

class _Chip {
  final String? id;
  final String label;

  const _Chip({required this.id, required this.label});
}

class _ShimmerGrid extends StatelessWidget {
  const _ShimmerGrid();

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
          sliver: _ShimmerSliver(),
        ),
      ],
    );
  }
}

class _ShimmerSliver extends StatelessWidget {
  const _ShimmerSliver();

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      gridDelegate: _gridDelegate,
      itemCount: 6,
      itemBuilder: (BuildContext context, int i) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Expanded(
              child: ShimmerBoxWidget(width: double.infinity, borderRadius: 18),
            ),
            const SizedBox(height: 8),
            ShimmerBoxWidget(
              width: MediaQuery.sizeOf(context).width * 0.3,
              height: 10,
            ),
            const SizedBox(height: 6),
            const ShimmerBoxWidget(width: 50, height: 8),
          ],
        );
      },
    );
  }
}
