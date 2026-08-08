import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../settings/domain/usecases/get_settings.dart';
import '../../../settings/domain/usecases/update_settings.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({
    required this.getSettings,
    required this.updateSettings,
  }) : super(const OnboardingState());

  final GetSettings getSettings;
  final UpdateSettings updateSettings;

  Future<void> completeOnboarding() async {
    emit(state.copyWith(status: OnboardingStatus.completing, clearError: true));

    final settingsResult = await getSettings(const NoParams());
    
    await settingsResult.fold(
      (failure) async {
        emit(state.copyWith(
          status: OnboardingStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (settings) async {
        final updated = settings.copyWith(onboardingDone: true);
        final result = await updateSettings(updated);
        
        result.fold(
          (failure) => emit(state.copyWith(
            status: OnboardingStatus.failure,
            errorMessage: failure.message,
          )),
          (_) => emit(state.copyWith(status: OnboardingStatus.completed)),
        );
      },
    );
  }
}
