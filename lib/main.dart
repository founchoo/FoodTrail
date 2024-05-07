import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:howismyfood/objectbox.g.dart';

import 'objectbox.dart';
import 'src/app.dart';
import 'src/food_list/food_item.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

late CameraDescription firstCamera;

late Box<FoodItem> foodBox;
late Box<FoodImage> foodImageBox;

late SettingsController settingsController;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  ObjectBox objectbox = await ObjectBox.create();
  foodBox = Box<FoodItem>(objectbox.store);
  foodImageBox = Box<FoodImage>(objectbox.store);

  final cameras = await availableCameras();
  firstCamera = cameras.first;

  settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  runApp(
    EasyLocalization(
        supportedLocales: Language.values
            .map((language) => Locale(language.name, ''))
            .toList(),
        path: 'assets/translations',
        fallbackLocale: Locale(Language.values.first.name, ''),
        child: const MyApp()),
  );
}
