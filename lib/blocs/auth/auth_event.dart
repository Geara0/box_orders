part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class ScrollEvent extends AuthEvent {
  final int index;

  ScrollEvent(this.index);
}

class ForgotPasswordButtonEvent extends AuthEvent {
  final String email;

  ForgotPasswordButtonEvent({
    required this.email,
  });
}

class LoginButtonEvent extends AuthEvent {
  final String email;
  final String password;

  LoginButtonEvent({
    required this.email,
    required this.password,
  });
}

class SignUpButtonEvent extends AuthEvent {
  final String email;
  final String password;
  final String passwordDuplicate;

  SignUpButtonEvent({
    required this.email,
    required this.password,
    required this.passwordDuplicate,
  });
}

class ChangeLoginTypeEvent extends AuthEvent {}

class ClearErrorEvent extends AuthEvent {}

class GoogleLoginEvent extends AuthEvent {}
