abstract class AppLogger {
  void debug(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> attributes,
  });

  void info(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> attributes,
  });

  void warn(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> attributes,
  });

  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> attributes,
  });
}
