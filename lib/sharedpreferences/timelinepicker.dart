import 'package:shared_preferences/shared_preferences.dart';

class TimelinePicker {
  static const _keyTimeline = "timeline";

  /// Simpan timeline ke SharedPreferences
  static Future<void> saveTimeline(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTimeline, value);
  }

  /// Ambil timeline dari SharedPreferences
  static Future<String?> loadTimeline() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTimeline);
  }
}


