import 'package:equatable/equatable.dart';

class TrainingPreferences extends Equatable {
  final bool soundEnabled;
  final double soundVolume; // 0-100
  final String alertTone; // beep, chime, click, voice

  const TrainingPreferences({
    required this.soundEnabled,
    required this.soundVolume,
    required this.alertTone,
  });

  factory TrainingPreferences.defaults() {
    return const TrainingPreferences(
      soundEnabled: true,
      soundVolume: 75.0,
      alertTone: 'beep',
    );
  }

  TrainingPreferences copyWith({
    bool? soundEnabled,
    double? soundVolume,
    String? alertTone,
  }) {
    return TrainingPreferences(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      soundVolume: soundVolume ?? this.soundVolume,
      alertTone: alertTone ?? this.alertTone,
    );
  }

  @override
  List<Object> get props => [soundEnabled, soundVolume, alertTone];
}
