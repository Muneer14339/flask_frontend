// lib/core/widgets/searchable_dropdown.dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class SearchableDropdown extends StatefulWidget {
  final String? selectedValue;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final List<String> Function(String) onSearch;
  final String hintText;
  final String? Function(String?)? validator;

  const SearchableDropdown({
    Key? key,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
    required this.onSearch,
    this.hintText = 'Select option...',
    this.validator,
  }) : super(key: key);

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _searchController = TextEditingController();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  List<String> _filteredOptions = [];

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
    if (widget.selectedValue != null) {
      _searchController.text = widget.selectedValue!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isOpen = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredOptions = widget.onSearch(query);
    });

    // Update overlay if it's open
    if (_isOpen) {
      _overlayEntry?.markNeedsBuild();
    }
  }

  void _selectOption(String option) {
    setState(() {
      _searchController.text = option;
    });
    widget.onChanged(option);
    _closeDropdown();
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 4,
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 4.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search field inside dropdown
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        isDense: true,
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  const Divider(height: 1),
                  // Options list
                  Flexible(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _filteredOptions.length,
                      itemBuilder: (context, index) {
                        final option = _filteredOptions[index];
                        final isSpecial = option.startsWith('+ Add New');

                        return InkWell(
                          onTap: () => _selectOption(option),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: widget.selectedValue == option
                                  ? AppTheme.primary.withOpacity(0.1)
                                  : null,
                            ),
                            child: Text(
                              option,
                              style: TextStyle(
                                color: isSpecial ? AppTheme.accent : AppTheme.textPrimary,
                                fontWeight: isSpecial ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: FormField<String>(
          validator: widget.validator,
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: field.hasError ? AppTheme.danger : AppTheme.borderColor,
                      width: field.hasError ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(
                    controller: _searchController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      suffixIcon: Icon(
                        _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: AppTheme.textSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    onTap: _toggleDropdown,
                  ),
                ),
                if (field.hasError) ...[
                  const SizedBox(height: 4),
                  Text(
                    field.errorText!,
                    style: const TextStyle(
                      color: AppTheme.danger,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}