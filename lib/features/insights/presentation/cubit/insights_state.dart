import 'package:equatable/equatable.dart';

import '../../domain/services/insights_calculator.dart';

enum InsightsStatus { initial, loading, success, failure }

class InsightsState extends Equatable {
  final InsightsStatus status;
  final InsightsCalculator? calculator;
  final String? errorMessage;

  const InsightsState({
    this.status = InsightsStatus.initial,
    this.calculator,
    this.errorMessage,
  });

  InsightsState copyWith({
    InsightsStatus? status,
    InsightsCalculator? calculator,
    String? errorMessage,
  }) {
    return InsightsState(
      status: status ?? this.status,
      calculator: calculator ?? this.calculator,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, calculator, errorMessage];
}
