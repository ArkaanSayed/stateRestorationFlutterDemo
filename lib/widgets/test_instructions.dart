import 'package:flutter/material.dart';

class TestInstructions extends StatelessWidget {
  const TestInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber[900]),
              const SizedBox(width: 8),
              Text(
                'How to Test State Restoration',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[900],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InstructionStep(
            number: '1',
            text: 'Increment counters or navigate through screens',
          ),
          const SizedBox(height: 8),
          _InstructionStep(
            number: '2',
            text: 'Background the app (press home button)',
          ),
          const SizedBox(height: 8),
          _InstructionStep(
            number: '3',
            text: 'Kill the app from app switcher or settings',
          ),
          const SizedBox(height: 8),
          _InstructionStep(
            number: '4',
            text: 'Reopen the app and observe state restoration',
          ),
        ],
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final String number;
  final String text;

  const _InstructionStep({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.amber[700],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

