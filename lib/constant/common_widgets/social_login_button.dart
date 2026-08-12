import 'package:flutter/material.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';

/// A fully customisable social-login button.
///
/// The only required params are [onTap] and one of [icon] / [iconAssetPath] /
/// [iconNetworkUrl]. Everything else is optional and falls back to sensible
/// defaults that match the app's design system.
///
/// ─── Usage examples ────────────────────────────────────────────────────────
///
/// 1. With a Flutter icon (Apple):
/// ```dart
/// SocialLoginButton(
///   onTap: controller.handleAppleLogin,
///   icon: Icon(Icons.apple, size: 26, color: AppColor.blackShade1),
/// )
/// ```
///
/// 2. With a network image (Google favicon fallback):
/// ```dart
/// SocialLoginButton(
///   onTap: controller.handleGoogleLogin,
///   iconNetworkUrl: 'https://www.google.com/favicon.ico',
///   iconSize: 22,
///   label: 'Google',
/// )
/// ```
///
/// 3. With a local asset image:
/// ```dart
/// SocialLoginButton(
///   onTap: controller.handleFacebookLogin,
///   iconAssetPath: 'assets/images/facebook_icon.png',
///   iconSize: 24,
///   label: 'Facebook',
///   backgroundColor: const Color(0xFF1877F2),
///   foregroundColor: Colors.white,
/// )
/// ```
///
/// 4. Fully custom child:
/// ```dart
/// SocialLoginButton(
///   onTap: () {},
///   child: Row(children: [Icon(Icons.g_mobiledata), Text('Continue with Google')]),
/// )
/// ```
///
/// 5. Gradient background:
/// ```dart
/// SocialLoginButton(
///   onTap: () {},
///   icon: Icon(Icons.apple, color: Colors.white),
///   gradient: LinearGradient(colors: [Colors.black87, Colors.black]),
/// )
/// ```
///
/// 6. Compact / fixed-width:
/// ```dart
/// SocialLoginButton(
///   onTap: () {},
///   icon: Icon(Icons.apple),
///   fullWidth: false,
///   width: 64,
///   height: 52,
/// )
/// ```
///
/// 7. With loading state:
/// ```dart
/// SocialLoginButton(
///   onTap: controller.handleGoogleLogin,
///   icon: Image.asset(AppAssets.googleImage, height: 20),
///   isLoading: controller.isGoogleLoading.value,
/// )
/// ```
class SocialLoginButton extends StatefulWidget {
  // ── Content ──────────────────────────────────────────────────────────────

  /// Fully custom widget inside the button.
  /// When set, [icon], [iconAssetPath], [iconNetworkUrl], and [label] are ignored.
  final Widget? child;

  /// Any Flutter widget used as the icon (e.g. `Icon(Icons.apple)`).
  final Widget? icon;

  /// Path to a local asset image used as the icon.
  final String? iconAssetPath;

  /// URL to a network image used as the icon.
  final String? iconNetworkUrl;

  /// Rendered size for [iconAssetPath] / [iconNetworkUrl]. Defaults to 24.
  final double iconSize;

  /// Fallback widget shown when [iconNetworkUrl] fails to load.
  final Widget? iconNetworkFallback;

  /// Optional text label rendered next to the icon.
  final String? label;

  /// Gap between icon and [label]. Defaults to 10.
  final double iconLabelSpacing;

  // ── Interaction ───────────────────────────────────────────────────────────

  final VoidCallback onTap;

  /// Shows a spinner and blocks interaction.
  final bool isLoading;

  /// Disables the button entirely (no tap, dimmed appearance).
  final bool enabled;

  // ── Size ──────────────────────────────────────────────────────────────────

  /// Stretches to full available width when true. Defaults to true.
  final bool fullWidth;

  /// Explicit width. Used only when [fullWidth] is false.
  final double? width;

  /// Button height. Defaults to 52.
  final double height;

  // ── Shape ─────────────────────────────────────────────────────────────────

  /// Corner radius. Defaults to 30 (pill shape).
  final double borderRadius;

  /// Use a [BorderRadius] for asymmetric corners. Overrides [borderRadius].
  final BorderRadius? customBorderRadius;

  // ── Colour / decoration ───────────────────────────────────────────────────

  /// Solid background colour. Defaults to [Colors.white].
  /// Ignored when [gradient] is set.
  final Color backgroundColor;

  /// Colour applied to [label] and [icon] (when icon inherits colour).
  /// Defaults to [AppColor.blackShade1].
  final Color foregroundColor;

  /// Gradient background. Takes priority over [backgroundColor].
  final Gradient? gradient;

  /// Border around the button. Defaults to a subtle grey border.
  final Border? border;

  /// Optional shadow list.
  final List<BoxShadow>? boxShadow;

  // ── Typography ────────────────────────────────────────────────────────────

  /// Override the default label text style.
  final TextStyle? labelStyle;

  // ── Spinner ───────────────────────────────────────────────────────────────

  /// Size of the loading spinner. Defaults to 22.
  final double loaderSize;

  /// Stroke width of the loading spinner. Defaults to 2.5.
  final double loaderStrokeWidth;

  const SocialLoginButton({
    super.key,
    required this.onTap,
    this.child,
    this.icon,
    this.iconAssetPath,
    this.iconNetworkUrl,
    this.iconSize = 24,
    this.iconNetworkFallback,
    this.label,
    this.iconLabelSpacing = 10,
    this.isLoading = false,
    this.enabled = true,
    this.fullWidth = true,
    this.width,
    this.height = 52,
    this.borderRadius = 30,
    this.customBorderRadius,
    this.backgroundColor = Colors.white,
    this.foregroundColor = AppColor.blackShade1,
    this.gradient,
    this.border,
    this.boxShadow,
    this.labelStyle,
    this.loaderSize = 22,
    this.loaderStrokeWidth = 2.5,
  }) : assert(
         child != null ||
             icon != null ||
             iconAssetPath != null ||
             iconNetworkUrl != null,
         'Provide at least one of: child, icon, iconAssetPath, or iconNetworkUrl.',
       );

  @override
  State<SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<SocialLoginButton> {
  bool _pressed = false;

  bool get _isInteractive => widget.enabled && !widget.isLoading;

  void _onTapDown(TapDownDetails _) {
    if (_isInteractive) setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    if (_pressed) setState(() => _pressed = false);
  }

  void _onTapCancel() {
    if (_pressed) setState(() => _pressed = false);
  }

  void _onTap() {
    if (_isInteractive) widget.onTap();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _buildIcon() {
    if (widget.icon != null) return widget.icon!;

    if (widget.iconAssetPath != null) {
      return Image.asset(
        widget.iconAssetPath!,
        width: widget.iconSize,
        height: widget.iconSize,
        fit: BoxFit.contain,
      );
    }

    // iconNetworkUrl is guaranteed non-null here by the assert.
    return Image.network(
      widget.iconNetworkUrl!,
      width: widget.iconSize,
      height: widget.iconSize,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          widget.iconNetworkFallback ??
          Icon(Icons.image_not_supported_outlined, size: widget.iconSize),
    );
  }

  Widget _buildContent() {
    // Fully custom child takes priority.
    if (widget.child != null) return widget.child!;

    final iconWidget = _buildIcon();

    if (widget.label == null) return iconWidget;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        iconWidget,
        SizedBox(width: widget.iconLabelSpacing),
        Text(
          widget.label!,
          style: (widget.labelStyle ??
                  const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ))
              .copyWith(color: widget.foregroundColor),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedBorderRadius = widget.customBorderRadius ??
        BorderRadius.circular(widget.borderRadius);

    final double opacity = !widget.enabled
        ? 0.45
        : widget.isLoading
            ? 0.75
            : _pressed
                ? 0.82
                : 1.0;

    final double scale = _pressed && _isInteractive ? 0.975 : 1.0;

    final Border defaultBorder = Border.all(
      color: AppColor.lightGreyColor,
      width: 1.2,
    );

    return GestureDetector(
      onTap: _onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: widget.fullWidth ? double.infinity : widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.gradient != null ? null : widget.backgroundColor,
              gradient: widget.gradient,
              borderRadius: resolvedBorderRadius,
              border: widget.border ?? defaultBorder,
              boxShadow: widget.boxShadow,
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: widget.isLoading
                    ? _Loader(
                        key: const ValueKey('loader'),
                        size: widget.loaderSize,
                        strokeWidth: widget.loaderStrokeWidth,
                        color: widget.foregroundColor,
                      )
                    : KeyedSubtree(
                        key: const ValueKey('content'),
                        child: _buildContent(),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Loader extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color color;

  const _Loader({
    super.key,
    required this.size,
    required this.strokeWidth,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
