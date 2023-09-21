import 'dart:js';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/pages/login/cubit/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(InitialState());

  void signIn(String email, String password) async {
    emit(LoadingState());

    try {
      // Thực hiện đăng nhập ở đây (sử dụng FirebaseAuth hoặc hệ thống đăng nhập của bạn)
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );
      // Sau khi đăng nhập thành công:
      emit(LoggedInState());
    } on FirebaseAuthException catch (e) {
      emit(ErrorState(e.toString()));
    }
  }
}
