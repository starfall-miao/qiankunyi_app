import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/theme/theme_provider.dart';
import 'core/utils/logger.dart';
import 'features/paipan/providers/paipan_provider.dart';
import 'features/cases/providers/case_provider.dart';
import 'features/settings/settings_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final log = Logger.instance;
  log.info('应用启动');

  // 全局异常捕获 → 写入日志
  FlutterError.onError = (FlutterErrorDetails details) {
    log.error('渲染异常', '${details.exception}\n${details.stack ?? ""}');
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  // Release 模式下显示错误信息而非灰屏
  ErrorWidget.builder = (FlutterErrorDetails details) {
    log.error('ErrorWidget', '${details.exception}');
    return Material(
      color: const Color(0xFFF5F0EB),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Color(0xFFB71C1C)),
                  const SizedBox(height: 16),
                  const Text('⚠ 渲染异常',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A3728))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE0D5C8)),
                    ),
                    child: SelectableText('${details.exception}',
                        style: const TextStyle(fontSize: 13, color: Color(0xFFB71C1C))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  };

  // 未捕获的异步异常
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    log.error('未捕获异常', '$error\n$stack');
    return false;
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PaipanProvider()),
        ChangeNotifierProvider(create: (_) => CaseProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..init()),
      ],
      child: const QianKunYiApp(),
    ),
  );
}
