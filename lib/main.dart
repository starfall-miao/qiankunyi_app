import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/theme/theme_provider.dart';
import 'features/paipan/providers/paipan_provider.dart';
import 'features/cases/providers/case_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 全局错误捕获——显示错误详情而非空白灰屏
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  // Release 模式下，错误 Widget 显示红色背景+异常信息（默认是灰屏）
  ErrorWidget.builder = (FlutterErrorDetails details) {
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
                  Text(
                    '⚠ 渲染异常',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A3728),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE0D5C8)),
                    ),
                    child: SelectableText(
                      '${details.exception}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFFB71C1C)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PaipanProvider()),
        ChangeNotifierProvider(create: (_) => CaseProvider()),
      ],
      child: const QianKunYiApp(),
    ),
  );
}
