import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../database_service.dart';

class SettingsPage extends StatefulWidget {
  final Function(String name, Uint8List? imageBytes) onProfileUpdate;

  const SettingsPage({super.key, required this.onProfileUpdate});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final dbServices = DatabaseService();
  File? _selectedImage;
  Uint8List? _imageBytes;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStaffProfile(); 
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    ImageProvider? avatarImage;
    if (kIsWeb) {
      if (_imageBytes != null) avatarImage = MemoryImage(_imageBytes!);
    } else {
      if (_selectedImage != null) avatarImage = FileImage(_selectedImage!);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "User Profile",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              CircleAvatar(
                radius: 90,
                backgroundColor: Colors.black87,
                backgroundImage: avatarImage,
                child: avatarImage == null
                    ? const Text(
                        "S",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.image,
                        withData: true,
                      );

                      if (result != null) {
                        setState(() {
                          if (kIsWeb) {
                            _imageBytes = result.files.single.bytes;
                            _selectedImage = null;
                          } else {
                            if (result.files.single.path != null) {
                              _selectedImage = File(result.files.single.path!);
                              _imageBytes = null;
                            }
                          }
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      "Change Picture",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                        _imageBytes = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      "Delete Picture",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 50),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "First Name",
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Last Name",
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Contact Number",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 630,
                child: TextField(
                  controller: _contactController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Change Password",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 630,
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              SizedBox(
                width: 300,
                height: 46,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_firstNameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("First Name is required!")),
                      );
                      return;
                    }

                    if (_lastNameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Last Name is required!")),
                      );
                      return;
                    }

                    if (_contactController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Contact Number is required!")),
                      );
                      return;
                    }

                    String fName = _firstNameController.text;
                    String lName = _lastNameController.text;
                    String contactNumber = _contactController.text;
                    String password = _passwordController.text;

                    Uint8List? imageBytes;
                    if (_imageBytes != null) {
                      imageBytes = _imageBytes;
                    } else if (_selectedImage != null) {
                      imageBytes = await _selectedImage!.readAsBytes();
                    }

                    String? imageBase64 = imageBytes != null ? base64Encode(imageBytes) : null;

                    Map<String, dynamic> updateData = {
                      'staff_Fname': fName,
                      'staff_Lname': lName,
                      'profile_image': imageBase64,
                      'contact_number': contactNumber,
                    };

                    if (password.isNotEmpty) {
                      updateData['staff_password'] = password;
                    }

                    await dbServices.update(path: 'Staff/1', data: updateData);

                    widget.onProfileUpdate('$fName $lName', imageBytes);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profile updated!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 30),
            SizedBox(
              width: 300,
              height: 46,
              child: OutlinedButton(
                onPressed: () async {
                setState(() {
                  _firstNameController.text = 'Staff';
                  _lastNameController.clear();
                  _contactController.clear();
                  _passwordController.clear();
                  _selectedImage = null;
                  _imageBytes = null;
                });

                final defaultImageBase64 = await generateDefaultAvatar('S');

                Map<String, dynamic> defaultData = {
                  'staff_Fname': 'Staff',
                  'staff_Lname': '',
                  'profile_image': defaultImageBase64,
                  'contact_number': '',
                };

                await dbServices.update(path: 'Staff/1', data: defaultData);

                widget.onProfileUpdate('Staff', base64Decode(defaultImageBase64));

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile reset to default!")),
                );
              },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  "Return to Default",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _loadStaffProfile() async {
  final snapshot = await dbServices.read(path: 'Staff/1');
  if (snapshot != null && snapshot.value != null) {
    final data = snapshot.value as Map<dynamic, dynamic>;

    setState(() {
      final fName = data['staff_Fname'] ?? '';
      final lName = data['staff_Lname'] ?? '';

      _firstNameController.text = fName;
      _lastNameController.text = lName;

      _contactController.text = data['contact_number'] ?? '';

      if (data['profile_image'] != null) {
        _imageBytes = base64Decode(data['profile_image']);
        _selectedImage = null; 
      }
    });
  }
}

Future<String> generateDefaultAvatar(String letter) async {
  const int size = 180; 
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint()..color = Colors.black87;

  canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, paint);

  final textPainter = TextPainter(
    text: TextSpan(
      text: letter,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 90,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
  );

  final picture = recorder.endRecording();
  final img = await picture.toImage(size, size);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();

  return base64Encode(bytes);
}

}
