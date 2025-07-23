// lib/core/services/csv_file_writer.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class CSVFileWriter {
  static CSVFileWriter? _instance;
  static CSVFileWriter get instance => _instance ??= CSVFileWriter._();
  CSVFileWriter._();

  // File paths
  static const String _rifleFileName = 'full_rifle_list.csv';
  static const String _ammoFileName = 'rifle_ammunition_list.csv';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _rifleFile async {
    final path = await _localPath;
    return File('$path/$_rifleFileName');
  }

  Future<File> get _ammoFile async {
    final path = await _localPath;
    return File('$path/$_ammoFileName');
  }

  // Initialize CSV files from assets if they don't exist
  Future<void> initializeCSVFiles() async {
    try {
      final rifleFile = await _rifleFile;
      final ammoFile = await _ammoFile;

      // Check if rifle file exists, if not create from assets or hardcoded data
      if (!await rifleFile.exists()) {
        String rifleData;
        try {
          rifleData = await rootBundle.loadString('assets/csv/$_rifleFileName');
        } catch (e) {
          rifleData = _getHardcodedRifleData();
        }
        await rifleFile.writeAsString(rifleData);
        print('Rifle CSV file initialized at: ${rifleFile.path}');
      }

      // Check if ammo file exists, if not create from assets or hardcoded data
      if (!await ammoFile.exists()) {
        String ammoData;
        try {
          ammoData = await rootBundle.loadString('assets/csv/$_ammoFileName');
        } catch (e) {
          ammoData = _getHardcodedAmmoData();
        }
        await ammoFile.writeAsString(ammoData);
        print('Ammo CSV file initialized at: ${ammoFile.path}');
      }
    } catch (e) {
      print('Error initializing CSV files: $e');
      throw Exception('Failed to initialize CSV files: $e');
    }
  }

  // Read rifle CSV file
  Future<String> readRifleCSV() async {
    try {
      final file = await _rifleFile;
      if (await file.exists()) {
        return await file.readAsString();
      } else {
        // Initialize and return
        await initializeCSVFiles();
        return await file.readAsString();
      }
    } catch (e) {
      print('Error reading rifle CSV: $e');
      return _getHardcodedRifleData();
    }
  }

  // Read ammo CSV file
  Future<String> readAmmoCSV() async {
    try {
      final file = await _ammoFile;
      if (await file.exists()) {
        return await file.readAsString();
      } else {
        // Initialize and return
        await initializeCSVFiles();
        return await file.readAsString();
      }
    } catch (e) {
      print('Error reading ammo CSV: $e');
      return _getHardcodedAmmoData();
    }
  }

  // Write rifle data to CSV file
  Future<void> writeRifleCSV(List<Map<String, dynamic>> rifleData) async {
    try {
      final file = await _rifleFile;
      final csvContent = _convertRifleDataToCSV(rifleData);
      await file.writeAsString(csvContent);
      print('Rifle CSV file updated successfully');
    } catch (e) {
      print('Error writing rifle CSV: $e');
      throw Exception('Failed to write rifle CSV: $e');
    }
  }

  // Write ammo data to CSV file
  Future<void> writeAmmoCSV(List<Map<String, dynamic>> ammoData) async {
    try {
      final file = await _ammoFile;
      final csvContent = _convertAmmoDataToCSV(ammoData);
      await file.writeAsString(csvContent);
      print('Ammo CSV file updated successfully');
    } catch (e) {
      print('Error writing ammo CSV: $e');
      throw Exception('Failed to write ammo CSV: $e');
    }
  }

  // Add single rifle entry to CSV
  Future<void> addRifleToCSV(String name, String manufacturer, String model, String caliber, String notes) async {
    try {
      final csvContent = await readRifleCSV();
      final lines = csvContent.split('\n');

      // Create new line
      final newLine = _escapeCSVField(name) + ',' +
          _escapeCSVField(manufacturer) + ',' +
          _escapeCSVField(model) + ',' +
          _escapeCSVField(caliber) + ',' +
          _escapeCSVField(notes);

      lines.add(newLine);

      final updatedContent = lines.join('\n');
      final file = await _rifleFile;
      await file.writeAsString(updatedContent);

      print('Added rifle to CSV: $name, $manufacturer, $model, $caliber');
    } catch (e) {
      print('Error adding rifle to CSV: $e');
      throw Exception('Failed to add rifle to CSV: $e');
    }
  }

  // Add single ammo entry to CSV
  Future<void> addAmmoToCSV(String name, String manufacturer, String caliber) async {
    try {
      final csvContent = await readAmmoCSV();
      final lines = csvContent.split('\n');

      // Create new line
      final newLine = _escapeCSVField(name) + ',' +
          _escapeCSVField(manufacturer) + ',' +
          _escapeCSVField(caliber);

      lines.add(newLine);

      final updatedContent = lines.join('\n');
      final file = await _ammoFile;
      await file.writeAsString(updatedContent);

      print('Added ammo to CSV: $name, $manufacturer, $caliber');
    } catch (e) {
      print('Error adding ammo to CSV: $e');
      throw Exception('Failed to add ammo to CSV: $e');
    }
  }

  // Helper method to escape CSV fields
  String _escapeCSVField(String field) {
    // If field contains comma, quote, or newline, wrap in quotes and escape quotes
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"' + field.replaceAll('"', '""') + '"';
    }
    return field;
  }

  // Convert rifle data to CSV format
  String _convertRifleDataToCSV(List<Map<String, dynamic>> data) {
    final StringBuffer buffer = StringBuffer();

    // Add header
    buffer.writeln('Rifle Name,Manufacturer,Model,Caliber,Notes');

    // Add data rows
    for (final row in data) {
      buffer.writeln(
          _escapeCSVField(row['Rifle Name'] ?? '') + ',' +
              _escapeCSVField(row['Manufacturer'] ?? '') + ',' +
              _escapeCSVField(row['Model'] ?? '') + ',' +
              _escapeCSVField(row['Caliber'] ?? '') + ',' +
              _escapeCSVField(row['Notes'] ?? '')
      );
    }

    return buffer.toString().trim();
  }

  // Convert ammo data to CSV format
  String _convertAmmoDataToCSV(List<Map<String, dynamic>> data) {
    final StringBuffer buffer = StringBuffer();

    // Add header
    buffer.writeln('Ammunition Name,Manufacturer,Caliber');

    // Add data rows
    for (final row in data) {
      buffer.writeln(
          _escapeCSVField(row['Ammunition Name'] ?? '') + ',' +
              _escapeCSVField(row['Manufacturer'] ?? '') + ',' +
              _escapeCSVField(row['Caliber'] ?? '')
      );
    }

    return buffer.toString().trim();
  }

  // Get file paths for backup/export
  Future<String> getRifleFilePath() async {
    final file = await _rifleFile;
    return file.path;
  }

  Future<String> getAmmoFilePath() async {
    final file = await _ammoFile;
    return file.path;
  }

  // Backup files
  Future<void> backupFiles() async {
    try {
      final path = await _localPath;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final rifleFile = await _rifleFile;
      final ammoFile = await _ammoFile;

      if (await rifleFile.exists()) {
        final backupRifleFile = File('$path/backup_${timestamp}_$_rifleFileName');
        await rifleFile.copy(backupRifleFile.path);
      }

      if (await ammoFile.exists()) {
        final backupAmmoFile = File('$path/backup_${timestamp}_$_ammoFileName');
        await ammoFile.copy(backupAmmoFile.path);
      }

      print('Files backed up successfully');
    } catch (e) {
      print('Error backing up files: $e');
      throw Exception('Failed to backup files: $e');
    }
  }

  String _getHardcodedRifleData() {
    return '''Rifle Name,Manufacturer,Model,Caliber,Notes
AI AXMC,Accuracy International,AXMC,.338 LM,Extreme long-range rifle
AK-47,Kalashnikov Concern,AKM,7.62x39mm,Widely used worldwide
AK-47,Kalashnikov Concern,AKM V2,7.62x39mm,Widely used worldwide
AK-47,Kalashnikov Concern,AKM V1,7.62x39mm,Widely used worldwide
AK-47,Kalashnikov Concern,AKM V3,7.62x39mm,Widely used worldwide
AK-47,Kalashnikov Concern,AKM V4,7.62x39mm,Widely used worldwide
AR-15,Colt,LE6920,5.56 NATO,Civilian version of M4
AR-15,Daniel Defense,DDM4 V7,5.56 NATO,High-quality build
AR-15,Smith & Wesson,M&P15,5.56 NATO,Popular civilian rifle
AR-15,BCM,Recce-16,5.56 NATO,Mid-length gas system
Armalite AR-10,Armalite,AR-10A,.308 Win,Original AR-10 design
Barrett M82,Barrett,M82A1,.50 BMG,Anti-material rifle
Bergara B-14,Bergara,HMR,6.5 Creedmoor,Precision rifle
Bergara B-14,Bergara,Ridge,.308 Win,Hunting rifle
Bergara B-14,Bergara,Wilderness,6.5 PRC,Long-range hunting
Blaser R8,Blaser,Professional,.300 Win Mag,Straight-pull bolt
Browning X-Bolt,Browning,Hell's Canyon,.270 Win,Long-range hunting
Bushmaster ACR,Bushmaster,Enhanced,6.8 SPC,Adaptive Combat Rifle
Christensen Arms Ridgeline,Christensen Arms,Ridgeline,28 Nosler,Carbon fiber barrel
CZ 457,CZ,Varmint,.22 LR,Precision rimfire
Desert Tech SRS,Desert Tech,A1,.338 LM,Bullpup sniper rifle
FN SCAR,FN Herstal,SCAR 17S,.308 Win,Battle rifle
Howa 1500,Howa,Barreled Action,6.5 Creedmoor,Precision base
Kimber Hunter,Kimber,Pro,.30-06,Lightweight hunting
Marlin 336,Marlin,Classic,.30-30 Win,Lever-action classic
Mossberg Patriot,Mossberg,Predator,.243 Win,Affordable precision
Noreen ULR,Noreen,ULR,.416 Barrett,Ultra Long Range
Remington 700,Remington,SPS,.308 Win,Popular platform
Remington 700,Remington,5R,.300 Win Mag,5R rifling
Remington 700,Remington,Long Range,.25-06 Rem,Long-range hunting
Ruger American,Ruger,Predator,.204 Ruger,Varmint hunting
Ruger Precision Rifle,Ruger,Gen 3,6.5 PRC,Competition ready
Savage 110,Savage,Tactical,.308 Win,AccuTrigger
Tikka T3x,Tikka,TAC A1,6.5 Creedmoor,Tactical chassis
Tikka T3x,Tikka,Hunter,.270 WSM,Lightweight hunting
Winchester Model 70,Winchester,Super Grade,.375 H&H,Premium hunting''';
  }

  String _getHardcodedAmmoData() {
    return '''Ammunition Name,Manufacturer,Caliber
XM193,Federal,5.56 NATO
M855 Green Tip,Lake City,5.56 NATO
Gold Medal Match,Federal,.308 Win
Fusion,Federal,.308 Win
Superformance,Hornady,6.5 Creedmoor
Precision Hunter,Hornady,6.5 Creedmoor
American Eagle,Federal,.223 Rem
Varmint Express,Hornady,.223 Rem
Power-Shok,Federal,.30-06
Core-Lokt,Remington,.30-06
Ballistic Tip,Nosler,.308 Win
Custom Lite,Hornady,.270 Win
Fusion MSR,Federal,6.8 SPC
Trophy Bonded Tip,Federal,.300 Win Mag
Varmageddon,Nosler,.204 Ruger
ELD Match,Hornady,6.5 Creedmoor
BTHP,Sierra,.308 Win
Partition,Nosler,.270 Win
Swift Scirocco,Swift,.300 Win Mag
Accubond,Nosler,28 Nosler
TSX,Barnes,.30-06
Berger VLD,Berger,6.5 Creedmoor
Match King,Sierra,.308 Win
Lapua Scenar,Lapua,6.5 Creedmoor
Federal Terminal Ascent,Federal,.270 WSM
Hornady SST,Hornady,.25-06 Rem
Winchester Ballistic Silvertip,Winchester,.375 H&H
Remington AccuTip,Remington,.243 Win
Federal Edge TLR,Federal,6.5 PRC
Hornady InterLock,Hornady,.30-30 Win
CCI Standard Velocity,CCI,.22 LR
Black Hills Match,Black Hills,.338 LM
Lapua Mega,Lapua,.416 Barrett
Barnes LRX,Barnes,.204 Ruger
Swift A-Frame,Swift,.50 BMG
Nosler E-Tip,Nosler,6.5 Creedmoor
Federal Power Point,Federal,.270 Win
Hornady MonoFlex,Hornady,.30-30 Win
Winchester Power Point,Winchester,.308 Win
Remington Pointed Soft Point,Remington,5.56 NATO
Federal Soft Point,Federal,.223 Rem
Hornady V-MAX,Hornady,.204 Ruger
Barnes TAC-TX,Barnes,6.8 SPC
Nosler Ballistic Tip Hunting,Nosler,.25-06 Rem
Federal Vital-Shok,Federal,.375 H&H
Winchester Supreme,Winchester,28 Nosler
Remington Express,Remington,.270 WSM
Hornady Outfitter,Hornady,6.5 PRC
Federal Trophy Copper,Federal,.30-06''';
  }
}