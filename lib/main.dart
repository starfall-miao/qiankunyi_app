import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/theme/theme_provider.dart';
import 'features/paipan/providers/paipan_provider.dart';
import 'features/cases/providers/case_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
