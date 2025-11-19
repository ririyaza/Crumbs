import 'package:flutter/material.dart';
import '../components/pc_navbar.dart';
import 'order.dart';
import 'favorite.dart';
import 'order_history.dart';
import 'message.dart';
import 'settings.dart';

class DashboardPage extends StatefulWidget {
  final int selectedIndex;
  const DashboardPage({super.key, this.selectedIndex = 0});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late int selectedIndex;

  final List<Widget> pages = [
    const Center(
      child: Text(
        'Welcome to Dashboard Page',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
    const OrderPage(),
    const FavoritePage(),
    const OrderHistoryPage(),
    const MessagePage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          PcSideNavbar(
            selectedIndex: selectedIndex,
            onItemSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
          Expanded(child: pages[selectedIndex]),
        ],
      ),
    );
  }
}
