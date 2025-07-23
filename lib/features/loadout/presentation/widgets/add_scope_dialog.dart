// lib/features/Loadout/presentation/widgets/add_scope_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/csv_scope_model.dart';
import '../../data/repositories/csv_repository.dart';
import '../../domain/entities/scope.dart';
import '../bloc/loadout_bloc.dart';
import 'searchable_dropdown.dart';

enum ScopeAddMode {
  fullScope,       // Complete new scope
  manufacturer,   // Add new manufacturer for selected model
}

class AddScopeDialog extends StatefulWidget {
  final ScopeAddMode addMode;
  final String? prefilledManufacturer;
  final bool editMode;
  final Scope? existingScope;

  const AddScopeDialog({
    Key? key,
    this.addMode = ScopeAddMode.fullScope,
    this.prefilledManufacturer,
    this.editMode = false,
    this.existingScope,
  }) : super(key: key);

  @override
  State<AddScopeDialog> createState() => _AddScopeDialogState();
}

class _AddScopeDialogState extends State<AddScopeDialog> with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // CSV Repository
  late CSVRepository _csvRepository;

  // CSV Data
  List<CSVScopeModel> _scopeData = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Form controllers for manual entry
  final _manualManufacturerController = TextEditingController();
  final _manualModelController = TextEditingController();

  // Form controllers for scope details
  final _notesController = TextEditingController();

  // Tracking specifications controllers
  final _clickValueController = TextEditingController();
  final _elevationTravelController = TextEditingController();
  final _windageTravelController = TextEditingController();

  // Zero data controllers
  final _distanceController = TextEditingController();
  final _elevationController = TextEditingController();
  final _windageController = TextEditingController();

  // Selection state
  String? _selectedManufacturer;
  String? _selectedModel;
  String? _selectedTubeSize;
  String? _selectedFocalPlane;
  String? _selectedTrackingUnits;
  String? _selectedZeroUnits;
  String? _selectedReticle;

  // Filtered options
  List<String> _availableModels = [];

  // Manual entry mode
  bool _isManualEntry = false;

  // Zero data list
  List<ZeroDataModel> _zeroDataList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _csvRepository = CSVRepositoryImpl();
    _loadCSVData();
    _initializePrefilledData();
  }

  void _initializePrefilledData() {
    // If in edit mode, populate all fields with existing scope data
    if (widget.editMode && widget.existingScope != null) {
      final scope = widget.existingScope!;

      _selectedManufacturer = scope.manufacturer;
      _selectedModel = scope.model;
      _selectedTubeSize = scope.tubeSize;
      _selectedFocalPlane = scope.focalPlane;
      _selectedTrackingUnits = scope.trackingUnits;
      _selectedReticle = scope.reticle;

      // Populate manual entry fields
      _manualManufacturerController.text = scope.manufacturer;
      _manualModelController.text = scope.model;

      // Populate other fields
      _notesController.text = scope.notes ?? '';
      _clickValueController.text = scope.clickValue ?? '';
      _elevationTravelController.text = scope.totalTravel.elevation ?? '';
      _windageTravelController.text = scope.totalTravel.windage ?? '';

      // Populate zero data
      _zeroDataList = scope.zeroData.map((zero) => ZeroDataModel(
        distance: zero.distance,
        units: zero.units,
        elevation: zero.elevation,
        windage: zero.windage,
      )).toList();

      // Set manual entry mode for edit
      _isManualEntry = true;
      return;
    }

    // Original prefilled data logic for add mode
    if (widget.prefilledManufacturer != null) {
      _selectedManufacturer = widget.prefilledManufacturer;
      _manualManufacturerController.text = widget.prefilledManufacturer!;
    }

    if (widget.addMode != ScopeAddMode.fullScope) {
      _isManualEntry = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _manualManufacturerController.dispose();
    _manualModelController.dispose();
    _notesController.dispose();
    _clickValueController.dispose();
    _elevationTravelController.dispose();
    _windageTravelController.dispose();
    _distanceController.dispose();
    _elevationController.dispose();
    _windageController.dispose();
    super.dispose();
  }

  Future<void> _loadCSVData() async {
    try {
      _scopeData = await _csvRepository.getScopes();
      setState(() {
        _isLoading = false;
        _updateAvailableOptions();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load scope data: $e';
      });
    }
  }

  void _updateAvailableOptions() {
    if (_selectedManufacturer != null) {
      _availableModels = _scopeData
          .where((e) => e.manufacturer == _selectedManufacturer)
          .map((e) => e.model)
          .toSet()
          .toList()
        ..sort();
    }
  }

  List<String> _getUniqueManufacturers() {
    return _scopeData
        .map((e) => e.manufacturer)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> _getFilteredManufacturers(String query) {
    final allManufacturers = _getUniqueManufacturers();
    if (query.isEmpty) return allManufacturers;

    return allManufacturers
        .where((manufacturer) => manufacturer.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void _onManufacturerSelected(String? manufacturer) {
    setState(() {
      _selectedManufacturer = manufacturer;
      _selectedModel = null;
      _isManualEntry = manufacturer == '+ Add New Manufacturer';

      if (manufacturer != null && manufacturer != '+ Add New Manufacturer') {
        _updateAvailableOptions();

        if (_availableModels.length == 1) {
          _selectedModel = _availableModels.first;
        }
      } else {
        _availableModels = [];
      }
    });
  }

  void _onModelSelected(String? model) {
    if (model == '+ Add New Model') {
      _showAddDialog(ScopeAddMode.manufacturer, _selectedManufacturer);
      return;
    }

    setState(() {
      _selectedModel = model;
    });
  }

  void _showAddDialog(ScopeAddMode mode, String? manufacturer) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddScopeDialog(
          addMode: mode,
          prefilledManufacturer: manufacturer,
        ),
      ),
    ).then((_) {
      _loadCSVData();
    });
  }

  String _getDialogTitle() {
    if (widget.editMode) {
      return 'Update Scope';
    }

    switch (widget.addMode) {
      case ScopeAddMode.manufacturer:
        return 'Add New Manufacturer';
      default:
        return _isManualEntry ? 'Add Custom Scope' : 'Add Scope Profile';
    }
  }

  String _getSubmitButtonText() {
    if (widget.editMode) {
      return 'Update Scope';
    }

    switch (widget.addMode) {
      case ScopeAddMode.manufacturer:
        return 'Add';
      default:
        return 'Add Scope';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
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
                  Expanded(
                    child: Text(
                      _getDialogTitle(),
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

            // Loading or Error State
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: AppTheme.danger, size: 48),
                      const SizedBox(height: 16),
                      Text(_errorMessage, style: const TextStyle(color: AppTheme.danger)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCSVData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
                // Tabs (only show for full scope mode and add mode)
                if (widget.addMode == ScopeAddMode.fullScope)
                  TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primary,
                    unselectedLabelColor: AppTheme.textSecondary,
                    indicatorColor: AppTheme.primary,
                    tabs: const [
                      Tab(text: 'Basic Info'),
                      Tab(text: 'Specifications'),
                      Tab(text: 'Zero Data'),
                    ],
                  ),

                // Tab Content
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: widget.addMode == ScopeAddMode.fullScope
                        ? TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBasicInfoTab(),
                        _buildSpecificationsTab(),
                        _buildZeroDataTab(),
                      ],
                    )
                        : _buildBasicInfoTab(),
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
                          child: Text(_getSubmitButtonText()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.addMode == ScopeAddMode.fullScope ? 'Basic Information' : _getDialogTitle(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
        ...[
            // CSV-based selection
            _buildSearchableDropdown(
              label: 'Manufacturer *',
              selectedValue: _selectedManufacturer,
              options: [..._getUniqueManufacturers(), '+ Add New Manufacturer'],
              onChanged: _onManufacturerSelected,
              onSearch: _getFilteredManufacturers,
            ),

            if (_selectedManufacturer != null && _selectedManufacturer != '+ Add New Manufacturer') ...[
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Model *',
                value: _selectedModel,
                items: [..._availableModels, '+ Add New Model'],
                onChanged: _onModelSelected,
                enabled: _availableModels.isNotEmpty,
              ),
            ],
          ],

          const SizedBox(height: 16),

          // Manual selection for Tube Size
          _buildDropdown(
            label: 'Tube Size *',
            value: _selectedTubeSize,
            items: const ['1 inch', '30mm', '34mm', '35mm'],
            onChanged: (value) => setState(() => _selectedTubeSize = value),
          ),

          const SizedBox(height: 16),

          // Manual selection for Focal Plane
          _buildDropdown(
            label: 'Focal Plane *',
            value: _selectedFocalPlane,
            items: const ['FFP', 'SFP'],
            onChanged: (value) => setState(() => _selectedFocalPlane = value),
          ),

          const SizedBox(height: 16),
          TextFormField(
            initialValue: _selectedReticle,
            decoration: const InputDecoration(
              labelText: 'Reticle',
              hintText: 'e.g. EBR-2C MRAD',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _selectedReticle = value,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tracking Specifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Tracking Units',
                  value: _selectedTrackingUnits,
                  items: const ['MOA', 'MRAD'],
                  onChanged: (value) => setState(() => _selectedTrackingUnits = value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _clickValueController,
                  decoration: const InputDecoration(
                    labelText: 'Click Value',
                    hintText: 'e.g. 0.1 MRAD',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _elevationTravelController,
                  decoration: const InputDecoration(
                    labelText: 'Elevation Travel',
                    hintText: 'e.g. 27.9 MRAD',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _windageTravelController,
                  decoration: const InputDecoration(
                    labelText: 'Windage Travel',
                    hintText: 'e.g. 9.4 MRAD',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Tracking performance, glass quality, etc.',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildZeroDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Zero Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add zero data for different distances. You can add more zeros after creating the scope profile.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _distanceController,
                  decoration: const InputDecoration(
                    labelText: 'Distance',
                    hintText: '100',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: 'Units',
                  value: _selectedZeroUnits ?? 'Yards',
                  items: const ['Yards', 'Meters'],
                  onChanged: (value) => setState(() => _selectedZeroUnits = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _elevationController,
                  decoration: const InputDecoration(
                    labelText: 'Elevation',
                    hintText: '2.4',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _windageController,
                  decoration: const InputDecoration(
                    labelText: 'Windage',
                    hintText: '0.2',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Display added zero data
          if (_zeroDataList.isNotEmpty) ...[
            const Text(
              'Added Zero Data:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            ..._zeroDataList.map((zero) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${zero.distance} ${zero.units}: ${zero.elevation}↑ ${zero.windage}→',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18, color: AppTheme.danger),
                    onPressed: () {
                      setState(() {
                        _zeroDataList.remove(zero);
                      });
                    },
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
          ],

          // Add zero button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addZeroData,
              icon: const Icon(Icons.add),
              label: const Text('Add Zero Data'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchableDropdown({
    required String label,
    required String? selectedValue,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required List<String> Function(String) onSearch,
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
        SearchableDropdown(
          selectedValue: selectedValue,
          options: options,
          onChanged: onChanged,
          onSearch: onSearch,
          hintText: 'Select or search manufacturer...',
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          validator: label.contains('*') ? (value) => value == null ? 'Please select an option' : null : null,
        ),
      ],
    );
  }

  void _addZeroData() {
    if (_distanceController.text.isNotEmpty &&
        _elevationController.text.isNotEmpty &&
        _windageController.text.isNotEmpty) {

      final distance = int.tryParse(_distanceController.text);
      if (distance == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid distance'),
            backgroundColor: AppTheme.accent,
          ),
        );
        return;
      }

      setState(() {
        _zeroDataList.add(ZeroDataModel(
          distance: distance,
          units: _selectedZeroUnits ?? 'Yards',
          elevation: _elevationController.text,
          windage: _windageController.text,
        ));
      });

      // Clear fields
      _distanceController.clear();
      _elevationController.clear();
      _windageController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all zero data fields'),
          backgroundColor: AppTheme.accent,
        ),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String manufacturer, model;

      if (_isManualEntry || widget.addMode != ScopeAddMode.fullScope) {
        manufacturer = _manualManufacturerController.text;
        model = _manualModelController.text;

        // Add to CSV file permanently (only if not in edit mode)
        if (!widget.editMode) {
          try {
            await _csvRepository.addScope(CSVScopeModel(
              manufacturer: manufacturer,
              model: model,
              tubeSize: _selectedTubeSize ?? '30mm',
              focalPlane: _selectedFocalPlane ?? 'FFP',
              reticle: _selectedReticle ?? '',
              trackingUnits: _selectedTrackingUnits ?? 'MRAD',
              clickValue: _clickValueController.text.isNotEmpty ? _clickValueController.text : '0.1 MRAD',
              maxElevation: _elevationTravelController.text.isNotEmpty ? _elevationTravelController.text : '20 MRAD',
              maxWindage: _windageTravelController.text.isNotEmpty ? _windageTravelController.text : '10 MRAD',
            ));

            Navigator.of(context).pop();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${_getDialogTitle().toLowerCase()} added to database!'),
                backgroundColor: AppTheme.success,
              ),
            );
            return;
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save: $e'),
                backgroundColor: AppTheme.danger,
              ),
            );
            return;
          }
        }
      }
      else {
        if (_selectedManufacturer == null || _selectedModel == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please complete all required selections'),
              backgroundColor: AppTheme.accent,
            ),
          );
          return;
        }

        manufacturer = _selectedManufacturer!;
        model = _selectedModel!;
      }

      // Check required fields
      if (_selectedTubeSize == null || _selectedFocalPlane == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select tube size and focal plane'),
            backgroundColor: AppTheme.accent,
          ),
        );
        return;
      }

      final scope = Scope(
        id: widget.editMode ? widget.existingScope!.id : const Uuid().v4(),
        manufacturer: manufacturer,
        model: model,
        tubeSize: _selectedTubeSize,
        focalPlane: _selectedFocalPlane,
        reticle: _selectedReticle,
        trackingUnits: _selectedTrackingUnits,
        clickValue: _clickValueController.text.isNotEmpty ? _clickValueController.text : null,
        totalTravel: TotalTravel(
          elevation: _elevationTravelController.text.isNotEmpty ? _elevationTravelController.text : null,
          windage: _windageTravelController.text.isNotEmpty ? _windageTravelController.text : null,
        ),
        zeroData: _zeroDataList.map((zero) => zero.toEntity()).toList(),
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      // Submit to bloc
      if (widget.editMode) {
        context.read<LoadoutBloc>().add(UpdateScopeEvent(scope));
      } else {
        context.read<LoadoutBloc>().add(AddScopeEvent(scope));
      }

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.editMode
              ? 'Scope "${scope.manufacturer} ${scope.model}" updated successfully!'
              : 'Scope "${scope.manufacturer} ${scope.model}" added successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }
}

// Helper class for zero data
class ZeroDataModel {
  final int distance;
  final String units;
  final String elevation;
  final String windage;

  ZeroDataModel({
    required this.distance,
    required this.units,
    required this.elevation,
    required this.windage,
  });

  ZeroData toEntity() {
    return ZeroData(
      distance: distance,
      units: units,
      elevation: elevation,
      windage: windage,
    );
  }
}