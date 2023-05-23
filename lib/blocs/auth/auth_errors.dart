class AuthErrors {
  final List<String> emailErrors = [];
  final List<String> passwordErrors = [];
  final List<String> passwordDuplicateErrors = [];

  bool get isEmpty =>
      emailErrors.isEmpty &&
      passwordErrors.isEmpty &&
      passwordDuplicateErrors.isEmpty;

  bool get isNotEmpty => !isEmpty;
}
