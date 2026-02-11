import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/register/repo_impl.dart';

class RegisterState {
  final bool loading;
  final String? error;

  RegisterState({this.loading = false, this.error});
}

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterRepoImpl repo;
  RegisterCubit(this.repo) : super(RegisterState());

  Future<void> register(String u, String e, String p) async {
    try {
      emit(RegisterState(loading: true));
      await repo.register(u, e, p);
      emit(RegisterState());
    } catch (er) {
      emit(RegisterState(error: er.toString()));
    }
  }
}
