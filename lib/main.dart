import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fitness_tracker/routes/router.dart';
import 'package:fitness_tracker/themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://nhagdzotvchrxzkoojeu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5oYWdkem90dmNocnh6a29vamV1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg3Njc5MjUsImV4cCI6MjA1NDM0MzkyNX0.oEgc2qQy_uAeHHo_jrzcFuJE2cm9uonsCbBnt8-I4h4',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
