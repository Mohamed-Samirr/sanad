import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../urge/domain/repositories/urge_repository.dart';
import '../../../urge/domain/repositories/trigger_repository.dart';
import '../../domain/services/insights_calculator.dart';
import 'insights_state.dart';

class InsightsCubit extends Cubit<InsightsState> {
  final UrgeRepository _urgeRepository;
  final TriggerRepository _triggerRepository;
  StreamSubscription? _urgeSub;
  StreamSubscription? _triggerSub;

  InsightsCubit({
    required UrgeRepository urgeRepository,
    required TriggerRepository triggerRepository,
  })  : _urgeRepository = urgeRepository,
        _triggerRepository = triggerRepository,
        super(const InsightsState()) {
    _urgeSub = _urgeRepository.watchUrges().listen((_) => loadInsights());
    _triggerSub = _triggerRepository.watchTriggers().listen((_) => loadInsights());
  }

  Future<void> loadInsights() async {
    emit(state.copyWith(status: InsightsStatus.loading));

    final urgeRes = await _urgeRepository.getUrgeHistory();
    final triggerRes = await _triggerRepository.getTriggers();

    urgeRes.fold(
      (failure) => emit(state.copyWith(
        status: InsightsStatus.failure,
        errorMessage: failure.message,
      )),
      (urges) {
        triggerRes.fold(
          (failure) => emit(state.copyWith(
            status: InsightsStatus.failure,
            errorMessage: failure.message,
          )),
          (triggers) {
            final calculator = InsightsCalculator(
              urges: urges,
              triggers: triggers,
            );
            emit(state.copyWith(
              status: InsightsStatus.success,
              calculator: calculator,
            ));
          },
        );
      },
    );
  }

  @override
  Future<void> close() {
    _urgeSub?.cancel();
    _triggerSub?.cancel();
    return super.close();
  }
}
