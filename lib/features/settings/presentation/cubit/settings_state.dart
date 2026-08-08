import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final bool isLoading;
  final String? error;
  final bool hasPin;
  final bool isBiometricsEnabled;
  final bool isUnlocked;

  const SettingsState({
    this.isLoading = false,
    this.error,
    this.hasPin = false,
    this.isBiometricsEnabled = false,
    this.isUnlocked = true, // default to unlocked until locked via startup
  });

  SettingsState copyWith({
    bool? isLoading,
    String? error,
    bool? hasPin,
    bool? isBiometricsEnabled,
    bool? isUnlocked,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // intentionally reset on state copy if not provided? No, let's keep it null by default.
      hasPin: hasPin ?? this.hasPin,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        hasPin,
        isBiometricsEnabled,
        isUnlocked,
      ];
}
