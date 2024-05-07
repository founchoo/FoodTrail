import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:howismyfood/main.dart';
import 'package:howismyfood/src/components/listtile.dart';

import '../food_list/food_item.dart';

class FoodSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, "");
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> history = settingsController.searchHistory;
    if (query.isNotEmpty) {
      int existedIndex = history.indexOf(query);
      if (existedIndex >= 0) {
        history.removeAt(existedIndex);
      }
      history.insert(0, query);
    }
    if (history.length > 5) {
      history.removeLast();
    }
    settingsController.updateSearchHistory(history);
    List<FoodItem> result = foodBox
        .getAll()
        .where((element) => element.matchesQuery(query))
        .toList();
    if (result.isEmpty) {
      return ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.search_off),
            title: const Text('search_no_result').tr(args: [query]),
          )
        ],
      );
    } else {
      return ListView.builder(
        itemCount: result.length,
        itemBuilder: (BuildContext context, int index) {
          return FoodListTile(
              null, context, result[index], FoodListTile.foodItemOnTap);
        },
      );
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> history = settingsController.searchHistory;
    if (history.isEmpty) {
      return ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.history_toggle_off_outlined),
            title: const Text('no_search_history').tr(),
          )
        ],
      );
    } else {
      return ListView.builder(
        itemCount: history.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == history.length) {
            return ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('clear_search_history').tr(),
              onTap: () {
                settingsController.updateSearchHistory([]);
              },
            );
          } else {
            String historyQuery = history[index];
            return ListTile(
                title: Text(historyQuery),
                leading: const Icon(Icons.history_outlined),
                onTap: () {
                  query = historyQuery;
                  showResults(context);
                });
          }
        },
      );
    }
  }
}
