import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HomeTabShellPage extends StatelessWidget {
  const HomeTabShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AutoRouter();
  }
}
