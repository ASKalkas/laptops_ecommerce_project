// ignore: file_names
import 'package:flutter/material.dart';

class FilterForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilter;

  const FilterForm({super.key, required this.onApplyFilter});

  @override
  // ignore: library_private_types_in_public_api
  _FilterFormState createState() => _FilterFormState();
}

class _FilterFormState extends State<FilterForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _selectedBrands = [];
  final List<String> _selectedCPUs = [];
  final List<String> _selectedGPUs = [];
  RangeValues _priceRange = const RangeValues(0, 50000);
  RangeValues _storageRange = const RangeValues(64, 4000);
  RangeValues _ramRange = const RangeValues(4, 48);

  final List<int> _allowedValues = [64, 128, 256, 512, 1000, 2000, 3000, 4000];

  bool _intelChecked = false;
  bool _amdProcessorChecked = false;
  bool _nvidiaChecked = false;
  bool _amdGpuChecked = false;
  bool _appleChecked = false;
  bool _microChecked = false;
  bool _asusChecked = false;

  double _mapValueToSlider(double value) {
    return _allowedValues.indexOf(value.round()) + 0.0;
  }

  double _mapSliderToValue(double value) {
    return _allowedValues[value.round()].toDouble();
  }

  String getStorage(double storage) {
    switch (storage) {
      case >= 4000:
        return "4 TB";
      case >= 3000:
        return "3 TB";
      case >= 2000:
        return "2 TB";
      case >= 1000:
        return "1 TB";
      case >= 512:
        return "512 GB";
      case >= 256:
        return "256 GB";
      case >= 128:
        return "128 GB";
      default:
        return "64 GB";
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    return Form(
      key: _formKey,
      child: Container(
        height: screenHeight, // Take up 80% of the screen height
        padding: EdgeInsets.only(
            top: (105 / 640) * screenHeight, left: (15 / 360) * screenWidth),
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: (330 / 360) * screenWidth,
                height: (485 / 640) * screenHeight,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 10,
                      offset: Offset(0, 10),
                      spreadRadius: 10,
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              left: (6 / 360) * screenWidth,
              top: (16 / 640) * screenHeight,
              child: const Text(
                'Price Range',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            Positioned(
              left: (9 / 360) * screenWidth,
              top: (20 / 640) * screenHeight,
              child: SizedBox(
                width: (308 / 360) * screenWidth,
                child: SliderTheme(
                  data: const SliderThemeData(
                      rangeThumbShape: CircleThumbShape(thumbRadius: 5),
                      trackHeight: 1,
                      activeTrackColor: Colors.black,
                      inactiveTrackColor: Colors.grey,
                      trackShape: RectangularSliderTrackShape()),
                  child: RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 50000,
                    divisions: 100,
                    labels: RangeLabels(
                      _priceRange.start.round().toString(),
                      _priceRange.end.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              left: (9 / 360) * screenWidth,
              top: (51 / 640) * screenHeight,
              child: const Text(
                '0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            Positioned(
              left: (281 / 360) * screenWidth,
              top: (51 / 640) * screenHeight,
              child: const Text(
                '50,0000',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            Positioned(
              left: (9 / 360) * screenWidth,
              top: (70 / 640) * screenHeight,
              child: const Text(
                'Processor:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            Positioned(
              left: (20 / 360) * screenWidth,
              top: (95 / 640) * screenHeight,
              child: const Text(
                'Intel',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            Positioned(
              left: (300 / 360) * screenWidth,
              top: (95 / 640) * screenHeight,
              child: SizedBox(
                width: 10,
                height: 10,
                child: Checkbox(
                  value: _intelChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _intelChecked = value!;
                      if (value) {
                        _selectedCPUs.add("intel");
                      } else {
                        _selectedCPUs.remove("intel");
                      }
                    });
                  },
                  activeColor: Colors.black,
                  checkColor: Colors.white,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            Positioned(
              left: (20 / 360) * screenWidth,
              top: (120 / 640) * screenHeight,
              child: const Text(
                'AMD',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            Positioned(
              left: (300 / 360) * screenWidth,
              top: (120 / 640) * screenHeight,
              child: SizedBox(
                width: 10,
                height: 10,
                child: Checkbox(
                  value: _amdProcessorChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _amdProcessorChecked = value!;
                      if (value) {
                        _selectedCPUs.add("amd");
                      } else {
                        _selectedCPUs.remove("amd");
                      }
                    });
                  },
                  activeColor: Colors.black,
                  checkColor: Colors.white,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            Positioned(
              left: (9 / 360) * screenWidth,
              top: (150 / 640) * screenHeight,
              child: const Text(
                'RAM:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            Positioned(
              left: (9 / 360) * screenWidth,
              top: (154 / 640) * screenHeight,
              child: SizedBox(
                width: (308 / 360) * screenWidth,
                child: SliderTheme(
                  data: const SliderThemeData(
                      rangeThumbShape: CircleThumbShape(thumbRadius: 5),
                      trackHeight: 1,
                      activeTrackColor: Colors.black,
                      inactiveTrackColor: Colors.grey,
                      trackShape: RectangularSliderTrackShape()),
                  child: RangeSlider(
                    values: _ramRange,
                    min: 4,
                    max: 48,
                    divisions: 11,
                    labels: RangeLabels(
                      _ramRange.start.round().toString(),
                      _ramRange.end.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _ramRange = values;
                      });
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              left: (14 / 360) * screenWidth,
              top: (190 / 640) * screenHeight,
              child: const Text(
                '4 GB',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            Positioned(
              left: (291 / 360) * screenWidth,
              top: (190 / 640) * screenHeight,
              child: const Text(
                '48 GB',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            Positioned(
              left: (9 / 360) * screenWidth,
              top: (220 / 640) * screenHeight,
              child: const Text(
                'Storage:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            Positioned(
              left: (9 / 360) * screenWidth,
              top: (224 / 640) * screenHeight,
              child: SizedBox(
                width: (308 / 360) * screenWidth,
                child: SliderTheme(
                  data: const SliderThemeData(
                      rangeThumbShape: CircleThumbShape(thumbRadius: 5),
                      trackHeight: 1,
                      activeTrackColor: Colors.black,
                      inactiveTrackColor: Colors.grey,
                      trackShape: RectangularSliderTrackShape()),
                  child: RangeSlider(
                    values: RangeValues(
                      _mapValueToSlider(_storageRange.start),
                      _mapValueToSlider(_storageRange.end),
                    ),
                    min: 0,
                    max: (_allowedValues.length - 1).toDouble(),
                    divisions: _allowedValues.length - 1,
                    labels: RangeLabels(
                      getStorage(_storageRange.start),
                      getStorage(_storageRange.end),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _storageRange = RangeValues(
                          _mapSliderToValue(values.start),
                          _mapSliderToValue(values.end),
                        );
                      });
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              left: (14 / 360) * screenWidth,
              top: (260 / 640) * screenHeight,
              child: const Text(
                '32 GB',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            Positioned(
              left: (291 / 360) * screenWidth,
              top: (260 / 640) * screenHeight,
              child: const Text(
                '4 TB',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            Positioned(
              left: (9 / 360) * screenWidth,
              top: (285 / 640) * screenHeight,
              child: const Text(
                'GPU: ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            Positioned(
              left: (20 / 360) * screenWidth,
              top: (310 / 640) * screenHeight,
              child: const Text(
                'Nvidia',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            Positioned(
              left: (300 / 360) * screenWidth,
              top: (310 / 640) * screenHeight,
              child: SizedBox(
                width: 10,
                height: 10,
                child: Checkbox(
                  value: _nvidiaChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _nvidiaChecked = value!;
                      if (value) {
                        _selectedGPUs.add("nvidia");
                      } else {
                        _selectedGPUs.remove("nvidia");
                      }
                    });
                  },
                  activeColor: Colors.black,
                  checkColor: Colors.white,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            Positioned(
              left: (20 / 360) * screenWidth,
              top: (330 / 640) * screenHeight,
              child: const Text(
                'AMD',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            Positioned(
              left: (300 / 360) * screenWidth,
              top: (330 / 640) * screenHeight,
              child: SizedBox(
                width: 10,
                height: 10,
                child: Checkbox(
                  value: _amdGpuChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _amdGpuChecked = value!;
                      if (value) {
                        _selectedGPUs.add("amd");
                      } else {
                        _selectedGPUs.remove("amd");
                      }
                    });
                  },
                  activeColor: Colors.black,
                  checkColor: Colors.white,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            Positioned(
              left: (9 / 360) * screenWidth,
              top: (365 / 640) * screenHeight,
              child: const Text(
                'Brand: ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            Positioned(
              left: (20 / 360) * screenWidth,
              top: (390 / 640) * screenHeight,
              child: const Text(
                'Lenovo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            Positioned(
              left: (300 / 360) * screenWidth,
              top: (390 / 640) * screenHeight,
              child: SizedBox(
                width: 10,
                height: 10,
                child: Checkbox(
                  value: _appleChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _appleChecked = value!;
                      if (value) {
                        _selectedBrands.add("Lenovo");
                      } else {
                        _selectedBrands.remove("Lenovo");
                      }
                    });
                  },
                  activeColor: Colors.black,
                  checkColor: Colors.white,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            Positioned(
              left: (20 / 360) * screenWidth,
              top: (410 / 640) * screenHeight,
              child: const Text(
                'Microsoft',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            Positioned(
              left: (300 / 360) * screenWidth,
              top: (410 / 640) * screenHeight,
              child: SizedBox(
                width: 10,
                height: 10,
                child: Checkbox(
                  value: _microChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _microChecked = value!;
                      if (value) {
                        _selectedBrands.add("microsoft");
                      } else {
                        _selectedBrands.remove("microsoft");
                      }
                    });
                  },
                  activeColor: Colors.black,
                  checkColor: Colors.white,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            Positioned(
              left: (20 / 360) * screenWidth,
              top: (430 / 640) * screenHeight,
              child: const Text(
                'Asus',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            Positioned(
              left: (300 / 360) * screenWidth,
              top: (430 / 640) * screenHeight,
              child: SizedBox(
                width: 10,
                height: 10,
                child: Checkbox(
                  value: _asusChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _asusChecked = value!;
                      if (value) {
                        _selectedBrands.add("asus");
                      } else {
                        _selectedBrands.remove("asus");
                      }
                    });
                  },
                  activeColor: Colors.black,
                  checkColor: Colors.white,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            Positioned(
              left: (65 / 360) * screenWidth,
              top: (450 / 640) * screenHeight,
              child: Container(
                width: (90 / 360) * screenWidth,
                height: (27 / 640) * screenHeight,
                decoration: ShapeDecoration(
                  color: const Color(0xFF181E1F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: FloatingActionButton(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    onPressed: () => {
                          Navigator.pop(context),
                          widget.onApplyFilter({
                            "brand": _selectedBrands,
                            "cpu": _selectedCPUs,
                            "gpu": _selectedGPUs,
                            "ram": _ramRange,
                            "storage": _storageRange,
                            "price": _priceRange,
                          })
                        },
                    child: const Text("apply")),
              ),
            ),
            Positioned(
              left: (175 / 360) * screenWidth,
              top: (450 / 640) * screenHeight,
              child: Container(
                width: (90 / 360) * screenWidth,
                height: (27 / 640) * screenHeight,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: Colors.black, // Set the border color
                      width: 2, // Set the border width
                    ),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: FloatingActionButton(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    onPressed: () => {
                          Navigator.pop(context),
                          widget.onApplyFilter({}),
                        },
                    child: const Text("cancel", style: TextStyle(color: Colors.black),)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircleThumbShape extends RangeSliderThumbShape {
  const CircleThumbShape({this.thumbRadius = 10.0});

  final double thumbRadius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required SliderThemeData sliderTheme,
    bool? isDiscrete,
    bool? isEnabled,
    bool? isOnTop,
    TextDirection? textDirection,
    Thumb? thumb,
    bool? isPressed,
  }) {
    final Canvas canvas = context.canvas;

    final Paint fillPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 0
      ..style = PaintingStyle.stroke;

    canvas
      ..drawCircle(center, thumbRadius, fillPaint)
      ..drawCircle(center, thumbRadius, borderPaint);
  }
}
