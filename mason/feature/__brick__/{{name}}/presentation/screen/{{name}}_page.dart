import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/feature/{{name}}/presentation/bloc/{{name}}_bloc.dart';
import 'package:klozy/src/feature/{{name}}/presentation/bloc/{{name}}_event.dart';
import 'package:klozy/src/feature/{{name}}/presentation/bloc/{{name}}_state.dart';
import 'package:klozy/src/feature/{{name}}/presentation/screen/states/{{name}}_idle_widget.dart';
import 'package:klozy/src/feature/{{name}}/presentation/screen/states/{{name}}_loading_widget.dart';

@RoutePage()
class {{#pascalCase}}{{name}}{{/pascalCase}}Page extends StatefulWidget implements AutoRouteWrapper {
  const {{#pascalCase}}{{name}}{{/pascalCase}}Page({super.key});

  @override
  State<{{#pascalCase}}{{name}}{{/pascalCase}}Page> createState() => _{{#pascalCase}}{{name}}{{/pascalCase}}PageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => locator.get<{{#pascalCase}}{{name}}{{/pascalCase}}Bloc>(),
      child: this,
    );
  }
}

class _{{#pascalCase}}{{name}}{{/pascalCase}}PageState extends State<{{#pascalCase}}{{name}}{{/pascalCase}}Page> {
  late {{#pascalCase}}{{name}}{{/pascalCase}}Bloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read();
    _bloc.add({{#pascalCase}}{{name}}{{/pascalCase}}InitEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: BlocConsumer<{{#pascalCase}}{{name}}{{/pascalCase}}Bloc, {{#pascalCase}}{{name}}{{/pascalCase}}State>(
          builder: _builder,
          listener: _listener,
          buildWhen: _buildWhen,
          listenWhen: _listenWhen,
        ),
      ),
    );
  }

  Future<void> _listener(BuildContext context, {{#pascalCase}}{{name}}{{/pascalCase}}State state) async {}

  bool _buildWhen({{#pascalCase}}{{name}}{{/pascalCase}}State previous, {{#pascalCase}}{{name}}{{/pascalCase}}State current) {
    return current is {{#pascalCase}}{{name}}{{/pascalCase}}IdleState ||
        current is {{#pascalCase}}{{name}}{{/pascalCase}}LoadingState ||
        current is {{#pascalCase}}{{name}}{{/pascalCase}}ErrorState;
  }

  bool _listenWhen({{#pascalCase}}{{name}}{{/pascalCase}}State previous, {{#pascalCase}}{{name}}{{/pascalCase}}State current) {
    return false;
  }

  Widget _builder(BuildContext context, {{#pascalCase}}{{name}}{{/pascalCase}}State state) {
    if (state is {{#pascalCase}}{{name}}{{/pascalCase}}IdleState) {
      return const {{#pascalCase}}{{name}}{{/pascalCase}}IdleWidget();
    } else if (state is {{#pascalCase}}{{name}}{{/pascalCase}}ErrorState) {
      return AppErrorWidget(
        type: state.type,
        onRetry: () => context.read<{{#pascalCase}}{{name}}{{/pascalCase}}Bloc>().add({{#pascalCase}}{{name}}{{/pascalCase}}InitEvent()),
      );
    } else {
      return const {{#pascalCase}}{{name}}{{/pascalCase}}LoadingWidget();
    }
  }
}
