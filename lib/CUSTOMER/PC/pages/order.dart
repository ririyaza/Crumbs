import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../components/helper/cart_manager.dart';
import '../components/helper/favorite_manager.dart';
import '../components/helper/order_summary_panel.dart';

class OrderPage extends StatefulWidget {
  final String customerId;
  final String? initialCategory;
  
  const OrderPage({super.key, required this.customerId, this.initialCategory});

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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 110,
                  child: _ScrollableCategories(
                    selectedCategory: selectedCategory,
                    onCategorySelected: (category) {
                      setState(() => selectedCategory = category);
                    },
                  ),
                ),
                const SizedBox(height: 32),
                isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.green))
                    : filteredIndexes.isEmpty
                        ? const Center(
                            child: Text("No products in this category",
                                style: TextStyle(fontSize: 18)),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 30,
                              mainAxisExtent: 300,
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
                                        Container(
                                          height: 150,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.vertical(
                                                top: Radius.circular(16)),
                                            image: DecorationImage(
                                              image: productImages[i].isNotEmpty
                                                  ? MemoryImage(productImages[i])
                                                  : const AssetImage(
                                                          'assets/no_image.png')
                                                      as ImageProvider,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(productNames[i],
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              const SizedBox(height: 4),
                                              Text(
                                                  '₱${productPrices[i].toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const SizedBox(height: 16),
                                              stock > 0
                                                  ? SizedBox(
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.green,
                                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
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
                                                        child: const Text("Add to Cart",
                                                            style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 16)),
                                                      ),
                                                    )
                                                  : Container(
                                                      width: double.infinity,
                                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                                      alignment: Alignment.center,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(12),
                                                        border: Border.all(color: Colors.red, width: 2),
                                                      ),
                                                      child: const Text(
                                                        "Out of Stock",
                                                        style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    right: 12,
                                    top: 12,
                                    child: IconButton(
                                      icon: Icon(
                                          isFav
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          size: 30,
                                          color: isFav ? Colors.red : Colors.black),
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
              ],
            ),
          ),
        ),
        SizedBox(
          width: 400,
          child: OrderSummaryPanel(selectedPayment: 'Cash'),
        ),
      ],
    );
  }
}

class _ScrollableCategories extends StatefulWidget {
  final String? selectedCategory;
  final void Function(String? category)? onCategorySelected;

  const _ScrollableCategories({super.key, this.selectedCategory, this.onCategorySelected});

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
            final isSelected = widget.selectedCategory == categories[i];
            return GestureDetector(
              onTap: () {
            if (widget.onCategorySelected != null) {
              if (widget.selectedCategory == categories[i]) {
                widget.onCategorySelected!(null); 
              } else {
                widget.onCategorySelected!(categories[i]);
              }
            }
          },
              child: Container(
                width: 190,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.green : Colors.transparent,
                    width: 2,
                  ),
                ),
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
                          shadows: [
                            Shadow(
                              blurRadius: 3,
                              color: Colors.black54,
                              offset: Offset(1, 1),
                            ),
                          ],
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
              child: const SizedBox(
                width: 40,
                child: Center(
                  child: Icon(Icons.arrow_back_ios, size: 24, color: Colors.black),
                ),
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
                child: Center(
                  child: Icon(Icons.arrow_forward_ios, size: 24, color: Colors.black),
                ),
              ),
            ),
          ),
      ],
    );
  }
}