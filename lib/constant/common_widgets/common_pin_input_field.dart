import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';

/// A fully customisable OTP / PIN input row built without any external package.
///
/// Each digit gets its own [TextField]. Focus automatically advances to the
/// next cell on input and moves back on delete. The widget exposes:
///   - [onCompleted]  — called with the full code string when all cells are filled.
///   - [onChanged]    — called on every keystroke with the current partial/full code.
///   - [controller]   — optional external [TextEditingController] whose [text] is
///                      kept in sync with the concatenated pin value.
///   - [validator]    — optional [FormFieldValidator] for [Form]-level validation.
///
/// ```dart
/// CommonPinInputField(
///   length: 6,
///   onCompleted: (code) => controller.verifyOtp(code),
/// )
/// ```
class CommonPinInputField extends StatefulWidget {
  // ── Config ───────────────────────────────────────────────────────────────────

  /// Number of pin cells. Defaults to 6.
  final int length;

  /// Called when every cell has a digit, with the complete pin string.
  final ValueChanged<String>? onCompleted;

  /// Called on every keystroke with the current (possibly partial) pin.
  final ValueChanged<String>? onChanged;

  /// External controller whose [text] mirrors the pin value at all times.
  final TextEditingController? controller;

  /// Validation run when the parent [Form] validates.
  final FormFieldValidator<String>? validator;

  // ── Appearance ───────────────────────────────────────────────────────────────

  /// Size of each cell (width == height). Defaults to 52.
  final double cellSize;

  /// Gap between cells. Defaults to 10.
  final double spacing;

  /// Border radius of each cell. Defaults to 14.
  final double borderRadius;

  /// Border width. Defaults to 1.4.
  final double borderWidth;

  /// Cell background colour. Defaults to [Colors.white].
  final Color backgroundColor;

  /// Border colour when idle. Defaults to [AppColor.lightGreyColor].
  final Color borderColor;

  /// Border colour when a cell is focused. Defaults to [AppColor.brownAccentPrimary].
  final Color focusedBorderColor;

  /// Border colour when a cell is filled. Defaults to [AppColor.blackShade1].
  final Color filledBorderColor;

  /// Border colour on validation error. Defaults to [Colors.red].
  final Color errorBorderColor;

  /// Text style inside each cell. Defaults to bold 20px [AppColor.blackShade1].
  final TextStyle? digitStyle;

  /// Whether to obscure each digit (useful for PIN entry). Defaults to false.
  final bool obscureText;

  /// Character used to obscure digits. Defaults to '•'.
  final String obscuringCharacter;

  /// Whether the field is enabled. Defaults to true.
  final bool enabled;

  /// Keyboard type. Defaults to [TextInputType.number].
  final TextInputType keyboardType;

  const CommonPinInputField({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.controller,
    this.validator,
    this.cellSize = 52,
    this.spacing = 10,
    this.borderRadius = 14,
    this.borderWidth = 1.4,
    this.backgroundColor = Colors.white,
    this.borderColor = AppColor.lightGreyColor,
    this.focusedBorderColor = AppColor.brownAccentPrimary,
    this.filledBorderColor = AppColor.blackShade1,
    this.errorBorderColor = Colors.red,
    this.digitStyle,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.enabled = true,
    this.keyboardType = TextInputType.number,
  }) : assert(length > 0, 'length must be greater than 0');

  @override
  State<CommonPinInputField> createState() => _CommonPinInputFieldState();
}

class _CommonPinInputFieldState extends State<CommonPinInputField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  // Tracks which cell is currently focused for border styling.
  int _focusedIndex = -1;

  // Tracks validation error message.
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());

    for (int i = 0; i < widget.length; i++) {
      _focusNodes[i].addListener(() {
        setState(() {
          _focusedIndex = _focusNodes[i].hasFocus ? i : _focusedIndex;
          if (!_focusNodes.any((n) => n.hasFocus)) _focusedIndex = -1;
        });
      });
    }
  }

  // ── Value helpers ─────────────────────────────────────────────────────────

  String get _currentValue =>
      _controllers.map((c) => c.text).join();

  bool get _isFilled => _currentValue.length == widget.length;

  void _syncExternalController() {
    if (widget.controller != null) {
      widget.controller!.text = _currentValue;
    }
  }

  // ── Input handling ────────────────────────────────────────────────────────

  void _onChanged(int index, String value) {
    if (value.isEmpty) {
      // Backspace — move focus back.
      _controllers[index].clear();
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    } else {
      // If multiple digits pasted, distribute across cells.
      if (value.length > 1) {
        _paste(value);
        return;
      }
      // Keep only the last character typed (in case system inserts extra).
      _controllers[index].text = value[value.length - 1];
      _controllers[index].selection = TextSelection.fromPosition(
        TextPosition(offset: 1),
      );
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    final pin = _currentValue;
    _syncExternalController();
    widget.onChanged?.call(pin);
    if (_isFilled) widget.onCompleted?.call(pin);

    // Clear inline error as user types.
    if (_errorMessage != null) setState(() => _errorMessage = null);
  }

  void _paste(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    for (int i = 0; i < widget.length && i < digits.length; i++) {
      _controllers[i].text = digits[i];
    }
    // Focus the cell after the last pasted digit.
    final nextFocus = digits.length < widget.length ? digits.length : widget.length - 1;
    _focusNodes[nextFocus].requestFocus();

    final pin = _currentValue;
    _syncExternalController();
    widget.onChanged?.call(pin);
    if (_isFilled) widget.onCompleted?.call(pin);
    setState(() {});
  }

  // ── Key event — handle backspace on already-empty cell ────────────────────

  KeyEventResult _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      _syncExternalController();
      widget.onChanged?.call(_currentValue);
      setState(() {});
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // ── Public API — clear all cells ──────────────────────────────────────────

  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _syncExternalController();
    setState(() => _errorMessage = null);
  }

  // ── Border colour per cell ────────────────────────────────────────────────

  Color _borderColor(int index) {
    if (_errorMessage != null) return widget.errorBorderColor;
    if (_focusedIndex == index) return widget.focusedBorderColor;
    if (_controllers[index].text.isNotEmpty) return widget.filledBorderColor;
    return widget.borderColor;
  }

  // ── Validation ────────────────────────────────────────────────────────────

  String? _validate(String? value) {
    // Built-in: all cells must be filled.
    final pin = _currentValue;
    if (pin.length < widget.length) {
      return 'Please enter the complete ${widget.length}-digit code';
    }
    // Custom validator.
    return widget.validator?.call(pin);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedDigitStyle = (widget.digitStyle ??
            AppTextStyle.titleSmallMedium.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ))
        .copyWith(color: AppColor.blackShade1);

    return FormField<String>(
      validator: _validate,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) {
        // Sync FormField error into local state for border styling.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && field.errorText != _errorMessage) {
            setState(() => _errorMessage = field.errorText);
          }
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── PIN cells ──────────────────────────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final totalSpacing = widget.spacing * (widget.length - 1);
                final maxCellSize = (constraints.maxWidth - totalSpacing) / widget.length;
                final cellSize = maxCellSize < widget.cellSize ? maxCellSize : widget.cellSize;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.length, (index) {
                    final isLast = index == widget.length - 1;
                    return Row(
                      children: [
                        _PinCell(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          size: cellSize,
                          borderRadius: widget.borderRadius,
                          borderWidth: widget.borderWidth,
                          borderColor: _borderColor(index),
                          backgroundColor: widget.backgroundColor,
                          digitStyle: resolvedDigitStyle,
                          obscureText: widget.obscureText,
                          obscuringCharacter: widget.obscuringCharacter,
                          enabled: widget.enabled,
                          keyboardType: widget.keyboardType,
                          onChanged: (v) => _onChanged(index, v),
                          onKeyEvent: (e) => _onKeyEvent(index, e),
                        ),
                        if (!isLast) SizedBox(width: widget.spacing),
                      ],
                    );
                  }),
                );
              },
            ),

            // ── Error text ─────────────────────────────────────────────────
            if (field.errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  field.errorText!,
                  style: AppTextStyle.bodySmallRegular.copyWith(
                    color: Colors.red.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── Private single cell ──────────────────────────────────────────────────────

class _PinCell extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final double size;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final Color backgroundColor;
  final TextStyle digitStyle;
  final bool obscureText;
  final String obscuringCharacter;
  final bool enabled;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final KeyEventResult Function(KeyEvent) onKeyEvent;

  const _PinCell({
    required this.controller,
    required this.focusNode,
    required this.size,
    required this.borderRadius,
    required this.borderWidth,
    required this.borderColor,
    required this.backgroundColor,
    required this.digitStyle,
    required this.obscureText,
    required this.obscuringCharacter,
    required this.enabled,
    required this.keyboardType,
    required this.onChanged,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: KeyboardListener(
        focusNode: FocusNode(skipTraversal: true),
        onKeyEvent: onKeyEvent,
        child: Center(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textAlign: TextAlign.center,
            maxLength: 1,
            obscureText: obscureText,
            obscuringCharacter: obscuringCharacter,
            enabled: enabled,
            style: digitStyle,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }
}
