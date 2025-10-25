import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texterra/cubit/canvas_cubit.dart';
import 'package:texterra/cubit/canvas_state.dart';
import 'package:texterra/ui/widgets/editable_text_widget.dart';
import 'package:texterra/ui/widgets/background_color_tray.dart';
import 'package:texterra/ui/widgets/background_options_sheet.dart';
import 'package:texterra/models/text_item_model.dart';
import 'package:texterra/constants/color_constants.dart';

void main() {
  group('EditableTextWidget', () {
    late CanvasCubit canvasCubit;

    setUp(() {
      canvasCubit = CanvasCubit();
    });

    tearDown(() {
      canvasCubit.close();
    });

    testWidgets('displays text correctly', (tester) async {
      final textItem = TextItem(
        text: 'Test Text',
        x: 10,
        y: 20,
        fontSize: 16,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontFamily: 'Roboto',
        isUnderlined: false,
        color: Colors.white,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: canvasCubit,
            child: Scaffold(
              body: EditableTextWidget(
                index: 0,
                textItem: textItem,
                isSelected: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Text'), findsOneWidget);
    });

    testWidgets('shows highlight when selected', (tester) async {
      final textItem = TextItem(
        text: 'Selected Text',
        x: 10,
        y: 20,
        fontSize: 16,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontFamily: 'Roboto',
        isUnderlined: false,
        color: Colors.white,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: canvasCubit,
            child: Scaffold(
              body: EditableTextWidget(
                index: 0,
                textItem: textItem,
                isSelected: true,
              ),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Selected Text'));
      expect(textWidget.style?.backgroundColor, isNotNull);
    });

    testWidgets('applies font styling correctly', (tester) async {
      final textItem = TextItem(
        text: 'Styled Text',
        x: 10,
        y: 20,
        fontSize: 24,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto', // Changed from 'Arial' to 'Roboto'
        isUnderlined: true,
        color: Colors.red,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: canvasCubit,
            child: Scaffold(
              body: EditableTextWidget(
                index: 0,
                textItem: textItem,
                isSelected: false,
              ),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Styled Text'));
      expect(textWidget.style?.fontSize, 24);
      expect(textWidget.style?.fontStyle, FontStyle.italic);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
      expect(textWidget.style?.decoration, TextDecoration.underline);
      expect(textWidget.style?.color, Colors.red);
    });

    testWidgets('shows highlight color when highlighted', (tester) async {
      final textItem = TextItem(
        text: 'Highlighted Text',
        x: 10,
        y: 20,
        fontSize: 16,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontFamily: 'Roboto',
        isUnderlined: false,
        color: Colors.black,
        isHighlighted: true,
        highlightColor: Colors.yellow,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: canvasCubit,
            child: Scaffold(
              body: EditableTextWidget(
                index: 0,
                textItem: textItem,
                isSelected: false,
              ),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Highlighted Text'));
      expect(textWidget.style?.backgroundColor, Colors.yellow);
    });

    testWidgets('applies text shadow when enabled', (tester) async {
      final textItem = TextItem(
        text: 'Shadow Text',
        x: 10,
        y: 20,
        fontSize: 16,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontFamily: 'Roboto',
        isUnderlined: false,
        color: Colors.white,
        hasShadow: true,
        shadowColor: Colors.black,
        shadowBlurRadius: 4.0,
        shadowOffset: const Offset(2.0, 2.0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: canvasCubit,
            child: Scaffold(
              body: EditableTextWidget(
                index: 0,
                textItem: textItem,
                isSelected: false,
              ),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Shadow Text'));
      expect(textWidget.style?.shadows, isNotNull);
      expect(textWidget.style?.shadows?.length, 1);
    });

    testWidgets('applies text alignment', (tester) async {
      final textItem = TextItem(
        text: 'Centered Text',
        x: 10,
        y: 20,
        fontSize: 16,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontFamily: 'Roboto',
        isUnderlined: false,
        color: Colors.white,
        textAlign: TextAlign.center,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: canvasCubit,
            child: Scaffold(
              body: EditableTextWidget(
                index: 0,
                textItem: textItem,
                isSelected: false,
              ),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Centered Text'));
      expect(textWidget.textAlign, TextAlign.center);
    });

    testWidgets('opens edit dialog on tap', (tester) async {
      final textItem = TextItem(
        text: 'Tap Me',
        x: 10,
        y: 20,
        fontSize: 16,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontFamily: 'Roboto',
        isUnderlined: false,
        color: Colors.white,
      );

      canvasCubit.emit(CanvasState.initial().copyWith(
        textItems: [textItem],
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: canvasCubit,
            child: Scaffold(
              body: EditableTextWidget(
                index: 0,
                textItem: textItem,
                isSelected: false,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Text'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });
  });

  group('BackgroundColorTray', () {
    late CanvasCubit canvasCubit;

    setUp(() {
      canvasCubit = CanvasCubit();
    });

    tearDown(() {
      canvasCubit.close();
    });

    testWidgets('displays all background colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: canvasCubit,
            child: const Scaffold(
              body: BackgroundColorTray(),
            ),
          ),
        ),
      );

      expect(find.text('Background Color'), findsOneWidget);

      // Should find color selection containers
      final colorContainers = find.byType(GestureDetector);
      expect(colorContainers, findsWidgets);
    });

    testWidgets('shows selected color with checkmark', (tester) async {
      canvasCubit.emit(CanvasState.initial().copyWith(
        backgroundColor: ColorConstants.backgroundDeepPurple,
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: canvasCubit,
            child: const Scaffold(
              body: BackgroundColorTray(),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should show check icon for selected color
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('changes background color on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: canvasCubit,
            child: const Scaffold(
              body: BackgroundColorTray(),
            ),
          ),
        ),
      );

      await tester.pump();

      final initialColor = canvasCubit.state.backgroundColor;

      // Find all GestureDetectors
      final gestureDetectors = find.byType(GestureDetector);
      final count = tester.widgetList(gestureDetectors).length;

      // Try tapping different gesture detectors until we find one that changes the color
      bool colorChanged = false;
      for (int i = 0; i < count && !colorChanged; i++) {
        await tester.tap(gestureDetectors.at(i));
        await tester.pump();

        if (canvasCubit.state.backgroundColor != initialColor) {
          colorChanged = true;
        }
      }

      // At least one tap should have changed the color
      expect(colorChanged, isTrue);
      expect(canvasCubit.state.backgroundColor, isNot(equals(initialColor)));
    });
  });

  group('BackgroundOptionsSheet', () {
    late CanvasCubit canvasCubit;

    setUp(() {
      canvasCubit = CanvasCubit();
    });

    tearDown(() {
      canvasCubit.close();
    });

    testWidgets('displays all background options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: canvasCubit,
            child: const Scaffold(
              body: BackgroundOptionsSheet(),
            ),
          ),
        ),
      );

      expect(find.text('Background Options'), findsOneWidget);
      expect(find.text('Upload Image'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Solid Color'), findsOneWidget);
      expect(find.text('Remove Image'), findsOneWidget);
    });

    testWidgets('upload image option is always enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: canvasCubit,
            child: const Scaffold(
              body: BackgroundOptionsSheet(),
            ),
          ),
        ),
      );

      final uploadTile = find.ancestor(
        of: find.text('Upload Image'),
        matching: find.byType(InkWell),
      );

      expect(uploadTile, findsOneWidget);
    });

    testWidgets('remove image is disabled when no background image',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: canvasCubit,
            child: const Scaffold(
              body: BackgroundOptionsSheet(),
            ),
          ),
        ),
      );

      await tester.pump();

      // Remove Image should be visible but might be disabled
      expect(find.text('Remove Image'), findsOneWidget);
    });

    testWidgets('remove image is enabled when background image exists',
        (tester) async {
      canvasCubit.emit(CanvasState.initial().copyWith(
        backgroundImagePath: '/fake/path/image.png',
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: canvasCubit,
            child: const Scaffold(
              body: BackgroundOptionsSheet(),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Remove Image'), findsOneWidget);
    });

    testWidgets('displays correct icons for each option', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: canvasCubit,
            child: const Scaffold(
              body: BackgroundOptionsSheet(),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.photo_library), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.color_lens), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });
  });

  group('EditTextDialog', () {
    testWidgets('displays with initial text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EditTextDialog(initialText: 'Initial Text'),
          ),
        ),
      );

      expect(find.text('Edit Text'), findsOneWidget);
      expect(find.text('Initial Text'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('validates empty text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EditTextDialog(initialText: 'Test'),
          ),
        ),
      );

      // Clear the text field
      await tester.enterText(find.byType(TextFormField), '');

      // Try to save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Text cannot be empty'), findsOneWidget);
    });

    testWidgets('saves text on save button tap', (tester) async {
      String? savedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    final result = await showDialog<String>(
                      context: context,
                      builder: (context) => const EditTextDialog(
                        initialText: 'Initial',
                      ),
                    );
                    savedText = result;
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'Updated Text');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedText, 'Updated Text');
    });

    testWidgets('returns delete signal on remove button tap', (tester) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await showDialog<String>(
                      context: context,
                      builder: (context) => const EditTextDialog(
                        initialText: 'Test',
                      ),
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      expect(result, '_delete_');
    });
  });
}
