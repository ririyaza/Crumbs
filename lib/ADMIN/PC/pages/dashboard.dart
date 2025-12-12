import 'dart:async';
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
  final String? staffId;
  final String? staffAvatar;
  const DashboardPage({super.key, this.selectedIndex = 0, this.staffId, this.staffAvatar});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final dbServices = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  final double _searchBorderRadius = 12;
  final double _notificationBorderRadius = 12;
  final double _searchWidth = 720;
  final double _profileSize = 66;
  late DatabaseReference productRef;
  late int selectedIndex;
  late DatabaseReference orderRef;
  Map<int, int> weeklySales = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
  StreamSubscription<DatabaseEvent>? _orderSubscription;
  String staffName = 'Staff';
  ImageProvider? staffImage;
  int _selectedDays = 7;
  int _ingredientDays = 7;

    int get totalUnitsSold {
    return _topSellingProducts.fold(0, (sum, item) {
      return sum + (int.tryParse(item['itemSold']?.toString() ?? '0') ?? 0);
    });
  }

  double get totalSales {
    return _topSellingProducts.fold(0.0, (sum, item) {
      String priceStr = item['unitPrice']?.toString() ?? '0';
      priceStr = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
      final unitPrice = double.tryParse(priceStr) ?? 0.0;

      int itemSold = int.tryParse(item['itemSold']?.toString() ?? '0') ?? 0;

      return sum + (unitPrice * itemSold);
    });
  }

  final List<Map<String, String>> _outOfStockItems = [
    {},
  ];

  final List<Map<String, dynamic>> _topSellingProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchStaffProfile();
    selectedIndex = widget.selectedIndex;

    productRef = dbServices.firebaseDatabase.child('Product');
    orderRef = dbServices.firebaseDatabase.child('Order');
    fetchWeeklySales();
    fetchOutOfStockProducts();
    fetchTopSellingProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _orderSubscription?.cancel();
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
                value: '₱${totalSales.toStringAsFixed(2)}',
                subtitle: 'vs last week',
              ),
            ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Unit Sold',
                  value: totalUnitsSold.toString(),
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
  const weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final maxSales = weeklySales.values.isEmpty
      ? 1
      : weeklySales.values.reduce((a, b) => a > b ? a : b);

  final step = (maxSales / 5).ceil(); 

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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
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
        SizedBox(
          height: 320,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  final labelValue = step * (5 - index);
                  return Text(
                    '₱$labelValue',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  );
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    final sales = weeklySales[index + 1] ?? 0;
                    final barHeight = maxSales == 0
                        ? 0.0
                        : (sales / maxSales) * 180; 

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '₱$sales',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 20,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: Colors.green[400],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          weekdayLabels[index],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
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
    const int productNameFlex = 3;
    const int itemSoldFlex = 1;
    const int inStockFlex = 1;
    const int unitPriceFlex = 1;
    const int totalValueFlex = 1;
    const int statusFlex = 2;

    Widget _buildStockStatus(int inStock) {
      Color bgColor;
      Color borderColor;
      String statusText;

      if (inStock == 0) {
        bgColor = Colors.red.shade100;
        borderColor = Colors.red;
        statusText = 'Out of Stock';
      } else if (inStock < 10) {
        bgColor = Colors.yellow.shade100;
        borderColor = Colors.orange;
        statusText = 'Low Stock';
      } else {
        bgColor = Colors.green.shade100;
        borderColor = Colors.green;
        statusText = 'In Stock';
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          statusText,
          style: TextStyle(
            color: borderColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

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
          Row(
            children: [
              Expanded(
                flex: productNameFlex,
                child: Text(
                  'Product Name',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: itemSoldFlex,
                child: Text(
                  'Item Sold',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: inStockFlex,
                child: Text(
                  'In Stock',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: unitPriceFlex,
                child: Text(
                  'Unit Price',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: totalValueFlex,
                child: Text(
                  'Total Value',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: statusFlex,
                child: Text(
                  'Status',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const Divider(),
          ..._topSellingProducts.map((row) {
            int inStock = int.tryParse(row['inStock'].toString()) ?? 0;
            double unitPrice = double.tryParse(row['unitPrice'].toString()) ?? 0.0;
            double totalValue = inStock * unitPrice;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: productNameFlex,
                    child: Text(
                      row['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: itemSoldFlex,
                    child: Text(
                      row['itemSold'].toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: inStockFlex,
                    child: Text(
                      inStock.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Expanded(
                  flex: unitPriceFlex,
                  child: Text(
                    '₱${(row['unitPrice'] as double).toStringAsFixed(2)}',
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: totalValueFlex,
                  child: Text(
                    '₱${(row['totalValue'] as double).toStringAsFixed(2)}',
                    textAlign: TextAlign.center,
                  ),
                ),
                  Expanded(
                    flex: statusFlex,
                    child: Align(
                      alignment: Alignment.center,
                      child: _buildStockStatus(inStock),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void fetchWeeklySales() {
    _orderSubscription = orderRef.onValue.listen((event) {
      final snapshot = event.snapshot;
      Map<int, int> salesMap = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
      if (snapshot.exists) {
        for (var child in snapshot.children) {
          final data = child.value as Map<dynamic, dynamic>;
          if (data['order_createdAt'] != null) {
            DateTime orderDate = DateTime.tryParse(data['order_createdAt']) ?? DateTime.now();
            int weekday = orderDate.weekday;

            if (data['items'] != null) {
              double orderTotal = 0.0;
              final items = data['items'] as Map<dynamic, dynamic>;
              for (var item in items.values) {
                String priceStr = item['product_price']?.toString() ?? '0';
                priceStr = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
                double unitPrice = double.tryParse(priceStr) ?? 0.0;
                int quantity = int.tryParse(item['product_quantity']?.toString() ?? '0') ?? 0;
                orderTotal += unitPrice * quantity;
              }
              salesMap[weekday] = (salesMap[weekday] ?? 0) + orderTotal.toInt();
            }
          }
        }
      }
      setState(() {
        weeklySales = salesMap;
      });
    });
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
        return MessagePage(
          staffId: widget.staffId ?? '',      
          staffAvatar: widget.staffAvatar ?? '',
        );
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

void fetchTopSellingProducts() {
  productRef.onValue.listen((event) {
    final snapshot = event.snapshot;
    if (snapshot.exists) {
      List<Map<String, dynamic>> products = [];

      for (var child in snapshot.children) {
        final data = child.value as Map<dynamic, dynamic>;
        final itemSold = int.tryParse(data['item_sold']?.toString() ?? '0') ?? 0;

        if (itemSold > 0) {
          final inStock = int.tryParse(data['quantity']?.toString() ?? '0') ?? 0;

          String priceStr = data['unit_price']?.toString() ?? '0';
          priceStr = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
          final unitPrice = double.tryParse(priceStr) ?? 0.0;
          final totalValue = inStock * unitPrice;

          products.add({
            'id': data['product_id']?.toString() ?? '',
            'name': data['product_name']?.toString() ?? '',
            'itemSold': itemSold,
            'inStock': inStock,
            'unitPrice': unitPrice,
            'totalValue': totalValue,
            'status': data['status']?.toString() ?? '',
          });
        }
      }

      products.sort((a, b) => (b['itemSold'] as int).compareTo(a['itemSold'] as int));

      setState(() {
        _topSellingProducts.clear();
        _topSellingProducts.addAll(products);
      });
    } else {
      setState(() {
        _topSellingProducts.clear();
      });
    }
  });
}


}
