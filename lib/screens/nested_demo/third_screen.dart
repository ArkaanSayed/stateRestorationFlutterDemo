import 'package:flutter/material.dart';

class ThirdScreen extends StatefulWidget {
  final bool useRestorablePush;

  const ThirdScreen({
    super.key,
    required this.useRestorablePush,
  });

  //    @pragma('vm:entry-point')
  // static Route<void> route({required bool useRestorablePush}) {
  //   return MaterialPageRoute(
  //     builder: (context) => ThirdScreen(useRestorablePush: useRestorablePush),
  //   );
  // }

  @override
  State<ThirdScreen> createState() => _ThirdScreenState();
}


@pragma('vm:entry-point')
class _ThirdScreenState extends State<ThirdScreen> with RestorationMixin {
  final RestorableInt _counter = RestorableInt(0);
  final RestorableTextEditingController _textController =
      RestorableTextEditingController();
  final RestorableBool _wasRestored = RestorableBool(false);
  RestorableBool? _useRestorablePush;

  @override
  String? get restorationId => 'third_screen';


  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    _useRestorablePush ??= RestorableBool(widget.useRestorablePush);
    
    registerForRestoration(_counter, 'counter');
    registerForRestoration(_textController, 'text_controller');
    registerForRestoration(_wasRestored, 'was_restored');
    registerForRestoration(_useRestorablePush!, 'use_restorable_push');

    if (!initialRestore) {
      _wasRestored.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Third Screen: State Restored!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _counter.dispose();
    _textController.dispose();
    _wasRestored.dispose();
    _useRestorablePush?.dispose();  
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Third Screen (Deepest)'),
        backgroundColor: Colors.green[100],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ScreenBadge(
              level: 3,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _NavigationTypeIndicator(
              isRestorable: _useRestorablePush!.value,  // FIX: Add !
            ),
            const SizedBox(height: 24),
            if (_wasRestored.value)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'SUCCESS! This deep screen was fully restored!',
                            style: TextStyle(
                              color: Colors.green[900],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This proves that restorable push preserves the entire navigation stack and all screen states.',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              'Deepest Screen',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This is the third level of navigation. All state here should be preserved with restorable push.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _CounterDisplay(
              counter: _counter.value,
              onIncrement: () {
                setState(() {
                  _counter.value++;
                });
              },
            ),
            const SizedBox(height: 16),
            _TextFieldDisplay(
              controller: _textController.value,
            ),
            const SizedBox(height: 24),
            _TestInstructions(isRestorable: _useRestorablePush!.value), // FIX: Add !
          ],
        ),
      ),
    );
  }
}

class _ScreenBadge extends StatelessWidget {
  final int level;
  final Color color;

  const _ScreenBadge({
    required this.level,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.layers, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Navigation Level: $level (Deepest)',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationTypeIndicator extends StatelessWidget {
  final bool isRestorable;

  const _NavigationTypeIndicator({
    required this.isRestorable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isRestorable ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isRestorable ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isRestorable ? Icons.restore_page : Icons.warning_amber_rounded,
            color: isRestorable ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            isRestorable ? 'Using Restorable Push' : 'Using Regular Push',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isRestorable ? Colors.green[900] : Colors.red[900],
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterDisplay extends StatelessWidget {
  final int counter;
  final VoidCallback onIncrement;

  const _CounterDisplay({
    required this.counter,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Third Screen Counter',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '$counter',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onIncrement,
              icon: const Icon(Icons.add),
              label: const Text('Increment'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextFieldDisplay extends StatelessWidget {
  final TextEditingController controller;

  const _TextFieldDisplay({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Restorable Text Input',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Type something and test restoration',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter text here...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestInstructions extends StatelessWidget {
  final bool isRestorable;

  const _TestInstructions({
    required this.isRestorable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRestorable ? Colors.amber[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRestorable ? Colors.amber[300]! : Colors.red[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isRestorable ? Icons.science : Icons.warning,
                color: isRestorable ? Colors.amber[900] : Colors.red[900],
              ),
              const SizedBox(width: 8),
              Text(
                isRestorable ? 'Test Restoration Now!' : 'What Will Happen?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isRestorable ? Colors.amber[900] : Colors.red[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isRestorable
                ? '1. Increment the counter and type some text\n'
                    '2. Background the app and kill it\n'
                    '3. Reopen the app\n'
                    '4. You should be back on THIS screen with your counter and text preserved! ✨'
                : '1. Increment the counter and type some text\n'
                    '2. Background the app and kill it\n'
                    '3. Reopen the app\n'
                    '4. You will be back at the home screen - the navigation stack is lost! ❌',
            style: TextStyle(
              fontSize: 13,
              color: isRestorable ? Colors.amber[900] : Colors.red[900],
            ),
          ),
        ],
      ),
    );
  }
}

