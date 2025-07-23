import '../entities/angle_reading.dart';
import '../repositories/training_repository.dart';

class GetRealtimeReadings {
  final TrainingRepository repository;

  GetRealtimeReadings(this.repository);

  Stream<AngleReading> call() {
    return repository.getRealtimeReadings();
  }
}