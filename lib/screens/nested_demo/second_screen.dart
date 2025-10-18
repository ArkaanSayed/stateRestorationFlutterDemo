import 'package:flutter/material.dart';
import 'third_screen.dart';

class SecondScreen extends StatefulWidget {
  final bool useRestorablePush;

  const SecondScreen({
    super.key,
    required this.useRestorablePush,
  });

  // static Route<void> route({required bool useRestorablePush}) {
  //   return MaterialPageRoute(
  //     builder: (context) => SecondScreen(useRestorablePush: useRestorablePush),
  //   );
  // }

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}


@pragma('vm:entry-point')
class _SecondScreenState extends State<SecondScreen> with RestorationMixin {
  final RestorableInt _counter = RestorableInt(0);
  final RestorableBool _wasRestored = RestorableBool(false);
  RestorableBool? _useRestorablePush;

  @override
  String? get restorationId => 'second_screen';


  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    // FIX: Initialize here if not already initialized
    _useRestorablePush ??= RestorableBool(widget.useRestorablePush);
    
    registerForRestoration(_counter, 'counter');
    registerForRestoration(_wasRestored, 'was_restored');
    registerForRestoration(_useRestorablePush!, 'use_restorable_push');

    if (!initialRestore) {
      _wasRestored.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Second Screen: State Restored!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _counter.dispose();
    _wasRestored.dispose();
    _useRestorablePush?.dispose();  // FIX: Add ? for null safety
    super.dispose();
  }

  void _navigateToThirdScreen() {
    if (_useRestorablePush!.value) {  // FIX: Add ! since we know it's initialized
      Navigator.of(context).restorablePush(_thirdScreenBuilder);
    } else {
      Navigator.of(context).push(
       MaterialPageRoute(
      builder: (context) => ThirdScreen(useRestorablePush: false,),
    ),
      );
    }
  }

  @pragma('vm:entry-point')
  static Route<void> _thirdScreenBuilder(
      BuildContext context, Object? arguments) {
    return MaterialPageRoute(
      builder: (context) => ThirdScreen(useRestorablePush: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Screen'),
        backgroundColor: Colors.orange[100],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ScreenBadge(
              level: 2,
              color: Colors.orange,
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
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This screen was restored! The navigation stack is intact.',
                        style: TextStyle(
                          color: Colors.green[900],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _CounterDisplay(
              counter: _counter.value,
              screenName: 'Second Screen',
              color: Colors.orange,
              onIncrement: () {
                setState(() {
                  _counter.value++;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToThirdScreen,
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                _useRestorablePush!.value
                    ? 'Go to Third Screen (Restorable)'
                    : 'Go to Third Screen (Regular)',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor:
                    _useRestorablePush!.value ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _StatusInfo(isRestorable: _useRestorablePush!.value),
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
        child: Text(
          'Navigation Level: $level',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
  final String screenName;
  final Color color;
  final VoidCallback onIncrement;

  const _CounterDisplay({
    required this.counter,
    required this.screenName,
    required this.color,
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
              '$screenName Counter',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '$counter',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
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

class _StatusInfo extends StatelessWidget {
  final bool isRestorable;

  const _StatusInfo({
    required this.isRestorable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[900]),
              const SizedBox(width: 8),
              Text(
                'Current Status',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isRestorable
                ? 'You\'re using restorable push. Continue to the third screen, then kill the app. When you reopen, you should be brought back to this exact navigation state!'
                : 'You\'re using regular push. If you kill the app now, you\'ll lose this navigation stack and return to the home screen.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue[900],
            ),
          ),
        ],
      ),
    );
  }
}

