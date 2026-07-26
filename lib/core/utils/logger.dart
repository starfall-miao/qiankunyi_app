/// 落·乾坤 — 日志服务
/// 全局单例，记录运行日志和异常

/// 日志级别
enum LogLevel { info, warn, error }

/// 单条日志
class LogEntry {
  final DateTime time;
  final LogLevel level;
  final String message;
  final String? detail;

  const LogEntry({
    required this.time,
    required this.level,
    required this.message,
    this.detail,
  });

  String get levelTag {
    switch (level) {
      case LogLevel.info: return 'INFO';
      case LogLevel.warn: return 'WARN';
      case LogLevel.error: return 'ERROR';
    }
  }

  String get formatted {
    final ts = '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
    return '[$ts][$levelTag] $message';
  }
}

/// 日志服务单例
class Logger {
  Logger._();
  static final Logger _instance = Logger._();
  static Logger get instance => _instance;

  bool _enabled = true;
  final List<LogEntry> _logs = [];

  bool get enabled => _enabled;
  List<LogEntry> get logs => List.unmodifiable(_logs);

  void setEnabled(bool v) {
    _enabled = v;
    if (v) _add(LogLevel.info, '日志记录已启用');
  }

  void info(String msg, [String? detail]) => _add(LogLevel.info, msg, detail);
  void warn(String msg, [String? detail]) => _add(LogLevel.warn, msg, detail);
  void error(String msg, [String? detail]) => _add(LogLevel.error, msg, detail);

  void _add(LogLevel level, String msg, [String? detail]) {
    if (!_enabled) return;
    _logs.insert(0, LogEntry(time: DateTime.now(), level: level, message: msg, detail: detail));
    if (_logs.length > 500) _logs.removeLast();
  }

  void clear() {
    _logs.clear();
    _add(LogLevel.info, '日志已清空');
  }
}
