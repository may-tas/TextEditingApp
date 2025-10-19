import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/canvas_cubit.dart';
import 'ui/screens/splash_screen.dart';
import 'utils/custom_snackbar.dart';
import 'utils/web_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize web-specific features
  if (kIsWeb) {
    await WebUtils.registerServiceWorker();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CanvasCubit(),
      child: MaterialApp(
        title: 'Texterra - Text Editor',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          // Enhanced theme for web
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.light,
          ),
          // Better text rendering on web
          fontFamily: kIsWeb ? 'Roboto' : null,
        ),
        debugShowCheckedModeBanner: false,
        navigatorKey: CustomSnackbar.navigatorKey,
        home: const SplashScreen(),
        // Handle deep links and shortcuts for PWA
        onGenerateRoute: (settings) {
          // Handle PWA shortcuts
          if (settings.name == '/?action=new') {
            return MaterialPageRoute(
              builder: (_) => const SplashScreen(),
              settings: const RouteSettings(arguments: {'action': 'new'}),
            );
          }
          if (settings.name == '/?action=saved') {
            return MaterialPageRoute(
              builder: (_) => const SplashScreen(),
              settings: const RouteSettings(arguments: {'action': 'saved'}),
            );
          }
          return null;
        },
      ),
    );
  }
}
