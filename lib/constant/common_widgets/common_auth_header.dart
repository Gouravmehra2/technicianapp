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

  static const double toolbarHeight = 56.0;
  static const double horizontalPadding = 20.0;
  static const double backButtonSize = 44.0;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;

    return SizedBox.expand(
      child: Stack(
        children: [
          // ----------------------------------------------------------
          // BACKGROUND IMAGE
          // ----------------------------------------------------------
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),

          // ----------------------------------------------------------
          // TOP TOOLBAR
          // ----------------------------------------------------------
          if (showBackButton)
            Positioned(
              top: topPadding,
              left: 0,
              right: 0,
              height: toolbarHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
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
                          color: AppColor.shadowGrey.withValues(
                            alpha: 0.30,
                          ),
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
            ),

          // ----------------------------------------------------------
          // BOTTOM CONTENT
          // ----------------------------------------------------------
          if (child != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: bottomPadding,
                ),
                child: child!,
              ),
            ),
        ],
      ),
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
        resizeToAvoidBottomInset: true,
        body: CommonAuthHeader(
          imagePath: imagePath,
          child: body.paddingSymmetric(
            horizontal: 10,
          ),
        ),
      ),
    );
  }
}