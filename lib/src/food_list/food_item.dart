import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:howismyfood/src/extensions/date_time_extension.dart';
import 'package:objectbox/objectbox.dart';
import 'package:howismyfood/objectbox.g.dart';
import 'package:material_symbols_icons/symbols.dart';

enum ShelfLifeUnit {
  day,
  month,
  year;

  int get days {
    switch (this) {
      case ShelfLifeUnit.day:
        return 1;
      case ShelfLifeUnit.month:
        return 30;
      case ShelfLifeUnit.year:
        return 365;
    }
  }

  String get description {
    switch (this) {
      case ShelfLifeUnit.day:
        return 'days'.tr();
      case ShelfLifeUnit.month:
        return 'months'.tr();
      case ShelfLifeUnit.year:
        return 'years'.tr();
    }
  }
}

enum FoodKind {
  fruits,
  vegetables,
  meat,
  fish,
  grains,
  dairy,
  eggs,
  other;

  IconData get icon {
    switch (this) {
      case FoodKind.fruits:
        return Symbols.nutrition_rounded;
      case FoodKind.vegetables:
        return Icons.eco_outlined;
      case FoodKind.meat:
        return Icons.kebab_dining_outlined;
      case FoodKind.fish:
        return Icons.set_meal_outlined;
      case FoodKind.grains:
        return Icons.grain_outlined;
      case FoodKind.dairy:
        return Symbols.grocery_rounded;
      case FoodKind.eggs:
        return Icons.egg_alt_outlined;
      case FoodKind.other:
        return Icons.local_dining_outlined;
    }
  }

  String get description {
    switch (this) {
      case FoodKind.fruits:
        return 'fruits'.tr();
      case FoodKind.vegetables:
        return 'vegetables'.tr();
      case FoodKind.eggs:
        return 'eggs'.tr();
      case FoodKind.other:
        return 'other'.tr();
      case FoodKind.fish:
        return 'fish'.tr();
      case FoodKind.meat:
        return 'meat'.tr();
      case FoodKind.grains:
        return 'grains'.tr();
      case FoodKind.dairy:
        return 'dairy'.tr();
    }
  }
}

@Entity()
class FoodItem {
  @Id()
  int id;

  String? barcode;

  @Property(type: PropertyType.date)
  DateTime? productionDate;

  int? shelfLife;
  int? shelfLifeUnitIndex;
  String? name;
  String? location;
  int? kindIndex;

  final image = ToOne<FoodImage>();

  FoodItem({
    required this.id,
    this.barcode,
    this.productionDate,
    this.shelfLife,
    this.shelfLifeUnitIndex,
    this.name,
    this.location,
    this.kindIndex,
  });

  ShelfLifeUnit? get shelfLifeUnit {
    if (shelfLifeUnitIndex == null) return null;
    return ShelfLifeUnit.values[shelfLifeUnitIndex!];
  }

  int? get shelfLifeInDays {
    if (shelfLife == null || shelfLifeUnit == null) return null;
    return shelfLife! * shelfLifeUnit!.days;
  }

  int? get daysToExpiration {
    if (expirationDate == null) return null;
    return DateTime.now().difference(expirationDate!).inDays.abs();
  }

  int? get daysAfterProduction {
    if (productionDate == null) return null;
    return DateTime.now().difference(productionDate!).inDays;
  }

  DateTime? get expirationDate {
    if (productionDate == null || shelfLife == null || shelfLifeUnit == null) {
      return null;
    }
    return productionDate!.add(Duration(days: shelfLifeInDays!));
  }

  bool? get isExpired {
    if (expirationDate == null) return null;
    return DateTime.now().isAfter(expirationDate!);
  }

  bool matchesQuery(String query) {
    query = query.toLowerCase().trim();
    return query.isNotEmpty &&
        ((name != null && name!.toLowerCase().contains(query)) ||
            (barcode != null && barcode!.contains(query)) ||
            (location != null && location!.toLowerCase().contains(query)) ||
            (kindIndex != null &&
                FoodKind.values[kindIndex!].description
                    .toLowerCase()
                    .contains(query)) ||
            (productionDate != null &&
                productionDate!.format().contains(query)) ||
            (expirationDate != null &&
                expirationDate!.format().contains(query)) ||
            (shelfLife != null && shelfLife!.toString().contains(query)));
  }

  bool equals(FoodItem? other) {
    if (other == null) return false;
    return id == other.id &&
        barcode == other.barcode &&
        productionDate == other.productionDate &&
        shelfLife == other.shelfLife &&
        shelfLifeUnitIndex == other.shelfLifeUnitIndex &&
        name == other.name &&
        location == other.location &&
        kindIndex == other.kindIndex;
  }

  void assign(FoodItem? other) {
    barcode = other?.barcode;
    productionDate = other?.productionDate;
    shelfLife = other?.shelfLife;
    shelfLifeUnitIndex = other?.shelfLifeUnitIndex;
    name = other?.name;
    location = other?.location;
    kindIndex = other?.kindIndex;
  }

  static FoodItem empty() {
    return FoodItem(id: 0);
  }
}

@Entity()
class FoodImage {
  @Id()
  int id;

  Uint8List image;

  FoodImage({required this.id, required this.image});
}
