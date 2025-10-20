import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texterra/main.dart';
import 'package:texterra/ui/screens/splash_screen.dart';
import 'package:texterra/cubit/canvas_cubit.dart';

void main() {
  testWidgets('App initializes and shows splash screen',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app builds successfully
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verify that SplashScreen is shown initially
    expect(find.byType(SplashScreen), findsOneWidget);

    // Wait for all timers and animations to complete
    await tester.pumpAndSettle();
  });

  testWidgets('App has correct title', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MyApp());

    // Get the MaterialApp widget
    final MaterialApp app = tester.widget(find.byType(MaterialApp));

    // Verify the title
    expect(app.title, 'Text Editor');

    // Wait for all timers and animations to complete
    await tester.pumpAndSettle();
  });

  testWidgets('App has BlocProvider for CanvasCubit',
      (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MyApp());

    // Verify that BlocProvider is present in the widget tree
    expect(find.byType(BlocProvider<CanvasCubit>), findsOneWidget);

    // Wait for all timers and animations to complete
    await tester.pumpAndSettle();
  });
}
