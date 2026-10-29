class Validators {
  static bool isValidUrl(String input) {
    if (input.trim().isEmpty) return false;
    // Basic structural check
    final uri = Uri.tryParse(input.trim().startsWith('http') ? input.trim() : 'http://${input.trim()}');
    return uri != null && uri.host.isNotEmpty && uri.host.contains('.');
  }

  static bool isValidMessage(String input) {
    return input.trim().length >= 3;
  }
}
