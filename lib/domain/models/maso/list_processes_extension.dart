import 'i_process.dart';

extension ListProcessesExtension on List<IProcess> {
  /// Checks if a process with the specified [name] exists in the list,
  /// optionally ignoring the process at the given [position].
  ///
  /// - [name]: The name of the process to search for (case-insensitive).
  /// - [position]: (Optional) The index of the process to exclude from the search.
  ///
  /// Returns `true` if a matching process exists, `false` otherwise.
  bool containProcessWithName(String name, {int? position}) {
    /// Create a filtered list excluding the element at the given [position], if valid.
    final filteredList = position != null && position >= 0 && position < length
        ? asMap()
            .entries
            .where((entry) =>
                entry.key != position) // Exclude the specified index.
            .map((entry) => entry.value) // Extract the process values.
            .toList() // Convert back to a list.
        : this; // Use the original list if [position] is invalid or not provided.

    /// Check if any process in the filtered list matches the [name].
    return filteredList
        .any((x) => x.id.toLowerCase().trim() == name.toLowerCase().trim());
  }
}
