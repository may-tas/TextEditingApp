import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:texterra/cubit/canvas_cubit.dart';
import 'package:texterra/cubit/canvas_state.dart';
import 'package:texterra/models/draw_model.dart';
import 'package:texterra/constants/color_constants.dart';

void main() {
  // Initialize Flutter binding before running tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CanvasCubit', () {
    late CanvasCubit canvasCubit;

    setUp(() {
      canvasCubit = CanvasCubit();
    });

    tearDown(() {
      canvasCubit.close();
    });

    test('initial state is correct', () {
      expect(canvasCubit.state.textItems, isEmpty);
      expect(canvasCubit.state.drawPaths, isEmpty);
      expect(
          canvasCubit.state.backgroundColor, ColorConstants.backgroundDarkGray);
      expect(canvasCubit.state.selectedTextItemIndex, isNull);
      expect(canvasCubit.state.isDrawingMode, false);
      expect(canvasCubit.state.isTrayShown, false);
    });

    group('Text Operations', () {
      blocTest<CanvasCubit, CanvasState>(
        'addText adds a new text item',
        build: () => canvasCubit,
        act: (cubit) => cubit.addText('Hello World'),
        expect: () => [
          predicate<CanvasState>((state) {
            return state.textItems.length == 1 &&
                state.textItems.first.text == 'Hello World' &&
                state.selectedTextItemIndex == 0;
          }),
        ],
      );

      blocTest<CanvasCubit, CanvasState>(
        'addText creates items with offset positions',
        build: () => canvasCubit,
        act: (cubit) {
          cubit.addText('First');
          cubit.addText('Second');
        },
        verify: (cubit) {
          expect(cubit.state.textItems.length, 2);
          expect(cubit.state.textItems[0].x, 50);
          expect(cubit.state.textItems[0].y, 50);
          expect(cubit.state.textItems[1].x, 70); // 50 + 20 offset
          expect(cubit.state.textItems[1].y, 70); // 50 + 20 offset
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'editText updates text content',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.addText('Original');
          return canvasCubit.state;
        },
        act: (cubit) => cubit.editText(0, 'Updated'),
        verify: (cubit) {
          expect(cubit.state.textItems.first.text, 'Updated');
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'deleteText removes text item',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.addText('Test');
          return canvasCubit.state;
        },
        act: (cubit) => cubit.deleteText(0),
        verify: (cubit) {
          expect(cubit.state.textItems, isEmpty);
          expect(cubit.state.selectedTextItemIndex, isNull);
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'selectText updates selected index',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.addText('Test');
          return canvasCubit.state;
        },
        act: (cubit) => cubit.selectText(0),
        verify: (cubit) {
          expect(cubit.state.selectedTextItemIndex, 0);
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'deselectText clears selection',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.addText('Test');
          canvasCubit.selectText(0);
          return canvasCubit.state;
        },
        act: (cubit) => cubit.deselectText(),
        verify: (cubit) {
          expect(cubit.state.selectedTextItemIndex, isNull);
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'moveText updates position',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.addText('Test');
          return canvasCubit.state;
        },
        act: (cubit) => cubit.moveText(0, 100, 200),
        verify: (cubit) {
          expect(cubit.state.textItems.first.x, 100);
          expect(cubit.state.textItems.first.y, 200);
        },
      );
    });

    group('Font Styling', () {
      blocTest<CanvasCubit, CanvasState>(
        'changeFontSize updates font size',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.addText('Test');
          return canvasCubit.state;
        },
        act: (cubit) => cubit.changeFontSize(0, 24.0),
        verify: (cubit) {
          expect(cubit.state.textItems.first.fontSize, 24.0);
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'changeFontFamily updates font family',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.addText('Test');
          return canvasCubit.state;
        },
        act: (cubit) => cubit.changeFontFamily(0, 'Arial'),
        verify: (cubit) {
          expect(cubit.state.textItems.first.fontFamily, 'Arial');
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'changeFontWeight updates font weight',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.addText('Test');
          return canvasCubit.state;
        },
        act: (cubit) => cubit.changeFontWeight(0, FontWeight.bold),
        verify: (cubit) {
          expect(cubit.state.textItems.first.fontWeight, FontWeight.bold);
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'changeFontStyle updates font style',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.addText('Test');
          return canvasCubit.state;
        },
        act: (cubit) => cubit.changeFontStyle(0, FontStyle.italic),
        verify: (cubit) {
          expect(cubit.state.textItems.first.fontStyle, FontStyle.italic);
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'changeTextUnderline toggles underline',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.addText('Test');
          return canvasCubit.state;
        },
        act: (cubit) => cubit.changeTextUnderline(0, true),
        verify: (cubit) {
          expect(cubit.state.textItems.first.isUnderlined, true);
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'changeTextColor updates color',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.addText('Test');
          return canvasCubit.state;
        },
        act: (cubit) => cubit.changeTextColor(0, Colors.red),
        verify: (cubit) {
          expect(cubit.state.textItems.first.color, Colors.red);
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'changeTextAlignment updates text alignment',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.addText('Test');
          return canvasCubit.state;
        },
        act: (cubit) => cubit.changeTextAlignment(0, TextAlign.center),
        verify: (cubit) {
          expect(cubit.state.textItems.first.textAlign, TextAlign.center);
        },
      );
    });

    group('Text Highlighting', () {
      blocTest<CanvasCubit, CanvasState>(
        'toggleTextHighlight enables highlighting',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.addText('Test');
          return canvasCubit.state;
        },
        act: (cubit) => cubit.toggleTextHighlight(0),
        verify: (cubit) {
          expect(cubit.state.textItems.first.isHighlighted, true);
          expect(cubit.state.textItems.first.highlightColor,
              ColorConstants.highlightYellow);
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'changeHighlightColor updates highlight color',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.addText('Test');
          return canvasCubit.state;
        },
        act: (cubit) => cubit.changeHighlightColor(0, Colors.lime),
        verify: (cubit) {
          expect(cubit.state.textItems.first.isHighlighted, true);
          expect(cubit.state.textItems.first.highlightColor, Colors.lime);
        },
      );
    });

    group('Text Shadow', () {
      blocTest<CanvasCubit, CanvasState>(
        'toggleTextShadow enables shadow',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.addText('Test');
          return canvasCubit.state;
        },
        act: (cubit) => cubit.toggleTextShadow(0),
        verify: (cubit) {
          expect(cubit.state.textItems.first.hasShadow, true);
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'changeShadowColor updates shadow color',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.addText('Test');
          return canvasCubit.state;
        },
        act: (cubit) => cubit.changeShadowColor(0, Colors.blue),
        verify: (cubit) {
          expect(cubit.state.textItems.first.hasShadow, true);
          expect(cubit.state.textItems.first.shadowColor, Colors.blue);
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'changeShadowBlur updates blur radius',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.addText('Test');
          return canvasCubit.state;
        },
        act: (cubit) => cubit.changeShadowBlur(0, 10.0),
        verify: (cubit) {
          expect(cubit.state.textItems.first.shadowBlurRadius, 10.0);
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'changeShadowOffset updates offset',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.addText('Test');
          return canvasCubit.state;
        },
        act: (cubit) => cubit.changeShadowOffset(0, const Offset(5, 5)),
        verify: (cubit) {
          expect(cubit.state.textItems.first.shadowOffset, const Offset(5, 5));
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'applyShadowPreset applies soft shadow',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.addText('Test');
          return canvasCubit.state;
        },
        act: (cubit) => cubit.applyShadowPreset(0, ShadowPreset.soft),
        verify: (cubit) {
          final item = cubit.state.textItems.first;
          expect(item.hasShadow, true);
          expect(item.shadowBlurRadius, 8.0);
        },
      );
    });

    group('Format Reset', () {
      blocTest<CanvasCubit, CanvasState>(
        'resetFormatting resets all formatting',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.addText('Test');
          canvasCubit.changeFontSize(0, 32);
          canvasCubit.changeFontWeight(0, FontWeight.bold);
          canvasCubit.changeTextColor(0, Colors.red);
          canvasCubit.toggleTextHighlight(0);
          canvasCubit.toggleTextShadow(0);
          return canvasCubit.state;
        },
        act: (cubit) => cubit.resetFormatting(0),
        verify: (cubit) {
          final item = cubit.state.textItems.first;
          expect(item.fontSize, 16);
          expect(item.fontWeight, FontWeight.normal);
          expect(item.fontStyle, FontStyle.normal);
          expect(item.fontFamily, 'Roboto');
          expect(item.isUnderlined, false);
          expect(item.isHighlighted, false);
          expect(item.hasShadow, false);
          expect(item.color, ColorConstants.uiWhite);
        },
      );
    });

    group('Background Operations', () {
      blocTest<CanvasCubit, CanvasState>(
        'changeBackgroundColor updates background',
        build: () => canvasCubit,
        act: (cubit) => cubit.changeBackgroundColor(Colors.blue),
        verify: (cubit) {
          expect(cubit.state.backgroundColor, Colors.blue);
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'toggleTray toggles tray visibility',
        build: () => canvasCubit,
        act: (cubit) => cubit.toggleTray(),
        verify: (cubit) {
          expect(cubit.state.isTrayShown, true);
        },
      );
    });

    group('Drawing Mode', () {
      blocTest<CanvasCubit, CanvasState>(
        'toggleDrawingMode enables drawing mode',
        build: () => canvasCubit,
        act: (cubit) => cubit.toggleDrawingMode(),
        verify: (cubit) {
          expect(cubit.state.isDrawingMode, true);
          expect(cubit.state.selectedTextItemIndex, isNull);
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'setDrawingMode sets drawing mode explicitly',
        build: () => canvasCubit,
        act: (cubit) => cubit.setDrawingMode(true),
        verify: (cubit) {
          expect(cubit.state.isDrawingMode, true);
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'setDrawColor updates drawing color',
        build: () => canvasCubit,
        act: (cubit) => cubit.setDrawColor(Colors.red),
        verify: (cubit) {
          expect(cubit.state.currentDrawColor, Colors.red);
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'setStrokeWidth updates stroke width',
        build: () => canvasCubit,
        act: (cubit) => cubit.setStrokeWidth(10.0),
        verify: (cubit) {
          expect(cubit.state.currentStrokeWidth, 10.0);
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'setBrushType updates brush type',
        build: () => canvasCubit,
        act: (cubit) => cubit.setBrushType(BrushType.marker),
        verify: (cubit) {
          expect(cubit.state.currentBrushType, BrushType.marker);
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'startNewDrawPath creates new drawing path',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.setDrawingMode(true);
          return canvasCubit.state;
        },
        act: (cubit) => cubit.startNewDrawPath(const Offset(10, 10)),
        verify: (cubit) {
          expect(cubit.state.drawPaths.length, 1);
          expect(cubit.state.drawPaths.first.points.length, 1);
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'updateDrawPath adds points to current path',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.setDrawingMode(true);
          canvasCubit.startNewDrawPath(const Offset(10, 10));
          return canvasCubit.state;
        },
        act: (cubit) {
          cubit.updateDrawPath(const Offset(20, 20));
          cubit.updateDrawPath(const Offset(30, 30));
        },
        verify: (cubit) {
          expect(cubit.state.drawPaths.length, 1);
          expect(cubit.state.drawPaths.first.points.length, 3);
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'clearDrawings removes all drawing paths',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.setDrawingMode(true);
          canvasCubit.startNewDrawPath(const Offset(10, 10));
          return canvasCubit.state;
        },
        act: (cubit) => cubit.clearDrawings(),
        verify: (cubit) {
          expect(cubit.state.drawPaths, isEmpty);
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'undoLastDrawing removes last path',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.setDrawingMode(true);
          canvasCubit.startNewDrawPath(const Offset(10, 10));
          canvasCubit.startNewDrawPath(const Offset(20, 20));
          return canvasCubit.state;
        },
        act: (cubit) => cubit.undoLastDrawing(),
        verify: (cubit) {
          expect(cubit.state.drawPaths.length, 1);
        },
      );
    });

    group('Canvas Operations', () {
      blocTest<CanvasCubit, CanvasState>(
        'clearCanvas removes all content',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.addText('Test');
          canvasCubit.setDrawingMode(true);
          canvasCubit.startNewDrawPath(const Offset(10, 10));
          return canvasCubit.state;
        },
        act: (cubit) => cubit.clearCanvas(),
        verify: (cubit) {
          expect(cubit.state.textItems, isEmpty);
          expect(cubit.state.drawPaths, isEmpty);
          expect(cubit.state.isDrawingMode, false);
          expect(cubit.state.selectedTextItemIndex, isNull);
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'createNewPage resets canvas state',
        build: () => canvasCubit,
        seed: () {
          canvasCubit.addText('Test');
          return canvasCubit.state;
        },
        act: (cubit) => cubit.createNewPage(),
        verify: (cubit) {
          expect(cubit.state.textItems, isEmpty);
          expect(cubit.state.drawPaths, isEmpty);
          expect(cubit.state.currentPageName, isNull);
        },
      );
    });

    group('Undo/Redo', () {
      blocTest<CanvasCubit, CanvasState>(
        'undo restores previous state',
        build: () => canvasCubit,
        act: (cubit) {
          cubit.addText('First');
          cubit.addText('Second');
          cubit.undo();
        },
        verify: (cubit) {
          expect(cubit.state.textItems.length, 1);
          expect(cubit.state.textItems.first.text, 'First');
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'redo restores undone state',
        build: () => canvasCubit,
        act: (cubit) {
          cubit.addText('First');
          cubit.addText('Second');
          cubit.undo();
          cubit.redo();
        },
        verify: (cubit) {
          expect(cubit.state.textItems.length, 2);
          expect(cubit.state.textItems.last.text, 'Second');
        },
      );

      blocTest<CanvasCubit, CanvasState>(
        'new action clears redo history',
        build: () => canvasCubit,
        act: (cubit) {
          cubit.addText('First');
          cubit.addText('Second');
          cubit.undo();
          cubit.addText('Third');
        },
        verify: (cubit) {
          expect(cubit.state.future, isEmpty);
        },
      );
    });
  });
}
