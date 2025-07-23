import 'csv_file_writer.dart';

class CSVDataService {
  static CSVDataService? _instance;
  static CSVDataService get instance => _instance ??= CSVDataService._();
  CSVDataService._();

  List<Map<String, dynamic>>? _rifleData;
  List<Map<String, dynamic>>? _ammoData;

  Future<List<Map<String, dynamic>>> getRifleData() async {
    if (_rifleData != null) return _rifleData!;

    try {
      // Read from file using file writer service
      final fileWriter = CSVFileWriter.instance;
      final csvData = await fileWriter.readRifleCSV();

      _rifleData = _parseCSV(csvData, ['Rifle Name', 'Manufacturer', 'Model', 'Caliber', 'Notes']);
      return _rifleData!;
    } catch (e) {
      throw Exception('Failed to load rifle data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAmmoData() async {
    if (_ammoData != null) return _ammoData!;

    try {
      // Read from file using file writer service
      final fileWriter = CSVFileWriter.instance;
      final csvData = await fileWriter.readAmmoCSV();

      _ammoData = _parseCSV(csvData, ['Ammunition Name', 'Manufacturer', 'Caliber']);
      return _ammoData!;
    } catch (e) {
      throw Exception('Failed to load ammunition data: $e');
    }
  }

  List<Map<String, dynamic>> _parseCSV(String csvData, List<String> expectedHeaders) {
    final lines = csvData.split('\n');
    if (lines.isEmpty) return [];

    // Get headers from first line
    final headers = lines[0].split(',').map((h) => h.trim().replaceAll('"', '')).toList();

    // Validate headers
    for (final expectedHeader in expectedHeaders) {
      if (!headers.contains(expectedHeader)) {
        throw Exception('Missing expected header: $expectedHeader');
      }
    }

    final List<Map<String, dynamic>> result = [];

    // Process data lines
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final values = _parseCSVLine(line);
      if (values.length != headers.length) continue;

      final Map<String, dynamic> row = {};
      for (int j = 0; j < headers.length; j++) {
        row[headers[j]] = values[j].trim().replaceAll('"', '');
      }
      result.add(row);
    }

    return result;
  }

  List<String> _parseCSVLine(String line) {
    final List<String> result = [];
    String currentField = '';
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(currentField);
        currentField = '';
      } else {
        currentField += char;
      }
    }

    result.add(currentField);
    return result;
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

  List<String> getUniqueRifleNames() {
    if (_rifleData == null) return [];
    return _rifleData!
        .map((e) => e['Rifle Name'] as String)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> getUniqueAmmoNames() {
    if (_ammoData == null) return [];
    return _ammoData!
        .map((e) => e['Ammunition Name'] as String)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> getManufacturersForRifle(String rifleName) {
    if (_rifleData == null) return [];
    return _rifleData!
        .where((e) => e['Rifle Name'] == rifleName)
        .map((e) => e['Manufacturer'] as String)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> getManufacturersForAmmo(String ammoName) {
    if (_ammoData == null) return [];
    return _ammoData!
        .where((e) => e['Ammunition Name'] == ammoName)
        .map((e) => e['Manufacturer'] as String)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> getModelsForRifle(String rifleName, String manufacturer) {
    if (_rifleData == null) return [];
    return _rifleData!
        .where((e) =>
    e['Rifle Name'] == rifleName &&
        e['Manufacturer'] == manufacturer)
        .map((e) => e['Model'] as String)
        .toList()
      ..sort();
  }

  List<String> getCalibersForRifle(String rifleName, String manufacturer, String model) {
    if (_rifleData == null) return [];
    return _rifleData!
        .where((e) =>
    e['Rifle Name'] == rifleName &&
        e['Manufacturer'] == manufacturer &&
        e['Model'] == model)
        .map((e) => e['Caliber'] as String)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> getCalibersForAmmo(String ammoName, String manufacturer) {
    if (_ammoData == null) return [];
    return _ammoData!
        .where((e) =>
    e['Ammunition Name'] == ammoName &&
        e['Manufacturer'] == manufacturer)
        .map((e) => e['Caliber'] as String)
        .toSet()
        .toList()
      ..sort();
  }

  String? getNotesForRifle(String rifleName, String manufacturer, String model) {
    if (_rifleData == null) return null;
    try {
      final entry = _rifleData!.firstWhere((e) =>
      e['Rifle Name'] == rifleName &&
          e['Manufacturer'] == manufacturer &&
          e['Model'] == model);
      return entry['Notes'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<void> addRifleToCSV(String name, String manufacturer, String model, String caliber, String notes) async {
    try {
      // Add to file using file writer service
      final fileWriter = CSVFileWriter.instance;
      await fileWriter.addRifleToCSV(name, manufacturer, model, caliber, notes);

      // Update in-memory cache
      _rifleData ??= [];
      _rifleData!.add({
        'Rifle Name': name,
        'Manufacturer': manufacturer,
        'Model': model,
        'Caliber': caliber,
        'Notes': notes,
      });

      print('Added rifle to CSV permanently: $name, $manufacturer, $model, $caliber, $notes');
    } catch (e) {
      throw Exception('Failed to add rifle to CSV: $e');
    }
  }

  Future<void> addAmmoToCSV(String name, String manufacturer, String caliber) async {
    try {
      // Add to file using file writer service
      final fileWriter = CSVFileWriter.instance;
      await fileWriter.addAmmoToCSV(name, manufacturer, caliber);

      // Update in-memory cache
      _ammoData ??= [];
      _ammoData!.add({
        'Ammunition Name': name,
        'Manufacturer': manufacturer,
        'Caliber': caliber,
      });

      print('Added ammo to CSV permanently: $name, $manufacturer, $caliber');
    } catch (e) {
      throw Exception('Failed to add ammo to CSV: $e');
    }
  }

  void clearCache() {
    _rifleData = null;
    _ammoData = null;
  }

  // Initialize CSV files on first run
  Future<void> initializeCSVFiles() async {
    try {
      final fileWriter = CSVFileWriter.instance;
      await fileWriter.initializeCSVFiles();
    } catch (e) {
      print('Error initializing CSV files: $e');
    }
  }

  // Method to filter rifle names based on search query
  List<String> filterRifleNames(String query) {
    final allNames = getUniqueRifleNames();
    if (query.isEmpty) return allNames;

    return allNames
        .where((name) => name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Method to filter ammo names based on search query
  List<String> filterAmmoNames(String query) {
    final allNames = getUniqueAmmoNames();
    if (query.isEmpty) return allNames;

    return allNames
        .where((name) => name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}