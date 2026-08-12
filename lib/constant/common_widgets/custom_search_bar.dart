import 'package:flutter/material.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_text_form_field.dart';
import 'package:technicianapp/constant/common_widgets/debouncer.dart';

/// A reusable, fully-customisable search bar that wraps [CommonTextFormField].
///
/// Debounce is built-in — just pass [onSearch]. The debounce delay defaults to
/// 400 ms but can be overridden per screen via [debounceDuration].
///
/// ## Basic usage
/// ```dart
/// CustomSearchBar(
///   onSearch: (query) => controller.search(query),
/// )
/// ```
///
/// ## Custom debounce delay
/// ```dart
/// // Fast local filter — 200 ms
/// CustomSearchBar(
///   debounceDuration: Duration(milliseconds: 200),
///   onSearch: (query) => controller.filterLocally(query),
/// )
///
/// // Slow remote API — 700 ms
/// CustomSearchBar(
///   debounceDuration: Duration(milliseconds: 700),
///   onSearch: (query) => controller.fetchFromServer(query),
/// )
/// ```
///
/// ## Controlled mode (own controller)
/// ```dart
/// CustomSearchBar(
///   controller: _searchController,
///   onSearch: (query) => controller.search(query),
/// )
/// ```
class CustomSearchBar extends StatefulWidget {
  // ── Content ─────────────────────────────────────────────────────────────────

  /// Placeholder text inside the search field. Defaults to 'Search…'.
  final String hintText;

  // ── Controller / Focus ──────────────────────────────────────────────────────

  /// Optional external controller. If null, an internal one is created.
  final TextEditingController? controller;
  final FocusNode? focusNode;

  // ── Debounce ─────────────────────────────────────────────────────────────────

  /// How long to wait after the user stops typing before calling [onSearch].
  ///
  /// Defaults to 400 ms. Use a shorter value for local filtering (e.g. 200 ms)
  /// and a longer value for expensive API calls (e.g. 700 ms).
  final Duration debounceDuration;

  // ── Callbacks ───────────────────────────────────────────────────────────────

  /// Called with the current query after the debounce delay.
  /// Also called immediately with an empty string when the field is cleared.
  final ValueChanged<String>? onSearch;

  /// Called on every keystroke, without debounce. Useful for character counters
  /// or live validation feedback.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits (presses the search key on the keyboard).
  /// Fires immediately — bypasses the debounce timer.
  final ValueChanged<String>? onSubmitted;

  /// Called when the clear button is tapped.
  final VoidCallback? onClear;

  // ── Icons ────────────────────────────────────────────────────────────────────

  /// Leading icon. Defaults to [Icons.search].
  final IconData? prefixIcon;

  /// Replaces the default prefix icon with any widget (e.g. a back button).
  final Widget? prefixWidget;

  /// Whether to show the clear (×) button when the field has text.
  /// Defaults to true.
  final bool showClearButton;

  // ── Styling ──────────────────────────────────────────────────────────────────

  final Color backgroundColor;
  final Color borderColor;
  final Color focusedBorderColor;
  final double borderRadius;
  final double height;
  final double borderWidth;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final Color? prefixIconColor;
  final Color? clearIconColor;

  // ── Behaviour ────────────────────────────────────────────────────────────────

  /// Whether the search bar is read-only (e.g. tap-to-navigate pattern).
  final bool readOnly;

  /// Whether the search bar is enabled.
  final bool enabled;

  const CustomSearchBar({
    super.key,
    this.hintText = 'Search…',
    this.controller,
    this.focusNode,
    this.debounceDuration = const Duration(milliseconds: 400),
    this.onSearch,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.prefixIcon = Icons.search,
    this.prefixWidget,
    this.showClearButton = true,
    this.backgroundColor = Colors.white,
    this.borderColor = AppColor.lightGreyColor,
    this.focusedBorderColor = AppColor.brownAccentPrimary,
    this.borderRadius = 30,
    this.height = 52,
    this.borderWidth = 1.2,
    this.textStyle,
    this.hintStyle,
    this.prefixIconColor,
    this.clearIconColor,
    this.readOnly = false,
    this.enabled = true,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  late Debouncer _debouncer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _debouncer = Debouncer(delay: widget.debounceDuration);

    // Sync clear-button visibility when an external controller is provided.
    _controller.addListener(_onControllerChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  void _onControllerChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void didUpdateWidget(CustomSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the debounce duration changes at runtime, recreate the debouncer.
    if (oldWidget.debounceDuration != widget.debounceDuration) {
      _debouncer.cancel();
      _debouncer = Debouncer(delay: widget.debounceDuration);
    }
  }

  void _handleChanged(String value) {
    // Always fire raw onChanged synchronously.
    widget.onChanged?.call(value);

    // Fire onSearch after the debounce window.
    _debouncer.run(() => widget.onSearch?.call(value));
  }

  void _handleClear() {
    _controller.clear();
    _debouncer.cancel(); // discard any pending search for old text
    widget.onSearch?.call(''); // immediate clear notification
    widget.onClear?.call();
    setState(() => _hasText = false);
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _controller.removeListener(_onControllerChanged);
    // Only dispose the internal controller.
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonTextFormField(
      controller: _controller,
      focusNode: widget.focusNode,
      hintText: widget.hintText,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      autocorrect: false,
      enableSuggestions: false,
      backgroundColor: widget.backgroundColor,
      borderColor: widget.borderColor,
      focusedBorderColor: widget.focusedBorderColor,
      borderRadius: widget.borderRadius,
      height: widget.height,
      borderWidth: widget.borderWidth,
      textStyle: widget.textStyle ??
          AppTextStyle.titleSmallMedium.copyWith(color: AppColor.blackShade1),
      hintStyle: widget.hintStyle ??
          AppTextStyle.titleSmallMedium.copyWith(color: AppColor.coolGrayText),
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      // Prefix: custom widget takes priority over icon
      prefixWidget: widget.prefixWidget,
      prefixIcon: widget.prefixWidget == null ? (widget.prefixIcon ?? Icons.search) : null,
      // Suffix: clear button
      suffixIcon: (widget.showClearButton && _hasText && !widget.readOnly)
          ? _ClearButton(
              color: widget.clearIconColor ?? AppColor.coolGrayText,
              onTap: _handleClear,
            )
          : null,
      onChanged: _handleChanged,
      onFieldSubmitted: (value) {
        // On submit, cancel pending debounce and fire immediately.
        _debouncer.cancel();
        widget.onSearch?.call(value);
        widget.onSubmitted?.call(value);
      },
      onTap: widget.readOnly
          ? () {
              // Useful when readOnly is used as a tap-to-open pattern
              // (e.g. open a search delegate or bottom sheet).
            }
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ClearButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _ClearButton({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Icon(Icons.close, size: 18, color: color),
      ),
    );
  }
}
