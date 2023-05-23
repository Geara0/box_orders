import 'package:boxorders/blocs/auth/auth_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'error_field.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool showPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('login.header'.tr()),
          const SizedBox(height: 23),
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (prev, current) =>
                current is LoginErrorState ||
                current is OnChangeLoginTypeState ||
                current is OnClearErrorState,
            builder: (context, state) => _buildFields(context, state),
          ),
          const SizedBox(height: 7),
          _mainButton(context),
          const SizedBox(height: 25),
          _buildForgotPasswordLink(context),
          const SizedBox(height: 5),
          _buildSignUpLink(context),
          const SizedBox(height: 5),
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (prev, current) => current is OnChangeLoginTypeState,
            builder: (context, state) =>
                _buildChangeLoginTypeLink(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildFields(BuildContext context, AuthState state) {
    if (state is OnChangeLoginTypeState) {
      showPassword = state.showPassword;
    }
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'login.emailHint'.tr(),
            border: const OutlineInputBorder(),
            helperText: ' ',
            errorText: _buildErrorText(state, field: ErrorField.email),
            errorMaxLines: 99,
          ),
        ),
        AnimatedCrossFade(
          firstChild: Container(height: 0.0),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 7),
            child: TextFormField(
              controller: _passwordController,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'login.passwordHint'.tr(),
                border: const OutlineInputBorder(),
                helperText: ' ',
                errorText: _buildErrorText(state, field: ErrorField.password),
                errorMaxLines: 99,
              ),
            ),
          ),
          firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
          secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
          sizeCurve: Curves.fastOutSlowIn,
          crossFadeState: showPassword
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  String? _buildErrorText(state, {required ErrorField field}) {
    if (state is! LoginErrorState) {
      return null;
    }

    if (field == ErrorField.email) {
      return state.errors.emailErrors.isEmpty
          ? null
          : state.errors.emailErrors.join('\n');
    }

    return state.errors.passwordErrors.isEmpty
        ? null
        : state.errors.passwordErrors.join('\n');
  }

  Widget _mainButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () => _mainAction(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('login.button'.tr()),
        ),
      ),
    );
  }

  void _mainAction(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    context.read<AuthBloc>().add(
          LoginButtonEvent(
            email: _emailController.text,
            password: _passwordController.text,
          ),
        );
  }

  Widget _buildForgotPasswordLink(BuildContext context) {
    return TextButton(
      onPressed: () {
        context.read<AuthBloc>().add(ClearErrorEvent());
        context.read<AuthBloc>().add(ScrollEvent(0));
      },
      child: Text(
        'login.forgotPassword'.tr(),
      ),
    );
  }

  Widget _buildSignUpLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${'login.noAccountText'.tr()} '),
        TextButton(
          onPressed: () {
            context.read<AuthBloc>().add(ClearErrorEvent());
            context.read<AuthBloc>().add(ScrollEvent(2));
          },
          child: Text('login.noAccountLink'.tr()),
        ),
      ],
    );
  }

  Widget _buildChangeLoginTypeLink(BuildContext context, AuthState state) {
    return TextButton(
      onPressed: () => context.read<AuthBloc>().add(ChangeLoginTypeEvent()),
      child: Text(
        showPassword
            ? 'login.byEmailLink'.tr()
            : 'login.byEmailAndPassword'.tr(),
      ),
    );
  }
}
