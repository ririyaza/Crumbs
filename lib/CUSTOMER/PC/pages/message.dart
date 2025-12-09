import 'package:flutter/material.dart';

class MessagePage extends StatelessWidget {
  final String customerId;
  const MessagePage({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Message Page', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }
}
