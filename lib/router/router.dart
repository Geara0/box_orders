import 'dart:async';

import 'package:boxorders/blocs/auth/auth_bloc.dart';
import 'package:boxorders/blocs/settings/settings_bloc.dart';
import 'package:boxorders/pages/auth/auth.dart';
import 'package:boxorders/pages/create_box/create_box.dart';
import 'package:boxorders/pages/main/main_page.dart';
import 'package:boxorders/pages/settings/settings_page.dart';
import 'package:boxorders/pages/verify_email/verify_email.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  errorBuilder: (context, state) {
    return const MainPage();
  },
  redirect: _guard,
  routes: _routes,
  debugLogDiagnostics: true,
);

final List<GoRoute> _routes = [
  GoRoute(
    path: '/',
    builder: (context, state) => const MainPage(),
  ),
  GoRoute(
    path: '/box',
    redirect: _boxGuard,
    routes: [
      GoRoute(
        path: 'create',
        builder: (context, state) => CreateBoxPage(),
      ),
    ],
  ),
  GoRoute(
    path: '/settings',
    builder: (context, state) => BlocProvider(
      create: (context) => SettingsBloc(),
      child: const SettingsPage(),
    ),
  ),
  GoRoute(
    path: '/auth',
    builder: (context, state) => BlocProvider(
      create: (context) => AuthBloc(),
      child: AuthPage(),
    ),
    redirect: _authGuard,
  ),
  GoRoute(
    path: '/verify_email',
    builder: (context, state) => const VerifyEmailPage(),
    redirect: _verifyEmailGuard,
  ),
];

FutureOr<String?> _guard(BuildContext context, GoRouterState state) {
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return '/auth';
  } else if (!user.emailVerified) {
    return '/verify_email';
  }

  return null;
}

FutureOr<String?> _authGuard(BuildContext context, GoRouterState state) {
  if (FirebaseAuth.instance.currentUser != null) {
    return '/';
  }

  return null;
}

FutureOr<String?> _verifyEmailGuard(BuildContext context, GoRouterState state) {
  if (FirebaseAuth.instance.currentUser?.emailVerified == true) {
    return '/';
  }

  return null;
}

FutureOr<String?> _boxGuard(BuildContext context, GoRouterState state) {
  if (state.fullPath == '/box') {
    return '/';
  }

  return null;
}
