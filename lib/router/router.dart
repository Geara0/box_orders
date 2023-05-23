import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../main.dart';

final GoRouter router = GoRouter(
  errorBuilder: (context, state) {
    return const MyHomePage();
  },
  redirect: _guard,
  routes: _routes,
  debugLogDiagnostics: true,
);

final List<GoRoute> _routes = [
  GoRoute(
    path: '/',
    builder: (context, state) => const MyHomePage(),
    redirect: (a, b) => '/brand/tender',
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
