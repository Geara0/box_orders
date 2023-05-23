import 'package:boxorders/blocs/auth/auth_bloc.dart';
import 'package:boxorders/utils/message_utils/message_utils.dart';
import 'package:boxorders/widgets/auth/forgot_password.dart';
import 'package:boxorders/widgets/auth/login.dart';
import 'package:boxorders/widgets/auth/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AuthPage extends StatelessWidget {
  AuthPage({Key? key}) : super(key: key);
  static const routeName = '/auth';
  final PageController authController = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            height: 653,
            constraints: const BoxConstraints(
              maxWidth: 320,
            ),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _buildLogo(context),
                const SizedBox(height: 16),
                BlocConsumer<AuthBloc, AuthState>(
                  buildWhen: (prev, current) => current is AuthPageState,
                  listenWhen: (prev, current) => current is ListenState,
                  listener: _listener,
                  builder: _builder,
                ),
                _buildGoogleButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _listener(BuildContext context, AuthState state) {
    if (state is ScrollState) {
      authController.animateToPage(
        state.index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    } else if (state is LoginState) {
      context.go('/');
    } else if (state is ResultMessageState) {
      Navigator.pop(context);
      if (state.message != null) {
        MessageUtils.showTertiarySnackBar(state.message!, context);
      }
    }
  }

  Widget _builder(BuildContext context, AuthState state) {
    return SizedBox(
      height: 485,
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: authController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (_, i) {
          switch (i) {
            case 0:
              return const ForgotPasswordWidget();
            case 1:
              return const LoginWidget();
            case 2:
              return const SignUpWidget();
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGoogleButton(BuildContext context) {
    return IconButton(
      onPressed: () => _googleAction(context),
      icon: const Icon(Icons.abc),
    );
  }

  void _googleAction(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    context.read<AuthBloc>().add(GoogleLoginEvent());
  }

  Widget _buildLogo(BuildContext context) {
    return const SizedBox(
      height: 48,
      child: Text('Logo placeholder'),
    );
  }
}
