import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/login/repo_impl.dart';

class LoginState {
  final bool loading;
  final String? error;
  final bool success;

  LoginState({
    this.loading = false,
    this.error,
    this.success = false,
  });
}

class LoginCubit extends Cubit<LoginState> {
  final LoginRepoImpl repo;
  LoginCubit(this.repo) : super(LoginState());

  Future<void> login(String user, String pass) async {
    try {
      emit(LoginState(loading: true, success: false, error: null));

      await repo.login(user, pass); // token save bo'ladi

      emit(LoginState(loading: false, success: true, error: null));
    } catch (e) {
      emit(LoginState(loading: false, success: false, error: e.toString()));
    }
  }

  void reset() {
    emit(LoginState());
  }
}
