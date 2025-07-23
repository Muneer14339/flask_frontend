// lib/features/loadout/presentation/widgets/maintenance_schedule_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/maintenance.dart';
import '../bloc/loadout_bloc.dart';
import 'add_maintenance_dialog.dart';

class MaintenanceScheduleSection extends StatelessWidget {
  final LoadoutLoaded state;

  const MaintenanceScheduleSection({
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
                  child: Row(
                    children: [
                      Text(
                        '🎯 ',
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        'Maintenance Tracker',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IntrinsicWidth(
                child: ElevatedButton(
                  onPressed: () => _showAddMaintenanceDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const FittedBox(child: Text('+ Add Task')),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Show message if no maintenance tasks
          if (state.maintenance.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.build_outlined,
                    size: 48,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No Maintenance Tasks',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add maintenance tasks to keep track of your equipment care',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...state.maintenance.map((maintenance) => _MaintenanceItem(
                  maintenance: maintenance,
                )),
        ],
      ),
    );
  }

  void _showAddMaintenanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddMaintenanceDialog(),
    );
  }
}

class _MaintenanceItem extends StatelessWidget {
  final Maintenance maintenance;

  const _MaintenanceItem({
    Key? key,
    required this.maintenance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUrgent = _isMaintenanceOverdue();
    final status = _getMaintenanceStatus();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUrgent ? AppTheme.accent.withOpacity(0.05) : null,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: isUrgent
                  ? Border(left: BorderSide(color: AppTheme.accent, width: 4))
                  : null,
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _getMaintenanceIcon(),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and loadout name
                      Text(
                        maintenance.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getLoadoutName(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Component type
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getComponentColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getComponentDisplayName(),
                          style: TextStyle(
                            fontSize: 11,
                            color: _getComponentColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Due text
                      Text(
                        _getMaintenanceDueText(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Last completed
                      Text(
                        _getLastCompletedText(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Status and Actions
                Column(
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // More options button
                    GestureDetector(
                      onTap: () => _showMaintenanceOptions(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.textSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppTheme.textSecondary.withOpacity(0.3),
                              width: 1),
                        ),
                        child: const Icon(
                          Icons.more_horiz,
                          color: AppTheme.textSecondary,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons
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
                    text: 'Complete',
                    icon: Icons.check,
                    onPressed: () => _completeMaintenance(context),
                    color: AppTheme.success,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    text: 'Details',
                    icon: Icons.info,
                    onPressed: () => _showDetails(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLoadoutName() {
    // Extract loadout name from notes if it contains "Loadout: "
    return maintenance.type;
  }

  String _getComponentDisplayName() {
    switch (maintenance.type) {
      case 'rifle':
        return '🔫 Rifle';
      case 'scope':
        return '🔭 Scope';
      case 'ammunition':
        return '🎯 Ammunition';
      case 'accessories':
        return '🔧 Accessories';
      default:
        return maintenance.type.toUpperCase();
    }
  }

  Color _getComponentColor() {
    switch (maintenance.type) {
      case 'rifle':
        return const Color(0xFF8B4513); // Brown
      case 'scope':
        return const Color(0xFF4A90E2); // Blue
      case 'ammunition':
        return const Color(0xFFE74C3C); // Red
      case 'accessories':
        return const Color(0xFF27AE60); // Green
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getMaintenanceIcon() {
    switch (maintenance.type) {
      case 'rifle':
        return '🔫';
      case 'scope':
        return '🔭';
      case 'ammunition':
        return '🎯';
      case 'accessories':
        return '🔧';
      default:
        return '⚙️';
    }
  }

  bool _isMaintenanceOverdue() {
    if (maintenance.lastCompleted == null) return false;

    final now = DateTime.now();
    final lastCompleted = maintenance.lastCompleted!;

    switch (maintenance.interval.unit) {
      case 'days':
        return now.difference(lastCompleted).inDays >
            maintenance.interval.value;
      case 'weeks':
        return now.difference(lastCompleted).inDays >
            (maintenance.interval.value * 7);
      case 'months':
        return now.difference(lastCompleted).inDays >
            (maintenance.interval.value * 30);
      default:
        return false;
    }
  }

  String _getMaintenanceStatus() {
    final now = DateTime.now();

    // Use createdAt when lastCompleted is null, otherwise use lastCompleted
    final referenceDate = maintenance.lastCompleted ?? maintenance.createdAt;

    if (referenceDate == null) {
      return 'New';
    } // Handle case where both dates are null

    switch (maintenance.interval.unit) {
      case 'days':
        final daysDiff = now.difference(referenceDate).inDays;
        if (daysDiff > maintenance.interval.value) return 'Overdue';
        if (daysDiff > (maintenance.interval.value * 0.8)) return 'Due Soon';
        return 'OK';
      case 'weeks':
        final daysDiff = now.difference(referenceDate).inDays;
        final weeksDiff = daysDiff / 7;
        if (weeksDiff > maintenance.interval.value) return 'Overdue';
        if (weeksDiff > (maintenance.interval.value * 0.8)) return 'Due Soon';
        return 'OK';
      case 'months':
        final daysDiff = now.difference(referenceDate).inDays;
        final monthsDiff = daysDiff / 30;
        if (monthsDiff > maintenance.interval.value) return 'Overdue';
        if (monthsDiff > (maintenance.interval.value * 0.8)) return 'Due Soon';
        return 'OK';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor() {
    final status = _getMaintenanceStatus();
    switch (status) {
      case 'Overdue':
        return AppTheme.accent;
      case 'Due Soon':
        return AppTheme.warning;
      case 'OK':
        return AppTheme.success;
      case 'New':
        return AppTheme.info;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getMaintenanceDueText() {
    return 'Due: Every ${maintenance.interval.value} ${maintenance.interval.unit}';
  }

  String _getLastCompletedText() {
    if (maintenance.lastCompleted == null) {
      return 'Last: Never completed';
    }

    final now = DateTime.now();
    final lastCompleted = maintenance.lastCompleted!;
    final daysDiff = now.difference(lastCompleted).inDays;

    String timeSince;
    if (daysDiff == 0) {
      timeSince = 'Today';
    } else if (daysDiff == 1) {
      timeSince = '1 day ago';
    } else if (daysDiff < 30) {
      timeSince = '$daysDiff days ago';
    } else {
      final monthsDiff = (daysDiff / 30).round();
      timeSince = '$monthsDiff month${monthsDiff > 1 ? 's' : ''} ago';
    }

    return 'Last: $timeSince';
  }

  void _showMaintenanceOptions(BuildContext context) {
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
                Text(
                  _getMaintenanceIcon(),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    maintenance.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.check_circle, color: AppTheme.success),
              title: const Text('Mark as Complete'),
              subtitle: const Text('Record this maintenance as completed'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _completeMaintenance(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info, color: AppTheme.textSecondary),
              title: const Text('View Details'),
              subtitle: const Text('See full maintenance information'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showDetails(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: AppTheme.danger),
              title: const Text('Delete Task',
                  style: TextStyle(color: AppTheme.danger)),
              subtitle: const Text('Remove this maintenance task'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _deleteMaintenance(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _completeMaintenance(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Maintenance'),
        content: Text('Mark "${maintenance.title}" as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context
                  .read<LoadoutBloc>()
                  .add(CompleteMaintenanceEvent(maintenance.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Maintenance completed!'),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _MaintenanceDetailsDialog(maintenance: maintenance),
    );
  }

  // lib/features/loadout/presentation/widgets/maintenance_schedule_section.dart
  void _deleteMaintenance(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Maintenance Task'),
        content: Text(
            'Are you sure you want to delete "${maintenance.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<LoadoutBloc>().add(DeleteMaintenanceEvent(
                  maintenance.id)); // NEW: Dispatch event
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Maintenance task deleted'),
                  backgroundColor: AppTheme.danger,
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
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const _ActionButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(text, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color ?? AppTheme.borderColor),
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }
}

class _MaintenanceDetailsDialog extends StatelessWidget {
  final Maintenance maintenance;

  const _MaintenanceDetailsDialog({
    Key? key,
    required this.maintenance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  _getMaintenanceIcon(),
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        maintenance.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                      Text(
                        _getLoadoutName(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const Divider(height: 32),

            // Details
            _DetailRow(label: 'Component', value: _getComponentDisplayName()),
            _DetailRow(
                label: 'Schedule',
                value:
                    'Every ${maintenance.interval.value} ${maintenance.interval.unit}'),

            if (maintenance.lastCompleted != null)
              _DetailRow(
                  label: 'Last Completed',
                  value: _formatDate(maintenance.lastCompleted!))
            else
              _DetailRow(label: 'Last Completed', value: 'Never'),

            if (maintenance.notes != null &&
                !maintenance.notes!.startsWith('Loadout: ')) ...[
              const SizedBox(height: 16),
              const Text(
                'Notes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Text(
                  maintenance.notes!.contains('\n')
                      ? maintenance.notes!.split('\n').skip(1).join('\n')
                      : maintenance.notes!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLoadoutName() {
    // Extract loadout name from notes if it contains "Loadout: "
      return maintenance.type;
  }

  String _getComponentDisplayName() {
    switch (maintenance.type) {
      case 'rifle':
        return '🔫 Rifle';
      case 'scope':
        return '🔭 Scope/Optics';
      case 'ammunition':
        return '🎯 Ammunition';
      case 'accessories':
        return '🔧 Accessories';
      default:
        return maintenance.type.toUpperCase();
    }
  }

  String _getMaintenanceIcon() {
    switch (maintenance.type) {
      case 'rifle':
        return '🔫';
      case 'scope':
        return '🔭';
      case 'ammunition':
        return '🎯';
      case 'accessories':
        return '🔧';
      default:
        return '⚙️';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).round();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (difference / 30).round();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
