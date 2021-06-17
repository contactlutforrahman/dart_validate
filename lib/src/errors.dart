part of dart_validate;
/// Possible errors thrown by Validate

abstract class ErrorMessage extends Error {
  final String message;
  ErrorMessage(this.message);
}

class IllegalStateError extends ErrorMessage {
  IllegalStateError(final String message) : super(message);
}
