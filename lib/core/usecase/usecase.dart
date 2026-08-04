import 'package:dartz/dartz.dart';

import '../errors/failures.dart';

/// One use case per class, a single [call]. [Result] rather than `Type` so the
/// parameter does not shadow `dart:core`'s own `Type`.
abstract class UseCase<Result, Params> {
  Future<Either<Failure, Result>> call(Params params);
}

class NoParams {
  const NoParams();
}
