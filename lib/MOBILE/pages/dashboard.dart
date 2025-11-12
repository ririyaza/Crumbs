import 'package:flutter/material.dart';
import '../components/mobile_navbar.dart';
import 'favorite.dart';
import 'order.dart';
import 'order_history.dart';
import 'message.dart';
import 'settings.dart';

class MobileDashboardPage extends StatefulWidget {
  const MobileDashboardPage({super.key});

  @override
  State<MobileDashboardPage> createState() => _MobileDashboardPageState();
}

class _MobileDashboardPageState extends State<MobileDashboardPage> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    const Center(
      child: Text('Welcome to Dashboard Page', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    ),
    const FavoritePage(),
    const OrderPage(),
    const OrderHistoryPage(),
    const MessagePage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: MobileNavbar(
        selectedIndex: selectedIndex,
        onItemSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
