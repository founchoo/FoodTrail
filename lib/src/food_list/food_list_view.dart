import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:howismyfood/main.dart';
import 'package:howismyfood/src/components/listtile.dart';
import 'package:howismyfood/src/food_list/food_item.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../settings/settings_view.dart';
import '../food_search/food_search_delegate.dart';

class FoodListView extends StatefulWidget {
  const FoodListView({super.key});

  static const routeName = '/';

  @override
  FoodListViewState createState() => FoodListViewState();
}

class FoodListViewState extends State<FoodListView> {
  late Stream<List<FoodItem>> foodListStream;
  Map<int, bool> selected = {};

  DateTime? currentBackPressTime;
  bool canPopNow = false;
  int requiredSeconds = 2;

  @override
  void initState() {
    super.initState();
    setState(() {
      foodListStream = foodBox
          .query()
          .watch(triggerImmediately: true)
          .map((query) => query.find());
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPopNow,
      onPopInvoked: onPopInvoked,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('food_list_title')),
          actions: selected.values.contains(true)
              ? [
                  IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('delete_food_msg').tr(),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('cancel').tr(),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      List<int> idsToRemove = selected.entries
                                          .where((element) => element.value)
                                          .map((e) => e.key)
                                          .toList();
                                      setState(() {
                                        for (var id in idsToRemove) {
                                          foodBox.remove(id);
                                          selected.remove(id);
                                        }
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: const Text('confirm').tr(),
                                  ),
                                ],
                              );
                            });
                      },
                      icon: const Icon(Icons.delete_outline)),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          if (selected.values.contains(false)) {
                            selected.updateAll((key, value) => true);
                          } else {
                            selected.updateAll((key, value) => false);
                          }
                        });
                      },
                      icon: const Icon(Icons.select_all_outlined))
                ]
              : [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      showSearch(
                          context: context, delegate: FoodSearchDelegate());
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      Navigator.pushNamed(context, SettingsView.routeName);
                    },
                  ),
                ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async =>
              FoodListTile.foodItemOnTap(context, FoodItem(id: 0)),
          child: const Icon(Icons.add),
        ),
        body: StreamBuilder(
            stream: foodListStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var foodList = snapshot.data as List<FoodItem>;
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: foodList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = foodList[index];
                    selected.putIfAbsent(item.id, () => false);
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        child: Column(
                          children: [
                            FoodListTile(selected, context, item,
                                FoodListTile.foodItemOnTap),
                            LinearProgressIndicator(
                              color: item.isExpired!
                                  ? Colors.red.shade700
                                  : Colors.green.shade700,
                              value: item.daysAfterProduction!.toDouble() /
                                  item.shelfLifeInDays!.toDouble(),
                            )
                          ],
                        ),
                        onLongPress: () {
                          setState(() {
                            selected.update(item.id, (value) => !value);
                          });
                        },
                      ),
                    );
                  },
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }

  void onPopInvoked(bool didPop) {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) >
            Duration(seconds: requiredSeconds)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'exit_warning'.tr());
      Future.delayed(
        Duration(seconds: requiredSeconds),
        () {
          // Disable pop invoke and close the toast after 2s timeout
          setState(() {
            canPopNow = false;
          });
          Fluttertoast.cancel();
        },
      );
      // Ok, let user exit app on the next back press
      setState(() {
        canPopNow = true;
      });
    }
  }
}
