import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';

/// Validation helper — call these directly in the [validator] param or
/// chain them using [CommonValidators.compose].
///
/// ```dart
/// validator: CommonValidators.compose([
///   CommonValidators.required(),
///   CommonValidators.email(),
/// ]),
/// ```
class CommonValidators {
  CommonValidators._();

  /// Field must not be empty.
  static FormFieldValidator<String> required({
    String message = 'This field is required',
  }) =>
      (v) => (v == null || v.trim().isEmpty) ? message : null;

  /// Must be a valid email address.
  static FormFieldValidator<String> email({
    String message = 'Enter a valid email address',
  }) =>
      (v) {
        if (v == null || v.trim().isEmpty) return null; // let required() catch empty
        final emailRegex = RegExp(r'^[\w.+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
        return emailRegex.hasMatch(v.trim()) ? null : message;
      };

  /// Must be exactly [length] digits (default 10 for Indian numbers).
  static FormFieldValidator<String> phone({
    int length = 10,
    String? message,
  }) =>
      (v) {
        if (v == null || v.trim().isEmpty) return null;
        final digits = v.trim().replaceAll(RegExp(r'\D'), '');
        return digits.length == length
            ? null
            : message ?? 'Enter a valid $length-digit phone number';
      };

  /// Minimum character length.
  static FormFieldValidator<String> minLength(
    int min, {
    String? message,
  }) =>
      (v) {
        if (v == null || v.isEmpty) return null;
        return v.length >= min
            ? null
            : message ?? 'Minimum $min characters required';
      };

  /// Maximum character length.
  static FormFieldValidator<String> maxLength(
    int max, {
    String? message,
  }) =>
      (v) {
        if (v == null || v.isEmpty) return null;
        return v.length <= max
            ? null
            : message ?? 'Maximum $max characters allowed';
      };

  static FormFieldValidator<String> strongPassword({
    String message =
    'Password must contain uppercase, lowercase, number, special character and be at least 8 characters',
  }) =>
          (v) {
        if (v == null || v.isEmpty) return null;

        final regex = RegExp(
          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$',
        );

        return regex.hasMatch(v) ? null : message;
      };

  /// Must contain at least one uppercase letter.
  static FormFieldValidator<String> hasUppercase({
    String message = 'Must contain at least one uppercase letter',
  }) =>
      (v) {
        if (v == null || v.isEmpty) return null;
        return v.contains(RegExp(r'[A-Z]')) ? null : message;
      };

  /// Must contain at least one digit.
  static FormFieldValidator<String> hasDigit({
    String message = 'Must contain at least one number',
  }) =>
      (v) {
        if (v == null || v.isEmpty) return null;
        return v.contains(RegExp(r'[0-9]')) ? null : message;
      };

  /// Must contain at least one special character.
  static FormFieldValidator<String> hasSpecialChar({
    String message = 'Must contain at least one special character',
  }) =>
      (v) {
        if (v == null || v.isEmpty) return null;
        return v.contains(RegExp(r'[!@#\$&*~%^()\-_=+\[\]{};:,.<>?/\\|`]'))
            ? null
            : message;
      };

  /// Value must match [other] (useful for confirm-password).
  static FormFieldValidator<String> match(
    String Function() other, {
    String message = 'Fields do not match',
  }) =>
      (v) => v == other() ? null : message;

  /// Custom regex validator.
  static FormFieldValidator<String> pattern(
    String pattern, {
    String message = 'Invalid format',
  }) =>
      (v) {
        if (v == null || v.trim().isEmpty) return null;
        return RegExp(pattern).hasMatch(v.trim()) ? null : message;
      };

  /// Chains multiple validators. Returns the first non-null error message.
  static FormFieldValidator<String> compose(
    List<FormFieldValidator<String>> validators,
  ) =>
      (v) {
        for (final validator in validators) {
          final result = validator(v);
          if (result != null) return result;
        }
        return null;
      };
}

// ─────────────────────────────────────────────────────────────────────────────

/// A reusable, fully customisable [TextFormField] wrapped in the app's
/// pill/rounded border container style.
///
/// ## Basic usage
/// ```dart
/// CommonTextFormField(
///   hintText: 'Email',
///   prefixIcon: Icons.email_outlined,
///   validator: CommonValidators.compose([
///     CommonValidators.required(),
///     CommonValidators.email(),
///   ]),
/// )
/// ```
///
/// ## Password field
/// ```dart
/// CommonTextFormField.password(
///   controller: controller.passwordController,
///   isObscured: controller.isPasswordVisible.obs,   // RxBool
///   onToggleObscure: controller.togglePasswordVisibility,
/// )
/// ```
///
/// ## Phone field
/// ```dart
/// CommonTextFormField.phone(
///   controller: controller.phoneController,
/// )
/// ```
class CommonTextFormField extends StatefulWidget {
  // ── Content ─────────────────────────────────────────────────────────────────

  /// Optional label shown above the field.
  final String? label;

  /// Placeholder text inside the field.
  final String? hintText;

  /// Text shown below the field on validation error.
  /// Overrides [validator] error text when both are set.
  final String? errorText;

  /// Helper text shown below the field when there is no error.
  final String? helperText;

  // ── Controller / Focus ──────────────────────────────────────────────────────

  final TextEditingController? controller;
  final FocusNode? focusNode;

  // ── Keyboard / Input ────────────────────────────────────────────────────────

  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool autocorrect;
  final bool enableSuggestions;
  final int? maxLength;
  final int maxLines;
  final int minLines;

  // ── Obscure (password) ──────────────────────────────────────────────────────

  /// Whether the text is hidden. Use [onToggleObscure] to wire a toggle button.
  final bool obscureText;

  /// Custom widget for the suffix toggle (replaces built-in eye icon).
  final Widget? suffixIcon;

  /// Called when the built-in eye icon is tapped.
  /// When provided, a visibility toggle icon is rendered automatically.
  final VoidCallback? onToggleObscure;

  // ── Icons / Decoration ──────────────────────────────────────────────────────

  final IconData? prefixIcon;
  final Widget? prefixWidget;

  // ── Styling ─────────────────────────────────────────────────────────────────

  /// Container background. Defaults to [Colors.white].
  final Color backgroundColor;

  /// Border color when idle. Defaults to [AppColor.lightGreyColor].
  final Color borderColor;

  /// Border color when focused. Defaults to [AppColor.brownAccentPrimary].
  final Color focusedBorderColor;

  /// Border color on error. Defaults to [Colors.red].
  final Color errorBorderColor;

  /// Border width. Defaults to 1.2.
  final double borderWidth;

  /// Container height. Defaults to 52.
  final double height;

  /// Corner radius. Defaults to 30 (pill shape).
  final double borderRadius;

  /// Input text style. Defaults to [AppTextStyle.titleSmallMedium] in [AppColor.blackShade1].
  final TextStyle? textStyle;

  /// Hint text style. Defaults to [AppTextStyle.titleSmallMedium] in [AppColor.coolGrayText].
  final TextStyle? hintStyle;

  /// Label text style above the field.
  final TextStyle? labelStyle;

  /// Horizontal padding inside the field. Defaults to 18.
  final double contentHorizontalPadding;

  /// Vertical padding inside the field. Defaults to 14.
  final double contentVerticalPadding;

  // ── Callbacks ───────────────────────────────────────────────────────────────

  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool enabled;

  const CommonTextFormField({
    super.key,
    this.label,
    this.hintText,
    this.errorText,
    this.helperText,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLength,
    this.maxLines = 1,
    this.minLines = 1,
    this.obscureText = false,
    this.suffixIcon,
    this.onToggleObscure,
    this.prefixIcon,
    this.prefixWidget,
    this.backgroundColor = Colors.white,
    this.borderColor = AppColor.lightGreyColor,
    this.focusedBorderColor = AppColor.brownAccentPrimary,
    this.errorBorderColor = Colors.red,
    this.borderWidth = 1.2,
    this.height = 52,
    this.borderRadius = 30,
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.contentHorizontalPadding = 18,
    this.contentVerticalPadding = 14,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
  });

  // ── Named constructors ──────────────────────────────────────────────────────

  /// Pre-configured password field with built-in visibility toggle.
  ///
  /// Pass [obscureText] as a reactive bool (from your controller) and
  /// [onToggleObscure] to flip it.
  factory CommonTextFormField.password({
    Key? key,
    String? label,
    String hintText = 'Password',
    TextEditingController? controller,
    FocusNode? focusNode,
    bool obscureText = true,
    VoidCallback? onToggleObscure,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
    TextInputAction textInputAction = TextInputAction.done,
    Color backgroundColor = Colors.white,
    Color borderColor = AppColor.lightGreyColor,
    Color focusedBorderColor = AppColor.brownAccentPrimary,
    double borderRadius = 30,
    double height = 52,
  }) =>
      CommonTextFormField(
        key: key,
        label: label,
        hintText: hintText,
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.visiblePassword,
        textInputAction: textInputAction,
        obscureText: obscureText,
        onToggleObscure: onToggleObscure,
        autocorrect: false,
        enableSuggestions: false,
        validator: validator,
        onChanged: onChanged,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        focusedBorderColor: focusedBorderColor,
        borderRadius: borderRadius,
        height: height,
      );

  /// Pre-configured phone number field (numeric keyboard, 10-digit formatter).
  factory CommonTextFormField.phone({
    Key? key,
    String? label,
    String hintText = 'Phone Number',
    TextEditingController? controller,
    FocusNode? focusNode,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
    TextInputAction textInputAction = TextInputAction.next,
    Color backgroundColor = Colors.white,
    Color borderColor = AppColor.lightGreyColor,
    Color focusedBorderColor = AppColor.brownAccentPrimary,
    double borderRadius = 30,
    double height = 52,
  }) =>
      CommonTextFormField(
        key: key,
        label: label,
        hintText: hintText.tr,
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.phone,
        textInputAction: textInputAction,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        validator: validator ??
            CommonValidators.compose([
              CommonValidators.required(message: 'Phone number is required'),
              CommonValidators.phone(),
            ]),
        onChanged: onChanged,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        focusedBorderColor: focusedBorderColor,
        borderRadius: borderRadius,
        height: height,
      );

  /// Pre-configured email field.
  factory CommonTextFormField.email({
    Key? key,
    String? label,
    String hintText = 'Email Address',
    TextEditingController? controller,
    FocusNode? focusNode,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
    Color backgroundColor = Colors.white,
    Color borderColor = AppColor.lightGreyColor,
    Color focusedBorderColor = AppColor.brownAccentPrimary,
    double borderRadius = 30,
    double height = 52,
  }) =>
      CommonTextFormField(
        key: key,
        label: label,
        hintText: hintText.tr,
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autocorrect: false,
        enableSuggestions: false,
        prefixIcon: Icons.email_outlined,
        validator: validator ??
            CommonValidators.compose([
              CommonValidators.required(message: 'Email is required'),
              CommonValidators.email(),
            ]),
        onChanged: onChanged,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        focusedBorderColor: focusedBorderColor,
        borderRadius: borderRadius,
        height: height,
      );

  @override
  State<CommonTextFormField> createState() => _CommonTextFormFieldState();
}

// ─────────────────────────────────────────────────────────────────────────────

class _CommonTextFormFieldState extends State<CommonTextFormField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  Color get _activeBorderColor {
    if (_errorMessage != null || widget.errorText != null) {
      return widget.errorBorderColor;
    }
    if (_isFocused) return widget.focusedBorderColor;
    return widget.borderColor;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.removeListener(_onFocusChange);
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTextStyle = (widget.textStyle ?? AppTextStyle.titleSmallMedium)
        .copyWith(color: AppColor.blackShade1);

    final resolvedHintStyle = (widget.hintStyle ?? AppTextStyle.titleSmallMedium)
        .copyWith(color: AppColor.coolGrayText);

    final isMultiline = widget.maxLines > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Optional label ───────────────────────────────────────────────────
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: widget.labelStyle ??
                AppTextStyle.titleSmallSemiBold.copyWith(
                  color: AppColor.blackShade1,
                ),
          ),
          const SizedBox(height: 6),
        ],

        // ── Input container ──────────────────────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: isMultiline ? null : widget.height,
          decoration: BoxDecoration(
            color: widget.enabled
                ? widget.backgroundColor
                : AppColor.lightGreyColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(
              isMultiline ? 16 : widget.borderRadius,
            ),
            border: Border.all(
              color: _activeBorderColor,
              width: widget.borderWidth,
            ),
          ),
          child: isMultiline
              ? TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  inputFormatters: widget.inputFormatters,
                  autocorrect: widget.autocorrect,
                  enableSuggestions: widget.enableSuggestions,
                  maxLength: widget.maxLength,
                  maxLines: widget.maxLines,
                  minLines: widget.minLines,
                  readOnly: widget.readOnly,
                  enabled: widget.enabled,
                  style: resolvedTextStyle,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  onChanged: widget.onChanged,
                  onFieldSubmitted: widget.onFieldSubmitted,
                  onTap: widget.onTap,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) {
                    final error = widget.validator?.call(v) ?? widget.errorText;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _errorMessage = error);
                    });
                    return error;
                  },
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: resolvedHintStyle,
                    border: InputBorder.none,
                    errorBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    errorStyle: const TextStyle(height: 0, fontSize: 0),
                    counterText: '',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: widget.contentHorizontalPadding,
                      vertical: widget.contentVerticalPadding,
                    ),
                    prefixIcon: _buildPrefix(),
                    suffixIcon: _buildSuffix(),
                  ),
                )
              : Center(
                  child: TextFormField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    inputFormatters: widget.inputFormatters,
                    autocorrect: widget.autocorrect,
                    enableSuggestions: widget.enableSuggestions,
                    maxLength: widget.maxLength,
                    maxLines: 1,
                    obscureText: widget.obscureText,
                    readOnly: widget.readOnly,
                    enabled: widget.enabled,
                    style: resolvedTextStyle,
                    textAlignVertical: TextAlignVertical.center,
                    onChanged: widget.onChanged,
                    onFieldSubmitted: widget.onFieldSubmitted,
                    onTap: widget.onTap,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (v) {
                      final error =
                          widget.validator?.call(v) ?? widget.errorText;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) setState(() => _errorMessage = error);
                      });
                      return error;
                    },
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: resolvedHintStyle,
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      errorStyle: const TextStyle(height: 0, fontSize: 0),
                      counterText: '',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: widget.contentHorizontalPadding,
                        vertical: 0,
                      ),
                      prefixIcon: _buildPrefix(),
                      suffixIcon: _buildSuffix(),
                    ),
                  ),
                ),
        ),

        // ── Error / Helper text ──────────────────────────────────────────────
        _ErrorHelperText(
          errorText: _errorMessage ?? widget.errorText,
          helperText: widget.helperText,
        ),
      ],
    );
  }

  Widget? _buildPrefix() {
    if (widget.prefixWidget != null) return widget.prefixWidget;
    if (widget.prefixIcon != null) {
      return Icon(
        widget.prefixIcon,
        size: 20,
        color: _isFocused ? widget.focusedBorderColor : AppColor.coolGrayText,
      );
    }
    return null;
  }

  Widget? _buildSuffix() {
    // Custom suffix widget takes priority
    if (widget.suffixIcon != null) return widget.suffixIcon;

    // Built-in password toggle
    if (widget.onToggleObscure != null) {
      return IconButton(
        icon: Icon(
          widget.obscureText
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: AppColor.coolGrayText,
          size: 20,
        ),
        onPressed: widget.onToggleObscure,
        splashRadius: 20,
      );
    }
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ErrorHelperText extends StatelessWidget {
  final String? errorText;
  final String? helperText;

  const _ErrorHelperText({this.errorText, this.helperText});

  @override
  Widget build(BuildContext context) {
    final text = errorText ?? helperText;
    if (text == null) return const SizedBox.shrink();

    final isError = errorText != null;

    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 14),
      child: Text(
        text,
        style: AppTextStyle.bodySmallRegular.copyWith(
          color: isError ? Colors.red.shade600 : AppColor.coolGrayText,
        ),
      ),
    );
  }
}
