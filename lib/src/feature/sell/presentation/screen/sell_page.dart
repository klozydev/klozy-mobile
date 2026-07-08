import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_bloc.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_event.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_state.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_submit_error_reason.dart';
import 'package:klozy/src/feature/sell/presentation/widget/sell_photos_widget.dart';
import 'package:klozy/src/feature/sell/presentation/widget/sell_recap_widget.dart';
import 'package:klozy/src/feature/sell/presentation/widget/sell_success_widget.dart';
import 'package:klozy/src/feature/sell/presentation/widget/sell_transition_widget.dart';

@RoutePage()
class SellPage extends StatelessWidget implements AutoRouteWrapper {
  const SellPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<SellBloc>(
      create: (_) => locator<SellBloc>()..add(const SellStarted()),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SellBloc, SellState>(
      listenWhen: (SellState previous, SellState current) =>
          current is SellRecapState && current.submitError != null,
      listener: (BuildContext context, SellState state) {
        final SellSubmitErrorReason? submitError = state is SellRecapState
            ? state.submitError
            : null;
        if (submitError != null) {
          context.showSnackBar(switch (submitError) {
            SellSubmitErrorReason.publishFailed =>
              context.l10N.sell_publish_failed,
          });
        }
      },
      builder: (BuildContext context, SellState state) {
        return switch (state) {
          SellPhotosState() => Scaffold(
            backgroundColor: DSColor.surface,
            appBar: _closeBar(context),
            body: SafeArea(top: false, child: SellPhotosWidget(state: state)),
          ),
          SellAnalyzingState(:final coverPath) => Scaffold(
            backgroundColor: DSColor.surface,
            body: SellTransitionWidget(coverPath: coverPath),
          ),
          SellRecapState() => Scaffold(
            backgroundColor: DSColor.surface,
            appBar: _closeBar(context),
            body: SafeArea(top: false, child: SellRecapWidget(state: state)),
          ),
          SellDoneState(:final productId) => SellSuccessWidget(
            productId: productId,
          ),
          SellErrorState(:final type) => Scaffold(
            backgroundColor: DSColor.surface,
            appBar: _closeBar(context),
            body: AppErrorWidget(
              type: type,
              onRetry: () => context.read<SellBloc>().add(const SellStarted()),
            ),
          ),
        };
      },
    );
  }

  PreferredSizeWidget _closeBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => context.router.maybePop(),
      ),
    );
  }
}
