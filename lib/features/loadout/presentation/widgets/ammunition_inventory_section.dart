import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/ammunition.dart';
import '../bloc/loadout_bloc.dart';
import 'add_ammunition_dialog.dart';

class AmmunitionInventorySection extends StatelessWidget {
  final LoadoutLoaded state;

  const AmmunitionInventorySection({
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
                    'Ammunition Inventory',
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
                  onPressed: () => _showAddAmmoDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const FittedBox(child: Text('+ Add Ammo')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...state.ammunition.map((ammo) => _AmmunitionCard(ammunition: ammo)),
        ],
      ),
    );
  }

  void _showAddAmmoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddAmmunitionDialog(),
    );
  }
}

class _AmmunitionCard extends StatelessWidget {
  final Ammunition ammunition;

  const _AmmunitionCard({
    Key? key,
    required this.ammunition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ammunition Name
                      Text(
                        ammunition.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Basic Info Line
                      Text(
                        '${ammunition.caliber} • ${ammunition.bullet.weight ?? 'Unknown'} ${ammunition.bullet.type ?? ''} • G1 BC: ${ammunition.bullet.bc.g1?.toStringAsFixed(3) ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),

                      // Velocity and Lot Info
                      Text(
                        'Lot #${ammunition.lotNumber ?? 'Unknown'} • ${ammunition.velocity ?? 'Unknown'} fps MV • ${ammunition.tempStable ? 'Temp Stable' : 'Temp Sensitive'}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),

                      // Advanced Info (if available)
                      if (_hasAdvancedInfo(ammunition)) ...[
                        const SizedBox(height: 4),
                        Text(
                          _buildAdvancedInfoText(ammunition),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textTertiary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${ammunition.count}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.02),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    text: 'Edit',
                    onPressed: () => _handleEdit(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    text: 'Details',
                    onPressed: () => _showDetailsDialog(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    text: 'Delete',
                    onPressed: () => _handleDelete(context),
                    isDanger: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasAdvancedInfo(Ammunition ammo) {
    return ammo.cartridgeType != null ||
        ammo.caseMaterial != null ||
        ammo.primerType != null ||
        ammo.pressureClass != null ||
        ammo.sectionalDensity != null ||
        ammo.recoilEnergy != null ||
        ammo.powderCharge != null ||
        ammo.powderType != null ||
        ammo.chronographFPS != null;
  }

  String _buildAdvancedInfoText(Ammunition ammo) {
    final List<String> parts = [];

    if (ammo.cartridgeType != null) parts.add('${ammo.cartridgeType}');
    if (ammo.caseMaterial != null) parts.add('${ammo.caseMaterial} Case');
    if (ammo.primerType != null) parts.add('${ammo.primerType} Primer');
    if (ammo.pressureClass != null) parts.add('${ammo.pressureClass}');
    if (ammo.sectionalDensity != null) parts.add('SD: ${ammo.sectionalDensity!.toStringAsFixed(3)}');
    if (ammo.recoilEnergy != null) parts.add('${ammo.recoilEnergy!.toStringAsFixed(1)} ft-lbs');
    if (ammo.powderCharge != null && ammo.powderType != null) {
      parts.add('${ammo.powderCharge!.toStringAsFixed(1)}gr ${ammo.powderType}');
    } else if (ammo.powderType != null) {
      parts.add('${ammo.powderType}');
    }
    if (ammo.chronographFPS != null) parts.add('Chrono: ${ammo.chronographFPS} fps');

    return parts.join(' • ');
  }

  void _handleEdit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddAmmunitionDialog(
        editMode: true,
        existingAmmunition: ammunition,
      ),
    );
  }

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AmmunitionDetailsDialog(ammunition: ammunition),
    );
  }

  void _handleDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ammunition'),
        content: Text('Are you sure you want to delete ${ammunition.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<LoadoutBloc>().add(DeleteAmmunitionEvent(ammunition.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ammunition deleted successfully!'),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isDanger;

  const _ActionButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isDanger = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: isDanger ? AppTheme.danger : AppTheme.textPrimary,
        side: BorderSide(
          color: isDanger ? AppTheme.danger : AppTheme.borderColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDanger ? AppTheme.danger : AppTheme.textPrimary,
        ),
      ),
    );
  }
}

class _AmmunitionDetailsDialog extends StatelessWidget {
  final Ammunition ammunition;

  const _AmmunitionDetailsDialog({
    Key? key,
    required this.ammunition,
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
                      'Ammunition Details',
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
                        _DetailRow('Name', ammunition.name),
                        _DetailRow('Manufacturer', ammunition.manufacturer),
                        _DetailRow('Caliber', ammunition.caliber),
                        _DetailRow('Round Count', '${ammunition.count} rounds'),
                        if (ammunition.price != null) _DetailRow('Price per Round', '\$${ammunition.price!.toStringAsFixed(2)}'),
                        if (ammunition.lotNumber != null) _DetailRow('Lot Number', ammunition.lotNumber!),
                        _DetailRow('Temperature Stable', ammunition.tempStable ? 'Yes' : 'No'),
                        if (ammunition.notes != null) _DetailRow('Notes', ammunition.notes!),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Bullet Information
                    _buildDetailSection(
                      'Bullet Information',
                      [
                        if (ammunition.bullet.weight != null) _DetailRow('Weight', '${ammunition.bullet.weight} grains'),
                        if (ammunition.bullet.type != null) _DetailRow('Type', ammunition.bullet.type!),
                        if (ammunition.bullet.manufacturer != null) _DetailRow('Manufacturer', ammunition.bullet.manufacturer!),
                        if (ammunition.bullet.bc.g1 != null) _DetailRow('G1 BC', ammunition.bullet.bc.g1!.toStringAsFixed(3)),
                        if (ammunition.bullet.bc.g7 != null) _DetailRow('G7 BC', ammunition.bullet.bc.g7!.toStringAsFixed(3)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Ballistic Information
                    if (ammunition.velocity != null || ammunition.sectionalDensity != null || ammunition.recoilEnergy != null) ...[
                      _buildDetailSection(
                        'Ballistic Information',
                        [
                          if (ammunition.velocity != null) _DetailRow('Muzzle Velocity', '${ammunition.velocity} fps'),
                          if (ammunition.sectionalDensity != null) _DetailRow('Sectional Density', ammunition.sectionalDensity!.toStringAsFixed(3)),
                          if (ammunition.recoilEnergy != null) _DetailRow('Recoil Energy', '${ammunition.recoilEnergy!.toStringAsFixed(1)} ft-lbs'),
                          if (ammunition.chronographFPS != null) _DetailRow('Chronograph FPS', '${ammunition.chronographFPS} fps'),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Load Data Information
                    if (ammunition.cartridgeType != null || ammunition.caseMaterial != null || ammunition.primerType != null ||
                        ammunition.pressureClass != null || ammunition.powderCharge != null || ammunition.powderType != null) ...[
                      _buildDetailSection(
                        'Load Data Information',
                        [
                          if (ammunition.cartridgeType != null) _DetailRow('Cartridge Type', ammunition.cartridgeType!),
                          if (ammunition.caseMaterial != null) _DetailRow('Case Material', ammunition.caseMaterial!),
                          if (ammunition.primerType != null) _DetailRow('Primer Type', ammunition.primerType!),
                          if (ammunition.pressureClass != null) _DetailRow('Pressure Class', ammunition.pressureClass!),
                          if (ammunition.powderCharge != null) _DetailRow('Powder Charge', '${ammunition.powderCharge!.toStringAsFixed(1)} grains'),
                          if (ammunition.powderType != null) _DetailRow('Powder Type', ammunition.powderType!),
                          if (ammunition.primer != null) _DetailRow('Primer', ammunition.primer!),
                          if (ammunition.brass != null) _DetailRow('Brass', ammunition.brass!),
                          if (ammunition.powder != null) _DetailRow('Powder', ammunition.powder!),
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