// Sự kiện để xử lý đăng nhập
abstract class LoginEvent {}

class SignInEvent extends LoginEvent {
  final String email;
  final String password;

  SignInEvent(this.email, this.password);
}

// Trạng thái của trang đăng nhập
abstract class LoginState {}

class InitialState extends LoginState {}

class LoadingState extends LoginState {}

class ErrorState extends LoginState {
  final String errorMessage;

  ErrorState(this.errorMessage);
}

class LoggedInState extends LoginState {}
