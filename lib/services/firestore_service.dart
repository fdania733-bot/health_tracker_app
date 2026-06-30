import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create user profile
  Future<void> createUserProfile(UserModel user) async {
    try {
      print('🔵 Creating user profile in Firestore...');
      print('🔵 User UID: ${user.uid}');
      print('🔵 User data: ${user.toMap()}');

      await _firestore.collection('users').doc(user.uid).set(user.toMap());

      print('✅ User profile created successfully');
    } catch (e) {
      print('❌ Error creating user profile: $e');
      print('❌ Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      print('🔵 Fetching user profile for UID: $uid');
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        print('✅ User profile found');
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return UserModel.fromMap(data);
      } else {
        print('⚠️ User profile not found');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      print('🔵 Updating user profile for UID: $uid');
      await _firestore.collection('users').doc(uid).update(data);
      print('✅ User profile updated successfully');
    } catch (e) {
      print('❌ Error updating user profile: $e');
      rethrow;
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      print('❌ Error deleting user profile: $e');
      rethrow;
    }
  }

  // Save health record (NEW METHOD)
  Future<void> saveHealthRecord(Map<String, dynamic> healthData) async {
    try {
      print('🔵 Saving health record to Firestore...');

      // Get current user ID from healthData
      String? userId = healthData['userId'] as String?;
      if (userId == null || userId.isEmpty) {
        print('❌ No userId found in health data');
        throw Exception('User ID is required to save health record');
      }

      // Add timestamp if not present
      if (!healthData.containsKey('timestamp')) {
        healthData['timestamp'] = DateTime.now().toIso8601String();
      }

      // Save to health_records collection
      await _firestore
          .collection('health_records')
          .doc()
          .set(healthData);

      print('✅ Health record saved successfully');
    } catch (e) {
      print('❌ Error saving health record: $e');
      print('❌ Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  // Get health records for a user
  Future<List<Map<String, dynamic>>> getHealthRecords(String userId) async {
    try {
      print('🔵 Fetching health records for user: $userId');

      QuerySnapshot snapshot = await _firestore
          .collection('health_records')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> records = snapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      print('✅ Found ${records.length} health records');
      return records;
    } catch (e) {
      print('❌ Error fetching health records: $e');
      return [];
    }
  }
}