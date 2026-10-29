import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/portal_screen.dart';
import 'services/account_service.dart';
import 'theme/app_theme.dart';

class TraceLensApp extends StatelessWidget {
  const TraceLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TraceLens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: FutureBuilder<bool>(
        future: AccountService.isSignedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.data == true
              ? const HomeScreen()
              : const PortalScreen();
        },
      ),
    );
  }
}
