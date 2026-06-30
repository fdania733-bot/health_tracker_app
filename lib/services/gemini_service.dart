import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  // ✅ YOUR NEW API KEY IS ADDED HERE
  final String _apiKey = 'AQ.Ab8RN6I9UKmOKpXXgM9qODtg7FlHpTEgbKenio7CWSp8cg8ANQ';

  Future<String> getHealthAdvice({
    required int steps,
    required double heartRate,
    required double sleepHours,
    required double bmi,
    required String gender,
    required int age,
    required int moodScore,
  }) async {
    try {
      if (_apiKey.isEmpty || _apiKey.length < 10) {
        return '⚠️ API Key is missing. Please add your key in gemini_service.dart';
      }

      final prompt = '''
You are an expert AI Health Coach. 
CRITICAL INSTRUCTION: You MUST strictly tailor your tone, vocabulary, and recommendations based on the user's specific demographics and current mood.

USER DEMOGRAPHICS:
- Age: $age years old
- Gender: $gender
- Current Mood: $moodScore out of 5 (1=Very Sad/Stressed, 5=Very Happy/Energetic)

TODAY'S HEALTH DATA:
- Steps: $steps
- Heart Rate: ${heartRate > 0 ? '${heartRate.toInt()} BPM' : 'Not available'}
- Sleep: ${sleepHours > 0 ? '${sleepHours.toStringAsFixed(1)} hours' : 'Not available'}
- BMI: ${bmi > 0 ? bmi.toStringAsFixed(1) : 'Not available'}

YOUR TASK:
Provide 3-4 short, highly personalized bullet points. 
1. If the user is young (18-30), focus on high-energy fitness, muscle recovery, and building habits.
2. If the user is older (40+), focus on joint health, heart health, stress management, and moderate activity.
3. If the user is female, subtly consider hormonal impacts on energy, iron levels, and cycle tracking.
4. If the user is male, focus on cardiovascular endurance, strength, and metabolic health.
5. If their Mood is low (1-2), be highly empathetic, gentle, and focus on mental well-being and rest.
6. If their Mood is high (4-5), be highly motivational and push them to challenge their physical limits.

Keep the tone friendly, conversational, and easy to understand. Avoid complex medical jargon.
''';

      // ✅ USING THE MOST STABLE MODEL (gemini-1.5-flash)
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey',
      );

      print(' Sending request to Gemini API...');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 500,
          }
        }),
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      print(' API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        try {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          print('✅ AI Response received successfully');
          return text;
        } catch (e) {
          print('❌ Error parsing response: $e');
          return '⚠️ Received response but couldn\'t parse it. Please try again.';
        }
      } else if (response.statusCode == 400) {
        print('❌ Bad Request: ${response.body}');
        return '⚠️ Invalid request. Please check your API key and try again.';
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('❌ Auth Error: ${response.body}');
        return '⚠️ API Key is invalid, expired, or restricted. Please get a NEW key from https://aistudio.google.com/apikey';
      } else if (response.statusCode == 404) {
        print('❌ Not Found: ${response.body}');
        return '️ AI Model not found. The API key might be restricted or the model is unavailable in your region. Try getting a new key.';
      } else if (response.statusCode == 429) {
        print('❌ Rate Limit Exceeded');
        return '️ Too many requests. Please wait a minute and try again.';
      } else {
        print('❌ Unexpected error: ${response.statusCode} - ${response.body}');
        return '⚠️ Failed to get AI response. Status: ${response.statusCode}';
      }
    } catch (e) {
      print('❌ Gemini API Error: $e');
      if (e.toString().contains('SocketException')) {
        return '⚠️ No internet connection. Please check your network.';
      } else if (e.toString().contains('timeout')) {
        return '⚠️ Request timed out. Please check your internet and try again.';
      }
      return '⚠️ Error: ${e.toString()}';
    }
  }

  int calculateHealthScore({
    required int steps,
    required double heartRate,
    required double sleepHours,
    required double bmi,
    required int moodScore,
  }) {
    int score = 50;

    if (steps >= 10000) {
      score += 20;
    } else if (steps >= 5000) {
      score += 10;
    } else if (steps > 0) {
      score += (steps / 10000 * 10).toInt();
    }

    if (sleepHours >= 7 && sleepHours <= 9) {
      score += 15;
    } else if (sleepHours > 0) {
      score += 5;
    }

    if (heartRate >= 60 && heartRate <= 100) {
      score += 10;
    } else if (heartRate > 0) {
      score += 5;
    }

    if (bmi >= 18.5 && bmi <= 24.9) {
      score += 5;
    } else if (bmi > 0) {
      score += 2;
    }

    score += (moodScore - 3) * 3;

    return score > 100 ? 100 : (score < 0 ? 0 : score);
  }

  List<String> generateInsights({
    required int steps,
    required double heartRate,
    required double sleepHours,
    required double bmi,
    required int moodScore,
  }) {
    List<String> insights = [];

    if (steps < 3000) {
      insights.add('You\'re quite sedentary today. Try to move more!');
    } else if (steps < 7000) {
      insights.add('Good activity level! Aim for 10,000 steps for optimal health.');
    } else if (steps >= 10000) {
      insights.add('Excellent! You\'re crushing your step goal! 🎉');
    }

    if (sleepHours > 0) {
      if (sleepHours < 6) {
        insights.add('You got less sleep than recommended. Try to get 7-9 hours.');
      } else if (sleepHours > 9) {
        insights.add('You slept more than average. Make sure you\'re getting quality rest.');
      } else {
        insights.add('Great sleep duration! Keep it up! 😴');
      }
    }

    if (heartRate > 0) {
      if (heartRate > 100) {
        insights.add('Your heart rate is elevated. Consider resting and hydrating.');
      } else if (heartRate < 60) {
        insights.add('Your resting heart rate is low - good sign of cardiovascular fitness!');
      } else {
        insights.add('Your heart rate is in the normal range. ❤️');
      }
    }

    if (moodScore <= 2) {
      insights.add('Your mood seems low today. Consider some light exercise or meditation.');
    } else if (moodScore >= 4) {
      insights.add('Great mood today! Channel that energy into a challenging workout!');
    }

    if (insights.isEmpty) {
      insights.add('Keep tracking your health data for personalized insights!');
    }

    return insights;
  }
}