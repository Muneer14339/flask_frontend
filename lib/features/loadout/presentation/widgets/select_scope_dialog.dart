// lib/features/Loadout/presentation/widgets/select_scope_dialog.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/scope.dart';

class SelectScopeDialog extends StatefulWidget {
  final List<Scope> availableScopes;
  final Scope? currentScope;
  final Function(Scope?) onScopeSelected;

  const SelectScopeDialog({
    Key? key,
    required this.availableScopes,
    this.currentScope,
    required this.onScopeSelected,
  }) : super(key: key);

  @override
  State<SelectScopeDialog> createState() => _SelectScopeDialogState();
}

class _SelectScopeDialogState extends State<SelectScopeDialog> {
  Scope? selectedScope;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    selectedScope = widget.currentScope;
  }

  List<Scope> get filteredScopes {
    if (searchQuery.isEmpty) {
      return widget.availableScopes;
    }

    return widget.availableScopes.where((scope) {
      final searchLower = searchQuery.toLowerCase();
      return scope.manufacturer.toLowerCase().contains(searchLower) ||
          scope.model.toLowerCase().contains(searchLower) ||
          (scope.reticle?.toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // Header
            Container(
              padding: AppTheme.paddingMedium,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Scope',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Search Field
            Padding(
              padding: AppTheme.paddingMedium,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search scopes...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: AppTheme.radiusMedium,
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppTheme.radiusMedium,
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppTheme.radiusMedium,
                    borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),

            // No Scope Option
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedScope == null ? AppTheme.primary : AppTheme.borderColor,
                    width: selectedScope == null ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.cancel, color: AppTheme.textSecondary),
                  title: const Text('No Scope'),
                  subtitle: const Text('Remove scope assignment'),
                  trailing: selectedScope == null
                      ? const Icon(Icons.check_circle, color: AppTheme.success)
                      : null,
                  onTap: () {
                    setState(() {
                      selectedScope = null;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Scope List
            Expanded(
              child: filteredScopes.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: AppTheme.textSecondary),
                    SizedBox(height: 16),
                    Text(
                      'No scopes found',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredScopes.length,
                itemBuilder: (context, index) {
                  final scope = filteredScopes[index];
                  final isSelected = selectedScope?.id == scope.id;

                  return Container(
                    margin: AppTheme.paddingVerticalSmall.copyWith(left: 16, right: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: AppTheme.radiusMedium,
                      color: isSelected ? AppTheme.primary.withOpacity(0.05) : AppTheme.surface,
                    ),
                    child: ListTile(
                      leading: const Text('🔭', style: TextStyle(fontSize: 24)),
                      title: Text(
                        '${scope.manufacturer} ${scope.model}',
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${scope.focalPlane ?? 'Unknown'} • ${scope.reticle ?? 'Unknown'}',
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                          Text(
                            '${scope.tubeSize ?? 'Unknown'} Tube • ${scope.clickValue ?? 'Unknown'} Clicks',
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppTheme.success)
                          : null,
                      isThreeLine: true,
                      onTap: () {
                        setState(() {
                          selectedScope = scope;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            // Bottom Actions
            Container(
              padding: AppTheme.paddingMedium,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppTheme.borderColor),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: AppTheme.paddingVerticalMedium,
                        side: const BorderSide(color: AppTheme.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.radiusMedium,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onScopeSelected(selectedScope);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: AppTheme.paddingVerticalMedium,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.radiusMedium,
                        ),
                      ),
                      child: const Text('Select'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}