import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import './Providers/authProvider.dart' as AuthProvider;
import './Providers/productsProvider.dart';
import './navBar.dart';

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  String? _selectedProcessor;
  String? _selectedBrand;
  String? _selectedGPU;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  double _priceSliderValue = 0;
  double _ramSliderValue = 4;
  final List<int> _storageValues = [
    32,
    64,
    128,
    256,
    512,
    1000,
    2000,
    3000,
    4000
  ];
  double _storageSliderIndex = 0;
  String? _vendorID;
  File? _image;

  void addItem() async {
    if (_selectedBrand == null ||
        _selectedGPU == null ||
        _selectedProcessor == null ||
        _titleController.text == "" ||
        _descriptionController.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing field/s'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      final productProvider =
          Provider.of<ProductsProvider>(context, listen: false);
      String successFailure = await productProvider.addItem({
        "brand": _selectedBrand,
        "gpu": _selectedGPU,
        "cpu": _selectedProcessor,
        "title": _titleController.text,
        "description": _descriptionController.text,
        "price": _priceSliderValue,
        "storage": _storageValues[_storageSliderIndex.round()],
        "ram": _ramSliderValue.round(),
        "Image": _image,
        "vendorID": _vendorID,
      });
      if (successFailure.toLowerCase() == 'success') {
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/cart');
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    final authProvider = Provider.of<AuthProvider.AuthenticationProvider>(
        context,
        listen: false);
    _vendorID = authProvider.userId;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Add Item to Stock",
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 0,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(1.00, 0.00),
              end: Alignment(-1, 0),
              colors: [Colors.white, Color.fromARGB(255, 48, 46, 46)],
            ),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                authProvider.signOut();
                authProvider.setUserID(null);
                Navigator.pushNamed(context, "/login");
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.black,
              )),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: (25 / 640) * screenHeight),
          SizedBox(
            width: (350 / 360) * screenWidth,
            height: (490 / 640) * screenHeight,
            child: Stack(
              children: [
                Positioned(
                  left: (50 / 360) * screenWidth,
                  top: (30 / 640) * screenHeight,
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        final image = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() {
                            _image = File(image.path);
                          });
                        }
                      } catch (e) {}
                    },
                    child: Container(
                      width: (120 / 360) * screenWidth,
                      height: (120 / 360) * screenWidth,
                      decoration: ShapeDecoration(
                        color: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              20.0), // Adjust the radius as needed
                          side: const BorderSide(
                              width: 1, color: Color(0xFF644F3E)),
                        ),
                      ),
                      child: Center(
                        child: _image == null
                            ? const Text(
                                'Click to upload Image',
                                textAlign: TextAlign.center,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Image.file(
                                  _image!,
                                  fit: BoxFit.cover,
                                  width: (120 / 360) * screenWidth,
                                  height: (120 / 360) * screenWidth,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: (185 / 360) * screenWidth,
                  top: (25 / 640) * screenHeight,
                  child: Container(
                    width: (130 / 360) * screenWidth,
                    height: (20 / 640) * screenHeight,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFD9D9D9),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          strokeAlign: BorderSide.strokeAlignOutside,
                          color: Colors.white.withOpacity(0),
                        ),
                        borderRadius: BorderRadius.circular(4),
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
                    child: TextField(
                      cursorColor: Colors.black,
                      textAlign: TextAlign.center,
                      controller: _titleController,
                      maxLength: 20,
                      decoration: InputDecoration(
                        hintText: 'Title',
                        contentPadding:
                            EdgeInsets.only(top: (5 / 640) * screenHeight),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                          fontSize:
                              12), // Adjust the font size to fit the container
                    ),
                  ),
                ),
                Positioned(
                  left: (185 / 360) * screenWidth,
                  top: (55 / 640) * screenHeight,
                  child: Container(
                    width: (130 / 360) * screenWidth,
                    height: (20 / 640) * screenHeight,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFD9D9D9),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          strokeAlign: BorderSide.strokeAlignOutside,
                          color: Colors.white.withOpacity(0),
                        ),
                        borderRadius: BorderRadius.circular(4),
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
                    child: Center(
                      child: DropdownButton<String>(
                        value: _selectedProcessor,
                        hint: const Text(
                          'Processor',
                          style: TextStyle(fontSize: 12),
                        ),
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                        elevation: 16,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 12),
                        underline: Container(
                          height: 0,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedProcessor = newValue;
                          });
                        },
                        items: <String>['Intel', 'AMD']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: (185 / 360) * screenWidth,
                  top: (85 / 640) * screenHeight,
                  child: Container(
                    width: (130 / 360) * screenWidth,
                    height: (20 / 640) * screenHeight,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFD9D9D9),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          strokeAlign: BorderSide.strokeAlignOutside,
                          color: Colors.white.withOpacity(0),
                        ),
                        borderRadius: BorderRadius.circular(4),
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
                    child: Center(
                      child: DropdownButton<String>(
                        value: _selectedBrand,
                        hint: const Text(
                          'Brand',
                          style: TextStyle(fontSize: 12),
                        ),
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                        elevation: 16,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 12),
                        underline: Container(
                          height: 0,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedBrand = newValue;
                          });
                        },
                        items: <String>['Asus', 'Lenovo', 'Microsoft']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: (185 / 360) * screenWidth,
                  top: (115 / 640) * screenHeight,
                  child: Container(
                    width: (130 / 360) * screenWidth,
                    height: (20 / 640) * screenHeight,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFD9D9D9),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          strokeAlign: BorderSide.strokeAlignOutside,
                          color: Colors.white.withOpacity(0),
                        ),
                        borderRadius: BorderRadius.circular(4),
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
                    child: Center(
                      child: DropdownButton<String>(
                        value: _selectedGPU,
                        hint: const Text(
                          'GPU',
                          style: TextStyle(fontSize: 12),
                        ),
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                        elevation: 16,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 12),
                        underline: Container(
                          height: 0,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGPU = newValue;
                          });
                        },
                        items: <String>['AMD', 'Nvidia']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: (45 / 360) * screenWidth,
                  top: (155 / 640) * screenHeight,
                  child: Container(
                    width: (270 / 360) * screenWidth,
                    height: (60 / 640) * screenHeight,
                    constraints: BoxConstraints(
                      maxWidth: (270 / 360) * screenWidth,
                    ),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFD9D9D9),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          strokeAlign: BorderSide.strokeAlignOutside,
                          color: Colors.white.withOpacity(0),
                        ),
                        borderRadius: BorderRadius.circular(4),
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
                    child: TextField(
                      textAlign: TextAlign.center,
                      cursorColor: Colors.black,
                      controller: _descriptionController,
                      textAlignVertical: TextAlignVertical.bottom,
                      maxLines: null,
                      maxLength: 200,
                      decoration: InputDecoration(
                        hintText: 'Description',
                        contentPadding:
                            EdgeInsets.only(bottom: (10 / 640) * screenHeight),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                          fontSize:
                              12), // Adjust the font size to fit the container
                    ),
                  ),
                ),
                Positioned(
                  left: (10 / 360) * screenWidth,
                  top: (245 / 640) * screenHeight,
                  child: const Text(
                    'Price',
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
                  top: (255 / 640) * screenHeight,
                  child: SizedBox(
                    width: (320 / 360) * screenWidth,
                    child: SliderTheme(
                      data: const SliderThemeData(
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 5),
                        thumbColor: Colors.black,
                        trackHeight: 1,
                        activeTrackColor: Colors.black,
                        inactiveTrackColor: Colors.grey,
                        trackShape: RectangularSliderTrackShape(),
                      ),
                      child: Slider(
                        value: _priceSliderValue,
                        min: 0,
                        max: 50000,
                        divisions: 500, // This will create steps of 100
                        label: _priceSliderValue.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            _priceSliderValue = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: (20 / 360) * screenWidth,
                  top: (290 / 640) * screenHeight,
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
                  left: (310 / 360) * screenWidth,
                  top: (290 / 640) * screenHeight,
                  child: const Text(
                    '50,000',
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
                  left: (10 / 360) * screenWidth,
                  top: (315 / 640) * screenHeight,
                  child: const Text(
                    'RAM',
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
                  top: (325 / 640) * screenHeight,
                  child: SizedBox(
                    width: (320 / 360) * screenWidth,
                    child: SliderTheme(
                      data: const SliderThemeData(
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 5),
                        thumbColor: Colors.black,
                        trackHeight: 1,
                        activeTrackColor: Colors.black,
                        inactiveTrackColor: Colors.grey,
                        trackShape: RectangularSliderTrackShape(),
                      ),
                      child: Slider(
                        value: _ramSliderValue,
                        min: 4,
                        max: 48,
                        divisions: 11, // This will create steps of 100
                        label: _ramSliderValue.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            _ramSliderValue = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: (20 / 360) * screenWidth,
                  top: (360 / 640) * screenHeight,
                  child: const Text(
                    '4GB',
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
                  left: (310 / 360) * screenWidth,
                  top: (360 / 640) * screenHeight,
                  child: const Text(
                    '48GB',
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
                  left: (10 / 360) * screenWidth,
                  top: (385 / 640) * screenHeight,
                  child: const Text(
                    'Storage',
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
                  top: (395 / 640) * screenHeight,
                  child: SizedBox(
                    width: (320 / 360) * screenWidth,
                    child: SliderTheme(
                      data: const SliderThemeData(
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 5),
                        thumbColor: Colors.black,
                        trackHeight: 1,
                        activeTrackColor: Colors.black,
                        inactiveTrackColor: Colors.grey,
                        trackShape: RectangularSliderTrackShape(),
                      ),
                      child: Slider(
                        value: _storageSliderIndex,
                        min: 0,
                        max: (_storageValues.length - 1).toDouble(),
                        divisions: _storageValues.length - 1,
                        label: _storageValues[_storageSliderIndex.round()]
                            .toString(),
                        onChanged: (double value) {
                          setState(() {
                            _storageSliderIndex = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: (20 / 360) * screenWidth,
                  top: (430 / 640) * screenHeight,
                  child: const Text(
                    '32GB',
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
                  left: (310 / 360) * screenWidth,
                  top: (430 / 640) * screenHeight,
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
                  left: (135 / 360) * screenWidth,
                  top: (460 / 640) * screenHeight,
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
                        onPressed: addItem,
                        child: const Text("Add Item")),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const NavBar(),
    );
  }
}
