import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../core/errors/failures.dart';

class AppLockService {
  final FlutterSecureStorage _storage;
  final LocalAuthentication _auth;

  static const String _pinKey = 'sanad_app_pin';
  static const String _biometricsKey = 'sanad_app_biometrics_enabled';

  AppLockService({
    FlutterSecureStorage? storage,
    LocalAuthentication? auth,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _auth = auth ?? LocalAuthentication();

  Future<Either<Failure, bool>> isPinSet() async {
    try {
      final pin = await _storage.read(key: _pinKey);
      return Right(pin != null && pin.isNotEmpty);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> setPin(String pin) async {
    try {
      await _storage.write(key: _pinKey, value: pin);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> removePin() async {
    try {
      await _storage.delete(key: _pinKey);
      await _storage.delete(key: _biometricsKey); // disable biometrics too
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<Either<Failure, bool>> verifyPin(String pin) async {
    try {
      final storedPin = await _storage.read(key: _pinKey);
      return Right(storedPin == pin);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<Either<Failure, bool>> isBiometricsEnabled() async {
    try {
      final enabled = await _storage.read(key: _biometricsKey);
      return Right(enabled == 'true');
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> setBiometricsEnabled(bool enabled) async {
    try {
      await _storage.write(key: _biometricsKey, value: enabled.toString());
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<Either<Failure, bool>> authenticateWithBiometrics(String reason) async {
    try {
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) return const Right(false);

      final didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
      );
      return Right(didAuthenticate);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
