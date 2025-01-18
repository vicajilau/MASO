enum BurstType {
  io,
  cpu;

  /// Converts a string to a `BurstType` enum.
  ///
  /// This method parses the input string and returns the corresponding
  /// `BurstType` value. If the input does not match any defined mode,
  /// an `ArgumentError` is thrown.
  ///
  /// - [value]: A string representation of the mode.
  /// - Returns: The matching `BurstType` value.
  /// - Throws: `ArgumentError` if the input string is invalid.
  static BurstType fromJson(String value) {
    switch (value) {
      case 'io':
        return BurstType.io;
      case 'cpu':
        return BurstType.cpu;
    }
    throw ArgumentError("Invalid BurstType value: $value");
  }

  @override
  String toString() {
    switch (this) {
      case BurstType.io:
        return 'io';
      case BurstType.cpu:
        return 'cpu';
    }
  }
}
