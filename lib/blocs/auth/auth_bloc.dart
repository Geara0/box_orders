import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

import 'auth_errors.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  bool showPassword = true;

  AuthBloc() : super(AuthInitial()) {
    // on<AuthEvent>(_authEventHandler);
    on<LoginButtonEvent>(_loginButtonEvent);
    on<SignUpButtonEvent>(_signUpButtonEvent);
    on<ForgotPasswordButtonEvent>(_forgotPasswordButtonEvent);
    on<ChangeLoginTypeEvent>(_loginTypeEvent);
    on<ClearErrorEvent>(_clearErrorEvent);
    on<ScrollEvent>(_scrollEvent);
    on<GoogleLoginEvent>(_googleLoginEvent);
  }

  Future<void> _googleLoginEvent(
      GoogleLoginEvent event, Emitter<AuthState> emit) async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((_) => emit(LoginState()));
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(
          name: 'googleLoginError', parameters: {'error': e.toString()});

      emit(ResultMessageState());
    }
  }

  Future<void> _loginButtonEvent(
    LoginButtonEvent event,
    Emitter<AuthState> emit,
  ) async {
    var errors = _loginValidate(event.email, event.password, emit);
    if (errors.isEmpty) {
      AuthErrors? errors;
      if (showPassword) {
        errors = await _login(event.email, event.password, emit);
      } else {
        errors = await _loginByLink(event.email, emit);
      }
      if (errors != null) {
        emit(LoginErrorState(errors));
        return;
      }
      emit(LoginState());
      return;
    }

    emit(ResultMessageState());
    emit(LoginErrorState(errors));
  }

  Future<void> _signUpButtonEvent(
    SignUpButtonEvent event,
    Emitter<AuthState> emit,
  ) async {
    var errors = _signUpValidate(
        event.email, event.password, event.passwordDuplicate, emit);
    if (errors.isEmpty) {
      AuthErrors? errors;
      errors = await _signUp(event.email, event.password, emit);
      if (errors != null) {
        emit(SignUpErrorState(errors));
        return;
      }
      emit(LoginState());
      return;
    }

    emit(ResultMessageState());
    emit(SignUpErrorState(errors));
  }

  Future<void> _forgotPasswordButtonEvent(
    ForgotPasswordButtonEvent event,
    Emitter<AuthState> emit,
  ) async {
    var errors = _forgotPasswordValidate(event.email, emit);
    if (errors.isEmpty) {
      AuthErrors? errors;
      errors = await _forgotPassword(event.email, emit);
      if (errors != null) {
        emit(ForgotPasswordErrorState(errors));
        return;
      }
      return;
    }

    emit(ResultMessageState());
    emit(ForgotPasswordErrorState(errors));
  }

  Future<void> _loginTypeEvent(
      ChangeLoginTypeEvent event, Emitter<AuthState> emit) async {
    showPassword = !showPassword;
    emit(OnChangeLoginTypeState(showPassword));
  }

  Future<void> _clearErrorEvent(
      ClearErrorEvent event, Emitter<AuthState> emit) async {
    emit(OnClearErrorState());
  }

  Future<void> _scrollEvent(ScrollEvent event, Emitter<AuthState> emit) async {
    showPassword = true;
    emit(ScrollState(event.index));
  }

  AuthErrors _loginValidate(
      String login, String? password, Emitter<AuthState> emit) {
    final errors = AuthErrors();

    errors.emailErrors.addAll(_validateEmail(login, emit));
    errors.passwordErrors.addAll(_loginValidatePassword(password, emit));

    return errors;
  }

  AuthErrors _signUpValidate(String login, String password,
      String passwordDuplicate, Emitter<AuthState> emit) {
    final errors = AuthErrors();

    errors.emailErrors.addAll(_validateEmail(login, emit));
    errors.passwordErrors.addAll(_signUpValidatePassword(password, emit));
    errors.passwordDuplicateErrors.addAll(
        _signUpValidatePasswordDuplicate(password, passwordDuplicate, emit));

    return errors;
  }

  AuthErrors _forgotPasswordValidate(String login, Emitter<AuthState> emit) {
    final errors = AuthErrors();

    errors.emailErrors.addAll(_validateEmail(login, emit));

    return errors;
  }

  List<String> _validateEmail(String email, Emitter<AuthState> emit) {
    List<String> errors = [];
    email = email.trim();

    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      errors.add('login.enterValidEmail'.tr());
    }

    return errors;
  }

  List<String> _loginValidatePassword(
      String? password, Emitter<AuthState> emit) {
    List<String> errors = [];
    password = password?.trim();

    if (showPassword && (password == null || password.isEmpty)) {
      errors.add('login.noEmptyPassword'.tr());
    }

    return errors;
  }

  List<String> _signUpValidatePassword(
      String password, Emitter<AuthState> emit) {
    List<String> errors = [];
    password = password.trim();

    if (password.isEmpty) {
      errors.add('signUp.noEmptyPassword'.tr());
    }

    if (password.length < 8) {
      errors.add('signUp.longPassword'.tr());
    }

    if (!password.contains(RegExp('[A-Z]'))) {
      errors.add('signUp.uppercasePassword'.tr());
    }

    if (!password.contains(RegExp('[a-z]'))) {
      errors.add('signUp.lowercasePassword'.tr());
    }

    if (!password.contains(RegExp('[\$&+,:;=?@#|\'<>.^*()%!-]'))) {
      errors.add('signUp.specialPassword'.tr());
    }

    return errors;
  }

  List<String> _signUpValidatePasswordDuplicate(
      String password, String passwordDuplicate, Emitter<AuthState> emit) {
    List<String> errors = [];
    if (password.trim() != passwordDuplicate.trim()) {
      errors.add('signUp.matchPassword'.tr());
    }
    return errors;
  }

  Future<AuthErrors?> _forgotPassword(email, emit) async {
    emit(OnClearErrorState());
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email.trim())
          .then((_) {
        emit(ResultMessageState(message: 'forgotPassword.success'.tr()));
      });
    } on FirebaseAuthException catch (e) {
      var res = AuthErrors();

      if (e.message == null) {
        return res;
      }

      String message = e.message!;

      if (e.code.contains('email')) {
        res.emailErrors.add(message);
        emit(ResultMessageState());
        return res;
      } else {
        FirebaseAnalytics.instance.logEvent(
            name: 'forgotPasswordError',
            parameters: {
              'message': e.message.toString(),
              'stacktrace': e.stackTrace.toString()
            });
        emit(ResultMessageState(message: message));
      }
    }

    return null;
  }

  Future<AuthErrors?> _signUp(email, password, emit) async {
    emit(OnClearErrorState());
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          )
          .then((_) => emit(LoginState()));
    } on FirebaseAuthException catch (e) {
      var res = AuthErrors();

      if (e.message == null) {
        return res;
      }

      String message = e.message!;

      if (e.code.contains('email')) {
        res.emailErrors.add(message);
        emit(ResultMessageState());
        return res;
      } else if (e.code.contains('password')) {
        res.passwordErrors.add(message);
        emit(ResultMessageState());
        return res;
      } else {
        _logFirebaseAuthException(e, 'signUpError');
        emit(ResultMessageState(message: message));
      }
    }

    return null;
  }

  Future<AuthErrors?> _login(email, password, emit) async {
    emit(OnClearErrorState());
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          )
          .then((_) => emit(LoginState()));
    } on FirebaseAuthException catch (e) {
      var res = AuthErrors();

      if (e.message == null) {
        return res;
      }

      String message = e.message!;

      if (e.code.contains('email')) {
        res.emailErrors.add(message);
        emit(ResultMessageState());
        return res;
      } else if (e.code.contains('password')) {
        res.passwordErrors.add(message);
        emit(ResultMessageState());
        return res;
      } else {
        _logFirebaseAuthException(e, 'loginError');
        emit(ResultMessageState(message: message));
      }
    }

    return null;
  }

  // TODO: invalidDynamicLink
  Future<AuthErrors?> _loginByLink(email, emit) async {
    try {
      await FirebaseAuth.instance
          .sendSignInLinkToEmail(
              email: email.trim(),
              actionCodeSettings: ActionCodeSettings(
                  url: 'https://localstoreapp.page.link/',
                  handleCodeInApp: true,
                  iOSBundleId: 'com.google.firebase.localstoreapp',
                  androidPackageName: 'com.google.firebase.localstoreapp',
                  androidInstallApp: true,
                  androidMinimumVersion: "21"))
          .then((_) => emit(LoginState()));
    } on FirebaseAuthException catch (e) {
      if (e.message == null) {
        return null;
      }
      String message = e.message!;

      if (e.code.contains('email')) {
        emit(ResultMessageState());
        return AuthErrors()..emailErrors.add(message);
      } else {
        emit(ResultMessageState(message: message));
        _logFirebaseAuthException(e, 'loginByLinkError');
      }
    }

    return null;
  }

  _logFirebaseAuthException(FirebaseAuthException e, String name) {
    FirebaseAnalytics.instance.logEvent(name: name, parameters: {
      'message': e.message.toString(),
      'stacktrace': e.stackTrace.toString()
    });
  }
}
