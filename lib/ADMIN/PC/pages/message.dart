import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../chatpage.dart';

class MessagePage extends StatefulWidget {
  final String staffId;
  final String staffAvatar;

  const MessagePage({super.key, required this.staffId, required this.staffAvatar});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final DatabaseReference _customerRef = FirebaseDatabase.instance.ref('Customer');
  List<Map<String, dynamic>> customers = [];

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  void _fetchCustomers() {
    _customerRef.onValue.listen((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists) {
        setState(() => customers = []);
        return;
      }

      List<Map<String, dynamic>> temp = [];
      for (var child in snapshot.children) {
        final data = child.value as Map<dynamic, dynamic>;
        temp.add({
          'id': data['customer_id'],
          'name': '${data['customer_Fname'] ?? ''} ${data['customer_Lname'] ?? ''}',
          'avatar': data['profile_image'] ?? '',
        });
      }

      setState(() => customers = temp);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (customers.isEmpty) {
      return const Center(child: Text('No customers found'));
    }

    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        final avatarImage = customer['avatar'] != '' 
            ? MemoryImage(base64Decode(customer['avatar'])) 
            : null;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: avatarImage,
            child: avatarImage == null ? Text(customer['name'][0]) : null,
          ),
          title: Text(customer['name']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(
                  currentUserId: widget.staffId,
                  chatWithUserId: customer['id'],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
