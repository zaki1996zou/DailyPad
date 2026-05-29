import 'package:fc_app3_dailypad/app/theme.dart';
import 'package:flutter/material.dart';

/// Search field that keeps a stable [TextField] instance so iOS keyboard focus
/// is not lost when the clear button appears.
class SearchTextField extends StatefulWidget {
  const SearchTextField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Search notes...',
    this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;
  final VoidCallback? onClear;

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  static const _fieldKey = ValueKey<String>('dailypad_search_field');

  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    _showClear = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_handleControllerChange);
  }

  @override
  void didUpdateWidget(SearchTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChange);
      widget.controller.addListener(_handleControllerChange);
      _showClear = widget.controller.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);
    super.dispose();
  }

  void _handleControllerChange() {
    final show = widget.controller.text.isNotEmpty;
    if (show != _showClear) {
      setState(() => _showClear = show);
    }
  }

  void _clear() {
    widget.controller.clear();
    widget.onChanged('');
    widget.onClear?.call();
    if (_showClear) {
      setState(() => _showClear = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: _fieldKey,
      controller: widget.controller,
      onChanged: widget.onChanged,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      autocorrect: false,
      enableSuggestions: false,
      scrollPadding: const EdgeInsets.only(bottom: 120),
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _showClear
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clear,
                tooltip: 'Clear search',
              )
            : null,
        fillColor: AppTheme.cardColor(context),
      ),
    );
  }
}
