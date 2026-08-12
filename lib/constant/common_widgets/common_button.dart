import 'package:flutter/material.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';

/// A fully customisable button built on [GestureDetector] + [AnimatedContainer].
/// Every visual property can be overridden per screen.
///
/// ─── Usage examples ────────────────────────────────────────────────────────
///
/// 1. Simple label (primary, full-width):
/// ```dart
/// CommonButton(
///   label: 'Sign In',
///   onTap: controller.handleLogin,
///   isLoading: controller.isLoading.value,
/// )
/// ```
///
/// 2. Outlined / ghost style:
/// ```dart
/// CommonButton(
///   label: 'Cancel',
///   onTap: () => Get.back(),
///   backgroundColor: Colors.transparent,
///   foregroundColor: AppColor.blackShade1,
///   border: Border.all(color: AppColor.lightGreyColor, width: 1.4),
/// )
/// ```
///
/// 3. Gradient background:
/// ```dart
/// CommonButton(
///   label: 'Continue',
///   onTap: controller.next,
///   gradient: LinearGradient(
///     colors: [AppColor.brownAccentDark, AppColor.brownAccentPrimary],
///   ),
/// )
/// ```
///
/// 4. Icon + label:
/// ```dart
/// CommonButton(
///   label: 'Google',
///   onTap: controller.handleGoogleLogin,
///   leadingIcon: Image.asset('assets/google.png', height: 20),
///   backgroundColor: Colors.white,
///   foregroundColor: AppColor.blackShade1,
///   border: Border.all(color: AppColor.lightGreyColor),
/// )
/// ```
///
/// 5. Fully custom child:
/// ```dart
/// CommonButton(
///   onTap: () {},
///   child: Row(children: [Icon(Icons.apple), SizedBox(width: 8), Text('Apple')]),
/// )
/// ```
///
/// 6. Compact / wrap-width:
/// ```dart
/// CommonButton(
///   label: 'View',
///   onTap: () {},
///   fullWidth: false,
///   height: 40,
///   borderRadius: 12,
/// )
/// ```
class CommonButton extends StatefulWidget {
  // ── Content ──────────────────────────────────────────────────────────────────

  /// Simple text label. Ignored when [child] is provided.
  final String? label;

  /// Fully custom widget rendered inside the button.
  /// When provided, [label], [leadingIcon], [trailingIcon], and [textStyle]
  /// are all ignored.
  final Widget? child;

  // ── Interaction ───────────────────────────────────────────────────────────────

  /// Called on tap when [isLoading] is false and [enabled] is true.
  final VoidCallback? onTap;

  /// Shows a spinner and blocks interaction.
  final bool isLoading;

  /// Disables the button entirely (no tap, dimmed appearance).
  final bool enabled;

  // ── Size ──────────────────────────────────────────────────────────────────────

  /// Stretches to full available width when true (default).
  final bool fullWidth;

  /// Explicit width. Ignored when [fullWidth] is true.
  final double? width;

  /// Button height. Defaults to 52.
  final double height;

  /// Horizontal padding inside the button. Defaults to 24.
  final double paddingHorizontal;

  /// Vertical padding inside the button (only applies when [height] is null).
  final double paddingVertical;

  // ── Shape ──────────────────────────────────────────────────────────────────────

  /// Corner radius. Defaults to 30 (pill shape).
  final double borderRadius;

  /// Use a [BorderRadius] directly for asymmetric corners.
  /// Overrides [borderRadius] when provided.
  final BorderRadius? customBorderRadius;

  // ── Colour / decoration ───────────────────────────────────────────────────────

  /// Solid background colour. Ignored when [gradient] is provided.
  /// Defaults to [AppColor.blackColor].
  final Color? backgroundColor;

  /// Label / icon / spinner colour. Defaults to [Colors.white].
  final Color? foregroundColor;

  /// Gradient background. Takes priority over [backgroundColor].
  final Gradient? gradient;

  /// Optional box shadow list.
  final List<BoxShadow>? boxShadow;

  /// Border around the button container.
  final Border? border;

  // ── Typography ────────────────────────────────────────────────────────────────

  /// Override the default label text style.
  /// Colour is always forced to [foregroundColor].
  final TextStyle? textStyle;

  // ── Icons ─────────────────────────────────────────────────────────────────────

  /// Widget shown to the left of [label].
  final Widget? leadingIcon;

  /// Gap between [leadingIcon] and [label]. Defaults to 8.
  final double leadingSpacing;

  /// Widget shown to the right of [label].
  final Widget? trailingIcon;

  /// Gap between [label] and [trailingIcon]. Defaults to 8.
  final double trailingSpacing;

  // ── Spinner ───────────────────────────────────────────────────────────────────

  /// Size of the loading spinner. Defaults to 22.
  final double loaderSize;

  /// Stroke width of the loading spinner. Defaults to 2.5.
  final double loaderStrokeWidth;

  const CommonButton({
    super.key,
    this.label,
    this.child,
    required this.onTap,
    this.isLoading = false,
    this.enabled = true,
    this.fullWidth = true,
    this.width,
    this.height = 52,
    this.paddingHorizontal = 10,
    this.paddingVertical = 10,
    this.borderRadius = 30,
    this.customBorderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.boxShadow,
    this.border,
    this.textStyle,
    this.leadingIcon,
    this.leadingSpacing = 8,
    this.trailingIcon,
    this.trailingSpacing = 8,
    this.loaderSize = 22,
    this.loaderStrokeWidth = 2.5,
  }) : assert(
         label != null || child != null,
         'Provide either a label or a child widget.',
       );

  @override
  State<CommonButton> createState() => _CommonButtonState();
}

class _CommonButtonState extends State<CommonButton> {
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
    if (_isInteractive) widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppColor.blackColor;
    final fgColor = widget.foregroundColor ?? Colors.white;

    final resolvedBorderRadius =
        widget.customBorderRadius ?? BorderRadius.circular(widget.borderRadius);

    // Opacity: dimmed when loading or disabled; slight press-down effect.
    final double opacity = !widget.enabled
        ? 0.45
        : widget.isLoading
        ? 0.75
        : _pressed
        ? 0.82
        : 1.0;

    // Scale: subtle press-down shrink.
    final double scale = _pressed && _isInteractive ? 0.975 : 1.0;

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
            alignment: AlignmentGeometry.center,
            duration: const Duration(milliseconds: 150),
            width: widget.fullWidth ? double.infinity : widget.width,
            height: widget.height,
            padding: EdgeInsets.symmetric(
              horizontal: widget.paddingHorizontal,
              vertical: widget.paddingVertical,
            ),
            decoration: BoxDecoration(
              color: widget.gradient != null ? null : bgColor,
              gradient: widget.gradient,
              borderRadius: resolvedBorderRadius,
              border: widget.border,
              boxShadow:
                  widget.boxShadow ??
                  (widget.enabled && !widget.isLoading
                      ? [
                          BoxShadow(
                            color: bgColor.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: widget.isLoading
                    ? _Loader(
                        key: const ValueKey('loader'),
                        size: widget.loaderSize,
                        strokeWidth: widget.loaderStrokeWidth,
                        color: fgColor,
                      )
                    : (widget.child != null
                          ? KeyedSubtree(
                              key: const ValueKey('custom'),
                              child: widget.child!,
                            )
                          : _LabelRow(
                              key: const ValueKey('label'),
                              label: widget.label!,
                              style:
                                  (widget.textStyle ?? AppTextStyle.buttonLarge)
                                      .copyWith(color: fgColor),
                              leadingIcon: widget.leadingIcon,
                              leadingSpacing: widget.leadingSpacing,
                              trailingIcon: widget.trailingIcon,
                              trailingSpacing: widget.trailingSpacing,
                            )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Private helpers ──────────────────────────────────────────────────────────

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

class _LabelRow extends StatelessWidget {
  final String label;
  final TextStyle style;
  final Widget? leadingIcon;
  final double leadingSpacing;
  final Widget? trailingIcon;
  final double trailingSpacing;

  const _LabelRow({
    super.key,
    required this.label,
    required this.style,
    this.leadingIcon,
    required this.leadingSpacing,
    this.trailingIcon,
    required this.trailingSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          leadingIcon!,
          SizedBox(width: leadingSpacing),
        ],
        Text(label, style: style),
        if (trailingIcon != null) ...[
          SizedBox(width: trailingSpacing),
          trailingIcon!,
        ],
      ],
    );
  }
}
