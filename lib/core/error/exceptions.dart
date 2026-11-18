/// Base exception for data source layer errors.
abstract class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

/// Thrown when local Hive storage operations fail.
class CacheException extends AppException {
  const CacheException([super.message = 'Failed to access local cache']);
}

/// Thrown when validation fails in the data or business layer.
class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation rule violated']);
}
