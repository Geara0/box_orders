import 'package:boxorders/blocs/settings/settings_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<SettingsBloc>().add(GetCurrentAccountStateEvent());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('settings.title'.tr()),
      ),
      body: Center(
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: _builder,
        ),
      ),
    );
  }

  Widget _builder(BuildContext context, SettingsState state) {
    debugPrint('trigger builder');
    if (state is SettingsInitial) {
      return const CircularProgressIndicator();
    }

    if (state is! CurrentAccountState) {
      return ErrorWidget('something went wrong');
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (state.isSeller)
          Text('settings.seller'.tr())
        else
          Text('settings.user'.tr()),
        const SizedBox(height: 20),
        Switch(
          value: state.isSeller,
          onChanged: (bool val) {
            debugPrint('onChanged: $val');
            context
                .read<SettingsBloc>()
                .add(SetCurrentAccountStateEvent(isSeller: val));
          },
        )
      ],
    );
  }
}
