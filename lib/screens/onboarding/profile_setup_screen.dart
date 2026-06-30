import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _save() async {
    final h = double.tryParse(_heightCtrl.text);
    final w = double.tryParse(_weightCtrl.text);
    if (h == null || w == null) return;
    setState(() => _loading = true);
    await context.read<AuthProvider>().completeProfile(heightCm: h, weightKg: w);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Profile')),
      body: Padding(padding: const EdgeInsets.all(24.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('Enter height and weight to calculate BMI.', textAlign: TextAlign.center),
        const SizedBox(height: 24),
        TextField(controller: _heightCtrl, decoration: const InputDecoration(labelText: 'Height (cm)'), keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        TextField(controller: _weightCtrl, decoration: const InputDecoration(labelText: 'Weight (kg)'), keyboardType: TextInputType.number),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading ? null : _save, child: _loading ? const CircularProgressIndicator() : const Text('Save & Continue'))),
      ])),
    );
  }
}