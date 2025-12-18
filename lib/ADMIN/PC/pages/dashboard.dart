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

  String _selectedWeekOption = 'This Week';
  Map<int, int> _thisWeekSales = {};
  Map<int, int> _lastWeekSales = {};

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
            // ignore: deprecated_member_use
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

  final salesData = _selectedWeekOption == 'This Week' ? _thisWeekSales : _lastWeekSales;

  final int maxSales = salesData.values.every((v) => v == 0)
      ? 1
      : salesData.values.reduce((a, b) => a > b ? a : b);

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
            DropdownButton<String>(
              value: _selectedWeekOption,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'This Week', child: Text('This Week')),
                DropdownMenuItem(value: 'Last Week', child: Text('Last Week')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedWeekOption = value;
                  weeklySales = value == 'This Week' ? _thisWeekSales : _lastWeekSales;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 260,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  final value = (maxSales / 5 * (5 - i)).round();
                  return Text('₱$value', style: const TextStyle(fontSize: 12, color: Colors.grey));
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    final sales = salesData[index + 1] ?? 0;
                    final barHeight = (sales / maxSales) * 180;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('₱$sales', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Container(
                          width: 24,
                          height: barHeight.isNaN ? 0 : barHeight,
                          decoration: BoxDecoration(
                            color: Colors.green.shade400,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          weekdayLabels[index],
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
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

    Widget buildStockStatus(int inStock) {
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
                      child: buildStockStatus(inStock),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void fetchWeeklySales() {
  _orderSubscription = orderRef.onValue.listen((event) {
    final snapshot = event.snapshot;

    Map<int, int> thisWeekMap = {1:0,2:0,3:0,4:0,5:0,6:0,7:0};
    Map<int, int> lastWeekMap = {1:0,2:0,3:0,4:0,5:0,6:0,7:0};

    if (!snapshot.exists) {
      setState(() {
        _thisWeekSales = thisWeekMap;
        _lastWeekSales = lastWeekMap;
        weeklySales = thisWeekMap;
      });
      return;
    }

    final now = DateTime.now();
    final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfLastWeek = startOfThisWeek.subtract(Duration(days: 7));

    for (final orderSnap in snapshot.children) {
      if (orderSnap.value is! Map) continue;
      final data = orderSnap.value as Map;

      final status = data['order_status']?.toString().toLowerCase();
      if (status != 'completed') continue;

      final createdAt = data['order_createdAt'];
      if (createdAt == null) continue;

      final orderDate = DateTime.tryParse(createdAt.toString());
      if (orderDate == null) continue;

      final itemsRaw = data['items'];
      if (itemsRaw == null) continue;

      double orderTotal = 0;
      if (itemsRaw is List) {
        for (final item in itemsRaw) {
          if (item is! Map) continue;
          final price = double.tryParse(item['product_price']?.toString() ?? '0') ?? 0;
          final qty = int.tryParse(item['product_quantity']?.toString() ?? '0') ?? 0;
          orderTotal += price * qty;
        }
      } else if (itemsRaw is Map) {
        for (final item in itemsRaw.values) {
          if (item is! Map) continue;
          final price = double.tryParse(item['product_price']?.toString() ?? '0') ?? 0;
          final qty = int.tryParse(item['product_quantity']?.toString() ?? '0') ?? 0;
          orderTotal += price * qty;
        }
      }

      if (orderDate.isAfter(startOfThisWeek.subtract(const Duration(seconds: 1)))) {
        thisWeekMap[orderDate.weekday] = (thisWeekMap[orderDate.weekday] ?? 0) + orderTotal.toInt();
      } else if (orderDate.isAfter(startOfLastWeek.subtract(const Duration(seconds: 1))) &&
                 orderDate.isBefore(startOfThisWeek)) {
        lastWeekMap[orderDate.weekday] = (lastWeekMap[orderDate.weekday] ?? 0) + orderTotal.toInt();
      }
    }

    setState(() {
      _thisWeekSales = thisWeekMap;
      _lastWeekSales = lastWeekMap;
      weeklySales = _selectedWeekOption == 'This Week' ? _thisWeekSales : _lastWeekSales;
    });
  });
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
          // ignore: deprecated_member_use
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
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
