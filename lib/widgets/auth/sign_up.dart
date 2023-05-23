import 'package:boxorders/blocs/auth/auth_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'error_field.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({Key? key}) : super(key: key);

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordDuplicateController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordDuplicateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (MediaQuery.of(context).size.height >= 840) ...[
              Text('signUp.header'.tr()),
              const SizedBox(height: 23),
            ],
            BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (prev, current) =>
                  current is SignUpErrorState || current is ClearErrorEvent,
              builder: _buildFields,
            ),
            const SizedBox(height: 7),
            _buildMainButton(context),
            const SizedBox(height: 25),
            _buildNoAccountLink(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFields(BuildContext context, AuthState state) {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'signUp.emailHint'.tr(),
            border: const OutlineInputBorder(),
            helperText: ' ',
            errorText: _buildErrorText(state, field: ErrorField.email),
            errorMaxLines: 99,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: 'signUp.passwordHint'.tr(),
            border: const OutlineInputBorder(),
            helperText: ' ',
            errorText: _buildErrorText(state, field: ErrorField.password),
            errorMaxLines: 99,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: _passwordDuplicateController,
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: 'signUp.passwordDuplicateHint'.tr(),
            border: const OutlineInputBorder(),
            helperText: ' ',
            errorText:
                _buildErrorText(state, field: ErrorField.passwordDuplicate),
            errorMaxLines: 99,
          ),
        ),
      ],
    );
  }

  String? _buildErrorText(state, {required ErrorField field}) {
    if (state is! SignUpErrorState) {
      return null;
    }

    if (field == ErrorField.email) {
      return state.errors.emailErrors.isEmpty
          ? null
          : state.errors.emailErrors.join('\n');
    }

    if (field == ErrorField.password) {
      return state.errors.passwordErrors.isEmpty
          ? null
          : state.errors.passwordErrors.join('\n');
    }

    return state.errors.passwordDuplicateErrors.isEmpty
        ? null
        : state.errors.passwordDuplicateErrors.join('\n');
  }

  void _mainAction(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    context.read<AuthBloc>().add(SignUpButtonEvent(
        email: _emailController.text,
        password: _passwordController.text,
        passwordDuplicate: _passwordDuplicateController.text));
  }

  Widget _buildNoAccountLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${'signUp.noAccountText'.tr()} '),
        TextButton(
          onPressed: () {
            context.read<AuthBloc>().add(ClearErrorEvent());
            context.read<AuthBloc>().add(ScrollEvent(1));
          },
          child: Text('signUp.noAccountLink'.tr()),
        ),
      ],
    );
  }

  Widget _buildMainButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () => _mainAction(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('signUp.button'.tr()),
        ),
      ),
    );
  }
}
