import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:howismyfood/main.dart';
import 'package:howismyfood/src/extensions/date_time_extension.dart';
import 'package:howismyfood/src/food_detail/food_detail_view.dart';
import 'package:howismyfood/src/food_list/food_item.dart';

class FoodListTile extends ListTile {
  FoodListTile(Map? selected, BuildContext context, FoodItem item,
      Function(BuildContext, FoodItem) foodItemOnTap,
      {super.key})
      : super(
          title: Text(item.name!),
          subtitle: item.location?.isEmpty ?? true
              ? const Text('produced_on')
                  .tr(args: [item.productionDate!.format()])
              : const Text('stored_in').tr(args: [item.location!]),
          leading: selected?[item.id]! == true
              ? CircleAvatar(
                  backgroundColor: Theme.of(context).hintColor,
                  child: const Icon(Icons.check),
                )
              : CircleAvatar(
                  child: Icon(item.kindIndex == null
                      ? Icons.category_outlined
                      : FoodKind.values[item.kindIndex!].icon),
                ),
          trailing:
              Text(item.isExpired! ? 'expired_status' : 'unexpired_status')
                  .tr(args: [item.daysToExpiration.toString()]),
          onTap: () async => foodItemOnTap(context, item),
        );

  static Future<void> foodItemOnTap(BuildContext context, FoodItem item) async {
    var foodItem = await Navigator.pushNamed(
      context,
      FoodDetailView.routeName,
      arguments: item,
    );
    if (foodItem != null) {
      await foodBox.putAsync(foodItem as FoodItem);
    }
  }
}
