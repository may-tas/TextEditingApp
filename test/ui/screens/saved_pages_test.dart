import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Import your actual files - adjust paths as needed
import 'package:texterra/cubit/canvas_cubit.dart';
import 'package:texterra/cubit/canvas_state.dart';
import 'package:texterra/constants/color_constants.dart';
import 'package:texterra/ui/screens/saved_pages.dart';

// Generate mocks
@GenerateMocks([CanvasCubit])
import 'saved_pages_test.mocks.dart';

void main() {
  late MockCanvasCubit mockCanvasCubit;

  setUp(() {
    mockCanvasCubit = MockCanvasCubit();

    // Setup default state
    when(mockCanvasCubit.state).thenReturn(CanvasState.initial());
    when(mockCanvasCubit.stream)
        .thenAnswer((_) => Stream.value(CanvasState.initial()));
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: BlocProvider<CanvasCubit>.value(
        value: mockCanvasCubit,
        child: const SavedPagesScreen(),
      ),
    );
  }

  group('SavedPagesScreen Widget Tests', () {
    testWidgets('displays empty state when no pages saved',
        (WidgetTester tester) async {
      // Arrange
      when(mockCanvasCubit.getSavedPages()).thenAnswer((_) async => []);
      when(mockCanvasCubit.getPagePreview(any)).thenAnswer((_) async => null);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
      expect(find.text('No saved pages yet'), findsOneWidget);
      expect(find.text('Create and save your first page!'), findsOneWidget);
    });

    testWidgets('displays list of saved pages', (WidgetTester tester) async {
      // Arrange
      final mockPages = ['Page 1', 'Page 2', 'Page 3'];
      when(mockCanvasCubit.getSavedPages()).thenAnswer((_) async => mockPages);

      for (var pageName in mockPages) {
        when(mockCanvasCubit.getPagePreview(pageName)).thenAnswer((_) async => {
              'name': pageName,
              'textCount': 5,
              'backgroundColor': ColorConstants.dialogTextBlack,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
              'lastModified': DateTime.now(),
              'label': '',
            });
      }

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Page 1'), findsOneWidget);
      expect(find.text('Page 2'), findsOneWidget);
      expect(find.text('Page 3'), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(3));
    });

    testWidgets('displays correct text count for pages',
        (WidgetTester tester) async {
      // Arrange
      when(mockCanvasCubit.getSavedPages())
          .thenAnswer((_) async => ['Test Page']);
      when(mockCanvasCubit.getPagePreview('Test Page'))
          .thenAnswer((_) async => {
                'name': 'Test Page',
                'textCount': 3,
                'backgroundColor': ColorConstants.dialogTextBlack,
                'timestamp': DateTime.now().millisecondsSinceEpoch,
                'lastModified': DateTime.now(),
                'label': '',
              });

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('3 text items'), findsOneWidget);
    });

    testWidgets('displays singular text item correctly',
        (WidgetTester tester) async {
      // Arrange
      when(mockCanvasCubit.getSavedPages())
          .thenAnswer((_) async => ['Single Item']);
      when(mockCanvasCubit.getPagePreview('Single Item'))
          .thenAnswer((_) async => {
                'name': 'Single Item',
                'textCount': 1,
                'backgroundColor': ColorConstants.dialogTextBlack,
                'timestamp': DateTime.now().millisecondsSinceEpoch,
                'lastModified': DateTime.now(),
                'label': '',
              });

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('1 text item'), findsOneWidget);
    });

    testWidgets('has app bar with correct title', (WidgetTester tester) async {
      // Arrange
      when(mockCanvasCubit.getSavedPages()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Saved Pages'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('has back button in app bar', (WidgetTester tester) async {
      // Arrange
      when(mockCanvasCubit.getSavedPages()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('has refresh button in app bar', (WidgetTester tester) async {
      // Arrange
      when(mockCanvasCubit.getSavedPages()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('displays page label when available',
        (WidgetTester tester) async {
      // Arrange
      when(mockCanvasCubit.getSavedPages())
          .thenAnswer((_) async => ['Labeled Page']);
      when(mockCanvasCubit.getPagePreview('Labeled Page'))
          .thenAnswer((_) async => {
                'name': 'Labeled Page',
                'textCount': 2,
                'backgroundColor': ColorConstants.dialogTextBlack,
                'timestamp': DateTime.now().millisecondsSinceEpoch,
                'lastModified': DateTime.now(),
                'label': 'AB',
              });

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('AB'), findsOneWidget);
    });

    testWidgets('displays description icon when no label',
        (WidgetTester tester) async {
      // Arrange
      when(mockCanvasCubit.getSavedPages())
          .thenAnswer((_) async => ['No Label']);
      when(mockCanvasCubit.getPagePreview('No Label')).thenAnswer((_) async => {
            'name': 'No Label',
            'textCount': 2,
            'backgroundColor': ColorConstants.dialogTextBlack,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'lastModified': DateTime.now(),
            'label': '',
          });

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.description), findsOneWidget);
    });

    testWidgets('shows open and delete buttons for each page',
        (WidgetTester tester) async {
      // Arrange
      when(mockCanvasCubit.getSavedPages())
          .thenAnswer((_) async => ['Test Page']);
      when(mockCanvasCubit.getPagePreview('Test Page'))
          .thenAnswer((_) async => {
                'name': 'Test Page',
                'textCount': 2,
                'backgroundColor': ColorConstants.dialogTextBlack,
                'timestamp': DateTime.now().millisecondsSinceEpoch,
                'lastModified': DateTime.now(),
                'label': '',
              });

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.open_in_new), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('tapping page card calls loadPage',
        (WidgetTester tester) async {
      // Arrange
      when(mockCanvasCubit.getSavedPages())
          .thenAnswer((_) async => ['Clickable Page']);
      when(mockCanvasCubit.getPagePreview('Clickable Page'))
          .thenAnswer((_) async => {
                'name': 'Clickable Page',
                'textCount': 2,
                'backgroundColor': ColorConstants.dialogTextBlack,
                'timestamp': DateTime.now().millisecondsSinceEpoch,
                'lastModified': DateTime.now(),
                'label': '',
              });
      when(mockCanvasCubit.loadPage('Clickable Page')).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Assert
      verify(mockCanvasCubit.loadPage('Clickable Page')).called(1);
    });

    testWidgets('tapping delete button shows confirmation dialog',
        (WidgetTester tester) async {
      // Arrange
      when(mockCanvasCubit.getSavedPages())
          .thenAnswer((_) async => ['Delete Me']);
      when(mockCanvasCubit.getPagePreview('Delete Me'))
          .thenAnswer((_) async => {
                'name': 'Delete Me',
                'textCount': 2,
                'backgroundColor': ColorConstants.dialogTextBlack,
                'timestamp': DateTime.now().millisecondsSinceEpoch,
                'lastModified': DateTime.now(),
                'label': '',
              });

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Delete Page'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsWidgets);
    });

    testWidgets('confirming delete calls deletePage',
        (WidgetTester tester) async {
      // Arrange
      when(mockCanvasCubit.getSavedPages())
          .thenAnswer((_) async => ['Delete Me']);
      when(mockCanvasCubit.getPagePreview('Delete Me'))
          .thenAnswer((_) async => {
                'name': 'Delete Me',
                'textCount': 2,
                'backgroundColor': ColorConstants.dialogTextBlack,
                'timestamp': DateTime.now().millisecondsSinceEpoch,
                'lastModified': DateTime.now(),
                'label': '',
              });
      when(mockCanvasCubit.deletePage('Delete Me')).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockCanvasCubit.deletePage('Delete Me')).called(1);
    });

    testWidgets('canceling delete closes dialog without deleting',
        (WidgetTester tester) async {
      // Arrange
      when(mockCanvasCubit.getSavedPages())
          .thenAnswer((_) async => ['Keep Me']);
      when(mockCanvasCubit.getPagePreview('Keep Me')).thenAnswer((_) async => {
            'name': 'Keep Me',
            'textCount': 2,
            'backgroundColor': ColorConstants.dialogTextBlack,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'lastModified': DateTime.now(),
            'label': '',
          });

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      verifyNever(mockCanvasCubit.deletePage('Keep Me'));
      expect(find.text('Delete Page'), findsNothing);
    });

    testWidgets('refresh button reloads pages', (WidgetTester tester) async {
      // Arrange
      when(mockCanvasCubit.getSavedPages()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Assert
      verify(mockCanvasCubit.getSavedPages()).called(greaterThan(1));
    });
  });

  group('SavedPagesScreen Time Formatting Tests', () {
    testWidgets('displays "Just now" for recent pages',
        (WidgetTester tester) async {
      // Arrange
      when(mockCanvasCubit.getSavedPages()).thenAnswer((_) async => ['Recent']);
      when(mockCanvasCubit.getPagePreview('Recent')).thenAnswer((_) async => {
            'name': 'Recent',
            'textCount': 1,
            'backgroundColor': ColorConstants.dialogTextBlack,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'lastModified': DateTime.now(),
            'label': '',
          });

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Just now'), findsOneWidget);
    });

    testWidgets('displays hours ago for pages modified hours ago',
        (WidgetTester tester) async {
      // Arrange
      final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));
      when(mockCanvasCubit.getSavedPages()).thenAnswer((_) async => ['Old']);
      when(mockCanvasCubit.getPagePreview('Old')).thenAnswer((_) async => {
            'name': 'Old',
            'textCount': 1,
            'backgroundColor': ColorConstants.dialogTextBlack,
            'timestamp': twoHoursAgo.millisecondsSinceEpoch,
            'lastModified': twoHoursAgo,
            'label': '',
          });

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('2 hours ago'), findsOneWidget);
    });

    testWidgets('displays days ago for pages modified days ago',
        (WidgetTester tester) async {
      // Arrange
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      when(mockCanvasCubit.getSavedPages()).thenAnswer((_) async => ['Older']);
      when(mockCanvasCubit.getPagePreview('Older')).thenAnswer((_) async => {
            'name': 'Older',
            'textCount': 1,
            'backgroundColor': ColorConstants.dialogTextBlack,
            'timestamp': threeDaysAgo.millisecondsSinceEpoch,
            'lastModified': threeDaysAgo,
            'label': '',
          });

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('3 days ago'), findsOneWidget);
    });
  });

  group('SavedPagesScreen Error Handling Tests', () {
    testWidgets('handles null preview gracefully', (WidgetTester tester) async {
      // Arrange
      when(mockCanvasCubit.getSavedPages())
          .thenAnswer((_) async => ['Bad Page']);
      when(mockCanvasCubit.getPagePreview('Bad Page'))
          .thenAnswer((_) async => null);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - Should still display the page with default values
      expect(find.text('Bad Page'), findsOneWidget);
      expect(find.text('0 text items'), findsOneWidget);
    });
  });
}
