import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'dart:convert';

import '../components/helper/cart_manager.dart';
import '../components/helper/favorite_manager.dart';
import '../components/helper/order_summary_panel.dart';

class OrderPageWrapper extends StatelessWidget {
  final String customerId;
  final String customerName;
  final String? initialCategory;

  const OrderPageWrapper({
    super.key,
    required this.customerId,
    required this.customerName,
    this.initialCategory,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CartManager>(
      create: (_) => CartManager(
        customerId: customerId,
        customerName: customerName,
      ),
      child: OrderPage(
        customerId: customerId,
        initialCategory: initialCategory,
      ),
    );
  }
}

class OrderPage extends StatefulWidget {
  final String customerId;
  final String? initialCategory;

  const OrderPage({
    super.key,
    required this.customerId,
    this.initialCategory,
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final dbRef = FirebaseDatabase.instance.ref();

  List<String> productNames = [];
  List<String> productCategories = [];
  List<double> productPrices = [];
  List<Uint8List> productImages = [];
  List<int> productStocks = [];
  List<String> productFlavors = [];
  String? selectedCategory;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    FavoriteManager().setCurrentUser(widget.customerId);
    selectedCategory = widget.initialCategory ?? "Bread"; 
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() => isLoading = true);
    try {
      final snapshot = await dbRef.child('Product').get();
      productNames.clear();
      productPrices.clear();
      productImages.clear();
      productCategories.clear();
      productStocks.clear();
      productFlavors.clear();

      if (snapshot.exists) {
        final data = snapshot.value;

        if (data is Map) {
          data.forEach((key, value) {
            final prodMap = Map<String, dynamic>.from(value);
            productNames.add(prodMap['product_name']?.toString() ?? 'No Name');
            productPrices.add(double.tryParse(prodMap['unit_price'].toString()) ?? 0.0);
            productImages.add(prodMap['product_image'] != null
                ? base64Decode(prodMap['product_image'].toString())
                : Uint8List(0));
            productCategories.add(prodMap['product_category']?.toString() ?? '');
            productStocks.add(int.tryParse(prodMap['quantity']?.toString() ?? '0') ?? 0);
            productFlavors.add(prodMap['flavor']?.toString() ?? '');
          });
        } else if (data is List) {
          for (var item in data) {
            if (item == null) continue;
            final prodMap = Map<String, dynamic>.from(item);
            productNames.add(prodMap['product_name']?.toString() ?? 'No Name');
            productPrices.add(double.tryParse(prodMap['unit_price'].toString()) ?? 0.0);
            productImages.add(prodMap['product_image'] != null
                ? base64Decode(prodMap['product_image'].toString())
                : Uint8List(0));
            productCategories.add(prodMap['product_category']?.toString() ?? '');
            productStocks.add(int.tryParse(prodMap['quantity']?.toString() ?? '0') ?? 0);
            productFlavors.add(prodMap['flavor']?.toString() ?? '');
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cartManager = context.watch<CartManager>();

    final filteredIndexes = <int>[];
    for (int i = 0; i < productNames.length; i++) {
      if (selectedCategory == null || productCategories[i] == selectedCategory) {
        filteredIndexes.add(i);
      }
    }

    const double buttonHeight = 32;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Location',
                        style: TextStyle(color: Colors.grey),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_none),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      Icon(Icons.location_on, color: Colors.green),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Tabuc Suba, Jaro, Iloilo City',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
                            hintText: 'Search products',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.filter_alt_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            SizedBox(
              height: 110,
              child: _ScrollableCategories(
                selectedCategory: selectedCategory,
                onCategorySelected: (category) {
                  setState(() => selectedCategory = category);
                },
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.green))
                  : filteredIndexes.isEmpty
                      ? const Center(child: Text("No products in this category"))
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: filteredIndexes.length,
                          itemBuilder: (_, idx) {
                            final i = filteredIndexes[idx];
                            final productId = productNames[i];
                            final isFav = FavoriteManager().isFavorite(productId);
                            final stock = i < productStocks.length ? productStocks[i] : 0;

                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 3),
                                        color: Colors.black.withOpacity(.1),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                            image: DecorationImage(
                                              image: productImages[i].isNotEmpty
                                                  ? MemoryImage(productImages[i])
                                                  : const AssetImage('assets/no_image.png') as ImageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              productNames[i],
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '₱${productPrices[i].toStringAsFixed(2)}',
                                              style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 6),
                                            stock > 0
                                                ? SizedBox(
                                                    width: double.infinity,
                                                    height: buttonHeight,
                                                    child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.green,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        padding: EdgeInsets.zero,
                                                      ),
                                                      onPressed: () {
                                                        cartManager.addToCart({
                                                          'id': productId,
                                                          'name': productNames[i],
                                                          'price': productPrices[i],
                                                          'image': productImages[i],
                                                          'quantity': 1,
                                                          'flavor': productFlavors[i],
                                                        });
                                                      },
                                                      child: const Text("Add to Cart", style: TextStyle(color: Colors.white, fontSize: 12)),
                                                    ),
                                                  )
                                                : Container(
                                                    width: double.infinity,
                                                    height: buttonHeight,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(color: Colors.red, width: 2),
                                                    ),
                                                    child: const Text(
                                                      "Out of Stock",
                                                      style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: IconButton(
                                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                                        size: 24, color: isFav ? Colors.red : Colors.black),
                                    onPressed: () {
                                      setState(() {
                                        FavoriteManager().toggleFavorite({
                                          'id': productId,
                                          'name': productNames[i],
                                          'price': productPrices[i],
                                          'category': productCategories[i],
                                          'image': productImages[i],
                                          'stock': stock,
                                        });
                                      });
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final cartManager = context.read<CartManager>();

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => ChangeNotifierProvider.value(
              value: cartManager,
              child: FractionallySizedBox(
                heightFactor: 0.85,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: const OrderSummaryPanel(selectedPayment: 'Cash'),
                ),
              ),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.shopping_cart, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _ScrollableCategories extends StatefulWidget {
  final String? selectedCategory;
  final String? defaultCategory;
  final void Function(String? category)? onCategorySelected;

  const _ScrollableCategories({super.key, this.selectedCategory, this.defaultCategory, this.onCategorySelected});

  @override
  State<_ScrollableCategories> createState() => _ScrollableCategoriesState();
}

class _ScrollableCategoriesState extends State<_ScrollableCategories> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  final categories = ['Bread', 'Sourdough', 'Biscotti', 'Cookies', 'Cakes', 'Pie', 'Soft Bread'];
  final double scrollAmount = 200;

  late String? _currentCategory;

  @override
  void initState() {
    super.initState();

    _currentCategory = widget.defaultCategory ?? widget.selectedCategory;

    _scrollController.addListener(() {
      setState(() {
        _showLeftArrow = _scrollController.offset > 0;
        _showRightArrow = _scrollController.offset < _scrollController.position.maxScrollExtent;
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
    _scrollController.animateTo(newOffset, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void scrollRight() {
    double newOffset = _scrollController.offset + scrollAmount;
    if (newOffset > _scrollController.position.maxScrollExtent) newOffset = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(newOffset, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
            final isSelected = _currentCategory == categories[i];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentCategory = categories[i];
                });
                if (widget.onCategorySelected != null) {
                  widget.onCategorySelected!(categories[i]);
                }
              },
              child: Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? Colors.green : Colors.transparent, width: 2),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        "assets/cat_$i.jpg",
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
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
                          fontSize: 14,
                          shadows: [Shadow(blurRadius: 3, color: Colors.black54, offset: Offset(1, 1))],
                        ),
                      ),
                    ),
                  ],
                ),
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
              child: const SizedBox(width: 32, child: Center(child: Icon(Icons.arrow_back_ios, size: 20, color: Colors.black))),
            ),
          ),
        if (_showRightArrow)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: scrollRight,
              child: const SizedBox(width: 32, child: Center(child: Icon(Icons.arrow_forward_ios, size: 20, color: Colors.black))),
            ),
          ),
      ],
    );
  }
}
