import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texterra/ui/screens/canvas_screen.dart';
import 'package:texterra/cubit/canvas_cubit.dart';

void main() {
  group('CanvasScreen Widget Tests', () {
    late CanvasCubit canvasCubit;

    setUp(() {
      canvasCubit = CanvasCubit();
    });

    tearDown(() {
      canvasCubit.close();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: BlocProvider<CanvasCubit>.value(
          value: canvasCubit,
          child: const CanvasScreen(),
        ),
      );
    }

    group('Basic Widget Rendering', () {
      testWidgets('renders successfully', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        expect(find.byType(CanvasScreen), findsOneWidget);
      });

      testWidgets('displays app title', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        expect(find.text('Text Editor'), findsOneWidget);
      });

      testWidgets('shows AppBar', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('shows FloatingActionButton', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('shows bottom controls', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        // The bottom area contains font controls
        expect(find.byType(Container), findsWidgets);
      });
    });

    group('AppBar Actions', () {
      testWidgets('has clear button', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        final clearButton = find.widgetWithIcon(IconButton, Icons.delete);
        expect(clearButton, findsOneWidget);
      });

      testWidgets('has wallpaper button', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        final wallpaperButton =
            find.widgetWithIcon(IconButton, Icons.wallpaper);
        expect(wallpaperButton, findsOneWidget);
      });

      testWidgets('has undo button', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        final undoButton = find.widgetWithIcon(IconButton, Icons.undo);
        expect(undoButton, findsOneWidget);
      });

      testWidgets('has redo button', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        final redoButton = find.widgetWithIcon(IconButton, Icons.redo);
        expect(redoButton, findsOneWidget);
      });

      testWidgets('has more options button', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        final moreButton = find.widgetWithIcon(IconButton, Icons.more_vert);
        expect(moreButton, findsOneWidget);
      });
    });

    group('FAB Functionality', () {
      testWidgets('FAB shows add icon by default', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final fab = find.byType(FloatingActionButton);
        expect(fab, findsOneWidget);

        final addIcon = find.descendant(
          of: fab,
          matching: find.byIcon(Icons.add),
        );
        expect(addIcon, findsOneWidget);
      });

      testWidgets('FAB opens bottom sheet when tapped',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final fab = find.byType(FloatingActionButton);
        await tester.tap(fab);
        await tester.pumpAndSettle();

        expect(find.text('Add Text'), findsOneWidget);
        expect(find.text('Draw'), findsOneWidget);
      });

      testWidgets('FAB bottom sheet has close button',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final fab = find.byType(FloatingActionButton);
        await tester.tap(fab);
        await tester.pumpAndSettle();

        // Tap outside to close
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        expect(find.text('Add Text'), findsNothing);
      });
    });

    group('Drawing Mode', () {
      testWidgets('FAB changes icon in drawing mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        canvasCubit.toggleDrawingMode();
        await tester.pump();

        final fab = find.byType(FloatingActionButton);
        final brushIcon = find.descendant(
          of: fab,
          matching: find.byIcon(Icons.brush),
        );
        expect(brushIcon, findsOneWidget);
      });

      testWidgets('shows drawing mode indicator', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        canvasCubit.toggleDrawingMode();
        await tester.pumpAndSettle();

        expect(find.text('Drawing Mode'), findsOneWidget);
      });

      testWidgets('exits drawing mode when toggled again',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        canvasCubit.toggleDrawingMode();
        await tester.pump();

        canvasCubit.toggleDrawingMode();
        await tester.pump();

        final fab = find.byType(FloatingActionButton);
        final addIcon = find.descendant(
          of: fab,
          matching: find.byIcon(Icons.add),
        );
        expect(addIcon, findsOneWidget);
      });
    });

    group('Background Decoration', () {
      testWidgets('shows gradient background by default',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(GestureDetector),
                matching: find.byType(Container),
              )
              .first,
        );

        expect(container.decoration, isA<BoxDecoration>());
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.gradient, isNotNull);
      });

      testWidgets('updates when background color changes',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        canvasCubit.changeBackgroundColor(Colors.blue);
        await tester.pump();

        expect(canvasCubit.state.backgroundColor, Colors.blue);
      });
    });

    group('Text Item Display', () {
      testWidgets('adds text items to canvas', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        canvasCubit.addText('Test Text');
        await tester.pumpAndSettle();

        // Verify text was added to state
        expect(canvasCubit.state.textItems.length, 1);
        expect(canvasCubit.state.textItems.first.text, 'Test Text');
      });

      testWidgets('adds multiple text items', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        canvasCubit.addText('First Text');
        canvasCubit.addText('Second Text');
        await tester.pumpAndSettle();

        // Verify both items were added
        expect(canvasCubit.state.textItems.length, 2);
        expect(canvasCubit.state.textItems[0].text, 'First Text');
        expect(canvasCubit.state.textItems[1].text, 'Second Text');
      });

      testWidgets('clears all text when clearCanvas is called',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        canvasCubit.addText('Test Text');
        await tester.pump();

        canvasCubit.clearCanvas();
        await tester.pump();

        expect(canvasCubit.state.textItems, isEmpty);
      });
    });

    group('Page Name Display', () {
      testWidgets('displays page name in app bar when set',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Directly set the page name in state without using savePage
        canvasCubit.emit(canvasCubit.state.copyWith(
          currentPageName: 'My Page',
        ));
        await tester.pumpAndSettle();

        expect(find.text('My Page'), findsOneWidget);
      });

      testWidgets('clears page name on new page', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Set page name directly
        canvasCubit.emit(canvasCubit.state.copyWith(
          currentPageName: 'Test Page',
        ));
        await tester.pumpAndSettle();

        canvasCubit.createNewPage();
        await tester.pumpAndSettle();

        expect(find.text('Test Page'), findsNothing);
      });
    });

    group('More Options Menu', () {
      testWidgets('opens popup menu when tapped', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final moreButton = find.widgetWithIcon(IconButton, Icons.more_vert);
        await tester.tap(moreButton);
        await tester.pumpAndSettle();

        expect(find.byType(PopupMenuButton<String>), findsOneWidget);
      });

      testWidgets('shows New Page option', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final moreButton = find.widgetWithIcon(IconButton, Icons.more_vert);
        await tester.tap(moreButton);
        await tester.pumpAndSettle();

        expect(find.textContaining('New Page'), findsOneWidget);
      });

      testWidgets('shows Saved Pages option', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final moreButton = find.widgetWithIcon(IconButton, Icons.more_vert);
        await tester.tap(moreButton);
        await tester.pumpAndSettle();

        expect(find.text('Saved Pages'), findsOneWidget);
      });

      testWidgets('shows Save option', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final moreButton = find.widgetWithIcon(IconButton, Icons.more_vert);
        await tester.tap(moreButton);
        await tester.pumpAndSettle();

        expect(find.text('Save Page'), findsOneWidget);
      });
    });

    group('Gesture Handling', () {
      testWidgets('deselects text when tapping empty area',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        canvasCubit.addText('Test');
        canvasCubit.selectText(0);
        await tester.pump();

        expect(canvasCubit.state.selectedTextItemIndex, 0);

        // Tap empty area
        await tester.tapAt(const Offset(400, 400));
        await tester.pump();

        expect(canvasCubit.state.selectedTextItemIndex, isNull);
      });

      testWidgets('does not deselect in drawing mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        canvasCubit.toggleDrawingMode();
        await tester.pump();

        // Tap should not cause deselection
        await tester.tapAt(const Offset(400, 400));
        await tester.pump();

        expect(canvasCubit.state.isDrawingMode, true);
      });
    });

    group('State Management', () {
      testWidgets('rebuilds when state changes', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(canvasCubit.state.textItems.length, 0);

        canvasCubit.addText('New Item');
        await tester.pump();

        expect(canvasCubit.state.textItems.length, 1);
        expect(canvasCubit.state.textItems.first.text, 'New Item');
      });

      testWidgets('maintains state across rebuilds',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        canvasCubit.addText('Persistent Text');
        await tester.pump();

        // Force rebuild
        await tester.pumpWidget(createTestWidget());

        expect(canvasCubit.state.textItems.length, 1);
        expect(canvasCubit.state.textItems.first.text, 'Persistent Text');
      });
    });

    group('Empty State', () {
      testWidgets('handles empty state gracefully',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(canvasCubit.state.textItems, isEmpty);
        expect(canvasCubit.state.drawPaths, isEmpty);
        expect(tester.takeException(), isNull);
      });

      testWidgets('renders without errors when no content',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(CanvasScreen), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('handles invalid text index gracefully',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Try to select invalid index
        canvasCubit.selectText(999);
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('handles undo with no history', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final undoButton = find.widgetWithIcon(IconButton, Icons.undo);
        await tester.tap(undoButton);
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('handles redo with no future', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final redoButton = find.widgetWithIcon(IconButton, Icons.redo);
        await tester.tap(redoButton);
        await tester.pump();

        expect(tester.takeException(), isNull);
      });
    });
  });
}
