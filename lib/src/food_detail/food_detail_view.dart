import 'dart:io';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:howismyfood/main.dart';
import 'package:howismyfood/src/components/decoration.dart';
import 'package:howismyfood/src/components/sizedbox.dart';
import 'package:howismyfood/src/extensions/date_time_extension.dart';
import 'package:howismyfood/src/extensions/string_extension.dart';
import 'package:howismyfood/src/food_list/food_item.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

// ignore: must_be_immutable
class FoodDetailView extends StatefulWidget {
  @override
  FoodDetailViewState createState() => FoodDetailViewState();

  static const routeName = '/detail';

  FoodItem foodItem;

  FoodDetailView({Key? key, required this.foodItem}) : super(key: key);
}

class FoodDetailViewState extends State<FoodDetailView> {
  bool isNew = true;
  static const int _defaultDays = 365 * 100;

  final DateTime _fallbackProdDate =
      DateTime.now().subtract(const Duration(days: _defaultDays));
  final DateTime _fallbackExpyDate =
      DateTime.now().add(const Duration(days: _defaultDays));

  final TextEditingController _foodNameTextController = TextEditingController();
  final TextEditingController _foodLocationTextController =
      TextEditingController();
  final TextEditingController _foodBarcodeTextController =
      TextEditingController();
  final TextEditingController _prodDateTextController = TextEditingController();
  final TextEditingController _shelfLifeTextController =
      TextEditingController();
  final TextEditingController _expyDateTextController = TextEditingController();

  int? _selectedShelfLifeUnitIndex;
  int? _selectedKindIndex;

  bool canPopNow = false;

  // Camera related
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool isPhotoTaken = false;
  String photoPath = '';
  bool showCameraPreview = false;
  String barcode = '';
  FlashMode flashMode = FlashMode.off;
  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };
  final objectDetector = ObjectDetector(
      options: ObjectDetectorOptions(
          mode: DetectionMode.stream,
          classifyObjects: true,
          multipleObjects: false));
  String predictedFoodName = '';

  final shelfLifeUnitItems = ShelfLifeUnit.values
      .map((e) => DropdownMenuItem<int>(
            value: e.index,
            child: Text(e.description),
          ))
      .toList();

  final formKey = GlobalKey<FormState>();

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas
    final sensorOrientation = firstCamera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (firstCamera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }

  Future<void> detectFood(CameraImage image) async {
    final List<DetectedObject> objects =
        await objectDetector.processImage(_inputImageFromCameraImage(image)!);

    for (DetectedObject detectedObject in objects) {
      for (Label label in detectedObject.labels) {
        setState(() {
          predictedFoodName = label.text;
        });
      }
    }
  }

  Future<void> prodTextFieldOnTap() async {
    DateTime? selectedExpyDate = _expyDateTextController.text.parse();
    DateTime? selectedProdDate = await showDatePicker(
      context: context,
      firstDate: _fallbackProdDate,
      lastDate: selectedExpyDate == null
          ? DateTime.now()
          : selectedExpyDate.compareTo(DateTime.now()) < 0
              ? selectedExpyDate
              : DateTime.now(),
    );
    if (selectedProdDate != null) {
      setState(() {
        _prodDateTextController.text = selectedProdDate.format();
        if (selectedExpyDate != null) {
          _shelfLifeTextController.text =
              (selectedExpyDate.difference(selectedProdDate).inDays).toString();
          widget.foodItem.shelfLife = int.parse(_shelfLifeTextController.text);
          _selectedShelfLifeUnitIndex = ShelfLifeUnit.day.index;
          widget.foodItem.shelfLifeUnitIndex = _selectedShelfLifeUnitIndex;
        }
      });
    }
  }

  Future<void> expyTextFieldOnTap() async {
    DateTime? selectedProdDate = _prodDateTextController.text.parse();
    DateTime? selectedExpyDate = await showDatePicker(
      context: context,
      firstDate: selectedProdDate ?? _fallbackProdDate,
      lastDate: _fallbackExpyDate,
    );
    if (selectedExpyDate != null) {
      setState(() {
        _expyDateTextController.text = selectedExpyDate.format();
        if (selectedProdDate != null) {
          _shelfLifeTextController.text =
              (selectedExpyDate.difference(selectedProdDate).inDays).toString();
          widget.foodItem.shelfLife = int.parse(_shelfLifeTextController.text);
          _selectedShelfLifeUnitIndex = ShelfLifeUnit.day.index;
          widget.foodItem.shelfLifeUnitIndex = _selectedShelfLifeUnitIndex;
        }
      });
    }
  }

  void shelfLifeOnChanged(String value) {
    widget.foodItem.shelfLife = int.tryParse(value);
    if (value.isNotEmpty && _selectedShelfLifeUnitIndex != null) {
      DateTime? prodDateTime = _prodDateTextController.text.parse();
      if (prodDateTime != null) {
        setState(() {
          _expyDateTextController.text = prodDateTime
              .add(Duration(
                  days: int.parse(value) *
                      ShelfLifeUnit.values[_selectedShelfLifeUnitIndex!].days))
              .format();
        });
      }
    }
  }

  void shelfLifeUnitOnChanged(int? value) {
    widget.foodItem.shelfLifeUnitIndex = value;
    if (value != null) {
      setState(() {
        _selectedShelfLifeUnitIndex = value;
      });
      if (_shelfLifeTextController.text.isNotEmpty) {
        DateTime? prodDateTime = _prodDateTextController.text.parse();
        if (prodDateTime != null) {
          setState(() {
            _expyDateTextController.text = prodDateTime
                .add(Duration(
                    days: int.parse(_shelfLifeTextController.text) *
                        ShelfLifeUnit
                            .values[_selectedShelfLifeUnitIndex!].days))
                .format();
          });
        }
      }
    }
  }

  void kindOnChanged(int? value) {
    if (value != null) {
      widget.foodItem.kindIndex = value;
      setState(() {
        _selectedKindIndex = value;
      });
    }
  }

  Future<void> addFood() async {
    if (isPhotoTaken) {
      FoodImage foodImage = FoodImage(
        id: widget.foodItem.image.target?.id ?? 0,
        image: File(photoPath).readAsBytesSync(),
      );
      widget.foodItem.image.target = foodImage;
    } else if (widget.foodItem.image.target != null) {
      widget.foodItem.image.target = widget.foodItem.image.target;
    }
    Navigator.pop(context, widget.foodItem);
  }

  Future<void> initCamera() async {
    _initializeControllerFuture = _controller!.initialize().then((_) async {
      if (!mounted) {
        return;
      }
      await _controller!.startImageStream((image) async {
        Code result = await zx.processCameraImage(image);
        if (result.isValid) {
          setState(() {
            barcode = result.text!;
          });
        }
        await detectFood(image);
      });
    });
    await _initializeControllerFuture;
    zx.startCameraProcessing();
    await _controller!.setFlashMode(flashMode);
  }

  Future<void> disposeCamera() async {
    if (_controller == null) {
      return;
    }
    zx.stopCameraProcessing();
    await _controller!.stopImageStream();
    // _controller!.dispose();
    barcode = '';
  }

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    isNew = widget.foodItem.id == 0;
    setState(() {
      _foodNameTextController.text = widget.foodItem.name ?? '';
      _foodLocationTextController.text = widget.foodItem.location ?? '';
      _foodBarcodeTextController.text = widget.foodItem.barcode ?? '';
      _prodDateTextController.text =
          widget.foodItem.productionDate?.format() ?? '';
      _shelfLifeTextController.text = widget.foodItem.shelfLife == null
          ? ''
          : widget.foodItem.shelfLife.toString();
      _selectedShelfLifeUnitIndex = widget.foodItem.shelfLifeUnitIndex;
      _expyDateTextController.text =
          widget.foodItem.expirationDate?.format() ?? '';
      _selectedKindIndex = widget.foodItem.kindIndex;
    });
  }

  Future<void> onPopInvoked(bool didPop) async {
    FoodItem? record;
    if (didPop) return;
    if (widget.foodItem.id == 0) {
      if (widget.foodItem.equals(FoodItem.empty())) {
        Navigator.pop(context);
        return;
      }
    } else {
      record = foodBox.getMany([widget.foodItem.id]).first!;
      if (record.equals(widget.foodItem)) {
        Navigator.of(context).pop();
        return;
      }
    }
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('msg_title').tr(),
        content: const Text('back_on_unsaved_food').tr(),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('cancel').tr(),
          ),
          TextButton(
            onPressed: () {
              if (record != null) {
                widget.foodItem.assign(record);
              }
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('confirm').tr(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPopNow,
      onPopInvoked: onPopInvoked,
      child: Scaffold(
        appBar: AppBar(
          title: widget.foodItem.name == null
              ? const Text('new_food').tr()
              : Text(widget.foodItem.name!),
        ),
        body: Form(
          key: formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Food image
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(15.0), //or 15.0
                              child: isPhotoTaken
                                  ? buildPhotoTaken()
                                  : showCameraPreview
                                      ? buildCameraPreview()
                                      : buildPhotoPlaceholder(),
                            ),
                          ],
                        ),
                        const ThemedSizedBox(),

                        // Food barcode
                        TextFormField(
                          onChanged: (value) {
                            widget.foodItem.barcode = value;
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _foodBarcodeTextController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return null;
                            }
                            if (value.length != 8 &&
                                value.length != 12 &&
                                value.length != 13 &&
                                value.length != 14) {
                              return 'barcode_validator'.tr();
                            }
                            return null;
                          },
                          decoration: ThemedInputDecoration(
                            icon: Symbols.barcode,
                            labelText: 'food_barcode'.tr(),
                          ),
                        ),
                        const ThemedSizedBox(),

                        // Food name
                        TextFormField(
                          onChanged: (value) {
                            widget.foodItem.name = value;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _foodNameTextController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'food_name_validator'.tr();
                            }
                            return null;
                          },
                          decoration: ThemedInputDecoration(
                            icon: Icons.badge_outlined,
                            labelText: 'food_name'.tr(),
                          ),
                        ),
                        const ThemedSizedBox(),

                        // Food kind
                        DropdownButtonFormField<int>(
                          decoration: ThemedInputDecoration(
                            icon: _selectedKindIndex == null
                                ? Icons.category_outlined
                                : FoodKind.values[_selectedKindIndex!].icon,
                            labelText: 'food_kind'.tr(),
                          ),
                          value: _selectedKindIndex,
                          items: FoodKind.values
                              .map((e) => DropdownMenuItem<int>(
                                    value: e.index,
                                    child: Text(e.description),
                                  ))
                              .toList(),
                          onChanged: kindOnChanged,
                        ),
                        const ThemedSizedBox(),

                        // Food location
                        TextFormField(
                          onChanged: (value) {
                            widget.foodItem.location = value;
                          },
                          controller: _foodLocationTextController,
                          decoration: ThemedInputDecoration(
                            icon: Icons.location_on_outlined,
                            labelText: 'food_storage_location'.tr(),
                          ),
                        ),
                        const ThemedSizedBox(),

                        // Production date
                        TextFormField(
                          onChanged: (value) {
                            widget.foodItem.productionDate = value.parse();
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          readOnly: true,
                          controller: _prodDateTextController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'production_date_validator'.tr();
                            }
                            return null;
                          },
                          decoration: ThemedInputDecoration(
                            icon: Icons.start_outlined,
                            labelText: 'production_date'.tr(),
                          ),
                          onTap: prodTextFieldOnTap,
                        ),
                        const ThemedSizedBox(),

                        // Shelf life
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _shelfLifeTextController,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'shelf_life_validator'.tr();
                            }
                            return null;
                          },
                          decoration: ThemedInputDecoration(
                            icon: Icons.query_builder_outlined,
                            labelText: 'shelf_life'.tr(),
                          ),
                          onChanged: shelfLifeOnChanged,
                        ),
                        const ThemedSizedBox(),

                        // Shelf life unit
                        DropdownButtonFormField<int>(
                          decoration: ThemedInputDecoration(
                            icon: Icons.timelapse_outlined,
                            labelText: 'shelf_life_unit'.tr(),
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null) {
                              return 'shelf_life_unit_validator'.tr();
                            }
                          },
                          value: _selectedShelfLifeUnitIndex,
                          items: shelfLifeUnitItems,
                          onChanged: shelfLifeUnitOnChanged,
                        ),
                        const ThemedSizedBox(),

                        // Expiration date
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          readOnly: true,
                          controller: _expyDateTextController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'expiration_date_validator'.tr();
                            }
                            return null;
                          },
                          decoration: ThemedInputDecoration(
                            icon: Icons.last_page_outlined,
                            labelText: 'expiration_date'.tr(),
                          ),
                          onTap: expyTextFieldOnTap,
                        ),
                        const ThemedSizedBox(),
                        Row(
                          children: [
                            const Spacer(),
                            FilledButton(
                              onPressed: () async {
                                FormState? formState = formKey.currentState;
                                if (formState?.validate() == true) {
                                  await addFood();
                                }
                              },
                              child: Text(isNew ? 'add' : 'modify').tr(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCameraPreview() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture!,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CameraPreview(
            _controller!,
            child: Column(children: [
              const Spacer(),
              Row(
                children: [
                  const Spacer(),
                  ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          flashMode = flashMode == FlashMode.always
                              ? FlashMode.off
                              : FlashMode.always;
                        });
                        await _controller!.setFlashMode(flashMode);
                      },
                      child: Icon(flashMode == FlashMode.always
                          ? Icons.flashlight_on_outlined
                          : Icons.flashlight_off_outlined)),
                  const SizedBox(width: 5.0),
                  ElevatedButton(
                    child: const Icon(Icons.camera_alt_outlined),
                    onPressed: () async {
                      try {
                        final image = await _controller!.takePicture();
                        if (!context.mounted) {
                          return;
                        }
                        setState(() {
                          photoPath = image.path;
                          isPhotoTaken = true;
                          showCameraPreview = false;
                        });
                        await disposeCamera();
                      } catch (e) {}
                    },
                  ),
                  const SizedBox(width: 5.0),
                  ElevatedButton(
                    child: const Icon(Icons.cancel_outlined),
                    onPressed: () async {
                      setState(() {
                        showCameraPreview = false;
                      });
                      await disposeCamera();
                    },
                  ),
                  const SizedBox(width: 5),
                ],
              ),
              if (barcode.isNotEmpty)
                Card(
                  child: InkWell(
                    child: ListTile(
                      leading: const Icon(Symbols.barcode),
                      title:
                          const Text('recognized_barcode').tr(args: [barcode]),
                      subtitle: const Text('fill_barcode_field_msg').tr(),
                    ),
                    onTap: () {
                      setState(() {
                        _foodBarcodeTextController.text = barcode;
                        widget.foodItem.barcode = barcode;
                      });
                    },
                  ),
                ),
              if (predictedFoodName.isNotEmpty)
                Card(
                  child: InkWell(
                    child: ListTile(
                      leading: const Icon(Icons.food_bank_outlined),
                      title: const Text('recognized_food')
                          .tr(args: [predictedFoodName]),
                      subtitle: const Text('fill_food_name_field_msg').tr(),
                    ),
                    onTap: () {
                      setState(() {
                        _foodNameTextController.text = predictedFoodName;
                        widget.foodItem.name = predictedFoodName;
                      });
                    },
                  ),
                ),
            ]),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget buildPhotoTaken() {
    return Stack(
      children: [
        Image.file(
          File(photoPath),
        ),
        Positioned(
          right: 5,
          bottom: 0,
          child: ElevatedButton(
            child: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                isPhotoTaken = false;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildPhotoPlaceholder() {
    return widget.foodItem.image.target == null
        ? Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () async {
                await initCamera();
                setState(() {
                  showCameraPreview = true;
                });
              },
              child: ListTile(
                title: const Text(
                  'take_photo_scan_barcode_msg',
                  textAlign: TextAlign.center,
                ).tr(),
              ),
            ),
          )
        : Stack(
            children: [
              Image.memory(widget.foodItem.image.target!.image),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () async {
                      await initCamera();
                      setState(() {
                        showCameraPreview = true;
                      });
                    },
                    child: ListTile(
                      title: const Text(
                        'take_photo_scan_barcode_msg',
                        textAlign: TextAlign.center,
                      ).tr(),
                    ),
                  ),
                ),
              ),
            ],
          );
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }
    super.dispose();
  }
}
