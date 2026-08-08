import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class UpdateSettings implements UseCase<void, AppSettings> {
  UpdateSettings(this.repository);

  final SettingsRepository repository;

  @override
  Future<Either<Failure, void>> call(AppSettings params) async {
    return await repository.updateSettings(params);
  }
}
