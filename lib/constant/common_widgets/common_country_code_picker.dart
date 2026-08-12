import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';

/// A reusable country code picker widget that wraps [CountryCodePicker]
/// with a consistent pill/rounded border style matching the app design.
///
/// Usage:
/// ```dart
/// CommonCountryCodePicker(
///   onChanged: controller.onCountryChanged,
///   initialSelection: 'IN',
/// )
/// ```
///
/// Customise per screen by overriding [backgroundColor], [borderColor],
/// [height], [borderRadius], [textStyle], [flagWidth], and [favorite].
class CommonCountryCodePicker extends StatelessWidget {
  /// Called when the user selects a new country.
  final ValueChanged<CountryCode> onChanged;

  /// ISO 3166-1 alpha-2 code or dial-code for the default country.
  /// Defaults to India ('IN').
  final String initialSelection;

  /// List of countries to pin at the top of the dialog.
  /// Defaults to India.
  final List<String> favorite;

  /// Background fill of the picker container. Defaults to [Colors.white].
  final Color backgroundColor;

  /// Border color of the picker container. Defaults to [AppColor.lightGreyColor].
  final Color borderColor;

  /// Border width. Defaults to 1.2.
  final double borderWidth;

  /// Height of the picker container. Defaults to 52.
  final double height;

  /// Corner radius of the container. Defaults to 30 (pill shape).
  final double borderRadius;

  /// Text style for the dial-code label shown on the picker button.
  final TextStyle? textStyle;

  /// Text style used inside the country search dialog.
  final TextStyle? dialogTextStyle;

  /// Width of the flag image. Defaults to 24.
  final double flagWidth;

  /// Whether to show the dropdown arrow. Defaults to true.
  final bool showDropDownButton;

  const CommonCountryCodePicker({
    super.key,
    required this.onChanged,
    this.initialSelection = 'IN',
    this.favorite = const ['+91', 'IN'],
    this.backgroundColor = Colors.white,
    this.borderColor = AppColor.lightGreyColor,
    this.borderWidth = 1.2,
    this.height = 52,
    this.borderRadius = 30,
    this.textStyle,
    this.dialogTextStyle,
    this.flagWidth = 24,
    this.showDropDownButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedTextStyle = textStyle ??
        const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColor.blackShade1,
        );

    final resolvedDialogTextStyle = dialogTextStyle ??
        const TextStyle(
          fontSize: 14,
          color: AppColor.blackShade1,
        );

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: CountryCodePicker(
        onChanged: onChanged,
        initialSelection: initialSelection,
        favorite: favorite,
        showCountryOnly: false,
        showOnlyCountryWhenClosed: false,
        alignLeft: false,
        padding: EdgeInsets.zero,
        textStyle: resolvedTextStyle,
        dialogTextStyle: resolvedDialogTextStyle,
        searchStyle: resolvedDialogTextStyle,
        flagWidth: flagWidth,
        showDropDownButton: showDropDownButton,
        boxDecoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
