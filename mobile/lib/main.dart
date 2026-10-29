import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.loadSavedBaseUrl();
  
  // Set system UI overlay style to match the light application theme.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFF7F8FA),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const TraceLensApp());
}
