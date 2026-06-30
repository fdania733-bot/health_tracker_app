class UserModel {
  final String uid;
  final String name;
  final String? nickname;
  final String email;
  final int age;
  final String gender;
  final DateTime createdAt;
  final double? heightCm;
  final double? weightKg;
  final bool profileComplete;

  UserModel({
    required this.uid,
    required this.name,
    this.nickname,
    required this.email,
    required this.age,
    required this.gender,
    required this.createdAt,
    this.heightCm,
    this.weightKg,
    this.profileComplete = false,
  });

  // BMI Getter - Calculate BMI from height and weight
  double? get bmi {
    if (heightCm == null || weightKg == null || heightCm == 0) return null;
    final heightInMeters = heightCm! / 100;
    return weightKg! / (heightInMeters * heightInMeters);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'nickname': nickname,
      'email': email,
      'age': age,
      'gender': gender,
      'createdAt': createdAt.toIso8601String(),
      'heightCm': heightCm,
      'weightKg': weightKg,
      'profileComplete': profileComplete,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? 'User',
      nickname: map['nickname'],
      email: map['email'] ?? '',
      age: map['age'] ?? 25,
      gender: map['gender'] ?? 'not specified',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      heightCm: map['heightCm']?.toDouble(),
      weightKg: map['weightKg']?.toDouble(),
      profileComplete: map['profileComplete'] ?? false,
    );
  }
}