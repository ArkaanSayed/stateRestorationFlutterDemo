# Mastering State Restoration in Flutter: From Basic Scope to Nested Routes

Have you ever noticed how some apps lose all your progress when they're killed by the system and reopened? Maybe you were filling out a form, navigating through multiple screens, or had some important counter state – and poof! Everything resets when you return to the app.

This is frustrating for users, but Flutter provides a powerful solution: **State Restoration**. In this article, we'll dive deep into Flutter's state restoration capabilities, starting with basic concepts and progressing to the more complex (and crucial) topic of preserving navigation stacks with nested routes.

## Table of Contents

1. [The Problem: Why State Gets Lost](#the-problem)
2. [Part 1: Understanding RestorationScope](#part-1-restoration-scope)
3. [Part 2: The Real Challenge - Nested Route Restoration](#part-2-nested-routes)
4. [Testing State Restoration](#testing)
5. [Best Practices & Gotchas](#best-practices)

---

## <a name="the-problem"></a>The Problem: Why State Gets Lost

When your Flutter app is backgrounded, the operating system might kill it to free up memory. When the user returns, the OS asks Flutter to restore the app to its previous state. **Without proper state restoration setup, your app will restart from scratch** – losing navigation history, form inputs, counters, and any other transient state.

This creates a poor user experience. Imagine:

- A multi-step form where the user loses all their inputs
- A shopping app where the user is kicked back to the home screen after browsing deep into categories
- Any app with complex navigation that doesn't remember where the user was

Let's fix this!

---

## <a name="part-1-restoration-scope"></a>Part 1: Understanding RestorationScope

### Step 1: Enable Restoration at the Root

First, we need to tell Flutter we want state restoration. This is done by adding a `restorationScopeId` to your `MaterialApp`:

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      // This single line enables state restoration!
      restorationScopeId: 'app',
      home: const HomeScreen(),
    );
  }
}
```

The `restorationScopeId` creates a restoration bucket at the root level. Think of it as enabling a "save game" feature for your app.

### Step 2: Make Your Widgets Restorable

Let's look at a simple counter example. Here's what happens WITHOUT restoration:

```dart
class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _counter = 0;  // ❌ This will reset to 0 on restoration

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Count: $_counter'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

**Problem**: When the app is killed and restored, `_counter` will always be 0.

### Step 3: Use RestorationMixin and Restorable Properties

Now let's make it restorable:

```dart
class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen>
    with RestorationMixin {  // ✅ Add RestorationMixin

  // ✅ Use RestorableInt instead of int
  final RestorableInt _counter = RestorableInt(0);

  @override
  String? get restorationId => 'counter_screen';  // ✅ Unique ID

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    // ✅ Register the restorable property
    registerForRestoration(_counter, 'counter');
  }

  @override
  void dispose() {
    _counter.dispose();  // ✅ Don't forget to dispose
    super.dispose();
  }

  void _increment() {
    setState(() {
      _counter.value++;  // Note: use .value to access/modify
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Count: ${_counter.value}'),  // Access via .value
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### Key Changes:

1. **Mix in `RestorationMixin`**: Provides restoration functionality
2. **Use `RestorableInt`** instead of `int`: Flutter provides restorable versions of common types:

   - `RestorableInt`, `RestorableDouble`, `RestorableBool`
   - `RestorableString`
   - `RestorableTextEditingController` (for text fields!)
   - `RestorableDateTime`, `RestorableEnum`, etc.

3. **Provide a `restorationId`**: Must be unique within the parent's restoration scope

4. **Register properties in `restoreState()`**: This tells Flutter what to save/restore

5. **Dispose properly**: Restorable properties need to be disposed

### Testing Basic Restoration

To test this:

1. Run your app
2. Increment the counter to, say, 42
3. Background the app (home button)
4. Kill the app from the app switcher or system settings
5. Reopen the app

With the restorable version, you should see 42 instead of 0! 🎉

---

## <a name="part-2-nested-routes"></a>Part 2: The Real Challenge - Nested Route Restoration

Here's where it gets interesting – and this is what many developers struggle with.

### The Problem with Regular Navigation

Even if you implement `RestorationMixin` on all your screens, **using regular `Navigator.push()` will NOT preserve your navigation stack**. Let me demonstrate:

**Scenario**: User navigates Home → Details → Editor

```dart
// Regular push - this is what you might be doing now
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const DetailsScreen(),
  ),
);
```

**What happens**:

1. User is on Editor screen (3 levels deep)
2. App gets killed by the system
3. App reopens → **User is back at Home screen** 😢

Even though each individual screen might preserve its local state using `RestorationMixin`, the navigation stack itself is lost because regular `push()` doesn't participate in state restoration.

### The Solution: Navigator.restorablePush()

Flutter provides `Navigator.restorablePush()` and `Navigator.restorablePushNamed()` specifically for this purpose.

### Implementation: First Screen

```dart
class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> with RestorationMixin {
  final RestorableInt _counter = RestorableInt(0);

  @override
  String? get restorationId => 'first_screen';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_counter, 'counter');
  }

  // ✅ Define a static route builder for restoration
  static Route<void> _secondScreenBuilder(
      BuildContext context, Object? arguments) {
    return MaterialPageRoute(
      builder: (context) => const SecondScreen(),
    );
  }

  void _navigateToSecondScreen() {
    // ✅ Use restorablePush instead of regular push
    Navigator.of(context).restorablePush(_secondScreenBuilder);
  }

  @override
  void dispose() {
    _counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('First Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Counter: ${_counter.value}',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() => _counter.value++);
              },
              child: const Text('Increment'),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _navigateToSecondScreen,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Go to Second Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Implementation: Second Screen

```dart
class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> with RestorationMixin {
  final RestorableInt _counter = RestorableInt(0);
  final RestorableTextEditingController _textController =
      RestorableTextEditingController();

  @override
  String? get restorationId => 'second_screen';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_counter, 'counter');
    registerForRestoration(_textController, 'text_controller');
  }

  static Route<void> _thirdScreenBuilder(
      BuildContext context, Object? arguments) {
    return MaterialPageRoute(
      builder: (context) => const ThirdScreen(),
    );
  }

  void _navigateToThirdScreen() {
    Navigator.of(context).restorablePush(_thirdScreenBuilder);
  }

  @override
  void dispose() {
    _counter.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second Screen')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Counter: ${_counter.value}',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() => _counter.value++);
              },
              child: const Text('Increment'),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _textController.value,
              decoration: const InputDecoration(
                labelText: 'Restorable Text Input',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _navigateToThirdScreen,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Go to Third Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### What Makes This Work?

1. **Each screen uses `RestorationMixin`** with a unique `restorationId`
2. **Navigation uses `restorablePush()`** instead of regular `push()`
3. **Route builders are static functions** that can be serialized and restored
4. **All state uses restorable properties** (`RestorableInt`, `RestorableTextEditingController`, etc.)

### The Magic Moment

Now when you:

1. Navigate: Home → First → Second → Third Screen
2. Increment counters and type text on each screen
3. Background and kill the app
4. Reopen

**Result**: You're restored to the Third Screen with:

- ✅ The full navigation stack intact (can press back through all screens)
- ✅ All counter values preserved
- ✅ All text input preserved
- ✅ Complete user context maintained

This is the power of `restorablePush()` combined with `RestorationMixin`!

---

## <a name="testing"></a>Testing State Restoration

### iOS Testing

1. Run your app in debug mode
2. Navigate through screens and modify state
3. Press the home button to background the app
4. Double-click home to see the app switcher
5. Swipe up to kill your app
6. Tap the app icon to reopen
7. The app should restore to your previous state

### Android Testing

1. Run your app
2. Navigate and modify state
3. Press the home button
4. Go to Settings → Apps → Your App → Force Stop
5. Reopen your app from the launcher
6. State should be restored

### Debug Mode Testing

For faster iteration during development:

```dart
// Add this button to trigger restoration manually in debug mode
if (kDebugMode) {
  ElevatedButton(
    onPressed: () {
      // This simulates the restoration process
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.paused,
      );
    },
    child: const Text('Simulate Background'),
  );
}
```

---

## <a name="best-practices"></a>Best Practices & Gotchas

### ✅ DO:

1. **Always provide unique `restorationId`s** within the same restoration scope

   ```dart
   @override
   String? get restorationId => 'unique_screen_identifier';
   ```

2. **Dispose restorable properties** in the `dispose()` method

   ```dart
   @override
   void dispose() {
     _counter.dispose();
     _textController.dispose();
     super.dispose();
   }
   ```

3. **Use restorable properties for all state you want preserved**

   - `RestorableInt`, `RestorableString`, `RestorableBool`
   - `RestorableTextEditingController` for text fields
   - Create custom `RestorableProperty` for complex objects

4. **Use `restorablePush()` for all navigation** if you want the stack preserved

5. **Test on real devices** – restoration behavior can differ from emulators

### ❌ DON'T:

1. **Don't use regular `push()` and expect navigation restoration**

   ```dart
   // ❌ This won't preserve navigation stack
   Navigator.push(context, MaterialPageRoute(...));

   // ✅ Use this instead
   Navigator.restorablePush(context, _routeBuilder);
   ```

2. **Don't forget the root `restorationScopeId`** in MaterialApp

   ```dart
   // ❌ Without this, nothing will restore
   MaterialApp(home: HomeScreen());

   // ✅ Add restorationScopeId
   MaterialApp(restorationScopeId: 'app', home: HomeScreen());
   ```

3. **Don't use regular variables for state you want restored**

   ```dart
   // ❌ Won't restore
   int _counter = 0;

   // ✅ Will restore
   final RestorableInt _counter = RestorableInt(0);
   ```

4. **Don't forget to register properties**

   ```dart
   @override
   void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
     // ❌ Forgot to register - won't restore!
     // _counter is declared but not registered

     // ✅ Must register
     registerForRestoration(_counter, 'counter');
   }
   ```

### Creating Custom Restorable Properties

For complex objects, you can create custom restorable properties:

```dart
class RestorableUserData extends RestorableProperty<UserData> {
  UserData _userData = UserData.empty();

  @override
  UserData createDefaultValue() => UserData.empty();

  @override
  UserData fromPrimitives(Object? data) {
    if (data == null) return UserData.empty();
    final map = data as Map<String, dynamic>;
    return UserData.fromJson(map);
  }

  @override
  Object? toPrimitives() {
    return _userData.toJson();
  }

  @override
  UserData get value => _userData;

  @override
  set value(UserData newValue) {
    if (_userData != newValue) {
      _userData = newValue;
      notifyListeners();
    }
  }
}
```

---

## Conclusion

State restoration is crucial for providing a professional, polished user experience in your Flutter apps. While basic restoration with `RestorationMixin` is straightforward, the real power comes from combining it with `restorablePush()` to preserve complex navigation stacks.

**Key Takeaways:**

1. **Enable restoration** at the root with `restorationScopeId: 'app'`
2. **Use `RestorationMixin`** on all stateful widgets you want to preserve
3. **Use restorable properties** like `RestorableInt`, `RestorableTextEditingController`
4. **Use `restorablePush()`** instead of regular `push()` for navigation
5. **Test thoroughly** on real devices

By following these patterns, your users will have a seamless experience even when your app is killed and restored by the system. No more frustrating "lost my place" moments!

---

## Demo Project

The complete demo project showcasing all these concepts is available at [your-repo-link]. It includes:

- Side-by-side comparison of restorable vs non-restorable counters
- Three-level navigation demonstrating `restorablePush()` vs regular `push()`
- Visual indicators showing when restoration occurs
- Comprehensive examples of different restorable property types

Clone it, run it, and see state restoration in action!

---

**Questions or feedback?** Leave a comment below or reach out on [Twitter/LinkedIn/etc.]!

Happy coding! 🚀
