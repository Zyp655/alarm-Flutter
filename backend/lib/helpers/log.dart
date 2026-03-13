class Log {
  static void info(String tag, String message) {
    _write('INFO', tag, message);
  }

  static void warning(String tag, String message) {
    _write('WARN', tag, message);
  }

  static void error(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    _write('ERROR', tag, message);
    if (error != null) _write('ERROR', tag, '$error');
    if (stackTrace != null) _write('ERROR', tag, '$stackTrace');
  }

  static void _write(String level, String tag, String message) {
    final now = DateTime.now().toIso8601String();
    // ignore: avoid_print
    print('$now [$level] [$tag] $message');
  }
}
