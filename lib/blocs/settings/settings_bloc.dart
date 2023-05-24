import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';
part 'settings_event.dart';

part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final ref = FirebaseDatabase.instance
      .ref('${FirebaseAuth.instance.currentUser?.uid}/params/isSeller');

  SettingsBloc() : super(SettingsInitial()) {
    on<SetCurrentAccountStateEvent>(_setCurrentAccountStateEvent);
    on<GetCurrentAccountStateEvent>(_getCurrentAccountStateEvent);
  }

  FutureOr<void> _setCurrentAccountStateEvent(
    SetCurrentAccountStateEvent event,
    Emitter<SettingsState> emit,
  ) {
    ref.set(event.isSeller);
    emit(CurrentAccountState(isSeller: event.isSeller));
  }

  Future<void> _getCurrentAccountStateEvent(
    GetCurrentAccountStateEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final isSeller = await _getCurrentAccountState();
    emit(CurrentAccountState(isSeller: isSeller));
  }

  Future<bool> _getCurrentAccountState() async {
    final snapshot = await ref.get();
    if (snapshot.exists) {
      return snapshot.value == true;
    }

    return false;
  }
}
