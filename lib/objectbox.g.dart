// GENERATED CODE - DO NOT MODIFY BY HAND
// This code was generated by ObjectBox. To update it run the generator again:
// With a Flutter package, run `flutter pub run build_runner build`.
// With a Dart package, run `dart run build_runner build`.
// See also https://docs.objectbox.io/getting-started#generate-objectbox-code

// ignore_for_file: camel_case_types, depend_on_referenced_packages
// coverage:ignore-file

import 'dart:typed_data';

import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'
    as obx_int; // generated code can access "internal" functionality
import 'package:objectbox/objectbox.dart' as obx;
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

import 'src/food_list/food_item.dart';

export 'package:objectbox/objectbox.dart'; // so that callers only have to import this file

final _entities = <obx_int.ModelEntity>[
  obx_int.ModelEntity(
      id: const obx_int.IdUid(2, 785625037113331970),
      name: 'FoodItem',
      lastPropertyId: const obx_int.IdUid(11, 8045023228361403586),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 6880699874258645301),
            name: 'barcode',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 3429851204135421155),
            name: 'productionDate',
            type: 10,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 3004748824203648497),
            name: 'name',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 440494540905450820),
            name: 'location',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 1050663383077809616),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(7, 4354415216741452803),
            name: 'shelfLife',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(8, 3000630801495338639),
            name: 'shelfLifeUnitIndex',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(10, 8657617901754435673),
            name: 'imageId',
            type: 11,
            flags: 520,
            indexId: const obx_int.IdUid(2, 8557041446375813089),
            relationTarget: 'FoodImage'),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(11, 8045023228361403586),
            name: 'kindIndex',
            type: 6,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(3, 4399451452550884965),
      name: 'FoodImage',
      lastPropertyId: const obx_int.IdUid(2, 8577180915537925897),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 3149552173221309877),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 8577180915537925897),
            name: 'image',
            type: 23,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[])
];

/// Shortcut for [Store.new] that passes [getObjectBoxModel] and for Flutter
/// apps by default a [directory] using `defaultStoreDirectory()` from the
/// ObjectBox Flutter library.
///
/// Note: for desktop apps it is recommended to specify a unique [directory].
///
/// See [Store.new] for an explanation of all parameters.
///
/// For Flutter apps, also calls `loadObjectBoxLibraryAndroidCompat()` from
/// the ObjectBox Flutter library to fix loading the native ObjectBox library
/// on Android 6 and older.
Future<obx.Store> openStore(
    {String? directory,
    int? maxDBSizeInKB,
    int? maxDataSizeInKB,
    int? fileMode,
    int? maxReaders,
    bool queriesCaseSensitiveDefault = true,
    String? macosApplicationGroup}) async {
  await loadObjectBoxLibraryAndroidCompat();
  return obx.Store(getObjectBoxModel(),
      directory: directory ?? (await defaultStoreDirectory()).path,
      maxDBSizeInKB: maxDBSizeInKB,
      maxDataSizeInKB: maxDataSizeInKB,
      fileMode: fileMode,
      maxReaders: maxReaders,
      queriesCaseSensitiveDefault: queriesCaseSensitiveDefault,
      macosApplicationGroup: macosApplicationGroup);
}

/// Returns the ObjectBox model definition for this project for use with
/// [Store.new].
obx_int.ModelDefinition getObjectBoxModel() {
  final model = obx_int.ModelInfo(
      entities: _entities,
      lastEntityId: const obx_int.IdUid(3, 4399451452550884965),
      lastIndexId: const obx_int.IdUid(2, 8557041446375813089),
      lastRelationId: const obx_int.IdUid(0, 0),
      lastSequenceId: const obx_int.IdUid(0, 0),
      retiredEntityUids: const [3511392915814559695],
      retiredIndexUids: const [2897447790740984793],
      retiredPropertyUids: const [
        4347389526527401443,
        5950787551962424345,
        5440004278180372648,
        3451878046990469289,
        713245602490420950,
        4789846676784205074,
        7358805984737454826
      ],
      retiredRelationUids: const [],
      modelVersion: 5,
      modelVersionParserMinimum: 5,
      version: 1);

  final bindings = <Type, obx_int.EntityDefinition>{
    FoodItem: obx_int.EntityDefinition<FoodItem>(
        model: _entities[0],
        toOneRelations: (FoodItem object) => [object.image],
        toManyRelations: (FoodItem object) => {},
        getId: (FoodItem object) => object.id,
        setId: (FoodItem object, int id) {
          object.id = id;
        },
        objectToFB: (FoodItem object, fb.Builder fbb) {
          final barcodeOffset =
              object.barcode == null ? null : fbb.writeString(object.barcode!);
          final nameOffset =
              object.name == null ? null : fbb.writeString(object.name!);
          final locationOffset = object.location == null
              ? null
              : fbb.writeString(object.location!);
          fbb.startTable(12);
          fbb.addOffset(0, barcodeOffset);
          fbb.addInt64(1, object.productionDate?.millisecondsSinceEpoch);
          fbb.addOffset(3, nameOffset);
          fbb.addOffset(4, locationOffset);
          fbb.addInt64(5, object.id);
          fbb.addInt64(6, object.shelfLife);
          fbb.addInt64(7, object.shelfLifeUnitIndex);
          fbb.addInt64(9, object.image.targetId);
          fbb.addInt64(10, object.kindIndex);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final productionDateValue =
              const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 6);
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 14, 0);
          final barcodeParam = const fb.StringReader(asciiOptimization: true)
              .vTableGetNullable(buffer, rootOffset, 4);
          final productionDateParam = productionDateValue == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(productionDateValue);
          final shelfLifeParam =
              const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 16);
          final shelfLifeUnitIndexParam =
              const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 18);
          final nameParam = const fb.StringReader(asciiOptimization: true)
              .vTableGetNullable(buffer, rootOffset, 10);
          final locationParam = const fb.StringReader(asciiOptimization: true)
              .vTableGetNullable(buffer, rootOffset, 12);
          final kindIndexParam =
              const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 24);
          final object = FoodItem(
              id: idParam,
              barcode: barcodeParam,
              productionDate: productionDateParam,
              shelfLife: shelfLifeParam,
              shelfLifeUnitIndex: shelfLifeUnitIndexParam,
              name: nameParam,
              location: locationParam,
              kindIndex: kindIndexParam);
          object.image.targetId =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 22, 0);
          object.image.attach(store);
          return object;
        }),
    FoodImage: obx_int.EntityDefinition<FoodImage>(
        model: _entities[1],
        toOneRelations: (FoodImage object) => [],
        toManyRelations: (FoodImage object) => {},
        getId: (FoodImage object) => object.id,
        setId: (FoodImage object, int id) {
          object.id = id;
        },
        objectToFB: (FoodImage object, fb.Builder fbb) {
          final imageOffset = fbb.writeListInt8(object.image);
          fbb.startTable(3);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, imageOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          final imageParam = const fb.Uint8ListReader(lazy: false)
              .vTableGet(buffer, rootOffset, 6, Uint8List(0)) as Uint8List;
          final object = FoodImage(id: idParam, image: imageParam);

          return object;
        })
  };

  return obx_int.ModelDefinition(model, bindings);
}

/// [FoodItem] entity fields to define ObjectBox queries.
class FoodItem_ {
  /// see [FoodItem.barcode]
  static final barcode =
      obx.QueryStringProperty<FoodItem>(_entities[0].properties[0]);

  /// see [FoodItem.productionDate]
  static final productionDate =
      obx.QueryDateProperty<FoodItem>(_entities[0].properties[1]);

  /// see [FoodItem.name]
  static final name =
      obx.QueryStringProperty<FoodItem>(_entities[0].properties[2]);

  /// see [FoodItem.location]
  static final location =
      obx.QueryStringProperty<FoodItem>(_entities[0].properties[3]);

  /// see [FoodItem.id]
  static final id =
      obx.QueryIntegerProperty<FoodItem>(_entities[0].properties[4]);

  /// see [FoodItem.shelfLife]
  static final shelfLife =
      obx.QueryIntegerProperty<FoodItem>(_entities[0].properties[5]);

  /// see [FoodItem.shelfLifeUnitIndex]
  static final shelfLifeUnitIndex =
      obx.QueryIntegerProperty<FoodItem>(_entities[0].properties[6]);

  /// see [FoodItem.image]
  static final image =
      obx.QueryRelationToOne<FoodItem, FoodImage>(_entities[0].properties[7]);

  /// see [FoodItem.kindIndex]
  static final kindIndex =
      obx.QueryIntegerProperty<FoodItem>(_entities[0].properties[8]);
}

/// [FoodImage] entity fields to define ObjectBox queries.
class FoodImage_ {
  /// see [FoodImage.id]
  static final id =
      obx.QueryIntegerProperty<FoodImage>(_entities[1].properties[0]);

  /// see [FoodImage.image]
  static final image =
      obx.QueryByteVectorProperty<FoodImage>(_entities[1].properties[1]);
}
