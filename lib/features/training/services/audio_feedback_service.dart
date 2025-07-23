import 'package:flutter/services.dart';

import '../domain/entities/angle_reading.dart';
import '../domain/entities/position_preset.dart';

class AudioFeedbackService {
  static const MethodChannel _platform = MethodChannel('com.example.rifle_audio/audio');

  // Current audio state tracking
  String? _currentCant;
  int? _currentCantLevel;
  int? _currentCantInterval;
  String? _currentTilt;
  int? _currentTiltLevel;
  int? _currentTiltInterval;

  // Rate limiting
  int _lastCantUpdate = 0;
  int _lastTiltUpdate = 0;
  static const int _updateThreshold = 200; // milliseconds

  bool _isEnabled = true;
  bool _isActive = false;

  // Singleton pattern
  static final AudioFeedbackService _instance = AudioFeedbackService._internal();
  factory AudioFeedbackService() => _instance;
  AudioFeedbackService._internal();

  /// Enable/disable audio feedback
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled) {
      stopAll();
    }
  }

  /// Start/stop audio feedback monitoring
  void setActive(bool active) {
    _isActive = active;
    if (!active) {
      stopAll();
    }
  }

  /// Main method to process angle readings and provide audio feedback
  void processAngleReading(AngleReading reading, PositionPreset preset) {
    if (!_isEnabled || !_isActive) {
      stopAll();
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    // Check cant (roll) direction and severity
    final cantDirection = _checkCantDirection(
        reading.cant,
        -preset.cantTolerance,
        preset.cantTolerance
    );

    // Check tilt (pitch) direction and severity
    final tiltDirection = _checkTiltDirection(
        reading.tilt,
        -preset.tiltTolerance,
        preset.tiltTolerance
    );

    // Manage cant audio feedback
    _manageCantAudio(cantDirection, now);

    // Manage tilt audio feedback
    _manageTiltAudio(tiltDirection, now);
  }

  /// Check cant direction and calculate severity
  Map<String, dynamic>? _checkCantDirection(double cant, double min, double max) {
    double severity = 0;
    String? direction;

    if (cant < min) {
      direction = 'left';
      severity = ((min - cant).abs()) / (min.abs() + 0.1); // Add small value to avoid division by zero
    } else if (cant > max) {
      direction = 'right';
      severity = ((cant - max).abs()) / (max.abs() + 0.1);
    } else {
      return null; // Within tolerance
    }

    // Calculate urgency level based on severity
    int level;
    int interval;
    if (severity >= 1.0) {
      level = 3; // High urgency
      interval = 150;
    } else if (severity >= 0.5) {
      level = 2; // Medium urgency
      interval = 300;
    } else {
      level = 1; // Low urgency
      interval = 500;
    }

    return {
      'direction': direction,
      'interval': interval,
      'level': level,
    };
  }

  /// Check tilt direction and calculate severity
  Map<String, dynamic>? _checkTiltDirection(double tilt, double min, double max) {
    double severity = 0;
    String? direction;

    if (tilt < min) {
      direction = 'down';
      severity = ((min - tilt).abs()) / (min.abs() + 0.1);
    } else if (tilt > max) {
      direction = 'up';
      severity = ((tilt - max).abs()) / (max.abs() + 0.1);
    } else {
      return null; // Within tolerance
    }

    // Calculate urgency level based on severity
    int level;
    int interval;
    if (severity >= 1.0) {
      level = 3; // High urgency
      interval = 150;
    } else if (severity >= 0.5) {
      level = 2; // Medium urgency
      interval = 300;
    } else {
      level = 1; // Low urgency
      interval = 500;
    }

    return {
      'direction': direction,
      'interval': interval,
      'level': level,
    };
  }

  /// Manage cant audio feedback with rate limiting
  void _manageCantAudio(Map<String, dynamic>? cantData, int currentTime) {
    if (cantData != null) {
      final direction = cantData['direction'];
      final interval = cantData['interval'];
      final level = cantData['level'];

      // Only update if parameters changed or enough time passed
      if ((direction != _currentCant ||
          level != _currentCantLevel ||
          interval != _currentCantInterval) &&
          (currentTime - _lastCantUpdate > _updateThreshold)) {

        _startCant(direction, interval);
        _currentCant = direction;
        _currentCantLevel = level;
        _currentCantInterval = interval;
        _lastCantUpdate = currentTime;
      }
    } else if (_currentCant != null) {
      // Stop cant audio if back in tolerance
      _stopCant();
      _currentCant = null;
      _currentCantLevel = null;
      _currentCantInterval = null;
    }
  }

  /// Manage tilt audio feedback with rate limiting
  void _manageTiltAudio(Map<String, dynamic>? tiltData, int currentTime) {
    if (tiltData != null) {
      final direction = tiltData['direction'];
      final interval = tiltData['interval'];
      final level = tiltData['level'];

      // Only update if parameters changed or enough time passed
      if ((direction != _currentTilt ||
          level != _currentTiltLevel ||
          interval != _currentTiltInterval) &&
          (currentTime - _lastTiltUpdate > _updateThreshold)) {

        _startTilt(direction, interval);
        _currentTilt = direction;
        _currentTiltLevel = level;
        _currentTiltInterval = interval;
        _lastTiltUpdate = currentTime;
      }
    } else if (_currentTilt != null) {
      // Stop tilt audio if back in tolerance
      _stopTilt();
      _currentTilt = null;
      _currentTiltLevel = null;
      _currentTiltInterval = null;
    }
  }

  /// Start cant audio feedback
  Future<void> _startCant(String direction, int interval) async {
    try {
      await _platform.invokeMethod('startCant', {
        'direction': direction,
        'interval': interval,
      });
    } catch (e) {
      print('AudioFeedbackService: Error starting cant audio: $e');
    }
  }

  /// Start tilt audio feedback
  Future<void> _startTilt(String direction, int interval) async {
    try {
      await _platform.invokeMethod('startTilt', {
        'direction': direction,
        'interval': interval,
      });
    } catch (e) {
      print('AudioFeedbackService: Error starting tilt audio: $e');
    }
  }

  /// Stop cant audio feedback
  Future<void> _stopCant() async {
    try {
      await _platform.invokeMethod('stopCant');
    } catch (e) {
      print('AudioFeedbackService: Error stopping cant audio: $e');
    }
  }

  /// Stop tilt audio feedback
  Future<void> _stopTilt() async {
    try {
      await _platform.invokeMethod('stopTilt');
    } catch (e) {
      print('AudioFeedbackService: Error stopping tilt audio: $e');
    }
  }

  /// Stop all audio feedback
  Future<void> stopAll() async {
    try {
      await _platform.invokeMethod('stopAll');

      // Reset state
      _currentCant = null;
      _currentCantLevel = null;
      _currentCantInterval = null;
      _currentTilt = null;
      _currentTiltLevel = null;
      _currentTiltInterval = null;
    } catch (e) {
      print('AudioFeedbackService: Error stopping all audio: $e');
    }
  }

  /// Get current audio feedback status
  Map<String, dynamic> getStatus() {
    return {
      'isEnabled': _isEnabled,
      'isActive': _isActive,
      'currentCant': _currentCant,
      'currentTilt': _currentTilt,
      'cantLevel': _currentCantLevel,
      'tiltLevel': _currentTiltLevel,
    };
  }

  /// Dispose and cleanup
  void dispose() {
    stopAll();
    _isActive = false;
  }
}