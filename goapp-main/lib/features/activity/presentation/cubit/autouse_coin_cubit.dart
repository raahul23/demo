import "package:flutter_bloc/flutter_bloc.dart";

class AutoUseCoinCubit extends Cubit<bool> {
  AutoUseCoinCubit({bool initialValue = true}) : super(initialValue);

  void setEnabled(bool enabled) => emit(enabled);
}
