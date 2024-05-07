import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:howismyfood/main.dart';
import 'package:howismyfood/src/food_detail/food_detail_view.dart';

import 'food_list/food_item.dart';
import 'food_list/food_list_view.dart';
import 'settings/settings_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          onGenerateTitle: (BuildContext context) => 'title'.tr(),
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  case FoodDetailView.routeName:
                    return FoodDetailView(
                        foodItem: routeSettings.arguments as FoodItem);
                  case FoodListView.routeName:
                  default:
                    return const FoodListView();
                }
              },
            );
          },
        );
      },
    );
  }
}
