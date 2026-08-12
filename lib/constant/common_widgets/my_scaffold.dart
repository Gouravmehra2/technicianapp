import 'package:flutter/material.dart';

class MyScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;

  /// Controls SafeArea behavior. Defaults to false (no SafeArea).
  final bool useSafeArea;

  /// Fine-grained SafeArea control (only used when [useSafeArea] is true).
  final bool safeAreaTop;
  final bool safeAreaBottom;
  final bool safeAreaLeft;
  final bool safeAreaRight;
  final bool extendBody;

  const MyScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.useSafeArea = false,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
    this.safeAreaLeft = true,
    this.safeAreaRight = true,
    this.extendBody = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget bodyWidget = useSafeArea
        ? SafeArea(
            top: safeAreaTop,
            bottom: safeAreaBottom,
            left: safeAreaLeft,
            right: safeAreaRight,
            child: body,
          )
        : body;

    return Scaffold(
      extendBody: extendBody ?? false,
      appBar: appBar,
      drawer: drawer,
      body: bodyWidget,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      backgroundColor: backgroundColor ?? Colors.white,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}