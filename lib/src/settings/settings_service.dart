import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Language {
  en,
  zh;

  String get description {
    switch (this) {
      case Language.en:
        return 'English';
      case Language.zh:
        return '中文';
    }
  }
}

class SettingsService {
  final String themeModeKey = 'theme';
  final String searchHistoryKey = 'search_history';
  final String languageKey = 'language';

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<ThemeMode> themeMode() async => ThemeMode
      .values[(await _prefs).getInt(themeModeKey) ?? ThemeMode.system.index];

  Future<List<String>> searchHistory() async =>
      (await _prefs).getStringList(searchHistoryKey) ?? [];

  Future<Language> language() async =>
      Language.values[(await _prefs).getInt(languageKey) ?? Language.en.index];

  Future<void> updateThemeMode(ThemeMode theme) async {
    await (await _prefs).setInt(themeModeKey, theme.index);
  }

  Future<void> updateSearchHistory(List<String> history) async {
    await (await _prefs).setStringList(searchHistoryKey, history);
  }

  Future<void> updateLanguage(Language language) async {
    await (await _prefs).setInt(languageKey, language.index);
  }
}
