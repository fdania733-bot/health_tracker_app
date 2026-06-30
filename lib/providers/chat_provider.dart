import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final bool isFromUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isFromUser,
    required this.timestamp,
  });
}

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _userName = 'User';
  int _userAge = 25;
  String _userGender = 'not specified';
  double _userBmi = 0;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  void initializeChat({
    required String name,
    required int age,
    required String gender,
    required double bmi,
  }) {
    _userName = name;
    _userAge = age;
    _userGender = gender;
    _userBmi = bmi;

    // Clear any existing messages
    _messages.clear();

    // Add welcome message
    _messages.add(ChatMessage(
      text: 'Hello $_userName! 👋 I\'m your AI Health Coach. I can help you with fitness tips, nutrition advice, and answer any health-related questions. How can I help you today?',
      isFromUser: false,
      timestamp: DateTime.now(),
    ));

    notifyListeners();
    print('✅ Chat initialized for $_userName');
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    _messages.add(ChatMessage(
      text: message,
      isFromUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    // Simulate AI thinking
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    // Generate AI response
    String aiResponse = _generateAIResponse(message);

    // Add AI response
    _messages.add(ChatMessage(
      text: aiResponse,
      isFromUser: false,
      timestamp: DateTime.now(),
    ));

    _isLoading = false;
    notifyListeners();
  }

  String _generateAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    // Simple keyword-based responses
    if (message.contains('hello') || message.contains('hi')) {
      return 'Hi $_userName! How are you feeling today? 😊';
    }

    if (message.contains('weight') || message.contains('lose')) {
      return 'For healthy weight loss, I recommend:\n\n1. Eat a balanced diet with plenty of vegetables\n2. Exercise at least 30 minutes daily\n3. Drink 8 glasses of water\n4. Get 7-8 hours of sleep\n\nBased on your BMI of ${_userBmi.toStringAsFixed(1)}, you\'re doing great! Keep it up! 💪';
    }

    if (message.contains('exercise') || message.contains('workout')) {
      return 'Great question! Here\'s a simple workout plan:\n\n🏃 Cardio: 20-30 min walking/jogging\n💪 Strength: 3x per week\n🧘 Flexibility: Daily stretching\n\nStart slow and increase gradually. Consistency is key!';
    }

    if (message.contains('sleep') || message.contains('tired')) {
      return 'Sleep is crucial for health! Tips:\n\n1. Keep a consistent sleep schedule\n2. Avoid screens 1 hour before bed\n3. Keep your room cool and dark\n4. Limit caffeine after 2 PM\n\nAim for 7-9 hours per night for optimal health! 😴';
    }

    if (message.contains('water') || message.contains('hydrat')) {
      return 'Staying hydrated is essential! 💧\n\n• Drink at least 8 glasses (2L) daily\n• More if you exercise\n• Drink before you feel thirsty\n• Eat water-rich foods like fruits\n\nI see you\'re tracking your water intake - keep it up!';
    }

    if (message.contains('bmi') || message.contains('weight')) {
      if (_userBmi > 0) {
        String category;
        if (_userBmi < 18.5) category = 'underweight';
        else if (_userBmi < 25) category = 'normal';
        else if (_userBmi < 30) category = 'overweight';
        else category = 'obese';

        return 'Your BMI is ${_userBmi.toStringAsFixed(1)}, which is in the $category range. ${_userBmi >= 18.5 && _userBmi < 25 ? "That's great! Keep maintaining your healthy lifestyle!" : "I can help you work towards a healthier range."}';
      }
      return 'To calculate your BMI, please update your height and weight in your profile settings.';
    }

    if (message.contains('diet') || message.contains('food') || message.contains('eat')) {
      return 'Healthy eating tips:\n\n🥗 Fill half your plate with vegetables\n🍗 Include lean protein\n🍚 Choose whole grains\n🥑 Add healthy fats\n🍎 Snack on fruits\n\nAvoid processed foods and sugary drinks. Small changes add up!';
    }

    if (message.contains('stress') || message.contains('anxiety') || message.contains('mental')) {
      return 'Mental health is just as important! Try:\n\n🧘 Meditation or deep breathing\n🚶 Nature walks\n📵 Digital detox periods\n😴 Quality sleep\n👥 Social connections\n\nRemember: It\'s okay to ask for professional help when needed. 💙';
    }

    // Default response
    return 'That\'s a great question, $_userName! As your AI Health Coach, I recommend focusing on:\n\n1. Regular physical activity\n2. Balanced nutrition\n3. Adequate sleep\n4. Stress management\n\nWould you like specific advice on any of these areas?';
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}