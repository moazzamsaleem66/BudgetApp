import 'package:shared_preferences/shared_preferences.dart';

class IntroPrefs {
  static const _hasSeenIntroKey = 'has_seen_intro_v1';

  static Future<bool> hasSeenIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenIntroKey) ?? false;
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenIntroKey, true);
  }
}
