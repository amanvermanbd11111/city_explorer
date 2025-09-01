class Logger {
  static void debug(String message) {
    print('[DEBUG] ${DateTime.now()}: $message');
  }
  
  static void info(String message) {
    print('[INFO] ${DateTime.now()}: $message');
  }
  
  static void error(String message, [dynamic error]) {
    print('[ERROR] ${DateTime.now()}: $message');
    if (error != null) {
      print('[ERROR] Details: $error');
    }
  }
}