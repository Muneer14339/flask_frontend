import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

class BleManager {
  final String serviceUuid = "0000b3a0-0000-1000-8000-00805f9b34fb";
  final String notifyUuid = "0000b3a1-0000-1000-8000-00805f9b34fb";
  final String writeUuid = "0000b3a2-0000-1000-8000-00805f9b34fb";
  final String debugUuid = "0000b3a3-0000-1000-8000-00805f9b34fb";

  fbp.BluetoothDevice? device;
  StreamController<List<int>> dataStreamController = StreamController.broadcast();
  StreamSubscription? _notifySubscription;
  StreamSubscription? _debugSubscription;

  Stream<List<int>> get dataStream => dataStreamController.stream;

  Future<List<fbp.ScanResult>> scanForDevices({int scanTimeoutSeconds = 15}) async {
    print("BleManager: Starting scan for devices");

    // Ensure any previous scan is stopped
    await fbp.FlutterBluePlus.stopScan();

    List<fbp.ScanResult> discoveredDevices = [];

    // Start scanning
    await fbp.FlutterBluePlus.startScan(
        timeout: Duration(seconds: scanTimeoutSeconds));

    // Listen to scan results
    var subscription = fbp.FlutterBluePlus.scanResults.listen((results) {
      discoveredDevices = results
          .where((result) => result.device.platformName == 'GMSync')
          .toList();
    });

    // Wait for the scan timeout
    await Future.delayed(Duration(seconds: scanTimeoutSeconds));

    // Clean up
    subscription.cancel();
    await fbp.FlutterBluePlus.stopScan();

    print("BleManager: Scan complete, found ${discoveredDevices.length} devices");
    return discoveredDevices;
  }

  Future<void> connectToDevice(fbp.BluetoothDevice targetDevice) async {
    print("BleManager: Connecting to device ${targetDevice.platformName}");

    // Reset the stream controller if it's closed
    if (dataStreamController.isClosed) {
      print("BleManager: Stream controller was closed, creating new one");
      dataStreamController = StreamController.broadcast();
    }

    // Ensure device is null to start fresh
    if (device != null) {
      print("BleManager: Device was not null, disconnecting first");
      try {
        await device!.disconnect();
        device = null;
      } catch (e) {
        print("BleManager: Error disconnecting old device: $e");
      }
      // Add a delay to ensure disconnect completes
      await Future.delayed(const Duration(milliseconds: 1500));
    }

    device = targetDevice;
    await device!.connect(autoConnect: false, timeout: const Duration(seconds: 10));
    print("BleManager: Connected to device ${device!.platformName}");
  }

  Future<void> disconnect() async {
    if (device != null) {
      try {
        // Disable sensors before disconnecting
        await disableSensors();

        await device!.disconnect();
        device = null;
        print("Disconnected from device");
      } catch (e) {
        print("Error during disconnect: $e");
      }
    }
    if (!dataStreamController.isClosed) {
      await dataStreamController.close();
      // Create new controller for future connections
      dataStreamController = StreamController.broadcast();
    }
  }

  Future<void> enableSensors() async {
    List<fbp.BluetoothService> services = await device!.discoverServices();
    String normalizeUuid(String uuid) => uuid.toLowerCase().replaceAll('-', '');

    fbp.BluetoothService? targetService;
    String targetUuidNormalized = normalizeUuid(serviceUuid);

    for (var service in services) {
      String serviceUuidStr = normalizeUuid(service.serviceUuid.toString());
      if (serviceUuidStr == targetUuidNormalized || serviceUuidStr == "b3a0") {
        targetService = service;
        break;
      }
    }

    if (targetService == null) {
      throw Exception("Service $serviceUuid not found");
    }

    fbp.BluetoothCharacteristic? notifyChar;
    fbp.BluetoothCharacteristic? debugChar;
    fbp.BluetoothCharacteristic? writeChar;

    String notifyUuidNormalized = normalizeUuid(notifyUuid);
    String debugUuidNormalized = normalizeUuid(debugUuid);
    String writeUuidNormalized = normalizeUuid(writeUuid);

    for (var char in targetService.characteristics) {
      String charUuidStr = normalizeUuid(char.characteristicUuid.toString());
      if (charUuidStr == notifyUuidNormalized || charUuidStr == "b3a1") {
        notifyChar = char;
      } else if (charUuidStr == debugUuidNormalized || charUuidStr == "b3a3") {
        debugChar = char;
      } else if (charUuidStr == writeUuidNormalized || charUuidStr == "b3a2") {
        writeChar = char;
      }
    }

    if (notifyChar != null) {
      await notifyChar.setNotifyValue(true);
      _notifySubscription?.cancel(); // Cancel any existing subscription
      _notifySubscription = notifyChar.onValueReceived.listen((data) {
        // Stream raw sensor data to processor
        if (!dataStreamController.isClosed) {
          dataStreamController.add(data);
        }
      });
    }

    if (debugChar != null) {
      await debugChar.setNotifyValue(true);
      _debugSubscription?.cancel(); // Cancel any existing subscription
      _debugSubscription = debugChar.onValueReceived.listen((data) {
        String ascii = String.fromCharCodes(data);
        print("Debug data: $ascii");
      });
    }

    if (writeChar != null) {
      await writeChar.write([0x55, 0xAA, 0xF0, 0x00], withoutResponse: true);
      await Future.delayed(const Duration(milliseconds: 500));

      // ✅ Setting Gyroscope to 833Hz (2ms interval)
      List<int> setGyro833Hz = [0x55, 0xAA, 0x11, 0x02, 0x00, 0x02];
      await writeChar.write(setGyro833Hz, withoutResponse: true);
      print("Sent command to set gyro to 833Hz: ${setGyro833Hz.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}");
      await Future.delayed(const Duration(milliseconds: 500));

      await writeChar.write([0x55, 0xAA, 0x0A, 0x00], withoutResponse: true);
      await Future.delayed(const Duration(milliseconds: 500));

      await writeChar.write([0x55, 0xAA, 0x08, 0x00], withoutResponse: true);
      print("All configuration commands sent.");
    } else {
      throw Exception("Write characteristic $writeUuid not found");
    }
  }

  Future<void> disableSensors() async {
    if (device == null) return;

    try {
      List<fbp.BluetoothService> services = await device!.discoverServices();

      String normalizeUuid(String uuid) => uuid.toLowerCase().replaceAll('-', '');
      fbp.BluetoothCharacteristic? writeChar;
      fbp.BluetoothCharacteristic? notifyChar;

      for (var service in services) {
        String serviceUuidStr = normalizeUuid(service.serviceUuid.toString());
        if (serviceUuidStr == normalizeUuid(serviceUuid) || serviceUuidStr == "b3a0") {
          for (var char in service.characteristics) {
            String charUuidStr = normalizeUuid(char.characteristicUuid.toString());
            if (charUuidStr == normalizeUuid(writeUuid) || charUuidStr == "b3a2") {
              writeChar = char;
            } else if (charUuidStr == normalizeUuid(notifyUuid) || charUuidStr == "b3a1") {
              notifyChar = char;
            }
          }
          break;
        }
      }

      // Stop sensors
      if (writeChar != null) {
        await writeChar.write([0x55, 0xAA, 0xF0, 0x00], withoutResponse: true);
        await Future.delayed(const Duration(milliseconds: 500));
        print("Sensors stopped");
      }

      // Disable notifications
      if (notifyChar != null) {
        await notifyChar.setNotifyValue(false);
        _notifySubscription?.cancel();
        _notifySubscription = null;
        print("Notify subscription canceled");
      }
    } catch (e) {
      print("Error during disableSensors: $e");
    }
  }

  // Check if device is connected
  bool get isConnected => device != null;

  // Get device name
  String? get deviceName => device?.platformName;

  Future<Map<String, dynamic>> getDeviceInfo() async {
    if (device == null) {
      return {
        'batteryLevel': 85,         // Default value
        'firmwareVersion': 'v2.1.3',
        'signalStrength': 'Strong',
      };
    }

    int batteryLevel = 85;          // Defaults
    String firmwareVersion = 'v2.1.3';
    String signalStrength = 'Strong';

    try {
      List<fbp.BluetoothService> services = await device!.discoverServices();

      // Battery Level (Service 180F → Characteristic 2A19)
      try {
        final batteryService = services.firstWhere(
              (s) => s.serviceUuid.toString().toLowerCase().contains('180f'),
        );
        final batteryLevelChar = batteryService.characteristics.firstWhere(
              (c) => c.characteristicUuid.toString().toLowerCase().contains('2a19'),
        );
        final value = await batteryLevelChar.read();
        batteryLevel = value.isNotEmpty ? value[0] : batteryLevel;
      } catch (e) {
        print("⚠️ Battery level read failed, using default ($batteryLevel%) → $e");
      }

      // Firmware Version (Service 180A → Characteristic 2A26)
      try {
        final infoService = services.firstWhere(
              (s) => s.serviceUuid.toString().toLowerCase().contains('180a'),
        );
        final firmwareChar = infoService.characteristics.firstWhere(
              (c) => c.characteristicUuid.toString().toLowerCase().contains('2a26'),
        );
        final value = await firmwareChar.read();
        firmwareVersion = String.fromCharCodes(value);
      } catch (e) {
        print("⚠️ Firmware version read failed, using default ($firmwareVersion) → $e");
      }

      // Signal Strength (RSSI)
      try {
        final rssi = await device!.readRssi();
        signalStrength = mapRssiToSignalStrength(rssi);
      } catch (e) {
        print("⚠️ Signal strength read failed, using default ($signalStrength) → $e");
      }
    } catch (e) {
      print("❗ Error discovering services or reading device info: $e");
    }

    return {
      'batteryLevel': batteryLevel,
      'firmwareVersion': firmwareVersion,
      'signalStrength':signalStrength,
    };
  }

  String mapRssiToSignalStrength(int rssi) {
    if (rssi >= -50) {
      return 'Strong';   // 📶📶📶
    } else if (rssi >= -70) {
      return 'Good';     // 📶📶⬜
    } else {
      return 'Weak';     // 📶⬜⬜
    }
  }


}