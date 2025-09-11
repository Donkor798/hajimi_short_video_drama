import 'package:logger/logger.dart';

///一些比较长的日志，使用工具进行打印
const String _tag = "HaJiMi";

var _logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // 要显示的方法调用数量
    errorMethodCount: 8, // 如果提供了 stacktrace，则显示方法调用数量
    lineLength: 120, // 输出的宽度
    colors: true, // 彩色日志消息
    printEmojis: false, // 为每个日志消息打印一个表情符号
    // dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,// 每个日志打印是否应包含时间戳
  ),
);

// 将长日志分段打印，避免控制台/Logcat 截断
void _logInChunks(String msg, void Function(String) out, {required String level}) {
  const int chunkSize = 800; // 单段最大长度（兼容多终端限制）
  if (msg.isEmpty) {
    out("$_tag [$level] :: <empty>");
    return;
  }
  if (msg.length <= chunkSize) {
    out("$_tag [$level] :: $msg");
    return;
  }
  int index = 0;
  int part = 1;
  while (index < msg.length) {
    int end = index + chunkSize;
    if (end > msg.length) end = msg.length;
    final piece = msg.substring(index, end);
    out("$_tag [$level] part $part :: $piece");
    index = end;
    part++;
  }
}


LogV(String msg) {
  _logInChunks(msg, (m) => _logger.v(m), level: 'V');
}

LogD(String msg) {
  _logInChunks(msg, (m) => _logger.d(m), level: 'D');
}

LogI(String msg) {
  _logInChunks(msg, (m) => _logger.i(m), level: 'I');
}

LogW(String msg) {
  _logInChunks(msg, (m) => _logger.w(m), level: 'W');
}

LogE(String msg) {
  _logInChunks(msg, (m) => _logger.e(m), level: 'E');
}

LogWTF(String msg) {
  _logInChunks(msg, (m) => _logger.wtf(m), level: 'WTF');
}