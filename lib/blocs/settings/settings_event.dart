part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {}

class SetCurrentAccountStateEvent extends SettingsEvent {
  final bool isSeller;

  SetCurrentAccountStateEvent({required this.isSeller});
}

class GetCurrentAccountStateEvent extends SettingsEvent {
  GetCurrentAccountStateEvent();
}
