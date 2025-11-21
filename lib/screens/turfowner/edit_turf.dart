import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '/components/buttons.dart';
import '/components/input.dart';
import '/util/colors.dart';
import '/util/api.dart';
import '/model/turf.dart';

class EditTurf extends StatefulWidget {
  final Turf turf;
  const EditTurf({super.key, required this.turf});

  @override
  State<EditTurf> createState() => _EditTurfState();
}

class _EditTurfState extends State<EditTurf> {
  final _formKey = GlobalKey<FormState>();

  File? newImage;
  late String oldImage;

  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final mapCtrl = TextEditingController();
  final lengthCtrl = TextEditingController();
  final widthCtrl = TextEditingController();
  final openCtrl = TextEditingController();
  final closeCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final upiCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  TimeOfDay? openingTime;
  TimeOfDay? closingTime;

  final areas = ["Vesu", "Adajan", "Pal"];
  String? selectedArea;

  List<String> amenitiesList = [
    'Parking', 'Cafeteria', 'Drinking water', 'Changing room',
    'Washrooms', 'First aid', 'Bat', 'Balls', 'Stumps',
    'Seating area', 'Flood lights'
  ];
  List<String> selectedAmenities = [];

  @override
  void initState() {
    super.initState();

    final t = widget.turf;

    nameCtrl.text = t.name;
    addressCtrl.text = t.fullAddress;
    mapCtrl.text = t.mapLink ?? "";
    lengthCtrl.text = t.length.toString();
    widthCtrl.text = t.width.toString();
    openCtrl.text = t.openingTime;
    closeCtrl.text = t.closingTime;
    priceCtrl.text = t.pricePerHour.toString();
    upiCtrl.text = t.upi;
    phoneCtrl.text = t.phone.toString();

    selectedArea = t.area;
    selectedAmenities = t.amenities;

    oldImage = t.image; // save old image name
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hour.toString().padLeft(2, '0');
    final minute = tod.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00'; // Manually adding :00 for seconds
  }

  Future<void> pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => newImage = File(img.path));
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
        openCtrl.text = _formatTimeOfDay(openingTime!);
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
        closeCtrl.text = _formatTimeOfDay(closingTime!);
      });
    }
  }

  void updateTurfBTNClick() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final res = await updateTurf(
        id: widget.turf.id,
        name: nameCtrl.text.trim(),
        area: selectedArea!,
        fullAddress: addressCtrl.text.trim(),
        mapLink: mapCtrl.text.trim(),
        pricePerHour: int.parse(priceCtrl.text.trim()),
        length: int.parse(lengthCtrl.text.trim()),
        width: int.parse(widthCtrl.text.trim()),
        openingTime: openCtrl.text,
        closingTime: closeCtrl.text,
        phone: phoneCtrl.text.trim(),
        amenities: selectedAmenities,
        oldImage: widget.turf.image,
        imageFile: newImage, // nullable
      );
      if (res['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Turf updated successfully!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Update failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BMTTheme.black,
        title: Text("Delete Turf?", style: TextStyle(color: Colors.white)),
        content: Text("Are you sure you want to delete this turf permanently?",
          style: TextStyle(color: BMTTheme.white50),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: BMTTheme.white50)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final response = await deleteTurf(widget.turf.id);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(response['message'])),
              );

              if (response['status'] == 'success') {
                // setState(() {}); // refresh list
                Navigator.pop(context);
              }
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BMTTheme.black,
      appBar: AppBar(
        title: Text("Edit Turf"),
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Input(
                  controller: nameCtrl,
                  hint: "Turf Name",
                  type: TextInputType.text,
                  validator: (val) => val == null || val.trim().isEmpty ? "Turf Name is required" : null,
                ),
                SizedBox(height: 12),

                // Image Picker
                GestureDetector(
                  onTap: pickImage,
                  child: newImage == null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network("$API/turfImages/$oldImage",
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(newImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 12),

                // Area dropdown
                DropdownButtonFormField(
                  value: selectedArea,
                  dropdownColor: BMTTheme.black,
                  items: areas.map((a) {
                    return DropdownMenuItem(value: a, child: Text(a));
                  }).toList(),
                  onChanged: (val) => setState(() => selectedArea = val),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: BMTTheme.background,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 12),

                Input(
                  controller: addressCtrl,
                  hint: "Full Address",
                  type: TextInputType.streetAddress,
                  validator: (val) => val == null || val.trim().isEmpty ? "Turf address is required" : null,
                ),
                SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: Input(
                        controller: lengthCtrl,
                        hint: "Length (ft)",
                        type: TextInputType.number,
                        validator: (val) => val == null || val.trim().isEmpty ? "Turf length is required" : null,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Input(
                        controller: widthCtrl,
                        hint: "Width (ft)",
                        type: TextInputType.number,
                        validator: (val) => val == null || val.trim().isEmpty ? "Turf width is required" : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                Input(
                  controller: mapCtrl,
                  hint: "Google Map Link",
                  type: TextInputType.url,
                  validator: (val) => val == null || val.trim().isEmpty ? "Turf map link is required" : null,
                ),
                SizedBox(height: 12),

                TextFormField(
                  validator: (val) => val == null || val.trim().isEmpty ? "Turf opening time is required" : null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: openCtrl,
                  readOnly: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 12,horizontal: 16),
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
                    suffixIcon: Icon(Icons.access_time, color: BMTTheme.white50),
                  ),
                  onTap: () => selectOpeningTime(context),
                  onTapOutside: (e) => FocusScope.of(context).unfocus(),
                ),
                SizedBox(height: 12),

                TextFormField(
                  validator: (val) => val == null || val.trim().isEmpty ? "Turf closing time is required" : null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: closeCtrl,
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
                    suffixIcon: Icon(Icons.access_time, color: BMTTheme.white50),
                  ),
                  onTap: () => selectClosingTime(context),
                  onTapOutside: (e) => FocusScope.of(context).unfocus(),
                ),
                SizedBox(height: 12),

                Input(
                  controller: priceCtrl,
                  hint: "Price Per Hr",
                  type: TextInputType.number,
                  validator: (val){
                    if (val == null || val.trim().isEmpty) {
                      return "Price per hour is required";
                    } else if (int.tryParse(val.trim())! < 100) {
                      return "Price per hour should be at least 100";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),

                Input(
                  controller: upiCtrl,
                  hint: "UPI ID",
                  type: TextInputType.none,
                  validator: (val) => val == null || val.trim().isEmpty ? "UPI ID is required" : null,
                ),
                SizedBox(height: 12),

                Input(
                  controller: phoneCtrl,
                  hint: "Phone Number",
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
                Wrap(
                  spacing: 0,
                  children: amenitiesList.map((amn) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: selectedAmenities.contains(amn),
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                selectedAmenities.add(amn);
                              } else {
                                selectedAmenities.remove(amn);
                              }
                            });
                          },
                        ),
                        Text(amn),
                      ],
                    );
                  }).toList(),
                ),
                SizedBox(height: 12),

                Button(text: "Update Turf", onClick: updateTurfBTNClick),
                SizedBox(height: 12),
                Button(text: "Delete Turf", onClick: confirmDelete, backColor: Colors.redAccent,),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
