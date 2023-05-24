part of 'settings_bloc.dart';

@immutable
abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class CurrentAccountState extends SettingsState {
  final bool isSeller;

  CurrentAccountState({required this.isSeller});
}
