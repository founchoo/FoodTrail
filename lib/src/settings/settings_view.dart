import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'settings_controller.dart';
import 'settings_service.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('settings_title').tr(),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('theme_mode').tr(),
            trailing: DropdownButton<ThemeMode>(
              underline: const SizedBox(),
              value: controller.themeMode,
              onChanged: controller.updateThemeMode,
              items: ThemeMode.values
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.name).tr(),
                      ))
                  .toList(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('language').tr(),
            trailing: DropdownButton<Language>(
              underline: const SizedBox(),
              value: controller.language,
              onChanged: (value) async {
                await controller.updateLanguage(context, value);
              },
              items: Language.values
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.description),
                      ))
                  .toList(),
            ),
          ),
          AboutListTile(
            applicationName: 'title'.tr(),
            icon: const Icon(Icons.info_outline),
            applicationVersion: '1.0.0',
            applicationIcon: Card(
              clipBehavior: Clip.antiAlias,
              child: CircleAvatar(child: Image.asset('assets/images/logo.png')),
            ),
            aboutBoxChildren: [
              const Text('slogan').tr(),
              const Text(
                '© 2024 founchoo',
                style: TextStyle(fontSize: 12),
              )
            ],
          ),
        ],
      ),
    );
  }
}
