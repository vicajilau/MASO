/// Custom exception to handle invalid file errors.
class FileInvalidException implements Exception {
  /// The message describing the error.
  final String message;

  /// Constructs a new [FileInvalidException].
  ///
  /// [message] provides the main description of the error.
  /// [details] can be used to pass additional context or the cause of the error.
  FileInvalidException(this.message);

  @override
  String toString() => 'FileInvalidException: $message';
}
