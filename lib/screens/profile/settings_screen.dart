import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String _gender = 'male';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().appUser;
    if (user != null) {
      _nameController.text = user.name;
      _nicknameController.text = user.nickname ?? '';
      _emailController.text = user.email;
      _ageController.text = user.age.toString();
      _gender = user.gender.toLowerCase();
      if (!['male', 'female', 'not specified'].contains(_gender)) {
        _gender = 'not specified';
      }
      if (user.heightCm != null) _heightController.text = user.heightCm.toString();
      if (user.weightKg != null) _weightController.text = user.weightKg.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().updateProfile(
        name: _nameController.text.trim(),
        nickname: _nicknameController.text.trim().isEmpty ? null : _nicknameController.text.trim(),
        email: _emailController.text.trim(),
        age: int.tryParse(_ageController.text) ?? 25,
        gender: _gender,
      );

      if (_heightController.text.isNotEmpty && _weightController.text.isNotEmpty) {
        await context.read<AuthProvider>().completeProfile(
          heightCm: double.tryParse(_heightController.text) ?? 0,
          weightKg: double.tryParse(_weightController.text) ?? 0,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveSettings,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('SAVE', style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Personal Information', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            _buildTextField(_nameController, 'Full Name', Icons.person, isRequired: true),
            const SizedBox(height: 12),
            _buildTextField(_nicknameController, 'Nickname (Optional)', Icons.alternate_email),
            const SizedBox(height: 12),
            _buildTextField(_emailController, 'Email Address', Icons.email, keyboardType: TextInputType.emailAddress, isRequired: true),
            const SizedBox(height: 12),
            _buildTextField(_ageController, 'Age', Icons.cake, keyboardType: TextInputType.number, isRequired: true),

            const SizedBox(height: 24),
            const Text('Physical Details', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Gender Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
              child: DropdownButton<String>(
                value: _gender,
                isExpanded: true,
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'female', child: Text('Female', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'not specified', child: Text('Not Specified', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (val) => setState(() => _gender = val!),
              ),
            ),
            const SizedBox(height: 12),

            _buildTextField(_heightController, 'Height (cm)', Icons.height, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildTextField(_weightController, 'Weight (kg)', Icons.monitor_weight, keyboardType: TextInputType.number),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        bool isRequired = false,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: isRequired ? (val) => val!.isEmpty ? 'This field is required' : null : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF97316), width: 2),
        ),
      ),
    );
  }
}