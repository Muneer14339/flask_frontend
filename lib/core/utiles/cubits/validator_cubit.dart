import 'package:flutter_bloc/flutter_bloc.dart';

class AutoValidationCubit extends Cubit<bool> {
  AutoValidationCubit() : super(false);

  void enableAuto() {
    if (!state) {
      emit(true);
    }
  }
}
