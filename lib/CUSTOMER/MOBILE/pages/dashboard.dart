import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../database_service.dart';
import '../components/helper/cart_manager.dart';
import '../components/mobile_navbar.dart';
import '../components/helper/favorite_manager.dart';
import 'favorite.dart';
import 'order.dart';
import 'order_history.dart';
import 'message.dart';
import 'settings.dart';

class MobileDashboardPage extends StatefulWidget {
  final String customerId;
  final String customerAvatar;

  const MobileDashboardPage({
    super.key,
    required this.customerId,
    required this.customerAvatar,
  });

  @override
  State<MobileDashboardPage> createState() => _MobileDashboardPageState();
}

class _MobileDashboardPageState extends State<MobileDashboardPage> {
  final DatabaseService dbServices = DatabaseService();

  final moods = [
    {'label': 'Bread', 'image': 'assets/cat_0.jpg'},
    {'label': 'Sourdough', 'image': 'assets/cat_1.jpg'},
    {'label': 'Biscotti', 'image': 'assets/cat_2.jpg'},
    {'label': 'Cookies', 'image': 'assets/cat_3.jpg'},
    {'label': 'Cakes', 'image': 'assets/cat_4.jpg'},
    {'label': 'Pie', 'image': 'assets/cat_5.jpg'},
  ];

  String? orderInitialCategory;
  int selectedIndex = 0;
  List<Map<String, dynamic>> popularProducts = [];
  String customerName = 'Guest';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    FavoriteManager().setCurrentUser(widget.customerId);
    fetchPopularProducts();
    fetchCustomerName();
  }

  Future<void> fetchPopularProducts() async {
    final snapshot = await dbServices.read(path: 'Product');
    if (snapshot != null && snapshot.value != null) {
      final rawData = snapshot.value;
      List<Map<String, dynamic>> products = [];

      if (rawData is Map) {
        rawData.forEach((_, value) {
          if (value is Map) {
            products.add(_mapProduct(value));
          }
        });
      } else if (rawData is List) {
        for (var e in rawData) {
          if (e != null && e is Map) {
            products.add(_mapProduct(e));
          }
        }
      }

      products.sort(
          (a, b) => (b['item_sold'] as int).compareTo(a['item_sold'] as int));

      setState(() {
        popularProducts = products.take(5).toList();
      });
    }
  }

  Map<String, dynamic> _mapProduct(Map value) {
    return {
      'product_name': value['product_name']?.toString() ?? 'Unnamed',
      'item_sold': int.tryParse(value['item_sold']?.toString() ?? '0') ?? 0,
      'unit_price': double.tryParse(value['unit_price']?.toString() ?? '0') ?? 0,
      'product_image': value['product_image']?.toString() ?? '',
    };
  }

  Future<void> fetchCustomerName() async {
    try {
      final snapshot =
          await dbServices.read(path: 'Customer/${widget.customerId}');
      if (snapshot != null && snapshot.value != null && snapshot.value is Map) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final fname = data['customer_Fname'] ?? '';
        final lname = data['customer_Lname'] ?? '';
        setState(() {
          customerName = '$fname $lname'.trim();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching customer name: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CartManager(
            customerId: widget.customerId,
            customerName: customerName,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoriteManager()..setCurrentUser(widget.customerId),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: selectedIndex,
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Location', style: TextStyle(color: Colors.grey)),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_none),
                        ),
                      ],
                    ),

                    Row(
                      children: const [
                        Icon(Icons.location_on, color: Colors.green),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Tabuc Suba, Jaro, Iloilo City',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search products...',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.filter_alt_outlined,
                              color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text('What are we feeling today?',
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: moods.map((mood) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              orderInitialCategory = mood['label'];
                              selectedIndex = 2; 
                            });
                          },
                          child: _MoodItem(
                            label: mood['label']!,
                            imagePath: mood['image']!,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    const Text('Popular Choices',
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    ...popularProducts.map((p) => _PopularItem(
                          productId: p['product_name'],
                          title: p['product_name'],
                          price:
                              '₱${(p['unit_price'] as double).toStringAsFixed(2)}',
                          imageBase64: p['product_image'],
                        )),
                  ],
                ),
              ),
            ),

            FavoritePage(customerId: widget.customerId),

            OrderPage(
              key: ValueKey(orderInitialCategory),
              customerId: widget.customerId,
              initialCategory: orderInitialCategory,
            ),

            OrderHistoryPage(customerId: widget.customerId),

            MessagePage(
              customerId: widget.customerId,
              customerAvatar: widget.customerAvatar,
            ),

            SettingsPage(customerId: widget.customerId),
          ],
        ),
        bottomNavigationBar: MobileNavbar(
          selectedIndex: selectedIndex,
          onItemSelected: (i) => setState(() => selectedIndex = i),
        ),
      ),
    );
  }
}

class _MoodItem extends StatelessWidget {
  final String label;
  final String imagePath;

  const _MoodItem({required this.label, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Image.asset(
            imagePath,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _PopularItem extends StatefulWidget {
  final String productId;
  final String title;
  final String price;
  final String? imageBase64;

  const _PopularItem({
    required this.productId,
    required this.title,
    required this.price,
    this.imageBase64,
  });

  @override
  State<_PopularItem> createState() => _PopularItemState();
}

class _PopularItemState extends State<_PopularItem> {
  @override
  Widget build(BuildContext context) {
    final isFav = context.watch<FavoriteManager>().isFavorite(widget.productId);

    ImageProvider imageProvider;
    if (widget.imageBase64 != null && widget.imageBase64!.isNotEmpty) {
      try {
        imageProvider = MemoryImage(base64Decode(widget.imageBase64!));
      } catch (_) {
        imageProvider = const AssetImage('assets/placeholder.png');
      }
    } else {
      imageProvider = const AssetImage('assets/placeholder.png');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image(
                  image: imageProvider,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 2,
                left: 2,
                child: GestureDetector(
                  onTap: () {
                    context.read<FavoriteManager>().toggleFavorite({
                      'id': widget.productId,
                      'name': widget.title,
                      'price': widget.price,
                      'image': widget.imageBase64,
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.85),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      size: 14,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(widget.price,
                    style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: () {
              Uint8List imageBytes;
              if (widget.imageBase64 != null && widget.imageBase64!.isNotEmpty) {
                try {
                  imageBytes = base64Decode(widget.imageBase64!);
                } catch (_) {
                  imageBytes = Uint8List(0); 
                }
              } else {
                imageBytes = Uint8List(0);
              }

             
              double parsedPrice = 0;
              try {
                parsedPrice = double.parse(
                    widget.price.replaceAll(RegExp(r'[^0-9.]'), ''));
              } catch (_) {
                parsedPrice = 0;
              }

              context.read<CartManager>().addToCart({
                'id': widget.productId,
                'name': widget.title,
                'price': parsedPrice,
                'image': imageBytes,
                'quantity': 1,
              });

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Success'),
                  content: Text('${widget.title} has been added to your cart!'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text(
              'Place Order',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
