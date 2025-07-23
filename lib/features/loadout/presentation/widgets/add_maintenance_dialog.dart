// lib/features/loadout/presentation/widgets/add_maintenance_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/maintenance.dart';
import '../../data/repositories/csv_repository.dart';
import '../bloc/loadout_bloc.dart';

class AddMaintenanceDialog extends StatefulWidget {
  const AddMaintenanceDialog({Key? key}) : super(key: key);

  @override
  State<AddMaintenanceDialog> createState() => _AddMaintenanceDialogState();
}

class _AddMaintenanceDialogState extends State<AddMaintenanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _csvRepository = CSVRepositoryImpl();

  // Form controllers
  final _loadoutNameController = TextEditingController();
  final _notesController = TextEditingController();
  final _intervalValueController = TextEditingController();

  // Selection state
  String? _selectedComponentType;
  String? _selectedMaintenanceTask;
  String? _selectedIntervalUnit;
  String? _selectedTaskIcon;

  // Data
  List<String> _availableComponents = [];
  List<Map<String, String>> _availableTasks = [];
  bool _isLoading = true;

  final List<String> _intervalUnits = [
    'days',
    'weeks',
    'months',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIntervalUnit = 'days';
    _intervalValueController.text = '7';
    _loadMaintenanceData();
  }

  @override
  void dispose() {
    _loadoutNameController.dispose();
    _notesController.dispose();
    _intervalValueController.dispose();
    super.dispose();
  }

  Future<void> _loadMaintenanceData() async {
    try {
      final maintenanceTasks = await _csvRepository.getMaintenanceTasks();
      final components = maintenanceTasks
          .map((e) => e.component)
          .toSet()
          .toList()
        ..sort();

      setState(() {
        _availableComponents = components;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading maintenance data: $e'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  Future<void> _updateAvailableTasks() async {
    if (_selectedComponentType == null) return;

    try {
      final maintenanceTasks = await _csvRepository.getMaintenanceTasks();
      final tasks = maintenanceTasks
          .where((e) => e.component == _selectedComponentType)
          .map((e) => {'task': e.task, 'icon': e.icon})
          .toList();

      setState(() {
        _availableTasks = tasks;
        _selectedMaintenanceTask = null;
        _selectedTaskIcon = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading tasks: $e'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.75,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Add Task',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Maintenance Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Loadout Name
                      _buildTextField(
                        controller: _loadoutNameController,
                        label: 'Loadout Name *',
                        hintText: 'e.g., Match Rifle, PRS Rifle',
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                      ),

                      const SizedBox(height: 16),

                      // Component Type
                      _buildDropdown(
                        label: 'Component Type *',
                        value: _selectedComponentType,
                        items: [
                          ..._availableComponents,
                          '+ Add New Component'
                        ],
                        onChanged: (value) {
                          if (value == '+ Add New Component') {
                            _showAddComponentDialog();
                            return;
                          }
                          setState(() {
                            _selectedComponentType = value;
                          });
                          _updateAvailableTasks();
                        },
                        validator: (value) => value == null
                            ? 'Please select a component type'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // Maintenance Task
                      _buildDropdown(
                        label: 'Maintenance Task *',
                        value: _selectedMaintenanceTask,
                        items: [
                          ..._availableTasks.map((e) => e['task']!),
                          if (_availableTasks.isNotEmpty) '+ Add New Task'
                        ],
                        onChanged: (value) {
                          if (value == '+ Add New Task') {
                            _showAddTaskDialog();
                            return;
                          }
                          final selectedTask = _availableTasks
                              .firstWhere((e) => e['task'] == value);
                          setState(() {
                            _selectedMaintenanceTask = value;
                            _selectedTaskIcon = selectedTask['icon'];
                          });
                        },
                        enabled: _selectedComponentType != null &&
                            _availableTasks.isNotEmpty,
                        validator: (value) => value == null
                            ? 'Please select a maintenance task'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // Maintenance Frequency
                      const Text(
                        'Maintenance Frequency *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _intervalValueController,
                              decoration: const InputDecoration(
                                hintText: 'Number',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              value: _selectedIntervalUnit,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              isExpanded: true,
                              items: _intervalUnits.map((unit) {
                                return DropdownMenuItem<String>(
                                  value: unit,
                                  child: Text(_getUnitDisplayName(unit)),
                                );
                              }).toList(),
                              onChanged: (value) => setState(
                                      () => _selectedIntervalUnit = value),
                              validator: (value) => value == null
                                  ? 'Please select a unit'
                                  : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _notesController,
                        label: 'Notes *',
                        hintText: 'Write Note here',
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      // Schedule Preview
                      if (_selectedMaintenanceTask != null &&
                          _selectedTaskIcon != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(8),
                            border:
                            Border.all(color: AppTheme.borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _selectedTaskIcon!,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Task Preview',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Task: $_selectedMaintenanceTask',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'Component: $_selectedComponentType',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Text(
                                _getSchedulePreview(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
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
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Add Task'),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: enabled ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            fillColor: enabled ? null : Colors.grey.shade100,
            filled: !enabled,
          ),
          isExpanded: true,
          items: enabled
              ? items.map((item) {
            final isAddOption = item.startsWith('+ Add');
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  color: isAddOption ? AppTheme.accent : null,
                  fontWeight: isAddOption ? FontWeight.w600 : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList()
              : [],
          onChanged: enabled ? onChanged : null,
          validator: validator,
        ),
      ],
    );
  }

  String _getUnitDisplayName(String unit) {
    switch (unit) {
      case 'days':
        return 'Days';
      case 'weeks':
        return 'Weeks';
      case 'months':
        return 'Months';
      default:
        return unit;
    }
  }

  String _getSchedulePreview() {
    final interval = _intervalValueController.text;
    final unit = _selectedIntervalUnit;

    if (interval.isEmpty || unit == null) {
      return 'Enter interval to see schedule preview';
    }

    return 'This task will be due every $interval ${_getUnitDisplayName(unit).toLowerCase()}';
  }

  void _showAddComponentDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddComponentDialog(
        onComponentAdded: (component) {
          setState(() {
            _availableComponents.add(component);
            _selectedComponentType = component;
          });
          _updateAvailableTasks();
        },
      ),
    );
  }

  void _showAddTaskDialog() {
    if (_selectedComponentType == null) return;

    showDialog(
      context: context,
      builder: (context) => _AddTaskDialog(
        component: _selectedComponentType!,
        onTaskAdded: (task, icon) {
          setState(() {
            _availableTasks.add({'task': task, 'icon': icon});
            _selectedMaintenanceTask = task;
            _selectedTaskIcon = icon;
          });
        },
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final maintenance = Maintenance(
        id: const Uuid().v4(),
        title: _selectedMaintenanceTask!,
        rifleId: _loadoutNameController.text, // Using loadout name as rifleId
        type: _selectedComponentType!.toLowerCase(),
        interval: MaintenanceInterval(
          value: int.parse(_intervalValueController.text),
          unit: _selectedIntervalUnit!,
        ),
        lastCompleted: null,
        currentCount: 0,
        torqueSpec: null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      context.read<LoadoutBloc>().add(AddMaintenanceEvent(maintenance));
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Maintenance task "${maintenance.title}" added successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }
}

// Dialog for adding new component
class _AddComponentDialog extends StatefulWidget {
  final Function(String) onComponentAdded;

  const _AddComponentDialog({Key? key, required this.onComponentAdded})
      : super(key: key);

  @override
  State<_AddComponentDialog> createState() => _AddComponentDialogState();
}

class _AddComponentDialogState extends State<_AddComponentDialog> {
  final _componentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Component'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Enter the name of the new component:'),
          const SizedBox(height: 16),
          TextField(
            controller: _componentController,
            decoration: const InputDecoration(
              labelText: 'Component Name',
              hintText: 'e.g., Bipod, Suppressor',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_componentController.text.isNotEmpty) {
              widget.onComponentAdded(_componentController.text);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// Dialog for adding new task
class _AddTaskDialog extends StatefulWidget {
  final String component;
  final Function(String, String) onTaskAdded;

  const _AddTaskDialog({
    Key? key,
    required this.component,
    required this.onTaskAdded,
  }) : super(key: key);

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final _taskController = TextEditingController();
  String _selectedIcon = '🔧';

  final List<String> _icons = [
    '🔧',
    '🧽',
    '🔍',
    '🛠️',
    '⚙️',
    '🎯',
    '🛡️',
    '👁️',
    '🔭',
    '🔋',
    '⚡',
    '⭕',
    '📦',
    '🏠',
    '📊',
    '📅',
    '🦵',
    '🎗️',
    '🔄',
    '🛤️',
    '💼',
    '🧰'
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Task for ${widget.component}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _taskController,
            decoration: const InputDecoration(
              labelText: 'Task Name',
              hintText: 'e.g., Cleaning, Inspection',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          const Text('Select Icon:'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _icons
                .map((icon) => GestureDetector(
              onTap: () => setState(() => _selectedIcon = icon),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedIcon == icon
                        ? AppTheme.primary
                        : AppTheme.borderColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(icon, style: const TextStyle(fontSize: 20)),
              ),
            ))
                .toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_taskController.text.isNotEmpty) {
              widget.onTaskAdded(_taskController.text, _selectedIcon);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}