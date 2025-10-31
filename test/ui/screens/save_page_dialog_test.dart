import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:texterra/cubit/canvas_state.dart';
import 'package:texterra/ui/screens/save_page_dialog.dart';

import 'package:texterra/cubit/canvas_cubit.dart';

import 'saved_pages_test.mocks.dart';

void main() {
  late MockCanvasCubit mockCanvasCubit;

  setUp(() {
    mockCanvasCubit = MockCanvasCubit();
    when(mockCanvasCubit.stream).thenAnswer((_) => const Stream.empty());
    when(mockCanvasCubit.state).thenReturn(CanvasState.initial());
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: BlocProvider<CanvasCubit>.value(
        value: mockCanvasCubit,
        child: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => BlocProvider<CanvasCubit>.value(
                      value: mockCanvasCubit,
                      child: const SavePageDialog(),
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openDialog(WidgetTester tester) async {
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();
  }

  group('SavePageDialog', () {
    testWidgets('renders dialog with all basic UI elements',
        (WidgetTester tester) async {
      when(mockCanvasCubit.getSavedPages()).thenAnswer((_) async => <String>[]);

      await tester.pumpWidget(createTestWidget());
      await openDialog(tester);

      expect(find.text('Save Page'), findsOneWidget);
      expect(find.byIcon(Icons.save), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('shows validation error for empty page name',
        (WidgetTester tester) async {
      when(mockCanvasCubit.getSavedPages()).thenAnswer((_) async => <String>[]);

      await tester.pumpWidget(createTestWidget());
      await openDialog(tester);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a page name'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid characters',
        (WidgetTester tester) async {
      when(mockCanvasCubit.getSavedPages()).thenAnswer((_) async => <String>[]);

      await tester.pumpWidget(createTestWidget());
      await openDialog(tester);

      await tester.enterText(find.byType(TextFormField).first, 'Invalid<>');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(
          find.text('Page name contains invalid characters'), findsOneWidget);
    });

    testWidgets('cancel button closes the dialog', (WidgetTester tester) async {
      when(mockCanvasCubit.getSavedPages()).thenAnswer((_) async => <String>[]);

      await tester.pumpWidget(createTestWidget());
      await openDialog(tester);

      expect(find.byType(SavePageDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(SavePageDialog), findsNothing);
    });

    testWidgets('saves valid page name and closes dialog',
        (WidgetTester tester) async {
      when(mockCanvasCubit.getSavedPages()).thenAnswer((_) async => <String>[]);
      when(mockCanvasCubit.savePage(any,
              label: anyNamed('label'), color: anyNamed('color')))
          .thenAnswer((_) async => Future.value());

      await tester.pumpWidget(createTestWidget());
      await openDialog(tester);

      await tester.enterText(find.byType(TextFormField).first, 'My Page');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.byType(SavePageDialog), findsNothing);
    });

    testWidgets('shows overwrite confirmation for existing page',
        (WidgetTester tester) async {
      when(mockCanvasCubit.getSavedPages())
          .thenAnswer((_) async => ['Existing Page']);

      await tester.pumpWidget(createTestWidget());
      await openDialog(tester);

      await tester.enterText(find.byType(TextFormField).first, 'Existing Page');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Page Already Exists'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.text('Overwrite'), findsOneWidget);
    });

    testWidgets('canceling overwrite keeps dialog open',
        (WidgetTester tester) async {
      when(mockCanvasCubit.getSavedPages())
          .thenAnswer((_) async => ['Existing Page']);

      await tester.pumpWidget(createTestWidget());
      await openDialog(tester);

      await tester.enterText(find.byType(TextFormField).first, 'Existing Page');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel').last);
      await tester.pumpAndSettle();

      expect(find.byType(SavePageDialog), findsOneWidget);
    });

    testWidgets('confirming overwrite saves and closes dialog',
        (WidgetTester tester) async {
      when(mockCanvasCubit.getSavedPages())
          .thenAnswer((_) async => ['Existing Page']);
      when(mockCanvasCubit.savePage(any,
              label: anyNamed('label'), color: anyNamed('color')))
          .thenAnswer((_) async => Future.value());

      await tester.pumpWidget(createTestWidget());
      await openDialog(tester);

      await tester.enterText(find.byType(TextFormField).first, 'Existing Page');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Overwrite'));
      await tester.pumpAndSettle();

      expect(find.byType(SavePageDialog), findsNothing);
    });

    testWidgets('displays color selection options',
        (WidgetTester tester) async {
      when(mockCanvasCubit.getSavedPages()).thenAnswer((_) async => <String>[]);

      await tester.pumpWidget(createTestWidget());
      await openDialog(tester);

      expect(find.text('Choose a color: '), findsOneWidget);

      final containers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );

      expect(containers, findsNWidgets(6));
    });

    testWidgets('saves with both name and label', (WidgetTester tester) async {
      when(mockCanvasCubit.getSavedPages()).thenAnswer((_) async => <String>[]);
      when(mockCanvasCubit.savePage(any,
              label: anyNamed('label'), color: anyNamed('color')))
          .thenAnswer((_) async => Future.value());

      await tester.pumpWidget(createTestWidget());
      await openDialog(tester);

      await tester.enterText(find.byType(TextFormField).first, 'Page Name');
      await tester.enterText(find.byType(TextFormField).at(1), 'My Label');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.byType(SavePageDialog), findsNothing);
    });

    testWidgets('handles save error and keeps dialog open',
        (WidgetTester tester) async {
      when(mockCanvasCubit.getSavedPages()).thenAnswer((_) async => <String>[]);
      when(mockCanvasCubit.savePage(any,
              label: anyNamed('label'), color: anyNamed('color')))
          .thenThrow(Exception('Save failed'));

      await tester.pumpWidget(createTestWidget());
      await openDialog(tester);

      await tester.enterText(find.byType(TextFormField).first, 'Test Page');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.byType(SavePageDialog), findsOneWidget);
    });
  });
}
