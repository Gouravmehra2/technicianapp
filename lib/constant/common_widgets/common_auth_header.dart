import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';

class CommonAuthHeader extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;
    final headerHeight = topPadding + toolbarHeight;

    return Stack(
      children: [
        // BACKGROUND IMAGE
        Positioned.fill(
          child: Image.asset(imagePath, fit: BoxFit.cover),
        ),

        // COLUMN: back button on top, scrollable content below
        Column(
          children: [
            // Fixed header area — back button lives here
            SizedBox(
              height: headerHeight,
              child: showBackButton
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: topPadding,
                        left: horizontalPadding,
                        right: horizontalPadding,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: onBackTap ?? () => Get.back(),
                            child: Container(
                              width: backButtonSize,
                              height: backButtonSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColor.shadowGrey.withValues(alpha: 0.30),
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
                    )
                  : const SizedBox.shrink(),
            ),

            // Scrollable content area — panel can never go above back button
            if (child != null)
              Expanded(
                child: SingleChildScrollView(
                  reverse: true,
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: child!,
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

  const AuthLayout({
    super.key,
    required this.imagePath,
    required this.body,
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
        // true so the Scaffold shrinks when keyboard appears,
        // which lets the inner SingleChildScrollView scroll properly
        // resizeToAvoidBottomInset: false,
        body: CommonAuthHeader(
          imagePath: imagePath,
          child: body.paddingSymmetric(horizontal: 10),
        ),
      ),
    );
  }
}