// lib/features/Loadout/presentation/widgets/add_rifle_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/csv_rifle_model.dart';
import '../../data/repositories/csv_repository.dart';
import '../../domain/entities/rifle.dart';
import '../bloc/loadout_bloc.dart';
import 'searchable_dropdown.dart';

enum AddMode {
  fullRifle,      // Complete new rifle
  manufacturer,   // Add new manufacturer for selected rifle
  model,         // Add new model for selected rifle + manufacturer
  caliber,       // Add new caliber for selected rifle + manufacturer + model
}

class AddRifleDialog extends StatefulWidget {
  final AddMode addMode;
  final String? prefilledRifleName;
  final String? prefilledManufacturer;
  final String? prefilledModel;
  final bool editMode;
  final Rifle? existingRifle;

  const AddRifleDialog({
    Key? key,
    this.addMode = AddMode.fullRifle,
    this.prefilledRifleName,
    this.prefilledManufacturer,
    this.prefilledModel,
    this.editMode = false,
    this.existingRifle,
  }) : super(key: key);

  @override
  State<AddRifleDialog> createState() => _AddRifleDialogState();
}

class _AddRifleDialogState extends State<AddRifleDialog> {
  final _formKey = GlobalKey<FormState>();

  // CSV Repository
  late CSVRepository _csvRepository;

  // CSV Data
  List<CSVRifleModel> _rifleData = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Advanced section toggle
  bool _showAdvancedSection = false;

  // Form controllers for new entries
  final _newRifleNameController = TextEditingController();
  final _newBrandController = TextEditingController();
  final _newModelController = TextEditingController();
  final _newGenerationVariantController = TextEditingController();
  final _newCaliberController = TextEditingController();
  final _newActionTypeController = TextEditingController();
  final _newManufacturerController = TextEditingController();
  final _newNotesController = TextEditingController();

  // Basic form controllers
  final _notesController = TextEditingController();

  // Advanced form controllers
  final _serialNumberController = TextEditingController();
  final _barrelLengthController = TextEditingController();
  final _overallLengthController = TextEditingController();
  final _weightController = TextEditingController();
  final _barrelTwistController = TextEditingController();
  final _capacityController = TextEditingController();
  final _barrelThreadingController = TextEditingController();
  final _triggerController = TextEditingController();
  final _triggerWeightController = TextEditingController();
  final _stockManufacturerController = TextEditingController();
  final _stockModelController = TextEditingController();
  final _sightModelController = TextEditingController();
  final _sightHeightController = TextEditingController();
  final _purchaseDateController = TextEditingController();
  final _modificationsController = TextEditingController();

  // Selection state
  String? _selectedRifleName;
  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedGenerationVariant;
  String? _selectedCaliber;
  String? _selectedActionType;
  String? _selectedManufacturer;
  String? _selectedBarrelMaterial;
  String? _selectedBarrelProfile;
  String? _selectedFinish;
  String? _selectedSightType;
  String? _selectedSightOptic;

  // All available options from CSV (unfiltered)
  List<String> _allBrands = [];
  List<String> _allModels = [];
  List<String> _allGenerationVariants = [];
  List<String> _allCalibres = [];
  List<String> _allActionTypes = [];
  List<String> _allManufacturers = [];

  // Filtered options for auto-selection logic
  List<String> _availableBrands = [];
  List<String> _availableModels = [];
  List<String> _availableGenerationVariants = [];
  List<String> _availableCalibres = [];
  List<String> _availableActionTypes = [];
  List<String> _availableManufacturers = [];

  // Checkboxes
  bool _adjustableLOP = false;
  bool _adjustableCheekRest = false;

  // Sight Type options
  final List<String> _sightTypeOptions = [
    'Iron Sights',
    'Optical Sights',
    'Electronic Sights',
    'Specialized Sights',
    'No Optic',
    'Other...',
  ];

  // Sight/Optic options
  final List<String> _sightOpticOptions = [
    'Open Iron Sights',
    'Peep Sights (Aperture)',
    'Ghost Ring Sights',
    'Low Power Variable Optic (LPVO)',
    'Fixed Power Scope',
    'Variable Power Scope',
    'Red Dot Sight (RDS)',
    'Holographic Sight',
    'Prism Sight',
    'Night Vision Scope',
    'Thermal Scope',
    'No Optic/Iron Sights Only',
    'Other...',
  ];

  @override
  void initState() {
    super.initState();
    _csvRepository = CSVRepositoryImpl();
    _loadCSVData();
    _initializePrefilledData();
  }

  void _initializePrefilledData() {
    // If in edit mode, populate all fields with existing rifle data
    if (widget.editMode && widget.existingRifle != null) {
      final rifle = widget.existingRifle!;

      _selectedRifleName = rifle.name;
      _selectedBrand = rifle.brand;

      _selectedManufacturer = rifle.manufacturer;
      _selectedGenerationVariant = rifle.generationVariant;
      _selectedModel = rifle.model;
      _selectedCaliber = rifle.caliber;

      // Populate basic fields
      _notesController.text = rifle.notes ?? '';

      // Populate barrel fields
      _barrelLengthController.text = rifle.barrel.length ?? '';
      _barrelTwistController.text = rifle.barrel.twist ?? '';
      _barrelThreadingController.text = rifle.barrel.threading ?? '';
      _selectedBarrelMaterial = rifle.barrel.material;
      _selectedBarrelProfile = rifle.barrel.profile;

      // Populate action fields
      _selectedActionType = rifle.action.type;
      _triggerController.text = rifle.action.trigger ?? '';
      _triggerWeightController.text = rifle.action.triggerWeight ?? '';

      // Populate stock fields
      _stockManufacturerController.text = rifle.stock.manufacturer ?? '';
      _stockModelController.text = rifle.stock.model ?? '';
      _adjustableLOP = rifle.stock.adjustableLOP;
      _adjustableCheekRest = rifle.stock.adjustableCheekRest;

      // Populate new advanced fields
      _serialNumberController.text = rifle.serialNumber ?? '';
      _overallLengthController.text = rifle.overallLength ?? '';
      _weightController.text = rifle.weight ?? '';
      _capacityController.text = rifle.capacity ?? '';
      _selectedFinish = rifle.finish;
      _selectedSightType = rifle.sightType;
      _selectedSightOptic = rifle.sightOptic;
      _sightModelController.text = rifle.sightModel ?? '';
      _sightHeightController.text = rifle.sightHeight ?? '';
      _purchaseDateController.text = rifle.purchaseDate ?? '';
      _modificationsController.text = rifle.modifications ?? '';

      return;
    }

    // Initialize prefilled data for add mode
    if (widget.prefilledRifleName != null) {
      _selectedRifleName = widget.prefilledRifleName;
    }

    if (widget.prefilledManufacturer != null) {
      _selectedManufacturer = widget.prefilledManufacturer;
    }

    if (widget.prefilledModel != null) {
      _selectedModel = widget.prefilledModel;
    }
  }

  @override
  void dispose() {
    // Dispose new entry controllers
    _newRifleNameController.dispose();
    _newBrandController.dispose();
    _newModelController.dispose();
    _newGenerationVariantController.dispose();
    _newCaliberController.dispose();
    _newActionTypeController.dispose();
    _newManufacturerController.dispose();
    _newNotesController.dispose();

    // Dispose basic controllers
    _notesController.dispose();

    // Dispose advanced controllers
    _serialNumberController.dispose();
    _barrelLengthController.dispose();
    _overallLengthController.dispose();
    _weightController.dispose();
    _barrelTwistController.dispose();
    _capacityController.dispose();
    _barrelThreadingController.dispose();
    _triggerController.dispose();
    _triggerWeightController.dispose();
    _stockManufacturerController.dispose();
    _stockModelController.dispose();
    _sightModelController.dispose();
    _sightHeightController.dispose();
    _purchaseDateController.dispose();
    _modificationsController.dispose();
    super.dispose();
  }

  Future<void> _loadCSVData() async {
    try {
      _rifleData = await _csvRepository.getRifles();
      setState(() {
        _isLoading = false;
        // Only set default for add mode
        if (!widget.editMode && _selectedRifleName == null && _rifleData.isNotEmpty) {
          _selectedRifleName = _rifleData.first.name;
        }
        _loadAllOptionsFromCSV();
        _updateAvailableOptions();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load rifle data: $e';
      });
    }
  }

  void _loadAllOptionsFromCSV() {
    // Load all unique values from CSV for dropdowns
    _allBrands = _rifleData
        .map((e) => e.brand)
        .where((brand) => brand != null)
        .toSet()
        .toList()
      ..sort();

    _allModels = _rifleData
        .map((e) => e.model)
        .where((model) => model != null)
        .toSet()
        .toList()
      ..sort();

    _allGenerationVariants = _rifleData
        .map((e) => e.generationVariant)
        .where((variant) => variant!= null)
        .toSet()
        .toList()
      ..sort();

    _allCalibres = _rifleData
        .map((e) => e.caliber)
        .where((caliber) => caliber!= null)
        .toSet()
        .toList()
      ..sort();

    _allActionTypes = _rifleData
        .map((e) => e.actionType)
        .where((action) => action!= null)
        .toSet()
        .toList()
      ..sort();

    _allManufacturers = _rifleData
        .map((e) => e.manufacturer)
        .where((manufacturer) => manufacturer.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  void _updateAvailableOptions() {
    if (_selectedRifleName != null) {
      _availableBrands = _rifleData
          .where((e) => e.name == _selectedRifleName)
          .map((e) => e.brand)
          .toSet()
          .toList()
        ..sort();

      // Auto-select if only one brand available (only in add mode)
      if (!widget.editMode && _availableBrands.length == 1 && _selectedBrand == null) {
        _selectedBrand = _availableBrands.first;
      }

      if (_selectedBrand != null) {
        _availableModels = _rifleData
            .where((e) => e.name == _selectedRifleName && e.brand == _selectedBrand)
            .map((e) => e.model)
            .toSet()
            .toList()
          ..sort();

        // Auto-select: if only one option then auto-select, else select first option (only in add mode)
        if (!widget.editMode && _availableModels.isNotEmpty && _selectedModel == null) {
          _selectedModel = _availableModels.first;
        }

        if (_selectedModel != null) {
          _availableGenerationVariants = _rifleData
              .where((e) =>
          e.name == _selectedRifleName &&
              e.brand == _selectedBrand &&
              e.model == _selectedModel)
              .map((e) => e.generationVariant)
              .toSet()
              .toList()
            ..sort();

          // Auto-select: if only one option then auto-select, else select first option (only in add mode)
          if (!widget.editMode && _availableGenerationVariants.isNotEmpty && _selectedGenerationVariant == null) {
            _selectedGenerationVariant = _availableGenerationVariants.first;
          }

          if (_selectedGenerationVariant != null) {
            _availableCalibres = _rifleData
                .where((e) =>
            e.name == _selectedRifleName &&
                e.brand == _selectedBrand &&
                e.model == _selectedModel &&
                e.generationVariant == _selectedGenerationVariant)
                .map((e) => e.caliber)
                .toSet()
                .toList()
              ..sort();

            // Auto-select: if only one option then auto-select, else select first option (only in add mode)
            if (!widget.editMode && _availableCalibres.isNotEmpty && _selectedCaliber == null) {
              _selectedCaliber = _availableCalibres.first;
            }

            if (_selectedCaliber != null) {
              _availableActionTypes = _rifleData
                  .where((e) =>
              e.name == _selectedRifleName &&
                  e.brand == _selectedBrand &&
                  e.model == _selectedModel &&
                  e.generationVariant == _selectedGenerationVariant &&
                  e.caliber == _selectedCaliber)
                  .map((e) => e.actionType)
                  .toSet()
                  .toList()
                ..sort();

              // Auto-select: if only one option then auto-select, else select first option (only in add mode)
              if (!widget.editMode && _availableActionTypes.isNotEmpty && _selectedActionType == null) {
                _selectedActionType = _availableActionTypes.first;
              }

              if (_selectedActionType != null) {
                _availableManufacturers = _rifleData
                    .where((e) =>
                e.name == _selectedRifleName &&
                    e.brand == _selectedBrand &&
                    e.model == _selectedModel &&
                    e.generationVariant == _selectedGenerationVariant &&
                    e.caliber == _selectedCaliber &&
                    e.actionType == _selectedActionType)
                    .map((e) => e.manufacturer)
                    .toSet()
                    .toList()
                  ..sort();

                // Auto-select: if only one option then auto-select, else select first option (only in add mode)
                if (!widget.editMode && _availableManufacturers.isNotEmpty && _selectedManufacturer == null) {
                  _selectedManufacturer = _availableManufacturers.first;
                  _loadNotesForSelection();
                }
              }
            }
          }
        }
      }
    }
  }

  void _loadNotesForSelection() {
    if (_selectedRifleName != null && _selectedBrand != null &&
        _selectedModel != null && _selectedGenerationVariant != null &&
        _selectedCaliber != null && _selectedActionType != null &&
        _selectedManufacturer != null) {
      try {
        final rifleEntry = _rifleData.firstWhere((e) =>
        e.name == _selectedRifleName &&
            e.brand == _selectedBrand &&
            e.model == _selectedModel &&
            e.generationVariant == _selectedGenerationVariant &&
            e.caliber == _selectedCaliber &&
            e.actionType == _selectedActionType &&
            e.manufacturer == _selectedManufacturer);
        _notesController.text = rifleEntry.notes;
      } catch (e) {
        // Notes not found, keep empty
      }
    }
  }

  List<String> _getUniqueRifleNames() {
    return _rifleData
        .map((e) => e.name)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> _getFilteredRifleNames(String query) {
    final allNames = _getUniqueRifleNames();
    if (query.isEmpty) return allNames;

    return allNames
        .where((name) => name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void _onRifleNameSelected(String? rifleName) {
    setState(() {
      _selectedRifleName = rifleName;
      // Reset all subsequent selections
      _selectedBrand = null;
      _selectedModel = null;
      _selectedGenerationVariant = null;
      _selectedCaliber = null;
      _selectedActionType = null;
      _selectedManufacturer = null;
      _notesController.clear();

      if (rifleName != null) {
        _updateAvailableOptions();
      } else {
        _clearAllOptions();
      }
    });
  }

  void _onBrandSelected(String? brand) {
    if (brand == 'Add New') {
      _showNewItemDialog('Brand', _newBrandController, () => _addNewBrand());
      return;
    }

    setState(() {
      _selectedBrand = brand;
      // Reset subsequent selections
      _selectedModel = null;
      _selectedGenerationVariant = null;
      _selectedCaliber = null;
      _selectedActionType = null;
      _selectedManufacturer = null;
      _notesController.clear();

      if (brand != null && _selectedRifleName != null) {
        _updateAvailableOptions();
      } else {
        _clearOptionsFrom('model');
      }
    });
  }

  void _onModelSelected(String? model) {
    if (model == 'Add New') {
      _showNewItemDialog('Model', _newModelController, () => _addNewModel());
      return;
    }

    setState(() {
      _selectedModel = model;

      if (model != null && _selectedRifleName != null && _selectedBrand != null) {
        _updateAvailableOptions();
      } else {
        _clearOptionsFrom('generation');
      }
    });
  }

  void _onGenerationVariantSelected(String? generationVariant) {
    if (generationVariant == 'Add New') {
      _showNewItemDialog('Generation/Variant', _newGenerationVariantController, () => _addNewGeneration());
      return;
    }

    setState(() {
      _selectedGenerationVariant = generationVariant;

      if (generationVariant != null && _selectedRifleName != null &&
          _selectedBrand != null && _selectedModel != null) {
        _updateAvailableOptions();
      } else {
        _clearOptionsFrom('caliber');
      }
    });
  }

  void _onCaliberSelected(String? caliber) {
    if (caliber == 'Add New') {
      _showNewItemDialog('Caliber', _newCaliberController, () => _addNewCaliber());
      return;
    }

    setState(() {
      _selectedCaliber = caliber;

      if (caliber != null && _selectedRifleName != null &&
          _selectedBrand != null && _selectedModel != null &&
          _selectedGenerationVariant != null) {
        _updateAvailableOptions();
      } else {
        _clearOptionsFrom('actionType');
      }
    });
  }

  void _onActionTypeSelected(String? actionType) {
    if (actionType == 'Add New') {
      _showNewItemDialog('Action Type', _newActionTypeController, () => _addNewActionType());
      return;
    }

    setState(() {
      _selectedActionType = actionType;

      if (actionType != null && _selectedRifleName != null &&
          _selectedBrand != null && _selectedModel != null &&
          _selectedGenerationVariant != null && _selectedCaliber != null) {
        _updateAvailableOptions();
      } else {
        _clearOptionsFrom('manufacturer');
      }
    });
  }

  void _onManufacturerSelected(String? manufacturer) {
    if (manufacturer == 'Add New') {
      _showNewItemDialog('Manufacturer', _newManufacturerController, () => _addNewManufacturer());
      return;
    }

    setState(() {
      _selectedManufacturer = manufacturer;
      if (manufacturer != null) {
        _loadNotesForSelection();
      }
    });
  }

  void _clearAllOptions() {
    _availableBrands = [];
    _availableModels = [];
    _availableGenerationVariants = [];
    _availableCalibres = [];
    _availableActionTypes = [];
    _availableManufacturers = [];
  }

  void _clearOptionsFrom(String fromField) {
    switch (fromField) {
      case 'model':
        _availableModels = [];
        _availableGenerationVariants = [];
        _availableCalibres = [];
        _availableActionTypes = [];
        _availableManufacturers = [];
        break;
      case 'generation':
        _availableGenerationVariants = [];
        _availableCalibres = [];
        _availableActionTypes = [];
        _availableManufacturers = [];
        break;
      case 'caliber':
        _availableCalibres = [];
        _availableActionTypes = [];
        _availableManufacturers = [];
        break;
      case 'actionType':
        _availableActionTypes = [];
        _availableManufacturers = [];
        break;
      case 'manufacturer':
        _availableManufacturers = [];
        break;
    }
  }

  String _getDialogTitle() {
    if (widget.editMode) {
      return 'Update Rifle';
    }

    switch (widget.addMode) {
      case AddMode.manufacturer:
        return 'Add New Manufacturer';
      case AddMode.model:
        return 'Add New Model';
      case AddMode.caliber:
        return 'Add New Caliber';
      default:
        return 'Add Rifle Profile';
    }
  }

  String _getSubmitButtonText() {
    if (widget.editMode) {
      return 'Update Rifle';
    }

    switch (widget.addMode) {
      case AddMode.manufacturer:
      case AddMode.model:
      case AddMode.caliber:
        return 'Add';
      default:
        return 'Add Rifle';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: MediaQuery.of(context).size.width * 0.95,
        ),
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
                // Main Content
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: AppTheme.paddingMedium,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Basic Information Section
                          _buildBasicInfoSection(),

                          const SizedBox(height: 24),

                          // Advanced Information Toggle
                          _buildAdvancedToggle(),

                          // Advanced Information Section
                          if (_showAdvancedSection) _buildAdvancedSection(),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Buttons
                Container(
                  padding: AppTheme.paddingMedium,
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: AppTheme.borderColor)),
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
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: AppTheme.paddingVerticalMedium,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppTheme.radiusMedium,
                            ),
                          ),
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

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 20),

          // Grid layout for form fields
          _buildGridContainer([
            // Rifle Name (Read-only display)
            _buildInfoField(
              label: 'Rifle Name *',
              value: _selectedRifleName ?? '—',
            ),

            // Brand
            _buildDropdownWithAdd(
              label: 'Brand *',
              value: _selectedBrand,
              items: _allBrands,
              onChanged: _onBrandSelected,
              enabled: _allBrands.isNotEmpty,
            ),

            // Model
            _buildDropdownWithAdd(
              label: 'Model *',
              value: _selectedModel,
              items: _allModels,
              onChanged: _onModelSelected,
              enabled: _allModels.isNotEmpty,
            ),

            // Generation/Variant
            _buildDropdownWithAdd(
              label: 'Generation/Variant *',
              value: _selectedGenerationVariant,
              items: _allGenerationVariants,
              onChanged: _onGenerationVariantSelected,
              enabled: _allGenerationVariants.isNotEmpty,
            ),

            // Caliber
            _buildDropdownWithAdd(
              label: 'Caliber *',
              value: _selectedCaliber,
              items: _allCalibres,
              onChanged: _onCaliberSelected,
              enabled: _allCalibres.isNotEmpty,
            ),

            // Action Type
            _buildDropdownWithAdd(
              label: 'Action Type *',
              value: _selectedActionType,
              items: _allActionTypes,
              onChanged: _onActionTypeSelected,
              enabled: _allActionTypes.isNotEmpty,
            ),
          ]),

          if (_selectedManufacturer != null) ...[
            const SizedBox(height: 16),
            _buildDropdownWithAdd(
              label: 'Manufacturer *',
              value: _selectedManufacturer,
              items: _allManufacturers,
              onChanged: _onManufacturerSelected,
              enabled: _allManufacturers.isNotEmpty,
            ),
          ],

          if (_selectedManufacturer != null) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Auto-filled from CSV or add personal notes...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdvancedToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAdvancedSection = !_showAdvancedSection;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          border: Border.all(color: Colors.green[200]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _showAdvancedSection
                      ? 'Advanced Information (Click to Collapse)'
                      : 'Advanced Information (Click to Expand)',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.success,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              _showAdvancedSection ? Icons.expand_less : Icons.expand_more,
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGridContainer([
            // Serial Number
            _buildTextField(
              controller: _serialNumberController,
              label: 'Serial Number',
              hintText: 'Enter serial number',
            ),

            // Barrel Length
            _buildTextField(
              controller: _barrelLengthController,
              label: 'Barrel Length (inches)',
              hintText: 'e.g., 24.0',
              keyboardType: TextInputType.number,
            ),

            // Overall Length
            _buildTextField(
              controller: _overallLengthController,
              label: 'Overall Length (inches)',
              hintText: 'e.g., 43.5',
              keyboardType: TextInputType.number,
            ),

            // Weight
            _buildTextField(
              controller: _weightController,
              label: 'Weight (oz)',
              hintText: 'e.g., 128.0',
              keyboardType: TextInputType.number,
            ),

            // Rifling Twist Rate
            _buildTextField(
              controller: _barrelTwistController,
              label: 'Rifling Twist Rate',
              hintText: 'e.g., 1:8',
            ),

            // Capacity
            _buildTextField(
              controller: _capacityController,
              label: 'Capacity',
              hintText: 'Magazine/cylinder capacity',
              keyboardType: TextInputType.number,
            ),

            // Finish/Color
            _buildSimpleDropdown(
              label: 'Finish/Color',
              value: _selectedFinish,
              items: [
                'Black',
                'Stainless Steel',
                'FDE (Flat Dark Earth)',
                'OD Green',
                'Cerakote',
                'Blued',
                'Nickel',
                'Other...',
              ],
              onChanged: (value) => setState(() => _selectedFinish = value),
            ),

            // Sight Type
            _buildSimpleDropdown(
              label: 'Sight Type',
              value: _selectedSightType,
              items: _sightTypeOptions,
              onChanged: (value) => setState(() => _selectedSightType = value),
            ),

            // Sight/Optic Model
            _buildSimpleDropdown(
              label: 'Sight/Optic',
              value: _selectedSightOptic,
              items: _sightOpticOptions,
              onChanged: (value) => setState(() => _selectedSightOptic = value),
            ),

            // Sight Height Over Bore
            _buildTextField(
              controller: _sightHeightController,
              label: 'Sight Height Over Bore (inches)',
              hintText: 'e.g., 1.5',
              keyboardType: TextInputType.number,
            ),

            // Trigger Pull Weight
            _buildTextField(
              controller: _triggerController,
              label: 'Trigger',
              hintText: 'e.g. Timney Calvin Elite',
              keyboardType: TextInputType.number,
            ),

            // Trigger Pull Weight
            _buildTextField(
              controller: _triggerWeightController,
              label: 'Trigger Pull Weight (lbs)',
              hintText: 'e.g., 3.5',
              keyboardType: TextInputType.number,
            ),

            // Barrel Profile
            _buildSimpleDropdown(
              label: 'Barrel Profile',
              value: _selectedBarrelProfile,
              items: [
                'Sporter',
                'Heavy Varmint',
                'Bull Barrel',
                'Sendero',
                'MTU',
                'M24',
                'Other...',
              ],
              onChanged: (value) => setState(() => _selectedBarrelProfile = value),
            ),

            // Barrel Material
            _buildSimpleDropdown(
              label: 'Barrel Material',
              value: _selectedBarrelMaterial,
              items: [
                'Stainless Steel',
                'Carbon Steel',
                'Carbon Fiber',
                'Chrome Moly',
                'Other...',
              ],
              onChanged: (value) => setState(() => _selectedBarrelMaterial = value),
            ),

          ]),

          const SizedBox(height: 16),

          // Stock fields and other additional fields
          _buildGridContainer([
            // Stock Manufacturer
            _buildTextField(
              controller: _stockManufacturerController,
              label: 'Stock Manufacturer',
              hintText: 'e.g., MDT, Magpul',
            ),

            // Stock Model
            _buildTextField(
              controller: _stockModelController,
              label: 'Stock Model',
              hintText: 'e.g., ESS Chassis, Hunter Stock',
            ),
          ]),

          const SizedBox(height: 16),
          // Stock Options
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Adjustable Length of Pull'),
                  value: _adjustableLOP,
                  onChanged: (value) => setState(() => _adjustableLOP = value ?? false),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Adjustable Cheek Rest'),
                  value: _adjustableCheekRest,
                  onChanged: (value) => setState(() => _adjustableCheekRest = value ?? false),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          // Purchase Date
          _buildDateField(
            controller: _purchaseDateController,
            label: 'Purchase Date',
          ),

          const SizedBox(height: 16),

          // Modifications/Attachments (Textarea)
          TextFormField(
            controller: _modificationsController,
            decoration: const InputDecoration(
              labelText: 'Modifications/Attachments',
              hintText: 'List any modifications: suppressor, compensator, aftermarket trigger, etc.',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),

        ],
      ),
    );
  }

  Widget _buildGridContainer(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate number of columns based on available width
        int columns = (constraints.maxWidth / 300).floor();
        if (columns < 1) columns = 1;
        if (columns > 3) columns = 3;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: children.map((child) => SizedBox(
            width: (constraints.maxWidth - (16 * (columns - 1))) / columns,
            child: child,
          )).toList(),
        );
      },
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
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
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
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
          decoration: const InputDecoration(
            hintText: 'Select date',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              controller.text = picked.toString().split(' ')[0]; // Format: YYYY-MM-DD
            }
          },
        ),
      ],
    );
  }

  Widget _buildSimpleDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
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
        DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdownWithAdd({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    // Create a clean list and only add "Add New" if enabled and not in edit mode
    List<String> dropdownItems = List.from(items);
    if (enabled && !widget.editMode) {
      dropdownItems.add('Add New');
    }

    // Ensure the current value is valid for the dropdown
    String? validValue = value;
    if (value != null && !dropdownItems.contains(value)) {
      validValue = null;
    }

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
          value: validValue,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            fillColor: enabled ? null : Colors.grey.shade100,
            filled: !enabled,
          ),
          isExpanded: true,
          items: enabled
              ? dropdownItems.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  color: item == 'Add New' ? Colors.red : null,
                  fontWeight: item == 'Add New' ? FontWeight.w600 : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList()
              : [],
          onChanged: enabled ? onChanged : null,
          validator: (value) => value == null || value == 'Add New' ? 'Please select an option' : null,
        ),
      ],
    );
  }

  void _showNewItemDialog(String itemName, TextEditingController controller, VoidCallback onAdd) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New $itemName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: itemName,
                    hintText: 'Enter $itemName...',
                    border: const OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          controller.clear();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (controller.text.trim().isNotEmpty) {
                            Navigator.of(context).pop();
                            onAdd();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Add'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Add new item methods (same as before)
  void _addNewBrand() async {
    if (_newBrandController.text.trim().isNotEmpty && _selectedRifleName != null) {
      final newRifle = CSVRifleModel(
        name: _selectedRifleName!,
        brand: _newBrandController.text.trim(),
        model: _selectedModel ?? " ",
        generationVariant: _selectedGenerationVariant ?? "",
        caliber: _selectedCaliber?? "",
        actionType: _selectedActionType?? "",
        manufacturer: _selectedManufacturer?? "",
        notes: _notesController.text?? "",
      );

      try {
        await _csvRepository.addRifle(newRifle);
        await _loadCSVData();
        setState(() {
          _selectedBrand = _newBrandController.text.trim();
          _newBrandController.clear();
          _updateAvailableOptions();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add brand: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  void _addNewModel() async {
    if (_newModelController.text.trim().isNotEmpty &&
        _selectedRifleName != null && _selectedBrand != null) {
      final newRifle = CSVRifleModel(
        name: _selectedRifleName!,
        brand: _selectedBrand!,
        model: _newModelController.text.trim(),
        generationVariant: _selectedGenerationVariant ?? "",
        caliber: _selectedCaliber?? "",
        actionType: _selectedActionType?? "",
        manufacturer: _selectedManufacturer?? "",
        notes: _notesController.text?? "",
      );

      try {
        await _csvRepository.addRifle(newRifle);
        await _loadCSVData();
        setState(() {
          _selectedModel = _newModelController.text.trim();
          _newModelController.clear();
          _updateAvailableOptions();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add model: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  void _addNewGeneration() async {
    if (_newGenerationVariantController.text.trim().isNotEmpty &&
        _selectedRifleName != null && _selectedBrand != null && _selectedModel != null) {
      final newRifle = CSVRifleModel(
        name: _selectedRifleName!,
        brand: _selectedBrand!,
        model: _selectedModel!,
        generationVariant: _newGenerationVariantController.text.trim(),
        caliber: _selectedCaliber?? "",
        actionType: _selectedActionType?? "",
        manufacturer: _selectedManufacturer?? "",
        notes: _notesController.text?? "",
      );

      try {
        await _csvRepository.addRifle(newRifle);
        await _loadCSVData();
        setState(() {
          _selectedGenerationVariant = _newGenerationVariantController.text.trim();
          _newGenerationVariantController.clear();
          _updateAvailableOptions();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add generation: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  void _addNewCaliber() async {
    if (_newCaliberController.text.trim().isNotEmpty &&
        _selectedRifleName != null && _selectedBrand != null &&
        _selectedModel != null && _selectedGenerationVariant != null) {
      final newRifle = CSVRifleModel(
        name: _selectedRifleName!,
        brand: _selectedBrand!,
        model: _selectedModel!,
        generationVariant: _selectedGenerationVariant!,
        caliber: _newCaliberController.text.trim(),
        actionType: _selectedActionType?? "",
        manufacturer: _selectedManufacturer?? "",
        notes: _notesController.text,
      );

      try {
        await _csvRepository.addRifle(newRifle);
        await _loadCSVData();
        setState(() {
          _selectedCaliber = _newCaliberController.text.trim();
          _newCaliberController.clear();
          _updateAvailableOptions();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add caliber: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  void _addNewActionType() async {
    if (_newActionTypeController.text.trim().isNotEmpty &&
        _selectedRifleName != null && _selectedBrand != null &&
        _selectedModel != null && _selectedGenerationVariant != null &&
        _selectedCaliber != null) {
      final newRifle = CSVRifleModel(
        name: _selectedRifleName!,
        brand: _selectedBrand!,
        model: _selectedModel!,
        generationVariant: _selectedGenerationVariant!,
        caliber: _selectedCaliber!,
        actionType: _newActionTypeController.text.trim(),
        manufacturer: _selectedManufacturer?? "",
        notes: _notesController.text,
      );

      try {
        await _csvRepository.addRifle(newRifle);
        await _loadCSVData();
        setState(() {
          _selectedActionType = _newActionTypeController.text.trim();
          _newActionTypeController.clear();
          _updateAvailableOptions();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add action type: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  void _addNewManufacturer() async {
    if (_newManufacturerController.text.trim().isNotEmpty &&
        _selectedRifleName != null && _selectedBrand != null &&
        _selectedModel != null && _selectedGenerationVariant != null &&
        _selectedCaliber != null && _selectedActionType != null) {
      final newRifle = CSVRifleModel(
        name: _selectedRifleName!,
        brand: _selectedBrand!,
        model: _selectedModel!,
        generationVariant: _selectedGenerationVariant!,
        caliber: _selectedCaliber!,
        actionType: _selectedActionType!,
        manufacturer: _newManufacturerController.text.trim(),
        notes: _newNotesController.text,
      );

      try {
        await _csvRepository.addRifle(newRifle);
        await _loadCSVData();
        setState(() {
          _selectedManufacturer = _newManufacturerController.text.trim();
          _newManufacturerController.clear();
          _updateAvailableOptions();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add manufacturer: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Validate that all required selections are made
      if (_selectedRifleName == null || _selectedBrand == null ||
          _selectedModel == null || _selectedGenerationVariant == null ||
          _selectedCaliber == null || _selectedActionType == null ||
          _selectedManufacturer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete all required selections'),
            backgroundColor: AppTheme.accent,
          ),
        );
        return;
      }

      // Create rifle object with all new fields
      final rifle = Rifle(
        id: widget.editMode ? widget.existingRifle!.id : const Uuid().v4(),
        name: _selectedRifleName!,
        brand: _selectedBrand!,
        manufacturer: _selectedManufacturer!,
        generationVariant: _selectedGenerationVariant!,
        model: _selectedModel!,
        caliber: _selectedCaliber!,
        barrel: Barrel(
          length: _barrelLengthController.text.isNotEmpty ? _barrelLengthController.text : null,
          twist: _barrelTwistController.text.isNotEmpty ? _barrelTwistController.text : null,
          threading: _barrelThreadingController.text.isNotEmpty ? _barrelThreadingController.text : null,
          material: _selectedBarrelMaterial,
          profile: _selectedBarrelProfile,
        ),
        action: RAAction(
          type: _selectedActionType,
          trigger: _triggerController.text.isNotEmpty ? _triggerController.text : null,
          triggerWeight: _triggerWeightController.text.isNotEmpty ? _triggerWeightController.text : null,
        ),
        stock: Stock(
          manufacturer: _stockManufacturerController.text.isNotEmpty ? _stockManufacturerController.text : null,
          model: _stockModelController.text.isNotEmpty ? _stockModelController.text : null,
          adjustableLOP: _adjustableLOP,
          adjustableCheekRest: _adjustableCheekRest,
        ),
        scope: widget.editMode ? widget.existingRifle!.scope : null,
        ammunition: widget.editMode ? widget.existingRifle!.ammunition : null,
        isActive: widget.editMode ? widget.existingRifle!.isActive : false,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        // New advanced fields
        serialNumber: _serialNumberController.text.isNotEmpty ? _serialNumberController.text : null,
        overallLength: _overallLengthController.text.isNotEmpty ? _overallLengthController.text : null,
        weight: _weightController.text.isNotEmpty ? _weightController.text : null,
        capacity: _capacityController.text.isNotEmpty ? _capacityController.text : null,
        finish: _selectedFinish,
        sightType: _selectedSightType,
        sightOptic: _selectedSightOptic,
        sightModel: _sightModelController.text.isNotEmpty ? _sightModelController.text : null,
        sightHeight: _sightHeightController.text.isNotEmpty ? _sightHeightController.text : null,
        purchaseDate: _purchaseDateController.text.isNotEmpty ? _purchaseDateController.text : null,
        modifications: _modificationsController.text.isNotEmpty ? _modificationsController.text : null,
      );

      // Submit to bloc
      if (widget.editMode) {
        context.read<LoadoutBloc>().add(UpdateRifleEvent(rifle));
      } else {
        context.read<LoadoutBloc>().add(AddRifleEvent(rifle));
      }

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.editMode
              ? 'Rifle "${rifle.name}" updated successfully!'
              : 'Rifle "${rifle.name}" added successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }
}