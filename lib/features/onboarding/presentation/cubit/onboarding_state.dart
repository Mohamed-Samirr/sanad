import 'package:equatable/equatable.dart';

enum OnboardingStatus { initial, completing, completed, failure }

class OnboardingState extends Equatable {
  const OnboardingState({
    this.status = OnboardingStatus.initial,
    this.errorMessage,
  });

  final OnboardingStatus status;
  final String? errorMessage;

  OnboardingState copyWith({
    OnboardingStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
