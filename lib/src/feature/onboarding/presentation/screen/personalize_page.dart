import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_brand_chip.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_segmented_control.dart';
import 'package:klozy/src/design/components/ds_selectable_chip.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/entity/preferences_input.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/personalize_bloc.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/personalize_event.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/personalize_state.dart';
import 'package:klozy/src/router/app_router.dart';

const _clothingSizes = <String>['XS', 'S', 'M', 'L', 'XL', 'XXL'];
const _shoeSizes = <String, List<String>>{
  'EU': <String>['38', '39', '40', '41', '42', '43'],
  'US': <String>['6', '7', '8', '9', '10', '11'],
};

@RoutePage()
class PersonalizePage extends StatefulWidget implements AutoRouteWrapper {
  const PersonalizePage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<PersonalizeBloc>(
      create: (_) =>
          locator<PersonalizeBloc>()..add(const PersonalizeStarted()),
      child: this,
    );
  }

  @override
  State<PersonalizePage> createState() => _PersonalizePageState();
}

class _PersonalizePageState extends State<PersonalizePage> {
  final TextEditingController _brandSearch = TextEditingController();
  final Set<String> _categories = <String>{};
  final Set<String> _sizes = <String>{};
  final Set<String> _brands = <String>{};
  String _sizeSystem = 'EU';

  int get _count => _categories.length + _sizes.length + _brands.length;

  @override
  void dispose() {
    _brandSearch.dispose();
    super.dispose();
  }

  void _toggle(Set<String> set, String value) {
    setState(() => set.contains(value) ? set.remove(value) : set.add(value));
  }

  void _goNext() => context.router.push(const ProfileCompletionRoute());

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PersonalizeBloc, PersonalizeState>(
      listener: (BuildContext context, PersonalizeState state) {
        if (state is PersonalizeCompleted) _goNext();
      },
      builder: (BuildContext context, PersonalizeState state) {
        return Scaffold(
          backgroundColor: DSColor.surface,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: <Widget>[
              TextButton(
                onPressed: _goNext,
                child: Text(
                  context.l10N.onboarding_skip,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodyMedium,
                    fontWeight: DSFontWeight.semiBold,
                    color: DSColor.onSurface60,
                  ),
                ),
              ),
            ],
          ),
          body: switch (state) {
            PersonalizeLoading() => const DSLoader(),
            PersonalizeFailure(:final type) => AppErrorWidget(
              type: type,
              onRetry: () => context.read<PersonalizeBloc>().add(
                const PersonalizeStarted(),
              ),
            ),
            PersonalizeReady() => _content(context, state),
            PersonalizeCompleted() => const DSLoader(),
          },
        );
      },
    );
  }

  Widget _content(BuildContext context, PersonalizeReady state) {
    return SafeArea(
      top: false,
      child: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    context.l10N.onboarding_personalize_title,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.headlineLarge,
                      fontWeight: DSFontWeight.bold,
                      letterSpacing: -0.4,
                      color: DSColor.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10N.onboarding_personalize_subtitle,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyLarge,
                      height: 1.57,
                      color: DSColor.onSurface60,
                    ),
                  ),
                  _sectionTitle(
                    context.l10N.onboarding_categories_title,
                    hint: context.l10N.onboarding_categories_hint,
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.categories
                        .map(
                          (c) => DSSelectableChip(
                            label: c.label,
                            selected: _categories.contains(c.id),
                            onTap: () => _toggle(_categories, c.id),
                          ),
                        )
                        .toList(),
                  ),
                  _sectionTitle(
                    context.l10N.onboarding_sizes_title,
                    trailing: SizedBox(
                      width: 96,
                      child: DSSegmentedControl(
                        size: DSSegmentedSize.sm,
                        labels: const <String>['EU', 'US'],
                        selectedIndex: _sizeSystem == 'EU' ? 0 : 1,
                        onChanged: (int i) =>
                            setState(() => _sizeSystem = i == 0 ? 'EU' : 'US'),
                      ),
                    ),
                  ),
                  _subLabel(context.l10N.onboarding_clothing_label),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _clothingSizes
                        .map(
                          (s) => DSSelectableChip(
                            label: s,
                            selected: _sizes.contains(s),
                            onTap: () => _toggle(_sizes, s),
                          ),
                        )
                        .toList(),
                  ),
                  _subLabel(context.l10N.onboarding_shoes_label(_sizeSystem)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _shoeSizes[_sizeSystem]!
                        .map(
                          (s) => DSSelectableChip(
                            label: s,
                            selected: _sizes.contains('$_sizeSystem $s'),
                            onTap: () => _toggle(_sizes, '$_sizeSystem $s'),
                          ),
                        )
                        .toList(),
                  ),
                  _sectionTitle(
                    context.l10N.onboarding_brands_title,
                    hint: context.l10N.onboarding_brands_hint,
                  ),
                  DSTextField(
                    controller: _brandSearch,
                    hintText: context.l10N.onboarding_brands_search_hint,
                    prefixIcon: Icons.search_rounded,
                    onChanged: (String q) => context
                        .read<PersonalizeBloc>()
                        .add(PersonalizeBrandQueryChanged(q)),
                  ),
                  const SizedBox(height: 12),
                  if (state.brands.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        context.l10N.onboarding_no_brand_matches,
                        style: const TextStyle(
                          fontFamily: dsFontFamily,
                          fontSize: DSFontSize.bodyMedium,
                          color: DSColor.onSurface35,
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: state.brands
                          .map(
                            (b) => DSBrandChip(
                              name: b.name,
                              selected: _brands.contains(b.id),
                              onTap: () => _toggle(_brands, b.id),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
          DSBottomBar(
            child: DSButtonElevated(
              text: _count > 0
                  ? context.l10N.onboarding_show_feed_count(_count)
                  : context.l10N.onboarding_show_feed,
              isLoading: state.isSubmitting,
              onPressed: () => context.read<PersonalizeBloc>().add(
                PersonalizeSubmitted(
                  PreferencesInput(
                    sizeSystem: _sizeSystem,
                    sizes: _sizes.toList(),
                    categoryIds: _categories.toList(),
                    brandIds: _brands.toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, {String? hint, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.titleLarge,
              fontWeight: DSFontWeight.semiBold,
              letterSpacing: -0.16,
              color: DSColor.onSurface,
            ),
          ),
          if (hint != null) ...<Widget>[
            const SizedBox(width: 8),
            Text(
              hint,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodySmall,
                color: DSColor.onSurface35,
              ),
            ),
          ],
          if (trailing != null) ...<Widget>[const Spacer(), trailing],
        ],
      ),
    );
  }

  Widget _subLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: dsFontFamily,
          fontSize: DSFontSize.bodyMedium,
          color: DSColor.onSurface45,
        ),
      ),
    );
  }
}
