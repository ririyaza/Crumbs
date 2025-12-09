import 'dart:convert';

import 'package:flutter/material.dart';
import '../components/pc_navbar.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../database_service.dart';
import 'inventory.dart';
import 'ingredients.dart';
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
  final dbServices = DatabaseService();
  late DatabaseReference productRef;
  late int selectedIndex;
  String staffName = 'Staff';
  ImageProvider? staffImage;

  final TextEditingController _searchController = TextEditingController();
  final double _searchBorderRadius = 12;
  final double _notificationBorderRadius = 12;
  final double _searchWidth = 720;
  final double _profileSize = 66;
  int _selectedDays = 7;
  int _ingredientDays = 7;

  final List<Map<String, String>> _outOfStockItems = [
    {},
  ];

  final List<Map<String, String>> _topSellingProducts = [
    {},
  ];

  @override
  void initState() {
    super.initState();
    _fetchStaffProfile();
    selectedIndex = widget.selectedIndex;

    productRef = dbServices.firebaseDatabase.child('Product');
    fetchOutOfStockProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(_notificationBorderRadius),
            ),
            child: IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 16),
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: _searchWidth),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(_searchBorderRadius),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(_searchBorderRadius),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(_searchBorderRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(_notificationBorderRadius),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_active),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 24),
          const Spacer(),
         Row(
          children: [
            Text(
              staffName, 
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 22,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              color: Colors.black87,
              size: 60,
            ),
            const SizedBox(width: 5),
            CircleAvatar(
              radius: _profileSize / 2,
              backgroundColor: Colors.black87,
              backgroundImage: staffImage,
              child: staffImage == null
                  ? Text(
                      staffName.isNotEmpty ? staffName[0] : "S",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ],
        ),
        ],
      ),
    );
  }

 void _fetchStaffProfile() async {
    final snapshot = await dbServices.read(path: 'Staff/1'); 
  if (snapshot != null && snapshot.value != null) {
    final data = snapshot.value as Map<dynamic, dynamic>;
    setState(() {
      final fName = data['staff_Fname'] ?? '';
      final lName = data['staff_Lname'] ?? '';
      staffName = '$fName $lName'.trim();

      if (data['profile_image'] != null) {
        staffImage = MemoryImage(base64Decode(data['profile_image']));
      } else {
        staffImage = null;
      }
    });
  }
}



  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _buildGenerateReportButton(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Top Sales',
                  value: '—',
                  subtitle: 'vs last week',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Unit Sold',
                  value: '—',
                  subtitle: 'vs last week',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Out of Stock',
                  value: '${_outOfStockItems.length}',
                  subtitle: ' ',
                  valueColor: Colors.red[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildSalesCard(),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: _buildOutOfStockCard(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildTopSellingCard(),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: _buildIngredientUsageCard(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
  required String title,
  required String value,
  required String subtitle,
  Color? valueColor, 
}) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: const Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildSalesCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sales',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              _buildDaysDropdown(
                value: _selectedDays,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedDays = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateReportButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00B027),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
      onPressed: () {},
      child: const Text(
        'Generate Report',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildOutOfStockCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Out of Stock',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                _tableHeaderCell('Product Name', flex: 3),
                _tableHeaderCell('Price'),
              ],
            ),
          ),
          const Divider(),
          ..._outOfStockItems.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  _tableCell(item['name'] ?? '', flex: 3),
                  _tableCell(item['price'] ?? ''),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSellingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Selling Products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                _tableHeaderCell('Product Name', flex: 3),
                _tableHeaderCell('ID'),
                _tableHeaderCell('Item Sold'),
                _tableHeaderCell('In Stock'),
                _tableHeaderCell('Unit Price'),
                _tableHeaderCell('Total Value'),
                _tableHeaderCell('Status', flex: 2),
              ],
            ),
          ),
          const Divider(),
          ..._topSellingProducts.map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  _tableCell(row['name'] ?? '', flex: 3),
                  _tableCell(row['id'] ?? ''),
                  _tableCell(row['itemSold'] ?? ''),
                  _tableCell(row['inStock'] ?? ''),
                  _tableCell(row['unitPrice'] ?? ''),
                  _tableCell(row['totalValue'] ?? ''),
                  _tableCell(
                    row['status'] ?? '',
                    flex: 2,
                    align: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientUsageCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ingredient Usage',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              _buildDaysDropdown(
                value: _ingredientDays,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _ingredientDays = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _tableCell(String text, {int flex = 1, TextAlign align = TextAlign.left}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  BoxDecoration _sectionDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget _buildDaysDropdown({
    required int value,
    required ValueChanged<int?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButton<int>(
        value: value,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        items: List.generate(
          7,
          (index) => DropdownMenuItem<int>(
            value: index + 1,
            child: Text('${index + 1} days'),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _selectedPage() {
    switch (selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const InventoryPage();
      case 2:
        return const IngredientsPage();
      case 3:
        return const OrderHistoryPage();
      case 4:
        return const MessagePage();
      case 5:
        return SettingsPage(
          onProfileUpdate: (name, imageBytes) {
            setState(() {
              staffName = name; 
              if (imageBytes != null) {
                staffImage = MemoryImage(imageBytes);
              } else {
                staffImage = null; 
              }
            });
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
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
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _selectedPage()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void fetchOutOfStockProducts() {
  productRef.onValue.listen((event) {
    final snapshot = event.snapshot;
    if (snapshot.exists) {
      List<Map<String, String>> products = [];
      for (var child in snapshot.children) {
        final data = child.value as Map<dynamic, dynamic>;
        final inStock = int.tryParse(data['quantity'].toString()) ?? 0;

        if (inStock == 0) {
          products.add({
            'id': data['product_id'].toString(),
            'name': data['product_name'].toString(),
            'price': '₱${data['unit_price'].toString()}',
          });
        }
      }

      setState(() {
        _outOfStockItems.clear();
        _outOfStockItems.addAll(products);
      });
    } else {
      setState(() {
        _outOfStockItems.clear();
      });
    }
  });
}
}
