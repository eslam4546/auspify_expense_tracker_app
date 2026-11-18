import 'package:equatable/equatable.dart';

/// Base Failure class for domain and presentation error handling.
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Represents failures originating from local storage/cache operations (Hive).
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local cache operation failed']);
}

/// Represents input validation failures (e.g., negative amounts or missing data).
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid input data']);
}
