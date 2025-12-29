import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/focusSessions.dart';

class FocusSessionStorage {
  static const String _key = "focus_sessions";

  Future<void> saveSession(FocusSession session) async {
    final prefs = await SharedPreferences.getInstance();

    final existing = prefs.getStringList(_key) ?? [];
    existing.add(jsonEncode(session.toJson()));

    await prefs.setStringList(_key, existing);
  }

  Future<List<FocusSession>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];

    return data
        .map((e) => FocusSession.fromJson(jsonDecode(e)))
        .toList();
  }
}
