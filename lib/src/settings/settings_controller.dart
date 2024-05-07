import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'settings_service.dart';

class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  final SettingsService _settingsService;

  late ThemeMode _themeMode;
  late List<String> _searchHistory;
  late Language _language;

  ThemeMode get themeMode => _themeMode;
  List<String> get searchHistory => _searchHistory;
  Language get language => _language;

  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _searchHistory = await _settingsService.searchHistory();
    _language = await _settingsService.language();
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;
    _themeMode = newThemeMode;
    notifyListeners();
    await _settingsService.updateThemeMode(newThemeMode);
  }

  Future<void> updateSearchHistory(List<String> newSearchHistory) async {
    if (newSearchHistory == _searchHistory) return;
    _searchHistory = newSearchHistory;
    notifyListeners();
    await _settingsService.updateSearchHistory(newSearchHistory);
  }

  Future<void> updateLanguage(
      BuildContext context, Language? newLanguage) async {
    if (newLanguage == null) return;
    if (newLanguage == _language) return;
    _language = newLanguage;
    notifyListeners();
    await _settingsService.updateLanguage(newLanguage);
    if (!context.mounted) return;
    await EasyLocalization.of(context)?.setLocale(Locale(newLanguage.name, ''));
  }
}
