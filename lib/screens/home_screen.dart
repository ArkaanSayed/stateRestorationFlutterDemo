import 'package:flutter/material.dart';
import 'nested_demo/first_screen.dart';
import '../widgets/test_instructions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


@pragma('vm:entry-point')
class _HomeScreenState extends State<HomeScreen> with RestorationMixin {
  // WITHOUT restoration - regular counter
  int _regularCounter = 0;

  // WITH restoration - restorable counter
  final RestorableInt _restorableCounter = RestorableInt(0);
  final RestorableBool _wasRestored = RestorableBool(false);

  @override
  String? get restorationId => 'home_screen';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_restorableCounter, 'restorable_counter');
    registerForRestoration(_wasRestored, 'was_restored');
    
    if (!initialRestore) {
      _wasRestored.value = true;
      // Show a snackbar when state is restored
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Home Screen: State Restored!'),
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
    _restorableCounter.dispose();
    _wasRestored.dispose();
    super.dispose();
  }

  void _navigateToNestedDemo() {
    Navigator.of(context).restorablePush(_firstScreenBuilder);
  }

  @pragma('vm:entry-point')
  static Route<void> _firstScreenBuilder(
      BuildContext context, Object? arguments) {
    return MaterialPageRoute(builder: (context) => const FirstScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('State Restoration Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.restore_page,
              size: 80,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 16),
            Text(
              'Flutter State Restoration',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Increment counters, navigate away, kill the app, then come back!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_wasRestored.value)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This screen was restored! Check the counters below.',
                        style: TextStyle(
                          color: Colors.green[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            const TestInstructions(),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),
            Text(
              'Counter Comparison',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _CounterCard(
                    title: 'Without Restoration',
                    subtitle: 'Resets to 0',
                    count: _regularCounter,
                    color: Colors.red,
                    icon: Icons.warning_amber_rounded,
                    onIncrement: () {
                      setState(() {
                        _regularCounter++;
                      });
                    },
                    onDecrement: () {
                      setState(() {
                        if (_regularCounter > 0) _regularCounter--;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _CounterCard(
                    title: 'With Restoration',
                    subtitle: 'Preserves value',
                    count: _restorableCounter.value,
                    color: Colors.green,
                    icon: Icons.check_circle,
                    onIncrement: () {
                      setState(() {
                        _restorableCounter.value++;
                      });
                    },
                    onDecrement: () {
                      setState(() {
                        if (_restorableCounter.value > 0) {
                          _restorableCounter.value--;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),
            Text(
              'Navigate to Test Restoration',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateToNestedDemo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.layers, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nested Navigation Demo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Navigate through multiple screens, kill the app, and see how restorable push preserves the entire navigation stack',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _CodeExplanation(),
          ],
        ),
      ),
    );
  }
}

class _CounterCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;
  final Color color;
  final IconData icon;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _CounterCard({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.color,
    required this.icon,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '$count',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onDecrement,
                  icon: const Icon(Icons.remove),
                  style: IconButton.styleFrom(
                    backgroundColor: color.withOpacity(0.1),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onIncrement,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: color.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeExplanation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Implementation Difference',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _CodeSnippet(
            label: 'Without Restoration (❌)',
            code: 'int _counter = 0;',
            color: Colors.red,
          ),
          const SizedBox(height: 12),
          _CodeSnippet(
            label: 'With Restoration (✅)',
            code:
                'final RestorableInt _counter = RestorableInt(0);\n\nregisterForRestoration(_counter, \'counter\');',
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

class _CodeSnippet extends StatelessWidget {
  final String label;
  final String code;
  final Color color;

  const _CodeSnippet({
    required this.label,
    required this.code,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            code,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

