import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';

class CommonAuthHeader extends StatefulWidget {
  final String imagePath;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final Widget? child;

  const CommonAuthHeader({
    super.key,
    required this.imagePath,
    this.showBackButton = true,
    this.onBackTap,
    this.child,
  });

  static const double toolbarHeight = 50.0;
  static const double horizontalPadding = 20.0;
  static const double backButtonSize = 44.0;

  @override
  State<CommonAuthHeader> createState() => _CommonAuthHeaderState();
}

class _CommonAuthHeaderState extends State<CommonAuthHeader> {
  @override
  void initState() {
    super.initState();
    // Global focus listener: whenever ANY field (inside this widget or
    // not) gains focus, try to scroll it into view. Scrollable.ensureVisible
    // silently no-ops if the focused widget has no Scrollable ancestor, so
    // this is safe to leave app-wide rather than wiring a FocusNode through
    // every CommonTextFormField individually.
    FocusManager.instance.addListener(_handleGlobalFocusChange);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_handleGlobalFocusChange);
    super.dispose();
  }

  void _handleGlobalFocusChange() {
    final focusedContext = FocusManager.instance.primaryFocus?.context;
    if (focusedContext == null) return;

    // Wait a beat so the keyboard has (mostly) finished animating in and
    // the SingleChildScrollView's viewport size has settled — otherwise
    // ensureVisible measures against a viewport that's still resizing
    // and can undershoot.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      Scrollable.ensureVisible(
        focusedContext,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        // Leaves a little space above the field (instead of pinning it
        // to the very top edge) so its label/error text stays visible too.
        alignment: 0.2,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;
    final headerHeight = topPadding + CommonAuthHeader.toolbarHeight;

    // Because AuthLayout sets resizeToAvoidBottomInset: false, the
    // Scaffold body (this whole Stack, background included) always stays
    // full-screen height — it is NEVER resized by the keyboard. That's
    // what keeps the background image static instead of rescaling/
    // shifting when the keyboard opens.
    //
    // MediaQuery.viewInsets.bottom still correctly reports the keyboard
    // height here (it's only zeroed out for descendants when
    // resizeToAvoidBottomInset is true), so we read it ourselves and
    // apply it as scroll padding below — moving only the *content*, not
    // the background.
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    return Stack(
      children: [
        // BACKGROUND IMAGE — fixed size, unaffected by the keyboard.
        Positioned.fill(
          child: Image.asset(
            widget.imagePath,
            fit: BoxFit.cover,
            // Fail gracefully instead of a red-screen exception if the
            // asset path is ever wrong.
            errorBuilder: (_, __, ___) => Container(
              color: AppColor.blackShade1,
            ),
          ),
        ),

        // COLUMN: back button on top, scrollable content below
        Column(
          children: [
            // Fixed header area — back button lives here.
            // Height is kept constant whether or not the back button is
            // shown, so content position stays consistent across screens
            // that toggle showBackButton (e.g. login vs. OTP verify).
            SizedBox(
              height: headerHeight,
              child: widget.showBackButton
                  ? Padding(
                padding: EdgeInsets.only(
                  top: topPadding,
                  left: CommonAuthHeader.horizontalPadding,
                  right: CommonAuthHeader.horizontalPadding,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: widget.onBackTap ?? () => Get.back(),
                      child: Semantics(
                        label: 'Back',
                        button: true,
                        child: Container(
                          width: CommonAuthHeader.backButtonSize,
                          height: CommonAuthHeader.backButtonSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.shadowGrey
                                .withValues(alpha: 0.30),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
                  : const SizedBox.shrink(),
            ),

            // Scrollable content area — panel can never go above back button.
            //
            // Not `reverse: true`: that anchors scroll offset 0 to the
            // *bottom* of the content, so overflow gets clipped from the
            // *top* — silently hiding the title above the fold once
            // content no longer fits. Instead, LayoutBuilder +
            // ConstrainedBox(minHeight) bottom-aligns the content only
            // when it actually fits (matching the at-rest "card touches
            // bottom of screen" design). Once content + keyboard padding
            // exceeds the available space, it scrolls normally,
            // top-to-bottom, so the title stays in reading position, and
            // _handleGlobalFocusChange above scrolls the focused field
            // into view automatically.
            if (widget.child != null)
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      // bottomPadding covers the safe-area inset at rest;
                      // keyboardHeight is added on top so content clears
                      // the keyboard without the background ever resizing.
                      padding: EdgeInsets.only(
                        bottom: bottomPadding + keyboardHeight,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [widget.child!],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class AuthLayout extends StatelessWidget {
  final String imagePath;
  final Widget body;
  final bool showBackButton;
  final VoidCallback? onBackTap;

  const AuthLayout({
    super.key,
    required this.imagePath,
    required this.body,
    this.showBackButton = true,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        // false, and intentionally so: true would resize the ENTIRE body
        // (background image included) whenever the keyboard opens, which
        // is what caused the background to visibly shift/rescale. With
        // this false, the body always stays full-screen, and
        // CommonAuthHeader handles keyboard clearance itself via
        // MediaQuery.viewInsets.bottom on just the scrollable content.
        resizeToAvoidBottomInset: false,
        body: CommonAuthHeader(
          imagePath: imagePath,
          showBackButton: showBackButton,
          onBackTap: onBackTap,
          child: body.paddingOnly(left: 10,right: 10,bottom: 20),
        ),
      ),
    );
  }
}