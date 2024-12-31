/// Custom exception to handle invalid file errors.
class FileInvalidException implements Exception {
  /// The message describing the error.
  final String message;

  /// Optional details providing additional context about the error.
  final dynamic details;

  /// Constructs a new [FileInvalidException].
  ///
  /// [message] provides the main description of the error.
  /// [details] can be used to pass additional context or the cause of the error.
  FileInvalidException(this.message, [this.details]);

  @override
  String toString() {
    if (details != null) {
      return 'FileInvalidException: $message\nDetails: $details';
    }
    return 'FileInvalidException: $message';
  }
}
