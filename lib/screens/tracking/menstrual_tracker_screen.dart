import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenstrualTrackerScreen extends StatefulWidget {
  const MenstrualTrackerScreen({super.key});
  @override
  State<MenstrualTrackerScreen> createState() => _MenstrualTrackerScreenState();
}

class _MenstrualTrackerScreenState extends State<MenstrualTrackerScreen> {
  String? _activeCycleId;
  DateTime? _startDate;
  String _phase = "Unknown";
  int _cycleDay = 0;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadActiveCycle();
  }

  Future<void> _loadActiveCycle() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        setState(() => _isLoading = false);
        return;
      }

      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('cycles')
          .orderBy('startDate', descending: true)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty && mounted) {
        final doc = snap.docs.first;
        final data = doc.data();
        final startDate = (data['startDate'] as Timestamp).toDate();
        final endDate = data['endDate'] != null ? (data['endDate'] as Timestamp).toDate() : null;

        // Only show as active if endDate is null
        if (endDate == null) {
          setState(() {
            _activeCycleId = doc.id;
            _startDate = startDate;
            _cycleDay = DateTime.now().difference(startDate).inDays + 1;
            _phase = _calculatePhase(_cycleDay);
            _isLoading = false;
          });
        } else {
          setState(() {
            _activeCycleId = null;
            _startDate = null;
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading cycle: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _calculatePhase(int cycleDay) {
    if (cycleDay <= 5) return "Menstrual";
    if (cycleDay <= 13) return "Follicular";
    if (cycleDay == 14) return "Ovulation";
    return "Luteal";
  }

  Future<void> _startCycle() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final now = DateTime.now();
      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('cycles')
          .add({
        'startDate': Timestamp.fromDate(now),
        'endDate': null,
        'cycleLength': 28,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          _activeCycleId = docRef.id;
          _startDate = now;
          _cycleDay = 1;
          _phase = "Menstrual";
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Period started! Day 1')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _endCycle() async {
    if (_isSaving || _activeCycleId == null) return;
    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('cycles')
          .doc(_activeCycleId)
          .update({
        'endDate': Timestamp.fromDate(DateTime.now()),
        'cycleDay': _cycleDay,
        'phase': _phase,
      });

      if (mounted) {
        setState(() {
          _activeCycleId = null;
          _startDate = null;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Period ended after $_cycleDay days')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cycle Tracker")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_activeCycleId == null) ...[
              // No active cycle - show Start button
              const Icon(
                Icons.calendar_month,
                size: 80,
                color: Colors.pink,
              ),
              const SizedBox(height: 24),
              const Text(
                'No active period',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tap the button below when your period starts',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _startCycle,
                  icon: _isSaving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.play_arrow),
                  label: Text(_isSaving ? 'Starting...' : 'Start Period'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ] else ...[
              // Active cycle - show End button
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.favorite,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Day $_cycleDay',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _phase,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Started: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _endCycle,
                  icon: _isSaving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.stop),
                  label: Text(_isSaving ? 'Ending...' : 'End Period'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}