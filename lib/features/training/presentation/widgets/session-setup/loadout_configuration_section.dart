// lib/features/training/presentation/widgets/session-setup/loadout_configuration_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../loadout/domain/entities/rifle.dart';
import '../../../domain/entities/session-setup/loadout_selection.dart';
import '../../bloc/training_bloc.dart';
import '../../bloc/training_event.dart';

class LoadoutConfigurationSection extends StatelessWidget {
  final LoadoutSelection loadoutSelection;
  final List<Rifle> availableRifles;
  final List<Rifle> availableRiflesWithAmmo;
  final List<Rifle> availableRiflesWithoutAmmo;
  final Rifle? activeRifle;
  final bool isCompleted;
  final VoidCallback onManageLoadout;

  const LoadoutConfigurationSection({
    Key? key,
    required this.loadoutSelection,
    required this.availableRifles,
    required this.availableRiflesWithAmmo,
    required this.availableRiflesWithoutAmmo,
    this.activeRifle,
    required this.isCompleted,
    required this.onManageLoadout,
  }) : super(key: key);

  // ✅ Helper method to get valid dropdown value
  String _getValidDropdownValue(
      BuildContext context,
      String? currentValue,
      List<Rifle> availableRiflesWithAmmo,
      List<Rifle> availableRiflesWithoutAmmo,
      ) {
    if (currentValue == null || currentValue.isEmpty) {
      return 'SELECT_RIFLE';
    }

    final bool existsInAvailableRifles = availableRiflesWithAmmo.any((rifle) => rifle.id == currentValue);

    if (existsInAvailableRifles) {
      return currentValue;
    }

    final bool existsButNoAmmo = availableRiflesWithoutAmmo.any((rifle) => rifle.id == currentValue);

    if (existsButNoAmmo) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selected rifle needs ammunition configuration. Please complete rifle profile.'),
              backgroundColor: AppTheme.warning,
              duration: Duration(seconds: 3),
            ),
          );
          context.read<TrainingBloc>().add(ClearActiveRifleEvent());
        }
      });
    }

    return 'SELECT_RIFLE';
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Column(
        children: [
// Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Loadout Configuration',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

// ✅ NEW: Section completion indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppTheme.success : AppTheme.borderColor,
                ),
                child: isCompleted
                    ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16
                )
                    : const Text(
                  '2',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(width: 8),

              IntrinsicWidth(
                child: ElevatedButton(
                  onPressed: onManageLoadout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: const FittedBox(
                    child: Text(
                      'Manage Loadout',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

// Loadout Dropdowns
          Column(
            children: [
              _buildConfigGroup(
                context: context,
                label: 'Active Rifle Profile',
                value: loadoutSelection.activeRifleId,
                availableRiflesWithAmmo: availableRiflesWithAmmo,
                availableRiflesWithoutAmmo: availableRiflesWithoutAmmo,
                helpText: 'This rifle will be used for training sessions',
              ),
            ],
          ),

// Active Loadout Display
          if (loadoutSelection.hasCompleteSetup && activeRifle != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8),
                border: const Border(
                  left: BorderSide(color: AppTheme.success, width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Training Setup',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryItem('Rifle:', activeRifle!.name),
                  _buildSummaryItem('Caliber:', activeRifle!.caliber),
                  _buildSummaryItem(
                      'Ammunition:',
                      activeRifle!.ammunition?.name ?? 'Not configured'
                  ),
                  if (activeRifle!.scope != null)
                    _buildSummaryItem(
                        'Scope:',
                        '${activeRifle!.scope!.manufacturer} ${activeRifle!.scope!.model}'
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfigGroup({
    required BuildContext context,
    required String label,
    required String? value,
    required List<Rifle> availableRiflesWithAmmo,
    required List<Rifle> availableRiflesWithoutAmmo,
    required String helpText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),

        DropdownButtonFormField<String>(
          value: _getValidDropdownValue(context, value, availableRiflesWithAmmo, availableRiflesWithoutAmmo),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppTheme.borderColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppTheme.borderColor, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            fillColor: AppTheme.surface,
            filled: true,
          ),
          items: [
// ✅ Default option
            const DropdownMenuItem<String>(
              value: 'SELECT_RIFLE',
              child: Text('Select rifle...'),
            ),

// ✅ Clear active rifle option if something is selected
            if (value != null && value.isNotEmpty)
              const DropdownMenuItem<String>(
                value: 'CLEAR_ACTIVE',
                child: Text(
                  '❌ Remove Active Rifle',
                  style: TextStyle(color: AppTheme.accent),
                ),
              ),

// ✅ Rifles with ammunition (selectable)
            ...availableRiflesWithAmmo.map((rifle) {
              return DropdownMenuItem<String>(
                value: rifle.id,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${rifle.name} (${rifle.caliber})'),
                    // Text(
                    //   '✓ Ready for training',
                    //   style: const TextStyle(
                    //     fontSize: 12,
                    //     color: AppTheme.success,
                    //   ),
                    // ),
                  ],
                ),
              );
            }),

// ✅ Rifles without ammunition (disabled with unique values)
            ...availableRiflesWithoutAmmo.asMap().entries.map((entry) {
              final int index = entry.key;
              final Rifle rifle = entry.value;
              return DropdownMenuItem<String>(
                value: 'DISABLED_RIFLE_$index', // Unique value for each disabled rifle
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${rifle.name} (${rifle.caliber})',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    const Text(
                      '⚠️ Complete rifle profile first',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.warning,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: (newValue) {
            if (newValue == 'CLEAR_ACTIVE') {
// Clear active rifle
              context.read<TrainingBloc>().add(ClearActiveRifleEvent());
            } else if (newValue != null && newValue != 'SELECT_RIFLE' && !newValue.startsWith('DISABLED_RIFLE_')) {
// Set new active rifle (only if it's a valid rifle ID)
              context.read<TrainingBloc>().add(SetActiveRifleEvent(rifleId: newValue));
            }
          },
          isExpanded: true,
        ),

        const SizedBox(height: 4),
        Text(
          helpText,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),

// ✅ Show rifle completion stats
        if (availableRiflesWithoutAmmo.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.warning, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${availableRiflesWithoutAmmo.length} rifle(s) need ammunition configuration',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}