/// Stable identifiers for the failures the UI has wording for.
///
/// The domain must not hold user-facing text — it has no locale. So a failure
/// carries a code, and the presentation layer turns that into a sentence in
/// the right language. [Failure.message] stays as a developer-facing fallback
/// for anything without a code.
class FailureCode {
  const FailureCode._();

  static const String nameRequired = 'name_required';
  static const String weekdayRequired = 'weekday_required';
  static const String weeklyTargetRange = 'weekly_target_range';
  static const String futureDay = 'future_day';
  static const String cache = 'cache';
  static const String notFound = 'not_found';
  static const String unexpected = 'unexpected';
  static const String reminderPermissionUnavailable =
      'reminder_permission_unavailable';
  static const String reminderPermissionDenied = 'reminder_permission_denied';
}

abstract class Failure {
  final String message;

  /// One of [FailureCode], when the UI has localized wording for it.
  final String? code;

  const Failure(this.message, {this.code});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Failure && other.message == message && other.code == code);

  @override
  int get hashCode => Object.hash(message, code);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not reach local storage.'])
      : super(code: FailureCode.cache);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'This habit no longer exists.'])
      : super(code: FailureCode.notFound);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'Something went wrong.',
    String? code,
  ]) : super(code: code ?? FailureCode.unexpected);
}
