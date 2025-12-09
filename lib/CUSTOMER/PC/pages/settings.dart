import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../database_service.dart';

class SettingsPage extends StatefulWidget {
  final String customerId;
  final void Function(String name, Uint8List? imageBytes)? onProfileUpdate;

  const SettingsPage({
    super.key,
    required this.customerId,
    this.onProfileUpdate,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final dbServices = DatabaseService();
  Uint8List? _imageBytes;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomerProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _loadCustomerProfile() async {
    final snapshot = await dbServices.read(path: 'Customer/${widget.customerId}');
    if (snapshot != null && snapshot.value != null) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _firstNameController.text = data['customer_Fname'] ?? '';
        _lastNameController.text = data['customer_Lname'] ?? '';
        _contactController.text = data['customer_contactNumber'] ?? '';
        if (data['profile_image'] != null) {
          _imageBytes = base64Decode(data['profile_image']);
        }
      });
    }
  }

 Future<void> _saveProfile() async {
  if (_firstNameController.text.isEmpty) {
    _showMessage("First Name is required!");
    return;
  }
  if (_lastNameController.text.isEmpty) {
    _showMessage("Last Name is required!");
    return;
  }
  if (_contactController.text.isEmpty) {
    _showMessage("Contact Number is required!");
    return;
  }

  Uint8List? imageBytes = _imageBytes;
  String? imageBase64 = imageBytes != null ? base64Encode(imageBytes) : null;

  Map<String, dynamic> updateData = {
    'customer_Fname': _firstNameController.text,
    'customer_Lname': _lastNameController.text,
    'customer_contactNumber': _contactController.text,
    'profile_image': imageBase64,
  };

  if (_passwordController.text.isNotEmpty) {
    updateData['customer_password'] = _passwordController.text;
  }

  await dbServices.update(
    path: 'Customer/${widget.customerId}',
    data: updateData,
  );

  if (widget.onProfileUpdate != null) {
    widget.onProfileUpdate!(
      '${_firstNameController.text} ${_lastNameController.text}',
      imageBytes,
    );
  }

  _showMessage("Profile updated successfully!");
}

  Future<void> _returnToDefault() async {
  setState(() {
    _firstNameController.clear();
    _lastNameController.clear();
    _contactController.clear();
    _passwordController.clear();
    _imageBytes = null;
  });

  Map<String, dynamic> defaultData = {
    'customer_Fname': 'Customer',
    'customer_Lname': '',
    'customer_contactNumber': '',
    'profile_image': null,
  };

  await dbServices.update(
    path: 'Customer/${widget.customerId}',
    data: defaultData,
  );

  if (widget.onProfileUpdate != null) {
    widget.onProfileUpdate!('Customer', null);
  }

  _showMessage("Profile reset to default!");
}


  @override
  Widget build(BuildContext context) {
    ImageProvider? avatarImage;
    if (_imageBytes != null) {
      avatarImage = MemoryImage(_imageBytes!);
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
            backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,
            child: _imageBytes == null
                ? const Text(
                    'C', 
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
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
                          _imageBytes = result.files.single.bytes;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
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
                      _imageBytes = null; 
                      _firstNameController.text = '';
                      _lastNameController.text = '';
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text(
                    "Delete Picture",
                    style: const TextStyle(color: Colors.black, fontSize: 20),
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
                  const Text("First Name",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Last Name",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
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
              const Text("Contact Number",
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
              const SizedBox(height: 6),
              SizedBox(
                width: 630,
                child: TextField(
                  controller: _contactController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Change Password",
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
              const SizedBox(height: 6),
              SizedBox(
                width: 630,
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6)),
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
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6))),
                  child: const Text(
                    "Save",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 30),
              SizedBox(
                width: 300,
                height: 46,
                child: OutlinedButton(
                  onPressed: _returnToDefault,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
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
}
