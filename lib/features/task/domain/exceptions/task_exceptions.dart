class DailyLimitException implements Exception {
  const DailyLimitException(this.code);
  final String code;

  @override
  String toString() => 'DailyLimitException($code)';
}
