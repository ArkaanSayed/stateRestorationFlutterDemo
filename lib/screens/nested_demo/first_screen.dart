import 'package:flutter/material.dart';
import 'second_screen.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});




  @override
  State<FirstScreen> createState() => _FirstScreenState();
}


@pragma('vm:entry-point')
class _FirstScreenState extends State<FirstScreen> with RestorationMixin {
  final RestorableInt _counter = RestorableInt(0);
  final RestorableBool _wasRestored = RestorableBool(false);

  @override
  String? get restorationId => 'first_screen';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_counter, 'counter');
    registerForRestoration(_wasRestored, 'was_restored');
    
    if (!initialRestore) {
      _wasRestored.value = true;
      // Show a snackbar when state is restored
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ First Screen: State Restored!'),
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
    super.dispose();
  }

  void _navigateWithRegularPush() {
    Navigator.of(context).push(
      MaterialPageRoute(
      builder: (context) => SecondScreen(useRestorablePush: false),
    ),
    );
  }

  void _navigateWithRestorablePush() {
    Navigator.of(context).restorablePush(_secondScreenBuilder);
  }

  @pragma('vm:entry-point')
  static Route<void> _secondScreenBuilder(
      BuildContext context, Object? arguments) {
    return MaterialPageRoute(
      builder: (context) => SecondScreen(useRestorablePush: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Screen'),
        backgroundColor: Colors.deepPurple[100],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ScreenBadge(
              level: 1,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 24),
            Text(
              'Nested Navigation Demo',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This demonstrates the difference between regular push and restorable push',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_wasRestored.value)
              Container(
                padding: const EdgeInsets.all(12),
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
                        'This screen was restored from previous state!',
                        style: TextStyle(
                          color: Colors.green[900],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
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
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Choose Navigation Type:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _NavigationButton(
              title: 'Regular Push',
              description:
                  'Navigation stack will NOT be restored when app is killed',
              icon: Icons.arrow_forward,
              color: Colors.red,
              onPressed: _navigateWithRegularPush,
            ),
            const SizedBox(height: 12),
            _NavigationButton(
              title: 'Restorable Push ✨',
              description:
                  'Navigation stack WILL be preserved and restored properly',
              icon: Icons.restore_page,
              color: Colors.green,
              onPressed: _navigateWithRestorablePush,
            ),
            const SizedBox(height: 24),
            _InfoBox(),
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
              'First Screen Counter',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '$counter',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
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

class _NavigationButton extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _NavigationButton({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
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
              Icon(Icons.lightbulb_outline, color: Colors.blue[900]),
              const SizedBox(width: 8),
              Text(
                'Try This:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '1. Navigate using one of the buttons\n'
            '2. Continue to deeper screens\n'
            '3. Background and kill the app\n'
            '4. Reopen and see which navigation method preserved the stack!',
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

