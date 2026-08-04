abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Failure && other.message == message);

  @override
  int get hashCode => message.hashCode;
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not reach local storage.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'This habit no longer exists.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Something went wrong.']);
}
