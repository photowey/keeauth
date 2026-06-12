import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:keeauth/core/storage/secure_storage_service.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class LoadTheme extends ThemeEvent {}

class SetThemeMode extends ThemeEvent {
  final ThemeMode mode;

  const SetThemeMode(this.mode);

  @override
  List<Object?> get props => [mode];
}

// State
class ThemeState extends Equatable {
  final ThemeMode mode;

  const ThemeState({this.mode = ThemeMode.system});

  ThemeState copyWith({ThemeMode? mode}) {
    return ThemeState(mode: mode ?? this.mode);
  }

  @override
  List<Object?> get props => [mode];
}

// BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SecureStorageService _storage = SecureStorageService();

  ThemeBloc() : super(const ThemeState()) {
    on<LoadTheme>(_onLoadTheme);
    on<SetThemeMode>(_onSetThemeMode);

    // Load saved theme on init
    add(LoadTheme());
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    final themeString = await _storage.getTheme();
    final mode = _parseThemeMode(themeString);
    emit(state.copyWith(mode: mode));
  }

  Future<void> _onSetThemeMode(SetThemeMode event, Emitter<ThemeState> emit) async {
    await _storage.setTheme(event.mode.name);
    emit(state.copyWith(mode: event.mode));
  }

  ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
