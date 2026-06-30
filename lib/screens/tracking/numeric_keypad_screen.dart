import 'package:flutter/material.dart';

class NumericKeypadScreen extends StatefulWidget {
  final String title;
  final String unit;

  const NumericKeypadScreen({
    super.key,
    required this.title,
    required this.unit,
  });

  @override
  State<NumericKeypadScreen> createState() => _NumericKeypadScreenState();
}

class _NumericKeypadScreenState extends State<NumericKeypadScreen> {
  String _value = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final numValue = double.tryParse(_value);
              if (numValue != null) {
                Navigator.pop(context, numValue);
              }
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.pink)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _value.isEmpty ? '_' : _value,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.unit,
                    style: const TextStyle(fontSize: 24, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildKeypadRow(['1', '2', '3']),
                _buildKeypadRow(['4', '5', '6']),
                _buildKeypadRow(['7', '8', '9']),
                _buildKeypadRow(['.', '0', '⌫']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        return GestureDetector(
          onTap: () {
            setState(() {
              if (key == '⌫') {
                if (_value.isNotEmpty) {
                  _value = _value.substring(0, _value.length - 1);
                }
              } else if (key == '.' && !_value.contains('.')) {
                _value += key;
              } else if (key != '.') {
                _value += key;
              }
            });
          },
          child: Container(
            width: 80,
            height: 60,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                key,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}