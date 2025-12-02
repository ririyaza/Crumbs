import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'dart:typed_data';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final dbRef = FirebaseDatabase.instance.ref();

  List<String> productNames = [];
  List<String> productCategories = [];
  List<double> productPrices = [];
  List<Uint8List> productImages = [];
  List<bool> isFavorite = [];

  List<Map<String, dynamic>> cartItems = [];

  DateTime? pickupTime;
  String selectedPayment = 'Cash';
  bool isLoading = true;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    final snapshot = await dbRef.child('Product').get();
    if (snapshot.exists) {
      final data = snapshot.value;

      productNames.clear();
      productPrices.clear();
      productImages.clear();
      isFavorite.clear();
      productCategories.clear();

      if (data is List) {
        for (var product in data) {
          if (product == null) continue;
          final prodMap = product as Map;

          productNames.add(prodMap['product_name'] ?? 'No Name');
          productPrices.add(double.tryParse(prodMap['unit_price'].toString()) ?? 0.0);
          productImages.add(prodMap['product_image'] != null
              ? base64Decode(prodMap['product_image'])
              : Uint8List(0));
          isFavorite.add(false);

          String category = '';
          if (prodMap['product_category'] != null) {
            category = prodMap['product_category'].toString();
          }
          productCategories.add(category);
        }
      } else if (data is Map) {
        data.forEach((key, value) {
          final prodMap = value as Map;

          productNames.add(prodMap['product_name'] ?? 'No Name');
          productPrices.add(double.tryParse(prodMap['unit_price'].toString()) ?? 0.0);
          productImages.add(prodMap['product_image'] != null
              ? base64Decode(prodMap['product_image'])
              : Uint8List(0));
          isFavorite.add(false);

          String category = '';
          if (prodMap['product_category'] != null) {
            category = prodMap['product_category'].toString();
          }
          productCategories.add(category);
        });
      }
    } else {
      print('No data found at Product node.');
    }

    setState(() {
      isLoading = false;
    });
  }

  double get subTotal =>
      cartItems.fold(0, (sum, item) => sum + (item['price'] as double));
  double get tax => subTotal * 0.12;
  double get discount => 0.0;
  double get total => subTotal + tax - discount;

  @override
  Widget build(BuildContext context) {
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
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 32),
                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.green),
                      )
                    : filteredIndexes.isEmpty
                        ? const Center(
                            child: Text(
                              "No products in this category",
                              style: TextStyle(fontSize: 18),
                            ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 150,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
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
                                              Text(
                                                productNames[i],
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '₱${productPrices[i].toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.green,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            vertical: 12),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      cartItems.add({
                                                        'name': productNames[i],
                                                        'price': productPrices[i],
                                                        'image': MemoryImage(productImages[i]),
                                                        'quantity': 1,
                                                      });
                                                    });
                                                  },
                                                  child: const Text(
                                                    "Add to Cart",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                  ),
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
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isFavorite[i] = !isFavorite[i];
                                        });
                                      },
                                      child: Icon(
                                        isFavorite[i]
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 30,
                                        color: isFavorite[i] ? Colors.red : Colors.black,
                                      ),
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
  child: Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(right: 32),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
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
        Center(
          child: Text(
            "Order Summary",
            style: TextStyle(
              color: Colors.green,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            int month = pickupTime?.month ?? 1;
            int day = pickupTime?.day ?? 1;
            int year = pickupTime?.year ?? DateTime.now().year;
            int hour = pickupTime?.hour ?? 12;
            int minute = pickupTime?.minute ?? 0;
            String amPm = hour >= 12 ? 'PM' : 'AM';
            if (hour > 12) hour -= 12;

            await showDialog(
              context: context,
              builder: (_) => StatefulBuilder(
                builder: (context, setDialogState) => AlertDialog(
                  title: const Text("Set Date & Time Pickup"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                DropdownButton<int>(
                                  value: month,
                                  items: List.generate(
                                    12,
                                    (i) => DropdownMenuItem(
                                      value: i + 1,
                                      child: Text("${i + 1}"),
                                    ),
                                  ),
                                  onChanged: (v) => setDialogState(() => month = v!),
                                ),
                                const Text("Month")
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                DropdownButton<int>(
                                  value: day,
                                  items: List.generate(
                                    31,
                                    (i) => DropdownMenuItem(
                                      value: i + 1,
                                      child: Text("${i + 1}"),
                                    ),
                                  ),
                                  onChanged: (v) => setDialogState(() => day = v!),
                                ),
                                const Text("Day")
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                DropdownButton<int>(
                                  value: year,
                                  items: List.generate(
                                    5,
                                    (i) => DropdownMenuItem(
                                      value: DateTime.now().year + i,
                                      child: Text("${DateTime.now().year + i}"),
                                    ),
                                  ),
                                  onChanged: (v) => setDialogState(() => year = v!),
                                ),
                                const Text("Year")
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                DropdownButton<int>(
                                  value: hour,
                                  items: List.generate(
                                    12,
                                    (i) => DropdownMenuItem(
                                      value: i + 1,
                                      child: Text("${i + 1}"),
                                    ),
                                  ),
                                  onChanged: (v) => setDialogState(() => hour = v!),
                                ),
                                const Text("Hour")
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                DropdownButton<int>(
                                  value: minute,
                                  items: List.generate(
                                    60,
                                    (i) => DropdownMenuItem(
                                      value: i,
                                      child: Text("${i.toString().padLeft(2, '0')}"),
                                    ),
                                  ),
                                  onChanged: (v) => setDialogState(() => minute = v!),
                                ),
                                const Text("Min")
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                DropdownButton<String>(
                                  value: amPm,
                                  items: const [
                                    DropdownMenuItem(value: 'AM', child: Text('AM')),
                                    DropdownMenuItem(value: 'PM', child: Text('PM')),
                                  ],
                                  onChanged: (v) => setDialogState(() => amPm = v!),
                                ),
                                const Text("AM/PM")
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () {
                        int h = hour;
                        if (amPm == 'PM' && h != 12) h += 12;
                        if (amPm == 'AM' && h == 12) h = 0;
                        setState(() {
                          pickupTime = DateTime(year, month, day, h, minute);
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Save"),
                    )
                  ],
                ),
              ),
            );
          },
          child: Row(
            children: [
              const Text("Pick up time", style: TextStyle(fontSize: 16)),
              const Spacer(),
              Text(
                pickupTime != null
                    ? "${pickupTime!.month}/${pickupTime!.day}/${pickupTime!.year} ${pickupTime!.hour}:${pickupTime!.minute.toString().padLeft(2, '0')}"
                    : "Select Time",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down_outlined),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (_, i) {
              final item = cartItems[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: item['image'] ?? const AssetImage('assets/no_image.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item['name']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        setState(() {
                          if (item['quantity'] > 1) {
                            item['quantity']--;
                          } else {
                            cartItems.removeAt(i);
                          }
                        });
                      },
                    ),
                    Text('${item['quantity']}'),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        setState(() {
                          item['quantity']++;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₱${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Sub Total"),
            Text(
              '₱${cartItems.fold(0.0, (sum, e) => sum + (e['price'] as double) * (e['quantity'] as int)).toStringAsFixed(2)}',
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Tax"),
            Text(
              '₱${(cartItems.fold(0.0, (sum, e) => sum + (e['price'] as double) * (e['quantity'] as int)) * 0.12).toStringAsFixed(2)}',
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Discount"),
            Text('₱0.00'),
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Total Amount",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '₱${(cartItems.fold(0.0, (sum, e) => sum + (e['price'] as double) * (e['quantity'] as int)) * 1.12).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => selectedPayment = 'Cash'),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: selectedPayment == 'Cash' ? Colors.green : Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.money, color: Colors.green),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => setState(() => selectedPayment = 'Credit'),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: selectedPayment == 'Credit' ? Colors.green : Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.credit_card, color: Colors.green),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
            },
            child: const Text(
              "Place Order",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  ),
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

  final categories = ['Bread', 'Sourdough', 'Biscotti', 'Cookies', 'Cakes', 'Pie'];
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
                  widget.onCategorySelected!(categories[i]);
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
