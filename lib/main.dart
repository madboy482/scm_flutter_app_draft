import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'theme.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        // Add other providers here for state management
      ],
      child: MaterialApp.router(
        title: 'SCM Flutter App',
        theme: AppTheme.themeData,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}