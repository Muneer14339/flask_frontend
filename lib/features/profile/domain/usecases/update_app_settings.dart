// import 'package:dartz/dartz.dart';
// import 'package:equatable/equatable.dart';
// import '../entities/app_settings.dart';
// import '../repositories/profile_repository.dart';
// import '../../core/error/failures.dart';
// import '../../core/usecases/usecase.dart';
//
// class UpdateAppSettings implements UseCase<void, UpdateAppSettingsParams> {
//   final ProfileRepository repository;
//
//   UpdateAppSettings(this.repository);
//
//   @override
//   Future<Either<Failure, void>> call(UpdateAppSettingsParams params) async {
//     return await repository.updateAppSettings(params.settings);
//   }
// }
//
// class UpdateAppSettingsParams extends Equatable {
//   final AppSettings settings;
//
//   const UpdateAppSettingsParams({required this.settings});
//
//   @override
//   List<Object> get props => [settings];
// }