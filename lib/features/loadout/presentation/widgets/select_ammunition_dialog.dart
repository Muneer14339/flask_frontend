// lib/features/Loadout/presentation/widgets/select_ammunition_dialog.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/ammunition.dart';

class SelectAmmunitionDialog extends StatefulWidget {
  final List<Ammunition> availableAmmunition;
  final Ammunition? currentAmmunition;
  final Function(Ammunition?) onAmmunitionSelected;

  const SelectAmmunitionDialog({
    Key? key,
    required this.availableAmmunition,
    this.currentAmmunition,
    required this.onAmmunitionSelected,
  }) : super(key: key);

  @override
  State<SelectAmmunitionDialog> createState() => _SelectAmmunitionDialogState();
}

class _SelectAmmunitionDialogState extends State<SelectAmmunitionDialog> {
  Ammunition? selectedAmmunition;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    selectedAmmunition = widget.currentAmmunition;
  }

  List<Ammunition> get filteredAmmunition {
    if (searchQuery.isEmpty) {
      return widget.availableAmmunition;
    }

    return widget.availableAmmunition.where((ammo) {
      final searchLower = searchQuery.toLowerCase();
      return ammo.name.toLowerCase().contains(searchLower) ||
          ammo.manufacturer.toLowerCase().contains(searchLower) ||
          ammo.caliber.toLowerCase().contains(searchLower) ||
          (ammo.bullet.type?.toLowerCase().contains(searchLower) ?? false);
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
                    'Select Ammunition',
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
                  hintText: 'Search ammunition...',
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

            // No Ammunition Option
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedAmmunition == null ? AppTheme.primary : AppTheme.borderColor,
                    width: selectedAmmunition == null ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.cancel, color: AppTheme.textSecondary),
                  title: const Text('No Ammunition'),
                  subtitle: const Text('Remove ammunition assignment'),
                  trailing: selectedAmmunition == null
                      ? const Icon(Icons.check_circle, color: AppTheme.success)
                      : null,
                  onTap: () {
                    setState(() {
                      selectedAmmunition = null;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Ammunition List
            Expanded(
              child: filteredAmmunition.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: AppTheme.textSecondary),
                    SizedBox(height: 16),
                    Text(
                      'No ammunition found',
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
                itemCount: filteredAmmunition.length,
                itemBuilder: (context, index) {
                  final ammo = filteredAmmunition[index];
                  final isSelected = selectedAmmunition?.id == ammo.id;

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
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight.withOpacity(0.1),
                          borderRadius: AppTheme.radiusSmall,
                        ),
                        child: Center(
                          child: Text(
                            '${ammo.count}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        ammo.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${ammo.caliber} • ${ammo.bullet.weight ?? 'Unknown'} ${ammo.bullet.type ?? ''}',
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                          Text(
                            '${ammo.manufacturer} • ${ammo.count} rounds • ${ammo.tempStable ? 'Temp Stable' : 'Temp Sensitive'}',
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                          if (ammo.velocity != null)
                            Text(
                              '${ammo.velocity} fps MV • G1 BC: ${ammo.bullet.bc.g1?.toStringAsFixed(3) ?? 'N/A'}',
                              style: const TextStyle(color: AppTheme.textTertiary, fontSize: 12),
                            ),
                        ],
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppTheme.success)
                          : null,
                      isThreeLine: true,
                      onTap: () {
                        setState(() {
                          selectedAmmunition = ammo;
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
                        widget.onAmmunitionSelected(selectedAmmunition);
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