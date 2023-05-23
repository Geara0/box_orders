part of 'auth_bloc.dart';

@immutable
abstract class AuthState {}

// Initial
class AuthInitial extends AuthState {}

// Methods for listener
class ListenState extends AuthState {}

class ScrollState extends ListenState {
  final int index;

  ScrollState(this.index);
}

class LoginState extends ListenState {}

class ResultMessageState extends ListenState {
  final String? message;

  ResultMessageState({this.message});
}

// Methods rebuilding whole page
class AuthPageState extends AuthState {}

// Pass data to firebase methods
abstract class ProcessDataState extends AuthState {
  final String login;
  final String password;

  ProcessDataState({required this.login, required this.password});
}

// Return error methods
abstract class ErrorState extends AuthState {
  final AuthErrors errors;

  ErrorState(this.errors);
}

class LoginErrorState extends ErrorState {
  LoginErrorState(super.errors);
}

class SignUpErrorState extends ErrorState {
  SignUpErrorState(super.errors);
}

class ForgotPasswordErrorState extends ErrorState {
  ForgotPasswordErrorState(super.errors);
}

// Method for sign up|login W|O password
class OnChangeLoginTypeState extends AuthState {
  final bool showPassword;

  OnChangeLoginTypeState(this.showPassword);
}

// Clear field errors
class OnClearErrorState extends AuthState {}
