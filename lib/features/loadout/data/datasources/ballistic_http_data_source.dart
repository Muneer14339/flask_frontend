// lib/features/loadout/data/datasources/ballistic_http_data_source.dart
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/ballistic_models.dart';

abstract class BallisticHttpDataSource {
  // DOPE Card operations
  Future<void> saveDopeEntry(DopeEntryModel entry);
  Future<List<DopeEntryModel>> getDopeEntries(String rifleId);
  Future<void> deleteDopeEntry(String entryId);
  Stream<List<DopeEntryModel>> getDopeEntriesStream(String rifleId);

  // Zero tracking operations
  Future<void> saveZeroEntry(ZeroEntryModel entry);
  Future<List<ZeroEntryModel>> getZeroEntries(String rifleId);
  Future<void> deleteZeroEntry(String entryId);
  Stream<List<ZeroEntryModel>> getZeroEntriesStream(String rifleId);

  // Chronograph data operations
  Future<void> saveChronographData(ChronographDataModel data);
  Future<List<ChronographDataModel>> getChronographData(String rifleId);
  Future<void> deleteChronographData(String dataId);
  Stream<List<ChronographDataModel>> getChronographDataStream(String rifleId);

  // Ballistic calculation operations
  Future<void> saveBallisticCalculation(BallisticCalculationModel calculation);
  Future<List<BallisticCalculationModel>> getBallisticCalculations(String rifleId);
  Future<void> deleteBallisticCalculation(String calculationId);
  Stream<List<BallisticCalculationModel>> getBallisticCalculationsStream(String rifleId);

  // Ballistic calculator
  Future<List<BallisticPointModel>> calculateBallistics(
      double ballisticCoefficient,
      double muzzleVelocity,
      int targetDistance,
      double windSpeed,
      double windDirection,
      );
}

class BallisticHttpDataSourceImpl implements BallisticHttpDataSource {
  final http.Client httpClient;
  final String baseUrl;
  final String Function() getToken;

  // Stream controllers for real-time updates
  final Map<String, StreamController<List<DopeEntryModel>>> _dopeControllers = {};
  final Map<String, StreamController<List<ZeroEntryModel>>> _zeroControllers = {};
  final Map<String, StreamController<List<ChronographDataModel>>> _chronographControllers = {};
  final Map<String, StreamController<List<BallisticCalculationModel>>> _calculationControllers = {};

  // Polling timers
  final Map<String, Timer> _dopeTimers = {};
  final Map<String, Timer> _zeroTimers = {};
  final Map<String, Timer> _chronographTimers = {};
  final Map<String, Timer> _calculationTimers = {};

  BallisticHttpDataSourceImpl({
    required this.httpClient,
    required this.baseUrl,
    required this.getToken,
  });

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${getToken()}',
  };

  // DOPE ENTRY OPERATIONS
  @override
  Future<void> saveDopeEntry(DopeEntryModel entry) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/api/ballistic/dope'),
        headers: _headers,
        body: json.encode(entry.toJson()),
      );

      if (response.statusCode == 200) {
        _refreshDopeStream(entry.rifleId);
        return;
      }
      throw Exception('Failed to save DOPE entry: ${response.body}');
    } catch (e) {
      throw Exception('Failed to save DOPE entry: $e');
    }
  }

  @override
  Future<List<DopeEntryModel>> getDopeEntries(String rifleId) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/api/ballistic/dope/$rifleId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> entriesJson = data['data'];
          return entriesJson.map((json) => DopeEntryModel.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to get DOPE entries: ${response.body}');
    } catch (e) {
      throw Exception('Failed to get DOPE entries: $e');
    }
  }

  @override
  Future<void> deleteDopeEntry(String entryId) async {
    try {
      final response = await httpClient.delete(
        Uri.parse('$baseUrl/api/ballistic/dope/$entryId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        // We need rifle ID to refresh stream, get it from active streams
        final rifleIds = _dopeControllers.keys.toList();
        for (final rifleId in rifleIds) {
          _refreshDopeStream(rifleId);
        }
        return;
      }
      throw Exception('Failed to delete DOPE entry: ${response.body}');
    } catch (e) {
      throw Exception('Failed to delete DOPE entry: $e');
    }
  }

  @override
  Stream<List<DopeEntryModel>> getDopeEntriesStream(String rifleId) {
    if (!_dopeControllers.containsKey(rifleId)) {
      _dopeControllers[rifleId] = StreamController<List<DopeEntryModel>>.broadcast();
      _startDopePolling(rifleId);
    }
    return _dopeControllers[rifleId]!.stream;
  }

  // ZERO ENTRY OPERATIONS
  @override
  Future<void> saveZeroEntry(ZeroEntryModel entry) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/api/ballistic/zero'),
        headers: _headers,
        body: json.encode(entry.toJson()),
      );

      if (response.statusCode == 200) {
        _refreshZeroStream(entry.rifleId);
        return;
      }
      throw Exception('Failed to save zero entry: ${response.body}');
    } catch (e) {
      throw Exception('Failed to save zero entry: $e');
    }
  }

  @override
  Future<List<ZeroEntryModel>> getZeroEntries(String rifleId) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/api/ballistic/zero/$rifleId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> entriesJson = data['data'];
          return entriesJson.map((json) => ZeroEntryModel.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to get zero entries: ${response.body}');
    } catch (e) {
      throw Exception('Failed to get zero entries: $e');
    }
  }

  @override
  Future<void> deleteZeroEntry(String entryId) async {
    try {
      final response = await httpClient.delete(
        Uri.parse('$baseUrl/api/ballistic/zero/$entryId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        // Refresh all active zero streams
        final rifleIds = _zeroControllers.keys.toList();
        for (final rifleId in rifleIds) {
          _refreshZeroStream(rifleId);
        }
        return;
      }
      throw Exception('Failed to delete zero entry: ${response.body}');
    } catch (e) {
      throw Exception('Failed to delete zero entry: $e');
    }
  }

  @override
  Stream<List<ZeroEntryModel>> getZeroEntriesStream(String rifleId) {
    if (!_zeroControllers.containsKey(rifleId)) {
      _zeroControllers[rifleId] = StreamController<List<ZeroEntryModel>>.broadcast();
      _startZeroPolling(rifleId);
    }
    return _zeroControllers[rifleId]!.stream;
  }

  // CHRONOGRAPH DATA OPERATIONS
  @override
  Future<void> saveChronographData(ChronographDataModel data) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/api/ballistic/chronograph'),
        headers: _headers,
        body: json.encode(data.toJson()),
      );

      if (response.statusCode == 200) {
        _refreshChronographStream(data.rifleId);
        return;
      }
      throw Exception('Failed to save chronograph data: ${response.body}');
    } catch (e) {
      throw Exception('Failed to save chronograph data: $e');
    }
  }

  @override
  Future<List<ChronographDataModel>> getChronographData(String rifleId) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/api/ballistic/chronograph/$rifleId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> dataJson = data['data'];
          return dataJson.map((json) => ChronographDataModel.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to get chronograph data: ${response.body}');
    } catch (e) {
      throw Exception('Failed to get chronograph data: $e');
    }
  }

  @override
  Future<void> deleteChronographData(String dataId) async {
    try {
      final response = await httpClient.delete(
        Uri.parse('$baseUrl/api/ballistic/chronograph/$dataId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        // Refresh all active chronograph streams
        final rifleIds = _chronographControllers.keys.toList();
        for (final rifleId in rifleIds) {
          _refreshChronographStream(rifleId);
        }
        return;
      }
      throw Exception('Failed to delete chronograph data: ${response.body}');
    } catch (e) {
      throw Exception('Failed to delete chronograph data: $e');
    }
  }

  @override
  Stream<List<ChronographDataModel>> getChronographDataStream(String rifleId) {
    if (!_chronographControllers.containsKey(rifleId)) {
      _chronographControllers[rifleId] = StreamController<List<ChronographDataModel>>.broadcast();
      _startChronographPolling(rifleId);
    }
    return _chronographControllers[rifleId]!.stream;
  }

  // BALLISTIC CALCULATION OPERATIONS
  @override
  Future<void> saveBallisticCalculation(BallisticCalculationModel calculation) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/api/ballistic/calculations'),
        headers: _headers,
        body: json.encode(calculation.toJson()),
      );

      if (response.statusCode == 200) {
        _refreshCalculationStream(calculation.rifleId);
        return;
      }
      throw Exception('Failed to save ballistic calculation: ${response.body}');
    } catch (e) {
      throw Exception('Failed to save ballistic calculation: $e');
    }
  }

  @override
  Future<List<BallisticCalculationModel>> getBallisticCalculations(String rifleId) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/api/ballistic/calculations/$rifleId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> calculationsJson = data['data'];
          return calculationsJson.map((json) => BallisticCalculationModel.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to get ballistic calculations: ${response.body}');
    } catch (e) {
      throw Exception('Failed to get ballistic calculations: $e');
    }
  }

  @override
  Future<void> deleteBallisticCalculation(String calculationId) async {
    try {
      final response = await httpClient.delete(
        Uri.parse('$baseUrl/api/ballistic/calculations/$calculationId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        // Refresh all active calculation streams
        final rifleIds = _calculationControllers.keys.toList();
        for (final rifleId in rifleIds) {
          _refreshCalculationStream(rifleId);
        }
        return;
      }
      throw Exception('Failed to delete ballistic calculation: ${response.body}');
    } catch (e) {
      throw Exception('Failed to delete ballistic calculation: $e');
    }
  }

  @override
  Stream<List<BallisticCalculationModel>> getBallisticCalculationsStream(String rifleId) {
    if (!_calculationControllers.containsKey(rifleId)) {
      _calculationControllers[rifleId] = StreamController<List<BallisticCalculationModel>>.broadcast();
      _startCalculationPolling(rifleId);
    }
    return _calculationControllers[rifleId]!.stream;
  }

  // BALLISTIC CALCULATOR
  @override
  Future<List<BallisticPointModel>> calculateBallistics(
      double ballisticCoefficient,
      double muzzleVelocity,
      int targetDistance,
      double windSpeed,
      double windDirection,
      ) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/api/ballistic/calculate'),
        headers: _headers,
        body: json.encode({
          'ballisticCoefficient': ballisticCoefficient,
          'muzzleVelocity': muzzleVelocity,
          'targetDistance': targetDistance,
          'windSpeed': windSpeed,
          'windDirection': windDirection,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> pointsJson = data['data'];
          return pointsJson.map((json) => BallisticPointModel.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to calculate ballistics: ${response.body}');
    } catch (e) {
      throw Exception('Failed to calculate ballistics: $e');
    }
  }

  // Polling methods
  void _startDopePolling(String rifleId) {
    _dopeTimers[rifleId]?.cancel();
    _dopeTimers[rifleId] = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final entries = await getDopeEntries(rifleId);
        _dopeControllers[rifleId]?.add(entries);
      } catch (e) {
        // Handle error silently for polling
      }
    });
  }

  void _startZeroPolling(String rifleId) {
    _zeroTimers[rifleId]?.cancel();
    _zeroTimers[rifleId] = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final entries = await getZeroEntries(rifleId);
        _zeroControllers[rifleId]?.add(entries);
      } catch (e) {
        // Handle error silently for polling
      }
    });
  }

  void _startChronographPolling(String rifleId) {
    _chronographTimers[rifleId]?.cancel();
    _chronographTimers[rifleId] = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final data = await getChronographData(rifleId);
        _chronographControllers[rifleId]?.add(data);
      } catch (e) {
        // Handle error silently for polling
      }
    });
  }

  void _startCalculationPolling(String rifleId) {
    _calculationTimers[rifleId]?.cancel();
    _calculationTimers[rifleId] = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final calculations = await getBallisticCalculations(rifleId);
        _calculationControllers[rifleId]?.add(calculations);
      } catch (e) {
        // Handle error silently for polling
      }
    });
  }

  // Refresh methods
  void _refreshDopeStream(String rifleId) async {
    try {
      final entries = await getDopeEntries(rifleId);
      _dopeControllers[rifleId]?.add(entries);
    } catch (e) {
      // Handle error silently
    }
  }

  void _refreshZeroStream(String rifleId) async {
    try {
      final entries = await getZeroEntries(rifleId);
      _zeroControllers[rifleId]?.add(entries);
    } catch (e) {
      // Handle error silently
    }
  }

  void _refreshChronographStream(String rifleId) async {
    try {
      final data = await getChronographData(rifleId);
      _chronographControllers[rifleId]?.add(data);
    } catch (e) {
      // Handle error silently
    }
  }

  void _refreshCalculationStream(String rifleId) async {
    try {
      final calculations = await getBallisticCalculations(rifleId);
      _calculationControllers[rifleId]?.add(calculations);
    } catch (e) {
      // Handle error silently
    }
  }

  // Cleanup method
  void dispose() {
    // Cancel all timers
    for (final timer in _dopeTimers.values) {
      timer.cancel();
    }
    for (final timer in _zeroTimers.values) {
      timer.cancel();
    }
    for (final timer in _chronographTimers.values) {
      timer.cancel();
    }
    for (final timer in _calculationTimers.values) {
      timer.cancel();
    }

    // Close all stream controllers
    for (final controller in _dopeControllers.values) {
      controller.close();
    }
    for (final controller in _zeroControllers.values) {
      controller.close();
    }
    for (final controller in _chronographControllers.values) {
      controller.close();
    }
    for (final controller in _calculationControllers.values) {
      controller.close();
    }
  }
}

