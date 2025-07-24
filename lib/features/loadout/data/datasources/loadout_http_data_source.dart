// lib/features/loadout/data/datasources/loadout_http_data_source.dart
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/rifle_model.dart';
import '../models/ammunition_model.dart';
import '../models/scope_model.dart';
import '../models/maintenance_model.dart';

abstract class LoadoutHttpDataSource {
  // CRUD operations
  Future<List<RifleModel>> getRifles();
  Future<List<AmmunitionModel>> getAmmunition();
  Future<List<ScopeModel>> getScopes();
  Future<List<MaintenanceModel>> getMaintenance();

  Future<RifleModel> addRifle(RifleModel rifle);
  Future<AmmunitionModel> addAmmunition(AmmunitionModel ammunition);
  Future<ScopeModel> addScope(ScopeModel scope);
  Future<MaintenanceModel> addMaintenance(MaintenanceModel maintenance);

  Future<RifleModel> updateRifle(RifleModel rifle);
  Future<AmmunitionModel> updateAmmunition(AmmunitionModel ammunition);
  Future<ScopeModel> updateScope(ScopeModel scope);
  Future<void> deleteAmmunition(String id);
  Future<void> completeMaintenance(String id);
  Future<void> deleteMaintenance(String id);
  Future<void> deleteScope(String id);

  Future<RifleModel> setActiveRifle(String rifleId);
  Future<RifleModel?> getActiveRifle();

  // Streams for real-time updates (simulated with polling)
  Stream<List<RifleModel>> getRiflesStream();
  Stream<List<AmmunitionModel>> getAmmunitionStream();
  Stream<List<ScopeModel>> getScopesStream();
  Stream<List<MaintenanceModel>> getMaintenanceStream();
}

class LoadoutHttpDataSourceImpl implements LoadoutHttpDataSource {
  final http.Client httpClient;
  final String baseUrl;
  final String Function() getToken;

  // Stream controllers for real-time updates
  final StreamController<List<RifleModel>> _riflesController = StreamController.broadcast();
  final StreamController<List<AmmunitionModel>> _ammunitionController = StreamController.broadcast();
  final StreamController<List<ScopeModel>> _scopesController = StreamController.broadcast();
  final StreamController<List<MaintenanceModel>> _maintenanceController = StreamController.broadcast();

  // Polling timers
  Timer? _riflesTimer;
  Timer? _ammunitionTimer;
  Timer? _scopesTimer;
  Timer? _maintenanceTimer;

  LoadoutHttpDataSourceImpl({
    required this.httpClient,
    required this.baseUrl,
    required this.getToken,
  });

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${getToken()}',
  };

  // RIFLES
  @override
  Future<List<RifleModel>> getRifles() async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/api/loadout/rifles'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> riflesJson = data['data'];
          return riflesJson.map((json) => RifleModel.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to get rifles: ${response.body}');
    } catch (e) {
      throw Exception('Failed to get rifles: $e');
    }
  }

  @override
  Future<RifleModel> addRifle(RifleModel rifle) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/api/loadout/rifles'),
        headers: _headers,
        body: json.encode(rifle.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final addedRifle = RifleModel.fromJson(data['data']);
          _refreshRiflesStream(); // Refresh stream
          return addedRifle;
        }
      }
      throw Exception('Failed to add rifle: ${response.body}');
    } catch (e) {
      throw Exception('Failed to add rifle: $e');
    }
  }

  @override
  Future<RifleModel> updateRifle(RifleModel rifle) async {
    try {
      final response = await httpClient.put(
        Uri.parse('$baseUrl/api/loadout/rifles/${rifle.id}'),
        headers: _headers,
        body: json.encode(rifle.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final updatedRifle = RifleModel.fromJson(data['data']);
          _refreshRiflesStream(); // Refresh stream
          return updatedRifle;
        }
      }
      throw Exception('Failed to update rifle: ${response.body}');
    } catch (e) {
      throw Exception('Failed to update rifle: $e');
    }
  }

  @override
  Future<RifleModel> setActiveRifle(String rifleId) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/api/loadout/rifles/set-active'),
        headers: _headers,
        body: json.encode({'rifleId': rifleId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final activeRifle = RifleModel.fromJson(data['data']);
          _refreshRiflesStream(); // Refresh stream
          return activeRifle;
        }
      }
      throw Exception('Failed to set active rifle: ${response.body}');
    } catch (e) {
      throw Exception('Failed to set active rifle: $e');
    }
  }

  @override
  Future<RifleModel?> getActiveRifle() async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/api/loadout/rifles/active'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return RifleModel.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // AMMUNITION
  @override
  Future<List<AmmunitionModel>> getAmmunition() async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/api/loadout/ammunition'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> ammunitionJson = data['data'];
          return ammunitionJson.map((json) => AmmunitionModel.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to get ammunition: ${response.body}');
    } catch (e) {
      throw Exception('Failed to get ammunition: $e');
    }
  }

  @override
  Future<AmmunitionModel> addAmmunition(AmmunitionModel ammunition) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/api/loadout/ammunition'),
        headers: _headers,
        body: json.encode(ammunition.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final addedAmmunition = AmmunitionModel.fromJson(data['data']);
          _refreshAmmunitionStream(); // Refresh stream
          return addedAmmunition;
        }
      }
      throw Exception('Failed to add ammunition: ${response.body}');
    } catch (e) {
      throw Exception('Failed to add ammunition: $e');
    }
  }

  @override
  Future<AmmunitionModel> updateAmmunition(AmmunitionModel ammunition) async {
    try {
      final response = await httpClient.put(
        Uri.parse('$baseUrl/api/loadout/ammunition/${ammunition.id}'),
        headers: _headers,
        body: json.encode(ammunition.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final updatedAmmunition = AmmunitionModel.fromJson(data['data']);
          _refreshAmmunitionStream(); // Refresh stream
          return updatedAmmunition;
        }
      }
      throw Exception('Failed to update ammunition: ${response.body}');
    } catch (e) {
      throw Exception('Failed to update ammunition: $e');
    }
  }

  @override
  Future<void> deleteAmmunition(String id) async {
    try {
      final response = await httpClient.delete(
        Uri.parse('$baseUrl/api/loadout/ammunition/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        _refreshAmmunitionStream(); // Refresh stream
        return;
      }
      throw Exception('Failed to delete ammunition: ${response.body}');
    } catch (e) {
      throw Exception('Failed to delete ammunition: $e');
    }
  }

  // SCOPES
  @override
  Future<List<ScopeModel>> getScopes() async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/api/loadout/scopes'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> scopesJson = data['data'];
          return scopesJson.map((json) => ScopeModel.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to get scopes: ${response.body}');
    } catch (e) {
      throw Exception('Failed to get scopes: $e');
    }
  }

  @override
  Future<ScopeModel> addScope(ScopeModel scope) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/api/loadout/scopes'),
        headers: _headers,
        body: json.encode(scope.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final addedScope = ScopeModel.fromJson(data['data']);
          _refreshScopesStream(); // Refresh stream
          return addedScope;
        }
      }
      throw Exception('Failed to add scope: ${response.body}');
    } catch (e) {
      throw Exception('Failed to add scope: $e');
    }
  }

  @override
  Future<ScopeModel> updateScope(ScopeModel scope) async {
    try {
      final response = await httpClient.put(
        Uri.parse('$baseUrl/api/loadout/scopes/${scope.id}'),
        headers: _headers,
        body: json.encode(scope.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final updatedScope = ScopeModel.fromJson(data['data']);
          _refreshScopesStream(); // Refresh stream
          return updatedScope;
        }
      }
      throw Exception('Failed to update scope: ${response.body}');
    } catch (e) {
      throw Exception('Failed to update scope: $e');
    }
  }

  @override
  Future<void> deleteScope(String id) async {
    try {
      final response = await httpClient.delete(
        Uri.parse('$baseUrl/api/loadout/scopes/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        _refreshScopesStream(); // Refresh stream
        return;
      }
      throw Exception('Failed to delete scope: ${response.body}');
    } catch (e) {
      throw Exception('Failed to delete scope: $e');
    }
  }

  // MAINTENANCE
  @override
  Future<List<MaintenanceModel>> getMaintenance() async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/api/loadout/maintenance'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> maintenanceJson = data['data'];
          return maintenanceJson.map((json) => MaintenanceModel.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to get maintenance: ${response.body}');
    } catch (e) {
      throw Exception('Failed to get maintenance: $e');
    }
  }

  @override
  Future<MaintenanceModel> addMaintenance(MaintenanceModel maintenance) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/api/loadout/maintenance'),
        headers: _headers,
        body: json.encode(maintenance.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final addedMaintenance = MaintenanceModel.fromJson(data['data']);
          _refreshMaintenanceStream(); // Refresh stream
          return addedMaintenance;
        }
      }
      throw Exception('Failed to add maintenance: ${response.body}');
    } catch (e) {
      throw Exception('Failed to add maintenance: $e');
    }
  }

  @override
  Future<void> completeMaintenance(String id) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/api/loadout/maintenance/$id/complete'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        _refreshMaintenanceStream(); // Refresh stream
        return;
      }
      throw Exception('Failed to complete maintenance: ${response.body}');
    } catch (e) {
      throw Exception('Failed to complete maintenance: $e');
    }
  }

  @override
  Future<void> deleteMaintenance(String id) async {
    try {
      final response = await httpClient.delete(
        Uri.parse('$baseUrl/api/loadout/maintenance/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        _refreshMaintenanceStream(); // Refresh stream
        return;
      }
      throw Exception('Failed to delete maintenance: ${response.body}');
    } catch (e) {
      throw Exception('Failed to delete maintenance: $e');
    }
  }

  // STREAMS (simulated with polling)
  @override
  Stream<List<RifleModel>> getRiflesStream() {
    _startRiflesPolling();
    return _riflesController.stream;
  }

  @override
  Stream<List<AmmunitionModel>> getAmmunitionStream() {
    _startAmmunitionPolling();
    return _ammunitionController.stream;
  }

  @override
  Stream<List<ScopeModel>> getScopesStream() {
    _startScopesPolling();
    return _scopesController.stream;
  }

  @override
  Stream<List<MaintenanceModel>> getMaintenanceStream() {
    _startMaintenancePolling();
    return _maintenanceController.stream;
  }

  // Polling methods
  void _startRiflesPolling() {
    _riflesTimer?.cancel();
    _riflesTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final rifles = await getRifles();
        _riflesController.add(rifles);
      } catch (e) {
        // Handle error silently for polling
      }
    });
  }

  void _startAmmunitionPolling() {
    _ammunitionTimer?.cancel();
    _ammunitionTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final ammunition = await getAmmunition();
        _ammunitionController.add(ammunition);
      } catch (e) {
        // Handle error silently for polling
      }
    });
  }

  void _startScopesPolling() {
    _scopesTimer?.cancel();
    _scopesTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final scopes = await getScopes();
        _scopesController.add(scopes);
      } catch (e) {
        // Handle error silently for polling
      }
    });
  }

  void _startMaintenancePolling() {
    _maintenanceTimer?.cancel();
    _maintenanceTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final maintenance = await getMaintenance();
        _maintenanceController.add(maintenance);
      } catch (e) {
        // Handle error silently for polling
      }
    });
  }

  // Refresh methods (for immediate updates after operations)
  void _refreshRiflesStream() async {
    try {
      final rifles = await getRifles();
      _riflesController.add(rifles);
    } catch (e) {
      // Handle error silently
    }
  }

  void _refreshAmmunitionStream() async {
    try {
      final ammunition = await getAmmunition();
      _ammunitionController.add(ammunition);
    } catch (e) {
      // Handle error silently
    }
  }

  void _refreshScopesStream() async {
    try {
      final scopes = await getScopes();
      _scopesController.add(scopes);
    } catch (e) {
      // Handle error silently
    }
  }

  void _refreshMaintenanceStream() async {
    try {
      final maintenance = await getMaintenance();
      _maintenanceController.add(maintenance);
    } catch (e) {
      // Handle error silently
    }
  }

// JSON conversion helpers for models
}

