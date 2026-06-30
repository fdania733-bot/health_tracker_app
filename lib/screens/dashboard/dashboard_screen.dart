import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'male_dashboard.dart';
import 'female_dashboard.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final gender = context.watch<AuthProvider>().appUser?.gender ?? 'male';
    return gender == 'female' ? const FemaleDashboard() : const MaleDashboard();
  }
}