class DeleteAccountException implements Exception {
  const DeleteAccountException(this.message);

  final String message;

  @override
  String toString() => 'DeleteAccountException: $message';
}
