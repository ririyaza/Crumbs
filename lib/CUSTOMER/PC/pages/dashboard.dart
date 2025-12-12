import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../database_service.dart';
import '../components/pc_navbar.dart';
import 'order.dart';
import 'favorite.dart';
import 'order_history.dart';
import 'message.dart';
import 'settings.dart';

class DashboardContent extends StatefulWidget {
  final VoidCallback? onOrderNowPressed;
  final String customerId;

  const DashboardContent({super.key, this.onOrderNowPressed, required this.customerId});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  final DatabaseService dbServices = DatabaseService();
  List<Map<String, dynamic>> recentProducts = [];

  @override
  void initState() {
    super.initState();
    fetchRecentOrders();
  }

Future<void> fetchRecentOrders() async {
  final snapshot = await dbServices.read(path: 'Order');
  if (snapshot != null && snapshot.value != null) {
    final data = snapshot.value as Map<dynamic, dynamic>;

    List<Map<String, dynamic>> orders = data.entries.map((e) {
      final order = Map<String, dynamic>.from(e.value as Map);
      order['order_createdAt'] = order['order_createdAt'] ?? '';

      // Convert items to List<Map<String, dynamic>>
      if (order['items'] != null) {
        if (order['items'] is Map) {
          order['items'] = (order['items'] as Map).values
              .map((i) => Map<String, dynamic>.from(i as Map))
              .toList();
        } else if (order['items'] is List) {
          order['items'] = List<Map<String, dynamic>>.from(
              (order['items'] as List).map((i) => Map<String, dynamic>.from(i as Map)));
        }
      } else {
        order['items'] = [];
      }

      return order;
    }).toList();

    // Filter by customer
    orders = orders
        .where((o) => o['customer_ID'].toString() == widget.customerId)
        .toList();

    // Sort newest first
    orders.sort((a, b) =>
        b['order_createdAt'].toString().compareTo(a['order_createdAt'].toString()));

    List<Map<String, dynamic>> products = [];
    Set<String> addedProducts = {}; // track duplicates by product_name
    int remaining = 6;

    for (var order in orders) {
      final items = List<Map<String, dynamic>>.from(order['items']);

      for (var item in items) {
        final productName = item['product_name'].toString();
        if (remaining <= 0) break;
        if (addedProducts.contains(productName)) continue; // skip duplicates

        products.add({
          'product_name': productName,
          'product_price': item['product_price'].toString(),
          'product_image': item['product_image'].toString(),
        });
        addedProducts.add(productName);
        remaining--;
      }
      if (remaining <= 0) break;
    }

    setState(() {
      recentProducts = products;
    });
  } else {
    print('No orders found in Firebase.');
  }
}



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner
                Container(
                  height: 180,
                  width: 1200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: AssetImage("assets/banner.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Text(
                          "Deliciously easy order",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 30),
                              child: Text(
                                "We offer you the most delicious breads and pastries with easy ordering options.",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: widget.onOrderNowPressed,
                              child: const Text(
                                "Order Now",
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                const Text(
                  "Explore Categories",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 110,
                  child: _ScrollableCategories(),
                ),
                const SizedBox(height: 32),

                const Text(
                  "Popular",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    mainAxisExtent: 260,
                  ),
                  itemCount: 3,
                  itemBuilder: (_, i) {
                    final productNames = ["Sourdough - Regular", "Biscotti - Plain", "Foccacia"];
                    final productPrices = ["₱280.00", "₱200.00", "₱250.00"];

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                            color: Colors.black.withOpacity(.1),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.asset(
                              "assets/pop_$i.jpg",
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productNames[i],
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  productPrices[i],
                                  style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),
                const Text(
                  "Recent Orders",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    mainAxisExtent: 260,
                  ),
                  itemCount: recentProducts.length,
                  itemBuilder: (_, i) {
                    final product = recentProducts[i];
                    ImageProvider imageProvider;

                    if (product['product_image'] != null && product['product_image'].isNotEmpty) {
                      try {
                        imageProvider = MemoryImage(base64Decode(product['product_image']));
                      } catch (e) {
                        imageProvider = const AssetImage("assets/placeholder.png");
                      }
                    } else {
                      imageProvider = const AssetImage("assets/placeholder.png");
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                            color: Colors.black.withOpacity(.1),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image(
                              image: imageProvider,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['product_name'],
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product['product_price'],
                                  style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        "Google Map",
                        style: TextStyle(fontSize: 20, color: Colors.black54),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Location",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 22, 107, 26)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.location_on),
                      SizedBox(width: 6),
                      Text(
                        "Tabuc Suba, Jaro, Iloilo City",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Hours",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 22, 107, 26)),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text("Monday        9:00 AM – 5:00 PM"),
                        SizedBox(height: 10),
                        Text("Tuesday       9:00 AM – 5:00 PM"),
                        SizedBox(height: 10),
                        Text("Wednesday  9:00 AM – 5:00 PM"),
                        SizedBox(height: 10),
                        Text("Thursday      9:00 AM – 5:00 PM"),
                        SizedBox(height: 10),
                        Text("Friday           9:00 AM – 5:00 PM"),
                        SizedBox(height: 10),
                        Text("Saturday      9:00 AM – 6:00 PM"),
                        SizedBox(height: 10),
                        Text("Sunday        9:00 AM – 12:00 PM"),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrollableCategories extends StatefulWidget {
  @override
  State<_ScrollableCategories> createState() => _ScrollableCategoriesState();
}

class _ScrollableCategoriesState extends State<_ScrollableCategories> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  final categories = ['Bread', 'Sourdough', 'Biscotti', 'Cookies', 'Cakes', 'Pie', 'Soft Bread'];
  final double scrollAmount = 200;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _showLeftArrow = _scrollController.offset > 0;
        _showRightArrow =
            _scrollController.offset < _scrollController.position.maxScrollExtent;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void scrollLeft() {
    double newOffset = _scrollController.offset - scrollAmount;
    if (newOffset < 0) newOffset = 0;
    _scrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void scrollRight() {
    double newOffset = _scrollController.offset + scrollAmount;
    if (newOffset > _scrollController.position.maxScrollExtent) {
      newOffset = _scrollController.position.maxScrollExtent;
    }
    _scrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (_, i) {
            return Container(
              width: 190,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      "assets/cat_$i.jpg",
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Text(
                      categories[i],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        shadows: [Shadow(blurRadius: 3, color: Colors.black54, offset: Offset(1, 1))],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (_showLeftArrow)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: scrollLeft,
              child: const SizedBox(
                width: 40,
                child: Center(child: Icon(Icons.arrow_back_ios, size: 24, color: Colors.black)),
              ),
            ),
          ),
        if (_showRightArrow)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: scrollRight,
              child: const SizedBox(
                width: 40,
                child: Center(child: Icon(Icons.arrow_forward_ios, size: 24, color: Colors.black)),
              ),
            ),
          ),
      ],
    );
  }
}

class DashboardPage extends StatefulWidget {
  final int selectedIndex;
  final String customerId;
  const DashboardPage({super.key, this.selectedIndex = 0, required this.customerId});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String staffName = 'Customer';
  ImageProvider? staffImage;
  late int selectedIndex;
  final TextEditingController _searchController = TextEditingController();
  final double _profileSize = 66;
  final double _searchWidth = 720;
  final DatabaseService dbServices = DatabaseService();

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
    _loadCustomerProfile();
  }

  Future<void> _loadCustomerProfile() async {
    final snapshot = await dbServices.read(path: 'Customer/${widget.customerId}');
    if (snapshot != null && snapshot.value != null) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        final firstName = data['customer_Fname'] ?? 'Customer';
        final lastName = data['customer_Lname'] ?? '';
        staffName = '$firstName $lastName'.trim();
        if (data['profile_image'] != null) {
          staffImage = MemoryImage(base64Decode(data['profile_image']));
        } else {
          staffImage = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardContent(
        onOrderNowPressed: () {
          setState(() {
            selectedIndex = 1;
          });
        },
        customerId: widget.customerId,
      ),
      OrderPage(customerId: widget.customerId),
      FavoritePage(customerId: widget.customerId),
      OrderHistoryPage(customerId: widget.customerId),
      MessagePage(customerId: widget.customerId),
      SettingsPage(
        customerId: widget.customerId,
        onProfileUpdate: (name, imageBytes) {
          setState(() {
            staffName = name;
            staffImage = imageBytes != null ? MemoryImage(imageBytes) : null;
          });
        },
      ),
    ];

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
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
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
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_active),
                          onPressed: () {},
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            staffName,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_drop_down, color: Colors.black87, size: 60),
                          const SizedBox(width: 5),
                          CircleAvatar(
                            radius: _profileSize / 2,
                            backgroundColor: Colors.black87,
                            backgroundImage: staffImage,
                            child: staffImage == null
                                ? const Text(
                                    'C',
                                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(child: pages[selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
