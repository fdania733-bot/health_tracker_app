import 'package:flutter/material.dart';

class SymptomsSelectorScreen extends StatefulWidget {
  const SymptomsSelectorScreen({super.key});
  @override
  State<SymptomsSelectorScreen> createState() => _SymptomsSelectorScreenState();
}

class _SymptomsSelectorScreenState extends State<SymptomsSelectorScreen> {
  final Map<String, bool> _selectedSymptoms = {};

  final Map<String, List<Map<String, String>>> _symptomGroups = {
    'Abdomen': [
      {'name': 'Diarrhea', 'icon': '🚽'},
      {'name': 'Heavy and swollen abdomen', 'icon': '🎈'},
      {'name': 'Abdominal pain', 'icon': '😣'},
      {'name': 'Loss of appetite', 'icon': '🍽️'},
    ],
    'Waist and hip': [
      {'name': 'Lower back pain', 'icon': '🦴'},
      {'name': 'Constipation', 'icon': '😰'},
    ],
    'Whole body': [
      {'name': 'Dry skin', 'icon': '🌵'},
      {'name': 'Bloating', 'icon': '💨'},
      {'name': 'Fever', 'icon': '🌡️'},
      {'name': 'Body aches', 'icon': '😫'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptoms'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final selected = _selectedSymptoms.entries
                  .where((e) => e.value)
                  .map((e) => e.key)
                  .toList();
              Navigator.pop(context, selected);
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.pink)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _symptomGroups.entries.map((group) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  group.key,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
              ),
              ...group.value.map((symptom) {
                return CheckboxListTile(
                  value: _selectedSymptoms[symptom['name']] ?? false,
                  onChanged: (value) {
                    setState(() {
                      _selectedSymptoms[symptom['name']!] = value ?? false;
                    });
                  },
                  title: Row(
                    children: [
                      Text(symptom['icon']!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Text(symptom['name']!),
                    ],
                  ),
                );
              }).toList(),
              const Divider(),
            ],
          );
        }).toList(),
      ),
    );
  }
}