<!-- de34280b-e370-4193-856a-9a1d9db27e62 ecd63da8-fe77-4946-961c-cefde3496518 -->
# Flutter State Restoration Demo App

## Overview

Create a demo app with two main sections: (1) Basic restoration scope demonstration with a counter, and (2) Nested route navigation using restorable push to show proper state restoration across deep navigation stacks.

## Implementation Structure

### 1. Setup MaterialApp with Restoration Support

**File**: `lib/main.dart`

- Add `restorationScopeId` to MaterialApp
- Configure root restoration bucket

### 2. Create Home Screen with Navigation Options

**File**: `lib/main.dart` or `lib/screens/home_screen.dart`

- Button to navigate to "Basic Counter Demo"
- Button to navigate to "Nested Navigation Demo"
- Clear explanatory text for blog readers

### 3. Basic Counter Demo (Part 1 of Blog)

**File**: `lib/screens/counter_demo_screen.dart`

- Create two side-by-side counters:
- **Without Restoration**: Regular `StatefulWidget` with `int _counter` - resets to 0 on restoration
- **With Restoration**: Uses `RestorationMixin` with `RestorableInt` - preserves value on restoration
- Clear labels showing "Without Restoration" vs "With Restoration"
- Instructions: "Increment counters, background the app, then restore to see the difference"

### 4. Nested Navigation Demo (Part 2 of Blog - Main Focus)

**Files**:

- `lib/screens/nested_demo/first_screen.dart`
- `lib/screens/nested_demo/second_screen.dart`
- `lib/screens/nested_demo/third_screen.dart`

**First Screen**:

- Show a `RestorableInt` counter
- Two navigation buttons:
- "Regular Push to Second Screen" (uses `Navigator.push()`)
- "Restorable Push to Second Screen" (uses `Navigator.restorablePush()`)
- Display which navigation type was used

**Second Screen**:

- Show its own `RestorableInt` counter
- Display the route information
- Button to navigate to Third Screen (use same navigation type as chosen in First Screen)

**Third Screen**:

- Show its own `RestorableInt` counter or text field input
- Deep nested screen to demonstrate stack preservation
- Display all restoration state

### 5. Visual Indicators

- Color coding or badges showing:
- Which screens use restoration
- Current navigation stack depth
- Whether state was restored (detect via `RestorationMixin.didRestoreState`)
- SnackBar/banner showing "State Restored!" when restoration occurs

### 6. Testing Instructions Component

**File**: `lib/widgets/test_instructions.dart`

- Reusable widget showing how to test restoration:
- "1. Increment counters / navigate through screens"
- "2. Background the app (home button/app switcher)"
- "3. Kill the app from system settings if needed"
- "4. Reopen and observe state restoration"

## Key Technical Points to Highlight

1. **MaterialApp.restorationScopeId**: Required at root level
2. **RestorationMixin**: Mix into State classes needing restoration
3. **Restorable Properties**: `RestorableInt`, `RestorableString`, `RestorableTextEditingController`, etc.
4. **registerForRestoration()**: Call in `initState()` with unique IDs
5. **Navigator.restorablePush()**: Preserves navigation stack vs regular `push()`
6. **RestorableRouteFuture**: For tracking async navigation

## Blog Post Flow

The app structure directly maps to blog sections:

- Introduction with basic counter comparison
- Deep dive into restorable push with 3-level navigation
- Side-by-side comparison of regular vs restorable push behavior
- Visual proof of restoration working (or not working)

## Platform Testing Notes

Restoration behavior can be tested on:

- **Android**: Background app, force stop from settings, reopen
- **iOS**: Background app, system may kill for memory, reopen
- **Desktop/Web**: Refresh/reload scenarios

This demo will clearly illustrate why restorable push is essential for production apps with complex navigation.

### To-dos

- [ ] Add restorationScopeId to MaterialApp and configure root restoration support
- [ ] Create home screen with navigation to both demo sections
- [ ] Build basic counter demo screen showing restoration vs non-restoration side-by-side
- [ ] Create three nested screens (First, Second, Third) with individual restoration state
- [ ] Implement both regular push and restorable push navigation paths in nested demo
- [ ] Add UI indicators showing restoration status, navigation depth, and state preservation
- [ ] Create instructions widget explaining how to test state restoration