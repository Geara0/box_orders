import 'package:boxorders/blocs/auth/auth_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'error_field.dart';

class ForgotPasswordWidget extends StatefulWidget {
  const ForgotPasswordWidget({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordWidget> createState() => _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends State<ForgotPasswordWidget> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('forgotPassword.header'.tr()),
          const SizedBox(height: 23),
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (prev, current) =>
                current is ForgotPasswordErrorState ||
                current is ClearErrorEvent,
            builder: _buildFields,
          ),
          const SizedBox(height: 7),
          _buildMainButton(context),
          const SizedBox(height: 25),
          _buildLoginLink(context),
        ],
      ),
    );
  }

  Widget _buildFields(BuildContext context, AuthState state) {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'forgotPassword.emailHint'.tr(),
        border: const OutlineInputBorder(),
        helperText: ' ',
        errorText: _buildErrorText(state, field: ErrorField.email),
        errorMaxLines: 99,
      ),
    );
  }

  String? _buildErrorText(state, {required ErrorField field}) {
    if (state is! ForgotPasswordErrorState) {
      return null;
    }

    return state.errors.emailErrors.isEmpty
        ? null
        : state.errors.emailErrors.join('\n');
  }

  Widget _buildMainButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () => _mainAction(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('forgotPassword.sendEmail'.tr()),
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
    context
        .read<AuthBloc>()
        .add(ForgotPasswordButtonEvent(email: _emailController.text));
  }

  Widget _buildLoginLink(BuildContext context) {
    return TextButton(
      onPressed: () {
        context.read<AuthBloc>().add(ClearErrorEvent());
        context.read<AuthBloc>().add(ScrollEvent(1));
      },
      child: Text(
        'forgotPassword.rememberPassword'.tr(),
      ),
    );
  }
}
