import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/components/buttons.dart';
import '/components/input.dart';
import '/util/colors.dart';
import '/util/api.dart';

class AddTurf extends StatefulWidget {
  const AddTurf({super.key});

  @override
  State<AddTurf> createState() => _AddTurfState();
}

class _AddTurfState extends State<AddTurf> {

  final _formKey = GlobalKey<FormState>();

  late final int id;
  final nameController = TextEditingController();
  File? _selectedImage;
  String? selectedArea;
  final addressController = TextEditingController();
  final lengthController = TextEditingController();
  final widthController = TextEditingController();
  final mapLinkController = TextEditingController();
  final openingTimeController = TextEditingController();
  final closingTimeController = TextEditingController();
  final pricePerHourController = TextEditingController();
  final upiController = TextEditingController();
  final phoneController = TextEditingController();
  TimeOfDay? openingTime;
  TimeOfDay? closingTime;

  Future<void> getId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final tempId = prefs.getInt("id");
    setState(() {
      id=tempId!;
    });
    print(id);
  }

  final areas = ["Vesu", "Adajan", "Pal"];

  String _formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hour.toString().padLeft(2, '0');
    final minute = tod.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00'; // Manually adding :00 for seconds
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> selectOpeningTime(BuildContext ctx) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: ctx,
      initialTime: openingTime ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      setState(() {
        openingTime = pickedTime;
        openingTimeController.text = _formatTimeOfDay(openingTime!);
      });
    }
  }

  Future<void> selectClosingTime(BuildContext ctx) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: ctx,
      initialTime: closingTime ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      setState(() {
        closingTime = pickedTime;
        closingTimeController.text = _formatTimeOfDay(closingTime!);
      });
    }
  }

  final amenitiesList = [
    'Parking',
    'Cafeteria',
    'Drinking water',
    'Changing room',
    'Washrooms',
    'First aid',
    'Bat',
    'Balls',
    'Stumps',
    'Seating area',
    'Flood lights',
  ];
  List<String> selectedAmenities = [];

  void addTurfBTNClick() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // area not selected warning
    if (selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an area")),
      );
      return;
    }

    // empty amenity warning
    if (selectedAmenities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one amenity")),
      );
      return;
    }

    try {
      final response = addTurf(
        turfOwnerId: id,
        name: nameController.text.trim(),
        imageFile: _selectedImage,
        area: selectedArea!,
        fullAddress: addressController.text.trim(),
        length: int.parse(lengthController.text.trim()),
        width: int.parse(widthController.text.trim()),
        googleMapLink: mapLinkController.text.trim(),
        openingTime: openingTimeController.text.trim(),
        closingTime: closingTimeController.text.trim(),
        pricePerHour: int.parse(pricePerHourController.text.trim()),
        upi: upiController.text.trim(),
        phone: phoneController.text.trim(),
        amenities: selectedAmenities,
      );
      print(response);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Turf added successfully!")),
      );
      Navigator.of(context).pop();
    } on Exception catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    getId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BMTTheme.black,
      appBar: AppBar(
        title: Text("Add New Turf", style: TextStyle(fontSize: 18)),
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Input(
                    controller: nameController,
                    hint: "Enter turf name",
                    type: TextInputType.text,
                    validator: (val) => val == null || val.trim().isEmpty ? "Turf Name is required" : null,
                  ),
                  SizedBox(height: 12),

                  if (_selectedImage == null)
                    InkWell(
                      splashColor: Colors.transparent,
                      onTap: _pickImage,
                      child: DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          radius: Radius.circular(12),
                          color: BMTTheme.white50,
                          // strokeWidth: 2,
                          dashPattern: [10, 5],
                        ),
                        child: SizedBox(
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            spacing: 12,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.not_interested, size: 36),
                              Text(
                                "No image selected",
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  if (_selectedImage != null)
                    SizedBox(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: ClipRRect(
                        borderRadius: BorderRadiusGeometry.all(
                          Radius.circular(12),
                        ),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
                    ),

                  SizedBox(height: 12),

                  InputDecorator(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      filled: true,
                      fillColor: BMTTheme.background,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: BMTTheme.brand),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      hintText: 'Select Area',
                      hintStyle: TextStyle(color: BMTTheme.white50),
                    ),
                    isEmpty: selectedArea == null,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedArea,
                        isExpanded: true,
                        dropdownColor: BMTTheme.background,
                        elevation: 8,
                        iconEnabledColor: BMTTheme.white50,
                        style: TextStyle(color: Colors.white),
                        items: areas.map((area) => DropdownMenuItem(
                          value: area,
                          child: Text(area, style: TextStyle(fontFamily: 'Parkinsans'),),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedArea = value;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  Input(
                    controller: addressController,
                    hint: "Enter turf address",
                    type: TextInputType.multiline,
                    validator: (val) => val == null || val.trim().isEmpty ? "Turf address is required" : null,
                  ),
                  SizedBox(height: 12),

                  Input(
                    controller: lengthController,
                    hint: "Enter turf length(ft)",
                    type: TextInputType.number,
                    validator: (val) => val == null || val.trim().isEmpty ? "Turf length is required" : null,
                  ),
                  SizedBox(height: 12),

                  Input(
                    controller: widthController,
                    hint: "Enter turf width(ft)",
                    type: TextInputType.number,
                    validator: (val) => val == null || val.trim().isEmpty ? "Turf width is required" : null,
                  ),
                  SizedBox(height: 12),

                  Input(
                    controller: mapLinkController,
                    hint: "Enter turf map link",
                    type: TextInputType.url,
                    //validator: (val) => val == null || val.trim().isEmpty ? "Turf map link is required" : null,
                  ),
                  SizedBox(height: 12),

                  TextFormField(
                    validator: (val) => val == null || val.trim().isEmpty ? "Turf opening time is required" : null,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: openingTimeController,
                    readOnly: true,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12, // Adjusted padding for better visual
                        horizontal: 16,
                      ),
                      filled: true,
                      fillColor: BMTTheme.background,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: BMTTheme.brand),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      hintText: 'Select opening time',
                      hintStyle: TextStyle(color: BMTTheme.white50),
                      suffixIcon: Icon(
                        Icons.access_time,
                        color: BMTTheme.white50,
                      ), // Added icon
                    ),
                    onTap: () => selectOpeningTime(context),
                    onTapOutside: (e) => FocusScope.of(context).unfocus(),
                  ),
                  SizedBox(height: 12),

                  TextFormField(
                    validator: (val) => val == null || val.trim().isEmpty ? "Turf closing time is required" : null,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: closingTimeController,
                    readOnly: true,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16,),
                      filled: true,
                      fillColor: BMTTheme.background,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: BMTTheme.brand),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      hintText: 'Select closing time',
                      hintStyle: TextStyle(color: BMTTheme.white50),
                      suffixIcon: Icon(
                        Icons.access_time,
                        color: BMTTheme.white50,
                      ),
                    ),
                    onTap: () => selectClosingTime(
                      context,
                    ), // Corrected to call selectClosingTime
                    onTapOutside: (e) => FocusScope.of(context).unfocus(),
                  ),
                  SizedBox(height: 12),

                  Input(
                    controller: pricePerHourController,
                    hint: "Enter price per hour",
                    type: TextInputType.number,
                    validator: (val){
                      if (val == null || val.trim().isEmpty) {
                        return "Price per hour is required";
                      } else if (int.tryParse(val.trim())! < 100) {
                        return "Price per hour should be at least 100";
                      }
                    },
                  ),
                  SizedBox(height: 12),

                  Input(
                    controller: upiController,
                    hint: "Enter UPI ID",
                    type: TextInputType.text,
                    validator: (val) => val == null || val.trim().isEmpty ? "UPI ID is required" : null,
                  ),
                  SizedBox(height: 12),

                  Input(
                    controller: phoneController,
                    hint: "Enter phone number",
                    type: TextInputType.phone,
                    validator: (val){
                      if (val == null || val.trim().isEmpty) {
                        return "Phone number is required";
                      } else if (val.trim().length != 10) {
                        return "Phone number must be 10 digits";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  Text("Amenities", style: TextStyle(fontSize: 18)),

                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Wrap(
                      children: amenitiesList.map((amn) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              activeColor: BMTTheme.brand,
                              value: selectedAmenities.contains(amn),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    selectedAmenities.add(amn);
                                  } else {
                                    selectedAmenities.remove(amn);
                                  }
                                });
                                print(selectedAmenities);
                              },
                            ),
                            Text(amn),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  Button(text: "Add Turf", onClick: addTurfBTNClick),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
