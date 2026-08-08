import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/services/app_lock_service.dart';
import '../../domain/services/data_export_service.dart';
import '../../domain/usecases/wipe_data.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final AppLockService _appLockService;
  final DataExportService _dataExportService;
  final WipeData _wipeData;

  SettingsCubit({
    required AppLockService appLockService,
    required DataExportService dataExportService,
    required WipeData wipeData,
  })  : _appLockService = appLockService,
        _dataExportService = dataExportService,
        _wipeData = wipeData,
        super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final pinResult = await _appLockService.isPinSet();
    final bioResult = await _appLockService.isBiometricsEnabled();

    final hasPin = pinResult.fold((_) => false, (r) => r);
    final hasBio = bioResult.fold((_) => false, (r) => r);

    emit(state.copyWith(
      hasPin: hasPin,
      isBiometricsEnabled: hasBio,
      isUnlocked: !hasPin, // lock on startup if PIN is set
    ));
  }

  Future<bool> verifyPin(String pin) async {
    final result = await _appLockService.verifyPin(pin);
    return result.fold((_) => false, (isValid) {
      if (isValid) {
        emit(state.copyWith(isUnlocked: true));
      }
      return isValid;
    });
  }

  Future<void> lockApp() async {
    if (state.hasPin) {
      emit(state.copyWith(isUnlocked: false));
    }
  }

  Future<void> setPin(String pin) async {
    emit(state.copyWith(isLoading: true));
    final result = await _appLockService.setPin(pin);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (_) {
        emit(state.copyWith(isLoading: false, hasPin: true));
      },
    );
  }

  Future<void> removePin() async {
    emit(state.copyWith(isLoading: true));
    final result = await _appLockService.removePin();
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (_) {
        emit(state.copyWith(
          isLoading: false,
          hasPin: false,
          isBiometricsEnabled: false,
          isUnlocked: true,
        ));
      },
    );
  }

  Future<void> toggleBiometrics(bool enabled) async {
    final result = await _appLockService.setBiometricsEnabled(enabled);
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) => emit(state.copyWith(isBiometricsEnabled: enabled)),
    );
  }

  Future<void> authenticateWithBiometrics(String reason) async {
    final result = await _appLockService.authenticateWithBiometrics(reason);
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (success) {
        if (success) {
          emit(state.copyWith(isUnlocked: true));
        }
      },
    );
  }

  Future<void> wipeData() async {
    emit(state.copyWith(isLoading: true));
    final result = await _wipeData(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (_) => emit(state.copyWith(isLoading: false)),
    );
  }

  Future<void> exportData() async {
    emit(state.copyWith(isLoading: true));
    final result = await _dataExportService.exportData();
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (_) => emit(state.copyWith(isLoading: false)),
    );
  }

  Future<void> importData() async {
    emit(state.copyWith(isLoading: true));
    final result = await _dataExportService.importData();
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (_) => emit(state.copyWith(isLoading: false)),
    );
  }
}
