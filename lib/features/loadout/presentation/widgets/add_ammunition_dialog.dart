import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/csv_ammunition_model.dart';
import '../../data/repositories/csv_repository.dart';
import '../../domain/entities/ammunition.dart';
import '../bloc/loadout_bloc.dart';
import 'searchable_dropdown.dart';

enum AmmoAddMode {
  fullAmmo,       // Complete new ammunition
  manufacturer,   // Add new manufacturer for selected ammo
  caliber,       // Add new caliber for selected ammo + manufacturer
}

class AddAmmunitionDialog extends StatefulWidget {
  final AmmoAddMode addMode;
  final String? prefilledAmmoName;
  final String? prefilledManufacturer;
  final bool editMode;
  final Ammunition? existingAmmunition;

  const AddAmmunitionDialog({
    Key? key,
    this.addMode = AmmoAddMode.fullAmmo,
    this.prefilledAmmoName,
    this.prefilledManufacturer,
    this.editMode = false,
    this.existingAmmunition,
  }) : super(key: key);

  @override
  State<AddAmmunitionDialog> createState() => _AddAmmunitionDialogState();
}

class _AddAmmunitionDialogState extends State<AddAmmunitionDialog> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  final _formKey = GlobalKey<FormState>();

  // CSV Repository
  late CSVRepository _csvRepository;

  // CSV Data
  List<CSVAmmunitionModel> _ammoData = [];
  AmmunitionOptionsModel? _ammoOptions;
  bool _isLoading = true;
  String _errorMessage = '';

  // Form controllers for manual entry
  final _manualNameController = TextEditingController();
  final _manualManufacturerController = TextEditingController();
  final _manualCaliberController = TextEditingController();

  // Basic Information Controllers
  final _bulletWeightController = TextEditingController();
  final _notesController = TextEditingController();
  final _roundCountController = TextEditingController();


  // Advanced Information Controllers
  final _muzzleVelocityController = TextEditingController();
  final _ballisticCoefficientController = TextEditingController();
  final _sectionalDensityController = TextEditingController();
  final _recoilEnergyController = TextEditingController();
  final _powderChargeController = TextEditingController();
  final _powderTypeController = TextEditingController();
  final _lotNumberController = TextEditingController();
  final _chronographFPSController = TextEditingController();

  // Selection state for basic info
  String? _selectedCaliber;
  String? _selectedBulletType;
  String? _selectedManufacturer;

  // Selection state for advanced info
  String? _selectedCartridgeType;
  String? _selectedCaseMaterial;
  String? _selectedPrimerType;
  String? _selectedPressureClass;

  // Filtered options
  List<String> _availableManufacturers = [];
  List<String> _availableCalibres = [];

  // Manual entry mode
  bool _isManualEntry = false;

  // Advanced section toggle
  bool _isAdvancedExpanded = false;

  // "Other" input controllers
  final _caliberOtherController = TextEditingController();
  final _bulletTypeOtherController = TextEditingController();
  final _manufacturerOtherController = TextEditingController();
  final _cartridgeTypeOtherController = TextEditingController();
  final _caseMaterialOtherController = TextEditingController();
  final _primerTypeOtherController = TextEditingController();
  final _pressureClassOtherController = TextEditingController();

  // Show "other" inputs
  bool _showCaliberOther = false;
  bool _showBulletTypeOther = false;
  bool _showManufacturerOther = false;
  bool _showCartridgeTypeOther = false;
  bool _showCaseMaterialOther = false;
  bool _showPrimerTypeOther = false;
  bool _showPressureClassOther = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _csvRepository = CSVRepositoryImpl();
    _loadCSVData();
    _initializePrefilledData();
  }

  void _initializePrefilledData() {
    // If in edit mode, populate all fields with existing ammunition data
    if (widget.editMode && widget.existingAmmunition != null) {
      final ammo = widget.existingAmmunition!;

      // Set basic selections
      _selectedCaliber = ammo.caliber;
      _selectedManufacturer = ammo.manufacturer;
      _selectedBulletType = ammo.bullet.type;

      // Populate basic controllers
      _manualNameController.text = ammo.name;
      _manualManufacturerController.text = ammo.manufacturer;
      _manualCaliberController.text = ammo.caliber;
      _bulletWeightController.text = ammo.bullet.weight ?? '';
      _notesController.text = ammo.notes ?? '';
      _roundCountController.text = ammo.count.toString() ?? '0';

      // Populate advanced controllers
      _muzzleVelocityController.text = ammo.velocity?.toString() ?? '';
      _ballisticCoefficientController.text = ammo.bullet.bc.g1?.toString() ?? '';
      _sectionalDensityController.text = ammo.sectionalDensity?.toString() ?? '';
      _recoilEnergyController.text = ammo.recoilEnergy?.toString() ?? '';
      _powderChargeController.text = ammo.powderCharge?.toString() ?? '';
      _powderTypeController.text = ammo.powderType ?? '';
      _lotNumberController.text = ammo.lotNumber ?? '';
      _chronographFPSController.text = ammo.chronographFPS?.toString() ?? '';

      // Set advanced selections
      _selectedCartridgeType = ammo.cartridgeType;
      _selectedCaseMaterial = ammo.caseMaterial;
      _selectedPrimerType = ammo.primerType;
      _selectedPressureClass = ammo.pressureClass;

      // Set manual entry mode for edit
      _isManualEntry = true;
      return;
    }

    // Original prefilled data logic for add mode
    if (widget.prefilledAmmoName != null) {
      _manualNameController.text = widget.prefilledAmmoName!;
    }

    if (widget.prefilledManufacturer != null) {
      _selectedManufacturer = widget.prefilledManufacturer;
      _manualManufacturerController.text = widget.prefilledManufacturer!;
    }

    // Set manual entry mode for focused add operations
    if (widget.addMode != AmmoAddMode.fullAmmo) {
      _isManualEntry = true;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _manualNameController.dispose();
    _manualManufacturerController.dispose();
    _manualCaliberController.dispose();
    _bulletWeightController.dispose();
    _notesController.dispose();
    _roundCountController.dispose();
    _muzzleVelocityController.dispose();
    _ballisticCoefficientController.dispose();
    _sectionalDensityController.dispose();
    _recoilEnergyController.dispose();
    _powderChargeController.dispose();
    _powderTypeController.dispose();
    _lotNumberController.dispose();
    _chronographFPSController.dispose();
    _caliberOtherController.dispose();
    _bulletTypeOtherController.dispose();
    _manufacturerOtherController.dispose();
    _cartridgeTypeOtherController.dispose();
    _caseMaterialOtherController.dispose();
    _primerTypeOtherController.dispose();
    _pressureClassOtherController.dispose();
    super.dispose();
  }

  Future<void> _loadCSVData() async {
    try {
      _ammoData = await _csvRepository.getAmmunition();
      _ammoOptions = await _csvRepository.getAmmunitionOptions();
      setState(() {
        _isLoading = false;
        _updateAvailableOptions();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load ammunition data: $e';
      });
    }
  }

  void _updateAvailableOptions() {
    // Update available options based on CSV data if needed
    // This can be expanded based on your CSV structure
  }

  String _getDialogTitle() {
    if (widget.editMode) {
      return 'Update Ammunition';
    }

    switch (widget.addMode) {
      case AmmoAddMode.manufacturer:
        return 'Add New Manufacturer';
      case AmmoAddMode.caliber:
        return 'Add New Caliber';
      default:
        return _isManualEntry ? 'Add Custom Ammunition' : 'Add Ammunition';
    }
  }

  String _getSubmitButtonText() {
    if (widget.editMode) {
      return 'Update Ammunition';
    }

    switch (widget.addMode) {
      case AmmoAddMode.manufacturer:
      case AmmoAddMode.caliber:
        return 'Add';
      default:
        return 'Add Ammunition';
    }
  }

  void _toggleAdvancedSection() {
    setState(() {
      _isAdvancedExpanded = !_isAdvancedExpanded;
      if (_isAdvancedExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
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
                // Content
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBasicInformationSection(),
                          const SizedBox(height: 20),
                          _buildAdvancedToggle(),
                          _buildAdvancedSection(),
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

  Widget _buildBasicInformationSection() {
    return Container(
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
          const Text(
            'Basic Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Caliber Dropdown
          _buildDropdownWithOther(
            label: 'Caliber *',
            value: _selectedCaliber,
            items: _ammoOptions?.calibers ?? [],
            onChanged: (value) {
              setState(() {
                _selectedCaliber = value;
                _showCaliberOther = value == 'Other...';
              });
            },
            showOtherInput: _showCaliberOther,
            otherController: _caliberOtherController,
            onOtherSaved: (customValue) async {
              await _csvRepository.addCustomCaliber(customValue);
              // Reload options to include the new value
              _ammoOptions = await _csvRepository.getAmmunitionOptions();
              setState(() {
                _selectedCaliber = customValue;
                _showCaliberOther = false;
              });
            },
          ),

          const SizedBox(height: 16),

          // Bullet Type Dropdown
          _buildDropdownWithOther(
            label: 'Bullet Type *',
            value: _selectedBulletType,
            items: _ammoOptions?.bulletTypes ?? [],
            onChanged: (value) {
              setState(() {
                _selectedBulletType = value;
                _showBulletTypeOther = value == 'Other...';
              });
            },
            showOtherInput: _showBulletTypeOther,
            otherController: _bulletTypeOtherController,
            onOtherSaved: (customValue) async {
              await _csvRepository.addCustomBulletType(customValue);
              _ammoOptions = await _csvRepository.getAmmunitionOptions();
              setState(() {
                _selectedBulletType = customValue;
                _showBulletTypeOther = false;
              });
            },
          ),

          const SizedBox(height: 16),

          // Bullet Weight
          TextFormField(
            controller: _bulletWeightController,
            decoration: const InputDecoration(
              labelText: 'Bullet Weight (grains) *',
              hintText: '62',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Manufacturer Dropdown
          _buildDropdownWithOther(
            label: 'Manufacturer *',
            value: _selectedManufacturer,
            items: _ammoOptions?.manufacturers ?? [],
            onChanged: (value) {
              setState(() {
                _selectedManufacturer = value;
                _showManufacturerOther = value == 'Other...';
              });
            },
            showOtherInput: _showManufacturerOther,
            otherController: _manufacturerOtherController,
            onOtherSaved: (customValue) async {
              await _csvRepository.addCustomManufacturer(customValue);
              _ammoOptions = await _csvRepository.getAmmunitionOptions();
              setState(() {
                _selectedManufacturer = customValue;
                _showManufacturerOther = false;
              });
            },
          ),

          const SizedBox(height: 16),

          // Round Count
          TextFormField(
            controller: _roundCountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Round Count',
              hintText: 'Approximate rounds fired',

              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),
          // Notes
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Enter notes here...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedToggle() {
    return GestureDetector(
      onTap: _toggleAdvancedSection,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.success.withOpacity(0.3)),
        ),
        child:Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _isAdvancedExpanded
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
              _isAdvancedExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppTheme.success,
            ),
          ],
        ),

      ),
    );
  }

  Widget _buildAdvancedSection() {
    return SizeTransition(
      sizeFactor: _expandAnimation,
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.borderColor, style: BorderStyle.solid),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: const Text(
                'Advanced Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildDropdownWithOther(
              label: 'Cartridge Type',
              value: _selectedCartridgeType,
              items: _ammoOptions?.cartridgeTypes ?? [],
              onChanged: (value) {
                setState(() {
                  _selectedCartridgeType = value;
                  _showCartridgeTypeOther = value == 'Other...';
                });
              },
              showOtherInput: _showCartridgeTypeOther,
              otherController: _cartridgeTypeOtherController,
              onOtherSaved: (customValue) async {
                await _csvRepository.addCustomCartridgeType(customValue);
                _ammoOptions = await _csvRepository.getAmmunitionOptions();
                setState(() {
                  _selectedCartridgeType = customValue;
                  _showCartridgeTypeOther = false;
                });
              },
            ),
            const SizedBox(height: 16),

            _buildDropdownWithOther(
              label: 'Case Material',
              value: _selectedCaseMaterial,
              items: _ammoOptions?.caseMaterials ?? [],
              onChanged: (value) {
                setState(() {
                  _selectedCaseMaterial = value;
                  _showCaseMaterialOther = value == 'Other...';
                });
              },
              showOtherInput: _showCaseMaterialOther,
              otherController: _caseMaterialOtherController,
              onOtherSaved: (customValue) async {
                await _csvRepository.addCustomCaseMaterial(customValue);
                _ammoOptions = await _csvRepository.getAmmunitionOptions();
                setState(() {
                  _selectedCaseMaterial = customValue;
                  _showCaseMaterialOther = false;
                });
              },
            ),
            const SizedBox(height: 16),

            _buildDropdownWithOther(
              label: 'Primer Type',
              value: _selectedPrimerType,
              items: _ammoOptions?.primerTypes ?? [],
              onChanged: (value) {
                setState(() {
                  _selectedPrimerType = value;
                  _showPrimerTypeOther = value == 'Other...';
                });
              },
              showOtherInput: _showPrimerTypeOther,
              otherController: _primerTypeOtherController,
              onOtherSaved: (customValue) async {
                await _csvRepository.addCustomPrimerType(customValue);
                _ammoOptions = await _csvRepository.getAmmunitionOptions();
                setState(() {
                  _selectedPrimerType = customValue;
                  _showPrimerTypeOther = false;
                });
              },
            ),
            const SizedBox(height: 16),

            _buildDropdownWithOther(
              label: 'Pressure Class',
              value: _selectedPressureClass,
              items: _ammoOptions?.pressureClasses ?? [],
              onChanged: (value) {
                setState(() {
                  _selectedPressureClass = value;
                  _showPressureClassOther = value == 'Other...';
                });
              },
              showOtherInput: _showPressureClassOther,
              otherController: _pressureClassOtherController,
              onOtherSaved: (customValue) async {
                await _csvRepository.addCustomPressureClass(customValue);
                _ammoOptions = await _csvRepository.getAmmunitionOptions();
                setState(() {
                  _selectedPressureClass = customValue;
                  _showPressureClassOther = false;
                });
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _muzzleVelocityController,
              decoration: const InputDecoration(
                labelText: 'Muzzle Velocity (fps)',
                hintText: '3100',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _ballisticCoefficientController,
              decoration: const InputDecoration(
                labelText: 'Ballistic Coefficient (G1)',
                hintText: '0.307',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _sectionalDensityController,
              decoration: const InputDecoration(
                labelText: 'Sectional Density',
                hintText: '0.177',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _recoilEnergyController,
              decoration: const InputDecoration(
                labelText: 'Recoil Energy (ft-lbs)',
                hintText: '4.2',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _powderChargeController,
              decoration: const InputDecoration(
                labelText: 'Powder Charge (grains)',
                hintText: '24.5',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _powderTypeController,
              decoration: const InputDecoration(
                labelText: 'Powder Type',
                hintText: 'H335',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _lotNumberController,
              decoration: const InputDecoration(
                labelText: 'Lot Number',
                hintText: 'Enter lot number here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _chronographFPSController,
              decoration: const InputDecoration(
                labelText: 'Chronograph FPS (optional)',
                hintText: 'Enter measured FPS here...',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildDropdownWithOther({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool showOtherInput,
    required TextEditingController otherController,
    Future<void> Function(String)? onOtherSaved,
  }) {
    final allItems = [...items, 'Other...'];

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
          items: allItems.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  color: item == 'Other...' ? AppTheme.accent : AppTheme.textPrimary,
                  fontWeight: item == 'Other...' ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: label.contains('*') ? (value) => value == null ? 'Please select an option' : null : null,
        ),
        if (showOtherInput) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: otherController,
                  decoration: InputDecoration(
                    labelText: 'Enter other ${label.toLowerCase().replaceAll('*', '').trim()}',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  validator: (value) {
                    if (showOtherInput && (value == null || value.isEmpty)) {
                      return 'Please enter the custom value';
                    }
                    return null;
                  },
                ),
              ),
              if (onOtherSaved != null) ...[
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (otherController.text.isNotEmpty) {
                      await onOtherSaved!(otherController.text);
                      otherController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Custom ${label.toLowerCase().replaceAll('*', '').trim()} added successfully!'),
                          backgroundColor: AppTheme.success,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Get final values (either from dropdown or "other" input)
      String finalCaliber = _selectedCaliber == 'Other...'
          ? _caliberOtherController.text
          : _selectedCaliber ?? '';

      String finalBulletType = _selectedBulletType == 'Other...'
          ? _bulletTypeOtherController.text
          : _selectedBulletType ?? '';

      String finalManufacturer = _selectedManufacturer == 'Other...'
          ? _manufacturerOtherController.text
          : _selectedManufacturer ?? '';

      String? finalCartridgeType = _selectedCartridgeType == 'Other...'
          ? _cartridgeTypeOtherController.text
          : _selectedCartridgeType;

      String? finalCaseMaterial = _selectedCaseMaterial == 'Other...'
          ? _caseMaterialOtherController.text
          : _selectedCaseMaterial;

      String? finalPrimerType = _selectedPrimerType == 'Other...'
          ? _primerTypeOtherController.text
          : _selectedPrimerType;

      String? finalPressureClass = _selectedPressureClass == 'Other...'
          ? _pressureClassOtherController.text
          : _selectedPressureClass;

      // Generate ammunition name
      String ammunitionName = '${finalManufacturer} ${finalCaliber}';
      if (_bulletWeightController.text.isNotEmpty) {
        ammunitionName += ' ${_bulletWeightController.text}gr';
      }
      if (finalBulletType.isNotEmpty) {
        ammunitionName += ' ${finalBulletType}';
      }

      // Create ammunition entity with all fields
      final ammunition = Ammunition(
        id: widget.editMode ? widget.existingAmmunition!.id : const Uuid().v4(),
        name: ammunitionName,
        manufacturer: finalManufacturer,
        caliber: finalCaliber,
        bullet: Bullet(
          weight: _bulletWeightController.text.isNotEmpty ? _bulletWeightController.text : null,
          type: finalBulletType.isNotEmpty ? finalBulletType : null,
          manufacturer: finalManufacturer.isNotEmpty ? finalManufacturer : null,
          bc: BallisticCoefficient(
            g1: _ballisticCoefficientController.text.isNotEmpty
                ? double.tryParse(_ballisticCoefficientController.text)
                : null,
            g7: null,
          ),
        ),
        powder: _powderTypeController.text.isNotEmpty ? _powderTypeController.text : null,
        primer: finalPrimerType,
        brass: finalCaseMaterial,
        velocity: _muzzleVelocityController.text.isNotEmpty
            ? int.tryParse(_muzzleVelocityController.text)
            : null,
        es: null,
        sd: null,
        lotNumber: _lotNumberController.text.isNotEmpty ? _lotNumberController.text : null,
        count: _roundCountController.text.isNotEmpty ? int.tryParse(_roundCountController.text) ?? 0 : (widget.editMode ? widget.existingAmmunition!.count : 0),
        // Default count, user can update later
        price: null,
        tempStable: false, // Default value
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        // Advanced fields
        cartridgeType: finalCartridgeType,
        caseMaterial: finalCaseMaterial,
        primerType: finalPrimerType,
        pressureClass: finalPressureClass,
        sectionalDensity: _sectionalDensityController.text.isNotEmpty
            ? double.tryParse(_sectionalDensityController.text)
            : null,
        recoilEnergy: _recoilEnergyController.text.isNotEmpty
            ? double.tryParse(_recoilEnergyController.text)
            : null,
        powderCharge: _powderChargeController.text.isNotEmpty
            ? double.tryParse(_powderChargeController.text)
            : null,
        powderType: _powderTypeController.text.isNotEmpty ? _powderTypeController.text : null,
        chronographFPS: _chronographFPSController.text.isNotEmpty
            ? int.tryParse(_chronographFPSController.text)
            : null,
      );

      // Add new CSV entry for new combinations (only if not in edit mode)
      if (!widget.editMode && widget.addMode == AmmoAddMode.fullAmmo) {
        try {
          await _csvRepository.addAmmunition(CSVAmmunitionModel(
            ammunitionName: ammunitionName,
            manufacturer: finalManufacturer,
            caliber: finalCaliber,
          ));
        } catch (e) {
          print('Warning: Could not add to CSV: $e');
          // Continue with adding to Firestore even if CSV fails
        }
      }

      // Submit to bloc
      if (widget.editMode) {
        context.read<LoadoutBloc>().add(UpdateAmmunitionEvent(ammunition));
      } else {
        context.read<LoadoutBloc>().add(AddAmmunitionEvent(ammunition));
      }

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.editMode
              ? 'Ammunition "${ammunition.name}" updated successfully!'
              : 'Ammunition "${ammunition.name}" added successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }
}