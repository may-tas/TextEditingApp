# Revert of PR #18: "Text Size Change Applied to Newest Text Instead of Selected One"

## Why This Revert Was Necessary

PR #18 introduced significant issues and breaking changes that made the codebase unstable:

### 1. **Syntax Errors**
- `canvas_state.dart` had duplicate factory methods and malformed constructor syntax
- Missing required parameters in constructor calls
- Incomplete widget structure in `editable_text_widget.dart`

### 2. **Breaking API Changes**
- Changed CanvasCubit method signatures from required positional to optional named parameters
- Added required `isSelected` parameter to EditableTextWidget without updating all usage sites
- These changes would break any external code calling these methods

### 3. **Incomplete Implementation**
- `font_controls.dart` had incomplete BlocBuilder implementation with duplicate return statements
- Selection logic was partially implemented but contained logic errors
- Widget structure was broken with incomplete child elements

### 4. **Code Quality Issues**
- Redundant code in `addText` method that called `_updateState` twice
- Inconsistent state management with `selectedItemIndex` field
- Poor code organization with scattered selection logic

## What Was Reverted

### Files Modified:
1. **lib/cubit/canvas_state.dart**
   - Removed `selectedItemIndex` field
   - Fixed duplicate factory methods
   - Restored clean constructor syntax

2. **lib/cubit/canvas_cubit.dart**
   - Removed `selectTextItem` method
   - Removed `_getIndexForUpdate` helper method
   - Restored original method signatures for all font/text modification methods
   - Fixed redundant code in `addText` method
   - Cleaned up `_updateState` method

3. **lib/ui/widgets/editable_text_widget.dart**
   - Removed broken selection UI with Container wrapper
   - Restored original clean Text widget structure
   - Removed references to non-existent `isSelected` parameter

4. **lib/ui/widgets/font_controls.dart**
   - Removed incomplete BlocBuilder implementation
   - Restored original working Container structure
   - Fixed duplicate return statements

## Current Status

The codebase has been restored to a stable, working state that:
- ✅ Has proper syntax without compilation errors
- ✅ Maintains original API compatibility
- ✅ Has clean, maintainable code structure
- ✅ Works with existing canvas_screen.dart usage

## Future Recommendations

If text selection functionality is needed in the future, it should be implemented with:
1. Proper testing to ensure no syntax errors
2. Backward compatibility maintenance
3. Complete implementation across all affected components
4. Proper code review process to catch issues before merging