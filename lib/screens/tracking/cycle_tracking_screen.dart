import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cycle_log_provider.dart';
import 'cycle_tab.dart';
import 'cycle_log_tab.dart';
import 'cycle_analysis_tab.dart';

class CycleTrackingScreen extends StatefulWidget {
  const CycleTrackingScreen({super.key});
  @override
  State<CycleTrackingScreen> createState() => _CycleTrackingScreenState();
}

class _CycleTrackingScreenState extends State<CycleTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Cycle Tracking'),
        actions: [
          // Analysis button at top right
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.analytics, color: Colors.white, size: 18),
            ),
            tooltip: 'Analysis',
            onPressed: () {
              // Switch to Analysis tab
              _tabController.animateTo(2);
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF97316),
          labelColor: const Color(0xFFF97316),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Cycle'),
            Tab(text: 'Log'),
            Tab(text: 'Analysis'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CycleTab(),
          CycleLogTab(),
          CycleAnalysisTab(),
        ],
      ),
    );
  }
}