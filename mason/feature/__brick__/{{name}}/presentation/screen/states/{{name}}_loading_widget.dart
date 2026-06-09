import 'package:flutter/material.dart';

class {{#pascalCase}}{{name}}{{/pascalCase}}LoadingWidget extends StatelessWidget {
  const {{#pascalCase}}{{name}}{{/pascalCase}}LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
