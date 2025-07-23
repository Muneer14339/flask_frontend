// lib/features/loadout/data/repositories/csv_repository.dart - Updated version with custom options support
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/csv_rifle_model.dart';
import '../models/csv_ammunition_model.dart';
import '../models/csv_scope_model.dart';

// Enhanced model for ammunition CSV data with extended fields
class CSVAmmunitionModelExtended {
  final String ammunitionName;
  final String manufacturer;
  final String caliber;
  final String? bulletType;
  final String? cartridgeType;
  final String? caseMaterial;
  final String? primerType;
  final String? pressureClass;

  const CSVAmmunitionModelExtended({
    required this.ammunitionName,
    required this.manufacturer,
    required this.caliber,
    this.bulletType,
    this.cartridgeType,
    this.caseMaterial,
    this.primerType,
    this.pressureClass,
  });

  Map<String, dynamic> toJson() {
    return {
      'ammunitionName': ammunitionName,
      'manufacturer': manufacturer,
      'caliber': caliber,
      'bulletType': bulletType,
      'cartridgeType': cartridgeType,
      'caseMaterial': caseMaterial,
      'primerType': primerType,
      'pressureClass': pressureClass,
    };
  }

  factory CSVAmmunitionModelExtended.fromJson(Map<String, dynamic> json) {
    return CSVAmmunitionModelExtended(
      ammunitionName: json['ammunitionName'] as String,
      manufacturer: json['manufacturer'] as String,
      caliber: json['caliber'] as String,
      bulletType: json['bulletType'] as String?,
      cartridgeType: json['cartridgeType'] as String?,
      caseMaterial: json['caseMaterial'] as String?,
      primerType: json['primerType'] as String?,
      pressureClass: json['pressureClass'] as String?,
    );
  }
}

// Add new model for maintenance CSV data
class CSVMaintenanceModel {
  final String component;
  final String task;
  final String icon;

  const CSVMaintenanceModel({
    required this.component,
    required this.task,
    required this.icon,
  });
}

// Enhanced model for ammunition options
class AmmunitionOptionsModel {
  final List<String> calibers;
  final List<String> bulletTypes;
  final List<String> manufacturers;
  final List<String> cartridgeTypes;
  final List<String> caseMaterials;
  final List<String> primerTypes;
  final List<String> pressureClasses;

  const AmmunitionOptionsModel({
    required this.calibers,
    required this.bulletTypes,
    required this.manufacturers,
    required this.cartridgeTypes,
    required this.caseMaterials,
    required this.primerTypes,
    required this.pressureClasses,
  });
}

abstract class CSVRepository {
  Future<List<CSVRifleModel>> getRifles();
  Future<List<CSVAmmunitionModel>> getAmmunition();
  Future<List<CSVScopeModel>> getScopes();
  Future<List<CSVMaintenanceModel>> getMaintenanceTasks();
  Future<AmmunitionOptionsModel> getAmmunitionOptions();

  Future<void> addRifle(CSVRifleModel rifle);
  Future<void> addAmmunition(CSVAmmunitionModel ammunition);
  Future<void> addScope(CSVScopeModel scope);
  Future<void> addMaintenanceTask(CSVMaintenanceModel maintenanceTask);

  // New methods for adding custom options
  Future<void> addCustomCaliber(String caliber);
  Future<void> addCustomBulletType(String bulletType);
  Future<void> addCustomManufacturer(String manufacturer);
  Future<void> addCustomCartridgeType(String cartridgeType);
  Future<void> addCustomCaseMaterial(String caseMaterial);
  Future<void> addCustomPrimerType(String primerType);
  Future<void> addCustomPressureClass(String pressureClass);

  Future<void> saveRiflesToFile(List<CSVRifleModel> rifles);
  Future<void> saveAmmunitionToFile(List<CSVAmmunitionModel> ammunition);
  Future<void> saveScopesToFile(List<CSVScopeModel> scopes);
  Future<void> saveMaintenanceTasksToFile(List<CSVMaintenanceModel> tasks);
}

class CSVRepositoryImpl implements CSVRepository {
  static const String rifleFileName = 'full_rifle_list.csv';
  static const String ammoFileName = 'rifle_ammunition_list.csv';
  static const String scopeFileName = 'scopes.csv';
  static const String maintenanceFileName = 'maintenance.csv';
  static const String ammoOptionsFileName = 'ammunition_options.csv';

  List<CSVRifleModel>? _cachedRifles;
  List<CSVAmmunitionModel>? _cachedAmmunition;
  List<CSVScopeModel>? _cachedScopes;
  List<CSVMaintenanceModel>? _cachedMaintenanceTasks;
  AmmunitionOptionsModel? _cachedAmmoOptions;

  @override
  Future<List<CSVRifleModel>> getRifles() async {
    if (_cachedRifles != null) return _cachedRifles!;

    try {
      final file = await _getLocalFile(rifleFileName);
      if (await file.exists()) {
        final contents = await file.readAsString();
        _cachedRifles = _parseRifleCSV(contents);
      } else {
        _cachedRifles = _getInitialRifleData();
        await saveRiflesToFile(_cachedRifles!);
      }
      return _cachedRifles!;
    } catch (e) {
      _cachedRifles = _getInitialRifleData();
      return _cachedRifles!;
    }
  }

  @override
  Future<List<CSVAmmunitionModel>> getAmmunition() async {
    if (_cachedAmmunition != null) return _cachedAmmunition!;

    try {
      final file = await _getLocalFile(ammoFileName);
      if (await file.exists()) {
        final contents = await file.readAsString();
        _cachedAmmunition = _parseAmmunitionCSV(contents);
      } else {
        _cachedAmmunition = _getInitialAmmunitionData();
        await saveAmmunitionToFile(_cachedAmmunition!);
      }
      return _cachedAmmunition!;
    } catch (e) {
      _cachedAmmunition = _getInitialAmmunitionData();
      return _cachedAmmunition!;
    }
  }

  @override
  Future<List<CSVScopeModel>> getScopes() async {
    if (_cachedScopes != null) return _cachedScopes!;

    try {
      final file = await _getLocalFile(scopeFileName);
      if (await file.exists()) {
        final contents = await file.readAsString();
        _cachedScopes = _parseScopeCSV(contents);
      } else {
        _cachedScopes = _getInitialScopeData();
        await saveScopesToFile(_cachedScopes!);
      }
      return _cachedScopes!;
    } catch (e) {
      _cachedScopes = _getInitialScopeData();
      return _cachedScopes!;
    }
  }

  @override
  Future<List<CSVMaintenanceModel>> getMaintenanceTasks() async {
    if (_cachedMaintenanceTasks != null) return _cachedMaintenanceTasks!;

    try {
      final file = await _getLocalFile(maintenanceFileName);
      if (await file.exists()) {
        final contents = await file.readAsString();
        _cachedMaintenanceTasks = _parseMaintenanceCSV(contents);
      } else {
        _cachedMaintenanceTasks = _getInitialMaintenanceData();
        await saveMaintenanceTasksToFile(_cachedMaintenanceTasks!);
      }
      return _cachedMaintenanceTasks!;
    } catch (e) {
      _cachedMaintenanceTasks = _getInitialMaintenanceData();
      return _cachedMaintenanceTasks!;
    }
  }

  @override
  Future<AmmunitionOptionsModel> getAmmunitionOptions() async {
    if (_cachedAmmoOptions != null) return _cachedAmmoOptions!;

    try {
      final file = await _getLocalFile(ammoOptionsFileName);
      if (await file.exists()) {
        final contents = await file.readAsString();
        _cachedAmmoOptions = _parseAmmunitionOptions(contents);
      } else {
        _cachedAmmoOptions = _getInitialAmmunitionOptions();
        await _saveAmmunitionOptionsToFile(_cachedAmmoOptions!);
      }
      return _cachedAmmoOptions!;
    } catch (e) {
      _cachedAmmoOptions = _getInitialAmmunitionOptions();
      return _cachedAmmoOptions!;
    }
  }

  // Custom option add methods
  @override
  Future<void> addCustomCaliber(String caliber) async {
    final options = await getAmmunitionOptions();
    if (!options.calibers.contains(caliber)) {
      final updatedOptions = AmmunitionOptionsModel(
        calibers: [...options.calibers, caliber]..sort(),
        bulletTypes: options.bulletTypes,
        manufacturers: options.manufacturers,
        cartridgeTypes: options.cartridgeTypes,
        caseMaterials: options.caseMaterials,
        primerTypes: options.primerTypes,
        pressureClasses: options.pressureClasses,
      );
      await _saveAmmunitionOptionsToFile(updatedOptions);
      _cachedAmmoOptions = updatedOptions;
    }
  }

  @override
  Future<void> addCustomBulletType(String bulletType) async {
    final options = await getAmmunitionOptions();
    if (!options.bulletTypes.contains(bulletType)) {
      final updatedOptions = AmmunitionOptionsModel(
        calibers: options.calibers,
        bulletTypes: [...options.bulletTypes, bulletType]..sort(),
        manufacturers: options.manufacturers,
        cartridgeTypes: options.cartridgeTypes,
        caseMaterials: options.caseMaterials,
        primerTypes: options.primerTypes,
        pressureClasses: options.pressureClasses,
      );
      await _saveAmmunitionOptionsToFile(updatedOptions);
      _cachedAmmoOptions = updatedOptions;
    }
  }

  @override
  Future<void> addCustomManufacturer(String manufacturer) async {
    final options = await getAmmunitionOptions();
    if (!options.manufacturers.contains(manufacturer)) {
      final updatedOptions = AmmunitionOptionsModel(
        calibers: options.calibers,
        bulletTypes: options.bulletTypes,
        manufacturers: [...options.manufacturers, manufacturer]..sort(),
        cartridgeTypes: options.cartridgeTypes,
        caseMaterials: options.caseMaterials,
        primerTypes: options.primerTypes,
        pressureClasses: options.pressureClasses,
      );
      await _saveAmmunitionOptionsToFile(updatedOptions);
      _cachedAmmoOptions = updatedOptions;
    }
  }

  @override
  Future<void> addCustomCartridgeType(String cartridgeType) async {
    final options = await getAmmunitionOptions();
    if (!options.cartridgeTypes.contains(cartridgeType)) {
      final updatedOptions = AmmunitionOptionsModel(
        calibers: options.calibers,
        bulletTypes: options.bulletTypes,
        manufacturers: options.manufacturers,
        cartridgeTypes: [...options.cartridgeTypes, cartridgeType]..sort(),
        caseMaterials: options.caseMaterials,
        primerTypes: options.primerTypes,
        pressureClasses: options.pressureClasses,
      );
      await _saveAmmunitionOptionsToFile(updatedOptions);
      _cachedAmmoOptions = updatedOptions;
    }
  }

  @override
  Future<void> addCustomCaseMaterial(String caseMaterial) async {
    final options = await getAmmunitionOptions();
    if (!options.caseMaterials.contains(caseMaterial)) {
      final updatedOptions = AmmunitionOptionsModel(
        calibers: options.calibers,
        bulletTypes: options.bulletTypes,
        manufacturers: options.manufacturers,
        cartridgeTypes: options.cartridgeTypes,
        caseMaterials: [...options.caseMaterials, caseMaterial]..sort(),
        primerTypes: options.primerTypes,
        pressureClasses: options.pressureClasses,
      );
      await _saveAmmunitionOptionsToFile(updatedOptions);
      _cachedAmmoOptions = updatedOptions;
    }
  }

  @override
  Future<void> addCustomPrimerType(String primerType) async {
    final options = await getAmmunitionOptions();
    if (!options.primerTypes.contains(primerType)) {
      final updatedOptions = AmmunitionOptionsModel(
        calibers: options.calibers,
        bulletTypes: options.bulletTypes,
        manufacturers: options.manufacturers,
        cartridgeTypes: options.cartridgeTypes,
        caseMaterials: options.caseMaterials,
        primerTypes: [...options.primerTypes, primerType]..sort(),
        pressureClasses: options.pressureClasses,
      );
      await _saveAmmunitionOptionsToFile(updatedOptions);
      _cachedAmmoOptions = updatedOptions;
    }
  }

  @override
  Future<void> addCustomPressureClass(String pressureClass) async {
    final options = await getAmmunitionOptions();
    if (!options.pressureClasses.contains(pressureClass)) {
      final updatedOptions = AmmunitionOptionsModel(
        calibers: options.calibers,
        bulletTypes: options.bulletTypes,
        manufacturers: options.manufacturers,
        cartridgeTypes: options.cartridgeTypes,
        caseMaterials: options.caseMaterials,
        primerTypes: options.primerTypes,
        pressureClasses: [...options.pressureClasses, pressureClass]..sort(),
      );
      await _saveAmmunitionOptionsToFile(updatedOptions);
      _cachedAmmoOptions = updatedOptions;
    }
  }

  // Implementation of existing methods (keeping them the same)
  @override
  Future<void> addRifle(CSVRifleModel rifle) async {
    final rifles = await getRifles();
    rifles.add(rifle);
    _cachedRifles = rifles;
    await saveRiflesToFile(rifles);
  }

  @override
  Future<void> addAmmunition(CSVAmmunitionModel ammunition) async {
    final ammo = await getAmmunition();
    ammo.add(ammunition);
    _cachedAmmunition = ammo;
    await saveAmmunitionToFile(ammo);
  }

  @override
  Future<void> addScope(CSVScopeModel scope) async {
    final scopes = await getScopes();
    scopes.add(scope);
    _cachedScopes = scopes;
    await saveScopesToFile(scopes);
  }

  @override
  Future<void> addMaintenanceTask(CSVMaintenanceModel maintenanceTask) async {
    final tasks = await getMaintenanceTasks();
    tasks.add(maintenanceTask);
    _cachedMaintenanceTasks = tasks;
    await saveMaintenanceTasksToFile(tasks);
  }

  @override
  Future<void> saveRiflesToFile(List<CSVRifleModel> rifles) async {
    try {
      final file = await _getLocalFile(rifleFileName);
      final csvContent = _generateRifleCSV(rifles);
      await file.writeAsString(csvContent);
    } catch (e) {
      print('Error saving rifles to file: $e');
    }
  }

  @override
  Future<void> saveAmmunitionToFile(List<CSVAmmunitionModel> ammunition) async {
    try {
      final file = await _getLocalFile(ammoFileName);
      final csvContent = _generateAmmunitionCSV(ammunition);
      await file.writeAsString(csvContent);
    } catch (e) {
      print('Error saving ammunition to file: $e');
    }
  }

  @override
  Future<void> saveScopesToFile(List<CSVScopeModel> scopes) async {
    try {
      final file = await _getLocalFile(scopeFileName);
      final csvContent = _generateScopeCSV(scopes);
      await file.writeAsString(csvContent);
    } catch (e) {
      print('Error saving scopes to file: $e');
    }
  }

  @override
  Future<void> saveMaintenanceTasksToFile(List<CSVMaintenanceModel> tasks) async {
    try {
      final file = await _getLocalFile(maintenanceFileName);
      final csvContent = _generateMaintenanceCSV(tasks);
      await file.writeAsString(csvContent);
    } catch (e) {
      print('Error saving maintenance tasks to file: $e');
    }
  }

  Future<void> _saveAmmunitionOptionsToFile(AmmunitionOptionsModel options) async {
    try {
      final file = await _getLocalFile(ammoOptionsFileName);
      final csvContent = _generateAmmunitionOptionsCSV(options);
      await file.writeAsString(csvContent);
    } catch (e) {
      print('Error saving ammunition options to file: $e');
    }
  }

  Future<File> _getLocalFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$fileName');
  }

  // Parse methods
  AmmunitionOptionsModel _parseAmmunitionOptions(String csvContent) {
    final lines = csvContent.split('\n').where((line) => line.trim().isNotEmpty).toList();
    if (lines.isEmpty) return _getInitialAmmunitionOptions();

    final calibers = <String>[];
    final bulletTypes = <String>[];
    final manufacturers = <String>[];
    final cartridgeTypes = <String>[];
    final caseMaterials = <String>[];
    final primerTypes = <String>[];
    final pressureClasses = <String>[];

    String currentSection = '';

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.startsWith('[') && trimmedLine.endsWith(']')) {
        currentSection = trimmedLine.substring(1, trimmedLine.length - 1);
        continue;
      }

      if (trimmedLine.isNotEmpty) {
        switch (currentSection) {
          case 'Calibers':
            calibers.add(trimmedLine);
            break;
          case 'BulletTypes':
            bulletTypes.add(trimmedLine);
            break;
          case 'Manufacturers':
            manufacturers.add(trimmedLine);
            break;
          case 'CartridgeTypes':
            cartridgeTypes.add(trimmedLine);
            break;
          case 'CaseMaterials':
            caseMaterials.add(trimmedLine);
            break;
          case 'PrimerTypes':
            primerTypes.add(trimmedLine);
            break;
          case 'PressureClasses':
            pressureClasses.add(trimmedLine);
            break;
        }
      }
    }

    return AmmunitionOptionsModel(
      calibers: calibers..sort(),
      bulletTypes: bulletTypes..sort(),
      manufacturers: manufacturers..sort(),
      cartridgeTypes: cartridgeTypes..sort(),
      caseMaterials: caseMaterials..sort(),
      primerTypes: primerTypes..sort(),
      pressureClasses: pressureClasses..sort(),
    );
  }

  String _generateAmmunitionOptionsCSV(AmmunitionOptionsModel options) {
    final buffer = StringBuffer();

    buffer.writeln('[Calibers]');
    for (final caliber in options.calibers) {
      buffer.writeln(caliber);
    }
    buffer.writeln();

    buffer.writeln('[BulletTypes]');
    for (final bulletType in options.bulletTypes) {
      buffer.writeln(bulletType);
    }
    buffer.writeln();

    buffer.writeln('[Manufacturers]');
    for (final manufacturer in options.manufacturers) {
      buffer.writeln(manufacturer);
    }
    buffer.writeln();

    buffer.writeln('[CartridgeTypes]');
    for (final cartridgeType in options.cartridgeTypes) {
      buffer.writeln(cartridgeType);
    }
    buffer.writeln();

    buffer.writeln('[CaseMaterials]');
    for (final caseMaterial in options.caseMaterials) {
      buffer.writeln(caseMaterial);
    }
    buffer.writeln();

    buffer.writeln('[PrimerTypes]');
    for (final primerType in options.primerTypes) {
      buffer.writeln(primerType);
    }
    buffer.writeln();

    buffer.writeln('[PressureClasses]');
    for (final pressureClass in options.pressureClasses) {
      buffer.writeln(pressureClass);
    }

    return buffer.toString();
  }

  AmmunitionOptionsModel _getInitialAmmunitionOptions() {
    return const AmmunitionOptionsModel(
      calibers: [
        '.17 HMR',
        '.22 LR',
        '.22 WMR',
        '.22-250 Remington',
        '.223 Remington',
        '.224 Valkyrie',
        '.243 Winchester',
        '.270 Winchester',
        '.30-06 Springfield',
        '.30-30 Winchester',
        '.300 Blackout',
        '.300 Weatherby Magnum',
        '.300 Winchester Magnum',
        '.303 British',
        '.308 Winchester',
        '.338 Lapua Magnum',
        '.408 CheyTac',
        '.45-70 Government',
        '.458 SOCOM',
        '.50 BMG',
        '5.45x39mm',
        '5.56mm NATO',
        '6.5 Creedmoor',
        '6.5 Grendel',
        '6.5x55 Swedish',
        '6.8 SPC',
        '6mm Creedmoor',
        '7.62x39mm',
        '7.62x51mm NATO',
        '7.62x54R',
        '7mm-08 Remington',
        '8mm Mauser',
      ],
      bulletTypes: [
        'CPRN',
        'FMJ',
        'HP',
        'HPBT',
        'JHP',
        'LRN',
        'Soft Point',
        'V-MAX',
      ],
      manufacturers: [
        'Barrett',
        'Berger',
        'Black Hills',
        'Buffalo Bore',
        'CCI',
        'Cutting Edge',
        'Eley',
        'Federal',
        'Hornady',
        'Lake City',
        'Lapua',
        'Lost River',
        'Nosler',
        'Prvi Partizan',
        'Remington',
        'SBR',
        'Sierra',
        'Weatherby',
        'Winchester',
        'Wolf',
      ],
      cartridgeTypes: [
        'Factory',
        'Mil-Surp',
      ],
      caseMaterials: [
        'Brass',
        'Steel',
      ],
      primerTypes: [
        'Berdan',
        'Boxer',
        'Rimfire',
      ],
      pressureClasses: [
        'NATO',
        'SAAMI',
      ],
    );
  }

  // Keep existing parse methods for other CSV files
  List<CSVMaintenanceModel> _parseMaintenanceCSV(String csvContent) {
    // Implementation remains the same as before
    final lines = csvContent.split('\n');
    if (lines.isEmpty) return [];

    final tasks = <CSVMaintenanceModel>[];
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final parts = _parseCSVLine(line);
      if (parts.length >= 3) {
        tasks.add(CSVMaintenanceModel(
          component: parts[0],
          task: parts[1],
          icon: parts[2],
        ));
      }
    }
    return tasks;
  }

  String _generateMaintenanceCSV(List<CSVMaintenanceModel> tasks) {
    final buffer = StringBuffer();
    buffer.writeln('Component,Task,Icon');

    for (final task in tasks) {
      buffer.writeln('${_escapeCSVField(task.component)},${_escapeCSVField(task.task)},${_escapeCSVField(task.icon)}');
    }

    return buffer.toString();
  }

  List<CSVMaintenanceModel> _getInitialMaintenanceData() {
    return [
      // Rifle maintenance tasks
      CSVMaintenanceModel(component: 'Rifle', task: 'Barrel Cleaning', icon: '🧽'),
      CSVMaintenanceModel(component: 'Rifle', task: 'Bore Inspection', icon: '🔍'),
      CSVMaintenanceModel(component: 'Rifle', task: 'Bolt Lubrication', icon: '🛠️'),
      CSVMaintenanceModel(component: 'Rifle', task: 'Action Cleaning', icon: '⚙️'),
      CSVMaintenanceModel(component: 'Rifle', task: 'Trigger Maintenance', icon: '🎯'),
      CSVMaintenanceModel(component: 'Rifle', task: 'Stock Screw Torque Check', icon: '🔧'),
      CSVMaintenanceModel(component: 'Rifle', task: 'Rust Prevention Treatment', icon: '🛡️'),
      CSVMaintenanceModel(component: 'Rifle', task: 'Overall Inspection', icon: '👁️'),

      // Scope maintenance tasks
      CSVMaintenanceModel(component: 'Scope', task: 'Lens Cleaning', icon: '🔭'),
      CSVMaintenanceModel(component: 'Scope', task: 'Mounting Torque Check', icon: '🔧'),
      CSVMaintenanceModel(component: 'Scope', task: 'Zero Verification', icon: '🎯'),
      CSVMaintenanceModel(component: 'Scope', task: 'Battery Replacement', icon: '🔋'),
      CSVMaintenanceModel(component: 'Scope', task: 'Parallax Adjustment Check', icon: '⚡'),
      CSVMaintenanceModel(component: 'Scope', task: 'Reticle Inspection', icon: '👁️'),
      CSVMaintenanceModel(component: 'Scope', task: 'Scope Ring Alignment', icon: '⭕'),

      // Ammunition maintenance tasks
      CSVMaintenanceModel(component: 'Ammunition', task: 'Inventory Check', icon: '📦'),
      CSVMaintenanceModel(component: 'Ammunition', task: 'Storage Condition Review', icon: '🏠'),
      CSVMaintenanceModel(component: 'Ammunition', task: 'Lot Performance Tracking', icon: '📊'),
      CSVMaintenanceModel(component: 'Ammunition', task: 'Expiration Date Check', icon: '📅'),
      CSVMaintenanceModel(component: 'Ammunition', task: 'Case Inspection', icon: '🔍'),
      CSVMaintenanceModel(component: 'Ammunition', task: 'Primer Condition Check', icon: '⚡'),

      // Accessories maintenance tasks
      CSVMaintenanceModel(component: 'Accessories', task: 'Bipod Maintenance', icon: '🦵'),
      CSVMaintenanceModel(component: 'Accessories', task: 'Sling Inspection', icon: '🎗️'),
      CSVMaintenanceModel(component: 'Accessories', task: 'Magazine Spring Check', icon: '🔄'),
      CSVMaintenanceModel(component: 'Accessories', task: 'Rail System Tightness', icon: '🛤️'),
      CSVMaintenanceModel(component: 'Accessories', task: 'Carrying Case Maintenance', icon: '💼'),
      CSVMaintenanceModel(component: 'Accessories', task: 'Tool Kit Inventory', icon: '🧰'),
    ];
  }

  // Keep existing methods for rifles, scopes, and ammunition
  List<CSVScopeModel> _parseScopeCSV(String csvContent) {
    final lines = csvContent.split('\n');
    if (lines.isEmpty) return [];

    final scopes = <CSVScopeModel>[];
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final parts = _parseCSVLine(line);
      if (parts.length >= 9) {
        scopes.add(CSVScopeModel(
          manufacturer: parts[0],
          model: parts[1],
          tubeSize: parts[2],
          focalPlane: parts[3],
          reticle: parts[4],
          trackingUnits: parts[5],
          clickValue: parts[6],
          maxElevation: parts[7],
          maxWindage: parts[8],
        ));
      }
    }
    return scopes;
  }

  String _generateScopeCSV(List<CSVScopeModel> scopes) {
    final buffer = StringBuffer();
    buffer.writeln('Manufacturer,Model,Tube Size,Focal Plane,Reticle,Tracking Units,Click Value,Max Elevation,Max Windage');

    for (final scope in scopes) {
      buffer.writeln('${_escapeCSVField(scope.manufacturer)},${_escapeCSVField(scope.model)},${_escapeCSVField(scope.tubeSize!)},${_escapeCSVField(scope.focalPlane!)},${_escapeCSVField(scope.reticle!)},${_escapeCSVField(scope.trackingUnits!)},${_escapeCSVField(scope.clickValue!)},${_escapeCSVField(scope.maxElevation!)},${_escapeCSVField(scope.maxWindage!)}');
    }

    return buffer.toString();
  }

  List<CSVScopeModel> _getInitialScopeData() {
    return [
      CSVScopeModel(manufacturer: 'Leupold', model: 'VX-Freedom 3-9x40', tubeSize: '1"', focalPlane: 'SFP', reticle: 'Duplex', trackingUnits: 'MOA', clickValue: '1/4 MOA', maxElevation: '60 MOA', maxWindage: '60 MOA'),
      CSVScopeModel(manufacturer: 'Vortex', model: 'Crossfire II 4-12x50', tubeSize: '1"', focalPlane: 'SFP', reticle: 'V-Plex', trackingUnits: 'MOA', clickValue: '1/4 MOA', maxElevation: '65 MOA', maxWindage: '65 MOA'),
      CSVScopeModel(manufacturer: 'Vortex', model: 'Viper PST Gen II 5-25x50 FFP', tubeSize: '30mm', focalPlane: 'FFP', reticle: 'EBR-7C', trackingUnits: 'MRAD', clickValue: '0.1 MRAD', maxElevation: '27.5 MRAD', maxWindage: '13.7 MRAD'),
      CSVScopeModel(manufacturer: 'Nightforce', model: 'ATACR 4-16x42 F1', tubeSize: '30mm', focalPlane: 'FFP', reticle: 'MOAR', trackingUnits: 'MOA', clickValue: '1/4 MOA', maxElevation: '100 MOA', maxWindage: '60 MOA'),
    ];
  }

  List<CSVRifleModel> _parseRifleCSV(String csvContent) {
    final lines = csvContent.split('\n');
    if (lines.isEmpty) return [];

    final rifles = <CSVRifleModel>[];
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final parts = _parseCSVLine(line);
      if (parts.length >= 7) {
        rifles.add(CSVRifleModel(
            name: parts[0],
            brand: parts[1],
            model: parts[2],
            generationVariant: parts[3],
            caliber: parts[4],
            actionType: parts[5],
            manufacturer: parts[6],
            notes: parts[7]
        ));
      }
    }
    return rifles;
  }

  List<CSVAmmunitionModel> _parseAmmunitionCSV(String csvContent) {
    final lines = csvContent.split('\n');
    if (lines.isEmpty) return [];

    final ammunition = <CSVAmmunitionModel>[];
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final parts = _parseCSVLine(line);
      if (parts.length >= 3) {
        ammunition.add(CSVAmmunitionModel(
          ammunitionName: parts[0],
          manufacturer: parts[1],
          caliber: parts[2],
        ));
      }
    }
    return ammunition;
  }

  List<String> _parseCSVLine(String line) {
    final result = <String>[];
    String currentField = '';
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(currentField.trim().replaceAll('"', ''));
        currentField = '';
      } else {
        currentField += char;
      }
    }

    result.add(currentField.trim().replaceAll('"', ''));
    return result;
  }

  String _generateRifleCSV(List<CSVRifleModel> rifles) {
    final buffer = StringBuffer();
    buffer.writeln('Rifle Name,Manufacturer,Model,Caliber,Notes');

    for (final rifle in rifles) {
      buffer.writeln('${_escapeCSVField(rifle.name)},${_escapeCSVField(rifle.brand)},${_escapeCSVField(rifle.model)},${_escapeCSVField(rifle.generationVariant)},${_escapeCSVField(rifle.caliber)},${_escapeCSVField(rifle.actionType)},${_escapeCSVField(rifle.manufacturer)},${_escapeCSVField(rifle.notes)}');
    }

    return buffer.toString();
  }

  String _generateAmmunitionCSV(List<CSVAmmunitionModel> ammunition) {
    final buffer = StringBuffer();
    buffer.writeln('Ammunition Name,Manufacturer,Caliber');

    for (final ammo in ammunition) {
      buffer.writeln('${_escapeCSVField(ammo.ammunitionName)},${_escapeCSVField(ammo.manufacturer)},${_escapeCSVField(ammo.caliber)}');
    }

    return buffer.toString();
  }

  String _escapeCSVField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  List<CSVRifleModel> _getInitialRifleData() {
    return[
      CSVRifleModel(name: 'Rifle', brand: 'Accuracy International', model: 'AXMC', generationVariant: 'AI AXMC', caliber: '.338 LM', actionType: 'Bolt-Action', manufacturer: 'Accuracy International Ltd. (UK)', notes: 'Extreme long-range rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Kalashnikov Concern', model: 'AKM', generationVariant: 'AK-47', caliber: '7.62x39mm', actionType: 'Semi-Automatic', manufacturer: 'Kalashnikov Concern (Russia)', notes: 'Widely used worldwide'),
      CSVRifleModel(name: 'Rifle', brand: 'Kalashnikov Concern', model: 'AK-74', generationVariant: 'AK-74', caliber: '5.45x39mm', actionType: 'Semi-Automatic', manufacturer: 'Kalashnikov Concern (Russia)', notes: 'Soviet standard rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'ArmaLite', model: 'AR-10', generationVariant: 'AR-10', caliber: '.308 Winchester', actionType: 'Semi-Automatic', manufacturer: 'ArmaLite, Inc. (USA)', notes: 'Eugene Stoner design'),
      CSVRifleModel(name: 'Rifle', brand: 'BCM', model: 'RECCE-16', generationVariant: 'AR-15', caliber: '5.56mm NATO', actionType: 'Semi-Automatic', manufacturer: 'Bravo Company MFG, Inc. (USA)', notes: 'Reconnaissance carbine'),
      CSVRifleModel(name: 'Rifle', brand: 'Colt', model: 'M4A1', generationVariant: 'AR-15', caliber: '5.56mm NATO', actionType: 'Semi-Automatic', manufacturer: 'Colt\'s Manufacturing Company (USA)', notes: 'Standard military carbine'),
      CSVRifleModel(name: 'Rifle', brand: 'Daniel Defense', model: 'DDM4 V7', generationVariant: 'AR-15', caliber: '5.56mm NATO', actionType: 'Semi-Automatic', manufacturer: 'Daniel Defense, Inc. (USA)', notes: 'High-quality AR platform'),
      CSVRifleModel(name: 'Rifle', brand: 'LaRue Tactical', model: 'PredatOBR', generationVariant: 'AR-15', caliber: '.308 Winchester', actionType: 'Semi-Automatic', manufacturer: 'LaRue Tactical (USA)', notes: 'Optimized battle rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Barrett', model: 'M82A1', generationVariant: 'Barrett M82', caliber: '.50 BMG', actionType: 'Semi-Automatic', manufacturer: 'Barrett Firearms Manufacturing (USA)', notes: 'Anti-materiel rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Barrett', model: 'M95', generationVariant: 'Barrett M95', caliber: '.50 BMG', actionType: 'Bolt-Action', manufacturer: 'Barrett Firearms Manufacturing (USA)', notes: 'Bullpup anti-materiel'),
      CSVRifleModel(name: 'Rifle', brand: 'Benelli', model: 'R1', generationVariant: 'Benelli R1', caliber: '.30-06', actionType: 'Semi-Automatic', manufacturer: 'Benelli Armi SpA (Italy)', notes: 'Italian hunting rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Beretta', model: 'ARX-100', generationVariant: 'Beretta ARX-100', caliber: '5.56mm NATO', actionType: 'Semi-Automatic', manufacturer: 'Beretta Holding SpA (Italy)', notes: 'Modular assault rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Blaser', model: 'R8', generationVariant: 'Blaser R8', caliber: '.308 Winchester', actionType: 'Bolt-Action', manufacturer: 'Blaser Group GmbH (Germany)', notes: 'Straight-pull bolt'),
      CSVRifleModel(name: 'Rifle', brand: 'Browning', model: 'BAR Mark III', generationVariant: 'Browning BAR', caliber: '.30-06', actionType: 'Semi-Automatic', manufacturer: 'FN Herstal (Belgium)', notes: 'Semi-auto hunting rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Browning', model: 'X-Bolt Hunter', generationVariant: 'Browning X-Bolt', caliber: '.308 Winchester', actionType: 'Bolt-Action', manufacturer: 'FN Herstal (Belgium)', notes: 'Modern hunting rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'CheyTac LLC', model: 'M200', generationVariant: 'CheyTac M200', caliber: '.408 CheyTac', actionType: 'Bolt-Action', manufacturer: 'CheyTac USA, LLC (USA)', notes: 'Extreme long-range'),
      CSVRifleModel(name: 'Rifle', brand: 'CZ', model: '452', generationVariant: 'CZ 452', caliber: '.22 LR', actionType: 'Bolt-Action', manufacturer: 'Česká zbrojovka (Czech Republic)', notes: 'Training and target rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'CZ', model: '527', generationVariant: 'CZ 527', caliber: '.223 Remington', actionType: 'Bolt-Action', manufacturer: 'Česká zbrojovka (Czech Republic)', notes: 'Varmint and target rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'CZ', model: '550', generationVariant: 'CZ 550', caliber: '.308 Winchester', actionType: 'Bolt-Action', manufacturer: 'Česká zbrojovka (Czech Republic)', notes: 'Mauser-style action'),
      CSVRifleModel(name: 'Rifle', brand: 'CZ', model: '557', generationVariant: 'CZ 557', caliber: '.308 Winchester', actionType: 'Bolt-Action', manufacturer: 'Česká zbrojovka (Czech Republic)', notes: 'Modern hunting rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Desert Tech', model: 'SRS-A1', generationVariant: 'Desert Tech SRS', caliber: '.308 Winchester', actionType: 'Bolt-Action', manufacturer: 'Desert Tech LLC (USA)', notes: 'Bullpup sniper rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'DPMS', model: 'LR-308', generationVariant: 'DPMS LR-308', caliber: '.308 Winchester', actionType: 'Semi-Automatic', manufacturer: 'DPMS Panther Arms (USA)', notes: 'AR-10 pattern rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'FN Herstal', model: 'FAL', generationVariant: 'FN FAL', caliber: '7.62x51mm NATO', actionType: 'Semi-Automatic', manufacturer: 'FN Herstal (Belgium)', notes: 'Battle rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'FN Herstal', model: 'SCAR 17S', generationVariant: 'FN SCAR-H', caliber: '7.62x51mm NATO', actionType: 'Semi-Automatic', manufacturer: 'FN Herstal (Belgium)', notes: 'Special operations rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'FN Herstal', model: 'SCAR 16S', generationVariant: 'FN SCAR-L', caliber: '5.56mm NATO', actionType: 'Semi-Automatic', manufacturer: 'FN Herstal (Belgium)', notes: 'Special operations carbine'),
      CSVRifleModel(name: 'Rifle', brand: 'Heckler & Koch', model: 'G3', generationVariant: 'G3', caliber: '7.62x51mm NATO', actionType: 'Semi-Automatic', manufacturer: 'Heckler & Koch GmbH (Germany)', notes: 'Roller-delayed blowback'),
      CSVRifleModel(name: 'Rifle', brand: 'Henry Repeating Arms', model: 'Big Boy', generationVariant: 'Henry Big Boy', caliber: '.44 Magnum', actionType: 'Lever-Action', manufacturer: 'Henry Repeating Arms (USA)', notes: 'Lever-action rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Henry Repeating Arms', model: 'Golden Boy', generationVariant: 'Henry Golden Boy', caliber: '.22 LR', actionType: 'Lever-Action', manufacturer: 'Henry Repeating Arms (USA)', notes: 'Classic lever-action'),
      CSVRifleModel(name: 'Rifle', brand: 'Heckler & Koch', model: 'HK416', generationVariant: 'HK 416', caliber: '5.56mm NATO', actionType: 'Semi-Automatic', manufacturer: 'Heckler & Koch GmbH (Germany)', notes: 'Improved AR platform'),
      CSVRifleModel(name: 'Rifle', brand: 'Heckler & Koch', model: 'HK417', generationVariant: 'HK 417', caliber: '7.62x51mm NATO', actionType: 'Semi-Automatic', manufacturer: 'Heckler & Koch GmbH (Germany)', notes: 'Battle rifle variant'),
      CSVRifleModel(name: 'Rifle', brand: 'Howa', model: '1500', generationVariant: 'Howa 1500', caliber: '.308 Winchester', actionType: 'Bolt-Action', manufacturer: 'Howa Machinery Co., Ltd. (Japan)', notes: 'Japanese hunting rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'IWI', model: 'TAR-21', generationVariant: 'IWI Tavor', caliber: '5.56mm NATO', actionType: 'Semi-Automatic', manufacturer: 'Israel Weapon Industries (Israel)', notes: 'Bullpup assault rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Kimber', model: '8400 Advanced Tactical', generationVariant: 'Kimber 8400', caliber: '.308 Winchester', actionType: 'Bolt-Action', manufacturer: 'Kimber Manufacturing, Inc. (USA)', notes: 'Precision rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Royal Small Arms Factory', model: 'No. 4 Mk I', generationVariant: 'Lee-Enfield', caliber: '.303 British', actionType: 'Bolt-Action', manufacturer: 'Royal Small Arms Factory (UK)', notes: 'British service rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Marlin', model: '1895', generationVariant: 'Marlin 1895', caliber: '.45-70 Government', actionType: 'Lever-Action', manufacturer: 'Marlin Firearms Company (USA)', notes: 'Big bore lever-action'),
      CSVRifleModel(name: 'Rifle', brand: 'Marlin', model: '336 Classic', generationVariant: 'Marlin 336', caliber: '.30-30 Winchester', actionType: 'Lever-Action', manufacturer: 'Marlin Firearms Company (USA)', notes: 'Classic deer rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Marlin', model: 'Model 60', generationVariant: 'Marlin Model 60', caliber: '.22 LR', actionType: 'Semi-Automatic', manufacturer: 'Marlin Firearms Company (USA)', notes: 'Popular .22 rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Mauser', model: 'Karabiner 98k', generationVariant: 'Mauser K98k', caliber: '8mm Mauser', actionType: 'Bolt-Action', manufacturer: 'Mauser Werke (Germany)', notes: 'German service rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Tula Arsenal', model: 'M91/30', generationVariant: 'Mosin-Nagant', caliber: '7.62x54R', actionType: 'Bolt-Action', manufacturer: 'Tula Arms Plant (Russia)', notes: 'Russian service rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Nosler', model: 'M48 Professional', generationVariant: 'Nosler M48', caliber: '.308 Winchester', actionType: 'Bolt-Action', manufacturer: 'Nosler, Inc. (USA)', notes: 'Custom hunting rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'PTR Industries', model: 'PTR 91', generationVariant: 'PTR 91', caliber: '7.62x51mm NATO', actionType: 'Semi-Automatic', manufacturer: 'PTR Industries, Inc. (USA)', notes: 'HK91 clone'),
      CSVRifleModel(name: 'Rifle', brand: 'Remington', model: '700 SPS', generationVariant: 'Remington 700', caliber: '.308 Winchester', actionType: 'Bolt-Action', manufacturer: 'Remington Arms Company (USA)', notes: 'Popular hunting rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Remington', model: '7400', generationVariant: 'Remington 7400', caliber: '.30-06', actionType: 'Semi-Automatic', manufacturer: 'Remington Arms Company (USA)', notes: 'Semi-auto hunting rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Rock River Arms', model: 'LAR-15', generationVariant: 'Rock River LAR-15', caliber: '5.56mm NATO', actionType: 'Semi-Automatic', manufacturer: 'Rock River Arms, Inc. (USA)', notes: 'AR-15 variant'),
      CSVRifleModel(name: 'Rifle', brand: 'Ruger', model: 'Tue Oct 21 2025 23:59:48 GMT+0500 (Pakistan Standard Time)', generationVariant: 'Ruger 10/22', caliber: '.22 LR', actionType: 'Semi-Automatic', manufacturer: 'Sturm, Ruger & Co., Inc. (USA)', notes: 'Popular training rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Ruger', model: 'American', generationVariant: 'Ruger American', caliber: '.308 Winchester', actionType: 'Bolt-Action', manufacturer: 'Sturm, Ruger & Co., Inc. (USA)', notes: 'Budget hunting rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Ruger', model: 'Gunsite Scout', generationVariant: 'Ruger Gunsite Scout', caliber: '.308 Winchester', actionType: 'Bolt-Action', manufacturer: 'Sturm, Ruger & Co., Inc. (USA)', notes: 'Scout rifle concept'),
      CSVRifleModel(name: 'Rifle', brand: 'Ruger', model: 'Mini-14', generationVariant: 'Ruger Mini-14', caliber: '.223 Remington', actionType: 'Semi-Automatic', manufacturer: 'Sturm, Ruger & Co., Inc. (USA)', notes: 'M1 Garand derivative'),
      CSVRifleModel(name: 'Rifle', brand: 'Ruger', model: 'Precision Rifle', generationVariant: 'Ruger Precision Rifle', caliber: '.308 Winchester', actionType: 'Bolt-Action', manufacturer: 'Sturm, Ruger & Co., Inc. (USA)', notes: 'Modular precision rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Savage', model: '110', generationVariant: 'Savage 110', caliber: '.308 Winchester', actionType: 'Bolt-Action', manufacturer: 'Savage Arms, Inc. (USA)', notes: 'AccuTrigger rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Savage', model: 'Axis', generationVariant: 'Savage Axis', caliber: '.308 Winchester', actionType: 'Bolt-Action', manufacturer: 'Savage Arms, Inc. (USA)', notes: 'Budget hunting rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'SIG Sauer', model: '716', generationVariant: 'SIG 716', caliber: '.308 Winchester', actionType: 'Semi-Automatic', manufacturer: 'SIG Sauer, Inc. (USA/Germany)', notes: 'Piston-driven AR'),
      CSVRifleModel(name: 'Rifle', brand: 'Springfield Armory', model: 'M1A', generationVariant: 'Springfield M1A', caliber: '.308 Winchester', actionType: 'Semi-Automatic', manufacturer: 'Springfield Armory, Inc. (USA)', notes: 'M14 civilian version'),
      CSVRifleModel(name: 'Rifle', brand: 'Springfield Armory', model: 'SAINT', generationVariant: 'Springfield SAINT', caliber: '5.56mm NATO', actionType: 'Semi-Automatic', manufacturer: 'Springfield Armory, Inc. (USA)', notes: 'Modern AR-15'),
      CSVRifleModel(name: 'Rifle', brand: 'Steyr Mannlicher', model: 'AUG A3', generationVariant: 'Steyr AUG', caliber: '5.56mm NATO', actionType: 'Semi-Automatic', manufacturer: 'Steyr Mannlicher GmbH (Austria)', notes: 'Bullpup assault rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Steyr Mannlicher', model: 'Scout', generationVariant: 'Steyr Scout', caliber: '.308 Winchester', actionType: 'Bolt-Action', manufacturer: 'Steyr Mannlicher GmbH (Austria)', notes: 'Jeff Cooper design'),
      CSVRifleModel(name: 'Rifle', brand: 'Tikka', model: 'T3x Hunter', generationVariant: 'Tikka T3x', caliber: '.308 Winchester', actionType: 'Bolt-Action', manufacturer: 'Sako Ltd. (Finland)', notes: 'Finnish hunting rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Weatherby', model: 'Mark V', generationVariant: 'Weatherby Mark V', caliber: '.300 Weatherby Magnum', actionType: 'Bolt-Action', manufacturer: 'Weatherby, Inc. (USA)', notes: 'Magnum hunting rifle'),
      CSVRifleModel(name: 'Rifle', brand: 'Winchester', model: 'Model 94', generationVariant: 'Winchester 94', caliber: '.30-30 Winchester', actionType: 'Lever-Action', manufacturer: 'Winchester Repeating Arms Company (USA)', notes: 'Classic lever-action'),
      CSVRifleModel(name: 'Rifle', brand: 'Winchester', model: 'Model 70', generationVariant: 'Winchester Model 70', caliber: '.30-06', actionType: 'Bolt-Action', manufacturer: 'Winchester Repeating Arms Company (USA)', notes: 'Classic American bolt-action'),
      CSVRifleModel(name: 'Rifle', brand: 'Winchester', model: 'Model 70 Featherweight', generationVariant: 'Winchester Model 70', caliber: '.30-06', actionType: 'Bolt-Action', manufacturer: 'Winchester Repeating Arms Company (USA)', notes: 'Classic American bolt-action'),
      CSVRifleModel(name: 'Rifle', brand: 'Zastava Arms', model: 'M91', generationVariant: 'Zastava M91', caliber: '7.62x54R', actionType: 'Semi-Automatic', manufacturer: 'Zastava Arms (Serbia)', notes: 'Designated marksman rifle')
    ];
  }

  List<CSVAmmunitionModel> _getInitialAmmunitionData() {
    return [
      CSVAmmunitionModel(ammunitionName: 'XM193', manufacturer: 'Federal', caliber: '5.56 NATO'),
      CSVAmmunitionModel(ammunitionName: 'Gold Medal Match', manufacturer: 'Federal', caliber: '.308 Win'),
      CSVAmmunitionModel(ammunitionName: 'Precision Hunter', manufacturer: 'Hornady', caliber: '6.5 Creedmoor'),
      CSVAmmunitionModel(ammunitionName: 'ELD Match', manufacturer: 'Hornady', caliber: '6.5 Creedmoor'),
      CSVAmmunitionModel(ammunitionName: 'Core-Lokt', manufacturer: 'Remington', caliber: '.30-06'),
    ];
  }

  void clearCache() {
    _cachedRifles = null;
    _cachedAmmunition = null;
    _cachedScopes = null;
    _cachedMaintenanceTasks = null;
    _cachedAmmoOptions = null;
  }
}