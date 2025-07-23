import 'dart:async';
import 'dart:math';

class SensorData {
  final double x, y, z;

  SensorData(this.x, this.y, this.z);
}

class Orientation {
  final double roll, pitch, yaw;

  Orientation(this.roll, this.pitch, this.yaw);
}

class ComplementaryFilter {
  final double alpha; // Weight for gyro
  double angle = 0.0;
  static const double pi = 3.141592653589793;

  ComplementaryFilter(this.alpha);

  double update(double gyroRate, double accelAngle, double dt) {
    angle = alpha * (angle + gyroRate * dt * pi / 180.0) + (1 - alpha) * accelAngle;
    return angle;
  }

  void reset() {
    angle = 0.0;
  }
}

class SensorProcessor {
  static double dt = 0.0012;
  static const double alpha = 0.95;
  static const double lpfAlpha = 0.0392;
  static const int calibrationSamples = 500;
  static const bool debug = true;

  List<int> _dataBuffer = [];
  SensorData? latestAccelData;
  SensorData? latestGyroData;

  // Orientation state - PUBLIC GETTERS for repository access
  double _roll = 0.0;
  double _pitch = 0.0;

  // Public getters for current orientation
  double get roll => _roll;

  double get pitch => _pitch;

  // Calibration offsets
  double gyroXOffset = 0.0,
      gyroYOffset = 0.0;
  double accelXOffset = 0.0,
      accelYOffset = 0.0,
      accelZOffset = 0.0;
  static bool gyroCalibrated = false;
  static bool accelCalibrated = false;

  bool isFirstSampleAccel = true;

  double filteredAccelX = 0.0;
  double filteredAccelY = 0.0;
  double filteredAccelZ = 0.0;

  double lastGyroTimestamp = 0;

  // Orientation offsets (for reset/recalibration)
  double rollOffset = 0.0;
  double pitchOffset = 0.0;

  ComplementaryFilter rollFilter = ComplementaryFilter(alpha);
  ComplementaryFilter pitchFilter = ComplementaryFilter(alpha);

  // Calibration sums
  double gyroSumX = 0.0,
      gyroSumY = 0.0,
      gyroSumZ = 0.0;
  double accelSumX = 0.0,
      accelSumY = 0.0,
      accelSumZ = 0.0;
  int gyroCalibrationCount = 0;
  int accelCalibrationCount = 0;

  // Skip initial readings which might be unstable
  static const int samplesToSkip = 10;

  // Maximum buffer sizes to prevent memory issues
  static const int maxBufferSize = 50;

  List<double> rollBuffer = [];
  List<double> pitchBuffer = [];

  final StreamController<Orientation> orientationStreamController =
  StreamController.broadcast();

  Stream<Orientation> get orientationStream =>
      orientationStreamController.stream;

  double getDeltaTime(int currentTimestamp) {
    if (lastGyroTimestamp == 0) {
      lastGyroTimestamp = currentTimestamp.toDouble();
      return 0.0;
    }
    double dt = (currentTimestamp - lastGyroTimestamp) /
        1000000.0; // micro to seconds
    lastGyroTimestamp = currentTimestamp.toDouble();
    return dt;
  }

  void processSensorPair(SensorData accel, SensorData gyro) {
    int currentTimestamp = DateTime
        .now()
        .microsecondsSinceEpoch;

    // Calculate accelerometer-based angles
    double accelPitch = atan2(accel.y, accel.z);
    double accelRoll = atan2(
        -accel.x, sqrt(accel.y * accel.y + accel.z * accel.z));

    dt = 0.0012;
    _roll = rollFilter.update(gyro.y, accelRoll, dt);
    _pitch = pitchFilter.update(gyro.x, accelPitch, dt);

    Orientation orientation = Orientation(
        _roll - rollOffset, _pitch - pitchOffset, 0);

    // Only emit if stream is not closed
    if (!orientationStreamController.isClosed) {
      orientationStreamController.add(orientation);
    }
  }

  void processData(List<int> newBytes) {
    _dataBuffer.addAll(newBytes);

    int currentParsePosition = 0;

    while (currentParsePosition + 3 < _dataBuffer.length) {
      // Check for valid header (0x55, 0xAA)
      if (_dataBuffer[currentParsePosition] == 0x55 &&
          _dataBuffer[currentParsePosition + 1] == 0xAA) {
        int packetType = _dataBuffer[currentParsePosition + 2];
        int payloadLength = _dataBuffer[currentParsePosition + 3];
        int totalPacketLength = 4 + payloadLength;

        // Ensure we have the complete declared packet in the buffer
        if (currentParsePosition + totalPacketLength > _dataBuffer.length) {
          break;
        }

        if ((packetType != 0x08 && packetType != 0x0A) ||
            payloadLength != 0x06) {
          currentParsePosition += totalPacketLength;
          if (currentParsePosition > _dataBuffer.length) {
            print("Warning: Skipper advanced beyond buffer length. Resetting.");
            currentParsePosition = _dataBuffer.length;
          }
          continue;
        }

        int x = (_dataBuffer[currentParsePosition + 4] << 8) |
        _dataBuffer[currentParsePosition + 5];
        int y = (_dataBuffer[currentParsePosition + 6] << 8) |
        _dataBuffer[currentParsePosition + 7];
        int z = (_dataBuffer[currentParsePosition + 8] << 8) |
        _dataBuffer[currentParsePosition + 9];

        // Convert to signed integers
        x = x > 32767 ? x - 65536 : x;
        y = y > 32767 ? y - 65536 : y;
        z = z > 32767 ? z - 65536 : z;

        if (packetType == 0x08) {
          // Accelerometer data
          SensorData accelData = SensorData(
            (x / 32768.0) * -16.0,
            (y / 32768.0) * -16.0,
            (z / 32768.0) * -16.0,
          );

          double movementThreshold = 1.05;
          List<double> prevAccel = [0.0, 0.0, 0.0];
          bool calibrationInProgress = false;

          if (!accelCalibrated) {
            // Calculate difference from last sample (movement detection)
            double diffX = (accelData.x - prevAccel[0]).abs();
            double diffY = (accelData.y - prevAccel[1]).abs();
            double diffZ = (accelData.z - prevAccel[2]).abs();
            double totalMovement = diffX + diffY + diffZ;

            prevAccel[0] = accelData.x;
            prevAccel[1] = accelData.y;
            prevAccel[2] = accelData.z;

            if (totalMovement > movementThreshold) {
              // Too much movement -> Reset calibration
              accelCalibrationCount = 0;
              accelSumX = 0;
              accelSumY = 0;
              accelSumZ = 0;
              gyroSumX = 0;
              gyroSumY = 0;
              gyroSumZ = 0;
              calibrationInProgress = false;
            } else {
              // Stable, proceed with calibration
              calibrationInProgress = true;

              if (accelCalibrationCount >= samplesToSkip) {
                accelSumX += accelData.x;
                accelSumY += accelData.y;
                accelSumZ += accelData.z;
              }
              accelCalibrationCount++;

              if (accelCalibrationCount >= calibrationSamples + samplesToSkip) {
                accelXOffset = accelSumX / calibrationSamples;
                accelYOffset = accelSumY / calibrationSamples;
                accelZOffset = (accelSumZ / calibrationSamples) -
                    1.0; // Adjust for gravity
                accelCalibrated = true;
                calibrationInProgress = false;
                print("Accelerometer calibration completed");
              }
            }
          } else {
            double calibratedX = accelData.x - accelXOffset;
            double calibratedY = accelData.y - accelYOffset;
            double calibratedZ = accelData.z - accelZOffset;

            if (isFirstSampleAccel) {
              filteredAccelX = calibratedX;
              filteredAccelY = calibratedY;
              filteredAccelZ = calibratedZ;
              isFirstSampleAccel = false;
            } else {
              filteredAccelX =
                  lpfAlpha * calibratedX + (1.0 - lpfAlpha) * filteredAccelX;
              filteredAccelY =
                  lpfAlpha * calibratedY + (1.0 - lpfAlpha) * filteredAccelY;
              filteredAccelZ =
                  lpfAlpha * calibratedZ + (1.0 - lpfAlpha) * filteredAccelZ;
            }

            latestAccelData =
                SensorData(filteredAccelX, filteredAccelY, filteredAccelZ);
          }
        } else if (packetType == 0x0A) {
          // Gyroscope data
          SensorData gyroData = SensorData(
              (x / 28571.0) * 500.0,
              (y / 28571.0) * 500.0,
              0
          );

          if (!gyroCalibrated) {
            gyroSumX += gyroData.x;
            gyroSumY += gyroData.y;

            gyroCalibrationCount++;
            if (gyroCalibrationCount >= calibrationSamples + samplesToSkip) {
              gyroXOffset = gyroSumX / calibrationSamples;
              gyroYOffset = gyroSumY / calibrationSamples;
              gyroCalibrated = true;
              print("Gyroscope calibration completed");
            }
          } else {
            double calibratedX = gyroData.x - gyroXOffset;
            double calibratedY = gyroData.y - gyroYOffset;

            latestGyroData = SensorData(calibratedX, calibratedY, 0);
          }
        }
        currentParsePosition += totalPacketLength;

        if (gyroCalibrated &&
            accelCalibrated &&
            latestAccelData != null &&
            latestGyroData != null) {
          processSensorPair(latestAccelData!, latestGyroData!);
          // Clear data after processing to ensure one pair at a time
          latestAccelData = null;
          latestGyroData = null;
        }
      } else {
        currentParsePosition++;
      }
    }

    // Remove the processed data from the beginning of the buffer
    if (currentParsePosition > 0) {
      if (currentParsePosition >= _dataBuffer.length) {
        _dataBuffer.clear();
      } else {
        _dataBuffer = _dataBuffer.sublist(currentParsePosition);
      }
    }
  }

  void reset() {
    _roll = 0.0;
    _pitch = 0.0;

    pitchOffset = 0.0;
    rollOffset = 0.0;

    rollFilter.reset();
    pitchFilter.reset();

    // Reset calibration
    gyroSumX = gyroSumY = gyroSumZ = 0.0;
    accelSumX = accelSumY = accelSumZ = 0.0;
    gyroCalibrationCount = accelCalibrationCount = 0;
    gyroCalibrated = false;
    accelCalibrated = false;
    gyroXOffset = 0.0;
    gyroYOffset = 0.0;
    accelXOffset = 0.0;
    accelYOffset = 0.0;

    isFirstSampleAccel = true;
    filteredAccelX = 0.0;
    filteredAccelY = 0.0;
    filteredAccelZ = 0.0;

    print('SensorProcessor: Reset to initial state');
  }

  void recalibrate() {
    rollOffset = _roll;
    pitchOffset = _pitch;
    print('SensorProcessor: Recalibrated, '
        'rollOffset=${rollOffset.toStringAsFixed(4)}, '
        'pitchOffset=${pitchOffset.toStringAsFixed(4)}, ');
  }

  bool get isCalibrated => gyroCalibrated && accelCalibrated;

  void dispose() {
    if (!orientationStreamController.isClosed) {
      orientationStreamController.close();
    }
    print('SensorProcessor: Disposed');
  }
}