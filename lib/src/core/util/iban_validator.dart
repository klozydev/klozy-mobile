/// UAE IBAN: `AE` + 2 check digits + 19 digits (23 chars total).
bool isValidUaeIban(String input) {
  final normalized = input.replaceAll(' ', '').toUpperCase();
  return RegExp(r'^AE\d{21}$').hasMatch(normalized);
}

/// Strips spaces and uppercases for submission.
String normalizeIban(String input) => input.replaceAll(' ', '').toUpperCase();
