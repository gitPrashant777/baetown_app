import 'package:flutter/material.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/route/router.dart' as router;
import 'package:shop/theme/app_theme.dart';
import 'package:shop/models/user_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load existing session if available
  await UserSession.loadSession();
  
  print('🚨🚨🚨 MAIN: App started - checking existing session...');
  if (UserSession.authToken != null) {
    print('🚨🚨🚨 MAIN: Found existing token: ${UserSession.authToken?.substring(0, 20)}...');
  } else {
    print('🚨🚨🚨 MAIN: No existing token found - user needs to login');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BAETOWN Jewelry - Premium Jewelry Collection',
      theme: AppTheme.lightTheme(context),
      themeMode: ThemeMode.light,
      onGenerateRoute: router.generateRoute,
      initialRoute: splashScreenRoute,
    );
  }
}
