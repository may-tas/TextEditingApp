import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/canvas_cubit.dart';
import 'ui/screens/splash_screen.dart';
import 'utils/custom_snackbar.dart';
import 'utils/web_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize web utilities if running on web
  if (WebUtils.isWeb) {
    await WebUtils().initialize();
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
        title: 'Text Editor',
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        navigatorKey: CustomSnackbar.navigatorKey,
        home: const SplashScreen(),
      ),
    );
  }
}
