class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message) : super(statusCode: 401);
}

class ValidationException extends ApiException {
  final List<ValidationError>? errors;

  ValidationException(super.message, {this.errors}) : super(statusCode: 422);
}

class ValidationError {
  final List<dynamic> location;
  final String message;
  final String type;

  ValidationError({
    required this.location,
    required this.message,
    required this.type,
  });

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      location: json['loc'] ?? [],
      message: json['msg'] ?? '',
      type: json['type'] ?? '',
    );
  }

  @override
  String toString() => '$message (${location.join('.')})';
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}

class UserEmailConflictException extends ApiException {
  UserEmailConflictException()
    : super("Пользователь с таким email уже существует", statusCode: 409);
}
