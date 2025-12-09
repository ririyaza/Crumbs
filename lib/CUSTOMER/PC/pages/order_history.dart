import 'package:flutter/material.dart';

class OrderHistoryPage extends StatelessWidget {
  final String customerId;
  const OrderHistoryPage({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Order History Page', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }
}
