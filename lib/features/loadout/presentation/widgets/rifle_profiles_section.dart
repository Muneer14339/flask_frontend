// lib/features/loadout/presentation/widgets/rifle_profiles_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/rifle.dart';
import '../../domain/entities/ammunition.dart';
import '../bloc/loadout_bloc.dart';
import '../pages/ballistic_data_view_page.dart';

import '../pages/ballistic_tools_page.dart';
import 'add_rifle_dialog.dart';
import 'select_scope_dialog.dart';
import 'select_ammunition_dialog.dart';

class RifleProfilesSection extends StatelessWidget {
  final LoadoutLoaded state;

  const RifleProfilesSection({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rifle Profiles',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IntrinsicWidth(
                child: ElevatedButton(
                  onPressed: () => _showAddRifleDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const FittedBox(child: Text('+ Add Rifle')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...state.rifles
              .map((rifle) => _RifleCard(rifle: rifle, state: state)),
        ],
      ),
    );
  }

  void _showAddRifleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddRifleDialog(),
    );
  }
}

class _RifleCard extends StatelessWidget {
  final Rifle rifle;
  final LoadoutLoaded state;

  const _RifleCard({
    Key? key,
    required this.rifle,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rifle.isActive
            ? AppTheme.background // AppTheme.success.withOpacity(0.05)
            : AppTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: rifle.isActive
            ? null //Border.all(color: AppTheme.success, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: const Text(
              '🎯',
              style: TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1st line: Rifle basic info
                Text(
                  rifle.brand,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${rifle.manufacturer} ${rifle.model} • ${rifle.caliber} • ${rifle.barrel.length ?? 'Unknown'}" Barrel',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),

                // 2nd line: Scope info (only if scope is not null)
                if (rifle.scope != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Scope: ${rifle.scope!.manufacturer} ${rifle.scope!.model}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],

                // 3rd line: Ammunition info (only if ammunition is not null)
                if (rifle.ammunition != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Ammo: ${rifle.ammunition!.name} • ${rifle.ammunition!.count} rounds',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],

              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'details',
                child: Row(
                  children: [
                    Icon(Icons.info, size: 18),
                    SizedBox(width: 8),
                    Text('Details'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'ballistics',
                child: Row(
                  children: [
                    Icon(Icons.calculate, size: 18),
                    SizedBox(width: 8),
                    Text('Ballistics'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'more',
                child: Row(
                  children: [
                    Icon(Icons.more_horiz, size: 18),
                    SizedBox(width: 8),
                    Text('More'),
                  ],
                ),
              ),
            ],
            child: const Icon(
              Icons.more_vert,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        _showEditOptions(context);
        break;
      case 'details':
        _showDetailsDialog(context);
        break;
      case 'ballistics':
        _navigateToBallisticViewPage(context);
        break;
      case 'more':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('More options coming soon!'),
            backgroundColor: AppTheme.primary,
          ),
        );
        break;
    }
  }

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _RifleDetailsDialog(rifle: rifle),
    );
  }

  void _showEditOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Edit ${rifle.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Update Scope
            ListTile(
              leading:
              const Icon(Icons.camera_alt, color: AppTheme.textSecondary),
              title: const Text('Update Scope'),
              subtitle: Text(
                rifle.scope != null
                    ? 'Current: ${rifle.scope!.manufacturer} ${rifle.scope!.model}'
                    : 'No scope assigned',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showSelectScopeDialog(context);
              },
            ),

            const Divider(),

            // Update Ammunition
            ListTile(
              leading: const Icon(Icons.adjust, color: AppTheme.textSecondary),
              title: const Text('Update Ammunition'),
              subtitle: Text(
                rifle.ammunition != null
                    ? 'Current: ${rifle.ammunition!.name}'
                    : 'No ammunition assigned',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showSelectAmmunitionDialog(context);
              },
            ),

            const Divider(),

            // Update Rifle Details
            ListTile(
              leading:
              const Icon(Icons.settings, color: AppTheme.textSecondary),
              title: const Text('Update Rifle Details'),
              subtitle:
              const Text('Edit rifle specifications and configuration'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showEditRifleDialog(context);
              },
            ),

            const Divider(),
            // Update Rifle Details
            ListTile(
              leading:
              const Icon(Icons.settings, color: AppTheme.textSecondary),
              title: const Text('Update Ballistics Tools'),
              subtitle:
              const Text('Edit Ballistics Tools '),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _navigateToBallisticTools(context);
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSelectScopeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SelectScopeDialog(
        availableScopes: state.scopes,
        currentScope: rifle.scope,
        onScopeSelected: (scope) {
          // Immediately update BLoC state
          context.read<LoadoutBloc>().add(
            UpdateRifleScopeEvent(rifleId: rifle.id, scope: scope),
          );

          // Show immediate feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                scope != null
                    ? 'Scope updated to ${scope.manufacturer} ${scope.model}'
                    : 'Scope removed from rifle',
              ),
              backgroundColor: AppTheme.success,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _showSelectAmmunitionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SelectAmmunitionDialog(
        availableAmmunition: state.ammunition,
        currentAmmunition: rifle.ammunition,
        onAmmunitionSelected: (ammunition) {
          // Immediately update BLoC state
          context.read<LoadoutBloc>().add(
            UpdateRifleAmmunitionEvent(
                rifleId: rifle.id, ammunition: ammunition),
          );

          // Show immediate feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ammunition != null
                    ? 'Ammunition updated to ${ammunition.name}'
                    : 'Ammunition removed from rifle',
              ),
              backgroundColor: AppTheme.success,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _showEditRifleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddRifleDialog(
        editMode: true,
        existingRifle: rifle,
      ),
    );
  }

  void _navigateToBallisticTools(BuildContext context) {
    // Get available ammunition for this rifle's caliber
    final availableAmmunition = rifle.ammunition;

    if (availableAmmunition==null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No ammunition available for ${rifle.caliber}. Please add ammunition first.'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BallisticToolsPage(
          rifle: rifle,
          availableAmmunition: availableAmmunition,
        ),
      ),
    );
  }

  void _navigateToBallisticViewPage(BuildContext context) {
    // Get available ammunition for this rifle's caliber
    final availableAmmunition = rifle.ammunition;

    if (availableAmmunition==null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No ammunition available for ${rifle.caliber}. Please add ammunition first.'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BallisticDataViewPage(
          rifle: rifle,
          ammunition: availableAmmunition,
        ),
      ),
    );
  }
}

class _RifleDetailsDialog extends StatelessWidget {
  final Rifle rifle;

  const _RifleDetailsDialog({
    Key? key,
    required this.rifle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Rifle Details',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information
                    _buildDetailSection(
                      'Basic Information',
                      [
                        _DetailRow('Name', rifle.name),
                        _DetailRow('Brand', rifle.brand),
                        _DetailRow('Manufacturer', rifle.manufacturer),
                        _DetailRow('Model', rifle.model),
                        _DetailRow('Generation/Variant', rifle.generationVariant),
                        _DetailRow('Caliber', rifle.caliber),
                        _DetailRow('Status', rifle.isActive ? 'Active' : 'Inactive'),
                        if (rifle.serialNumber != null) _DetailRow('Serial Number', rifle.serialNumber!),
                        if (rifle.overallLength != null) _DetailRow('Overall Length', rifle.overallLength!),
                        if (rifle.weight != null) _DetailRow('Weight', rifle.weight!),
                        if (rifle.capacity != null) _DetailRow('Capacity', rifle.capacity!),
                        if (rifle.finish != null) _DetailRow('Finish', rifle.finish!),
                        if (rifle.purchaseDate != null) _DetailRow('Purchase Date', rifle.purchaseDate!),
                        if (rifle.notes != null) _DetailRow('Notes', rifle.notes!),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Barrel Information
                    _buildDetailSection(
                      'Barrel Information',
                      [
                        if (rifle.barrel.length != null) _DetailRow('Length', '${rifle.barrel.length}"'),
                        if (rifle.barrel.twist != null) _DetailRow('Twist Rate', rifle.barrel.twist!),
                        if (rifle.barrel.threading != null) _DetailRow('Threading', rifle.barrel.threading!),
                        if (rifle.barrel.material != null) _DetailRow('Material', rifle.barrel.material!),
                        if (rifle.barrel.profile != null) _DetailRow('Profile', rifle.barrel.profile!),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Action Information
                    _buildDetailSection(
                      'Action Information',
                      [
                        if (rifle.action.type != null) _DetailRow('Type', rifle.action.type!),
                        if (rifle.action.trigger != null) _DetailRow('Trigger', rifle.action.trigger!),
                        if (rifle.action.triggerWeight != null) _DetailRow('Trigger Weight', rifle.action.triggerWeight!),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Stock Information
                    _buildDetailSection(
                      'Stock Information',
                      [
                        if (rifle.stock.manufacturer != null) _DetailRow('Manufacturer', rifle.stock.manufacturer!),
                        if (rifle.stock.model != null) _DetailRow('Model', rifle.stock.model!),
                        _DetailRow('Adjustable LOP', rifle.stock.adjustableLOP ? 'Yes' : 'No'),
                        _DetailRow('Adjustable Cheek Rest', rifle.stock.adjustableCheekRest ? 'Yes' : 'No'),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Scope Information
                    if (rifle.scope != null) ...[
                      _buildDetailSection(
                        'Mounted Scope',
                        [
                          _DetailRow('Manufacturer', rifle.scope!.manufacturer),
                          _DetailRow('Model', rifle.scope!.model),
                          if (rifle.scope!.tubeSize != null) _DetailRow('Tube Size', rifle.scope!.tubeSize!),
                          if (rifle.scope!.focalPlane != null) _DetailRow('Focal Plane', rifle.scope!.focalPlane!),
                          if (rifle.scope!.reticle != null) _DetailRow('Reticle', rifle.scope!.reticle!),
                          if (rifle.scope!.trackingUnits != null) _DetailRow('Tracking Units', rifle.scope!.trackingUnits!),
                          if (rifle.scope!.clickValue != null) _DetailRow('Click Value', rifle.scope!.clickValue!),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Ammunition Information
                    if (rifle.ammunition != null) ...[
                      _buildDetailSection(
                        'Loaded Ammunition',
                        [
                          _DetailRow('Name', rifle.ammunition!.name),
                          _DetailRow('Manufacturer', rifle.ammunition!.manufacturer),
                          _DetailRow('Caliber', rifle.ammunition!.caliber),
                          _DetailRow('Count', '${rifle.ammunition!.count} rounds'),
                          if (rifle.ammunition!.bullet.weight != null) _DetailRow('Bullet Weight', '${rifle.ammunition!.bullet.weight} grains'),
                          if (rifle.ammunition!.bullet.type != null) _DetailRow('Bullet Type', rifle.ammunition!.bullet.type!),
                          if (rifle.ammunition!.velocity != null) _DetailRow('Muzzle Velocity', '${rifle.ammunition!.velocity} fps'),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Sight Information
                    if (rifle.sightType != null || rifle.sightOptic != null || rifle.sightModel != null || rifle.sightHeight != null) ...[
                      _buildDetailSection(
                        'Sight Information',
                        [
                          if (rifle.sightType != null) _DetailRow('Sight Type', rifle.sightType!),
                          if (rifle.sightOptic != null) _DetailRow('Sight Optic', rifle.sightOptic!),
                          if (rifle.sightModel != null) _DetailRow('Sight Model', rifle.sightModel!),
                          if (rifle.sightHeight != null) _DetailRow('Sight Height', rifle.sightHeight!),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Modifications
                    if (rifle.modifications != null) ...[
                      _buildDetailSection(
                        'Modifications',
                        [
                          _DetailRow('Modifications', rifle.modifications!),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Close Button
            Container(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> details) {
    if (details.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            children: details,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}