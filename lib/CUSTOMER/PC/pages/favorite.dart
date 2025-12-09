import 'package:flutter/material.dart';
import 'dart:typed_data';

import '../components/helper/favorite_manager.dart';

class FavoritePage extends StatefulWidget {
  final String customerId;
  const FavoritePage({super.key, required this.customerId});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Map<String, dynamic>> cartItems = [];
  DateTime? pickupTime;
  String selectedPayment = 'Cash';

  double get subTotal =>
      cartItems.fold(0.0, (sum, item) => sum + (item['price'] as double) * (item['quantity'] as int));
  double get tax => subTotal * 0.12;
  double get discount => 0.0;
  double get total => subTotal + tax - discount;

  @override
  void initState() {
    super.initState();
    cartItems = FavoriteManager().favorites
        .map((item) => {
              'id': item['id'],
              'name': item['name'],
              'price': item['price'],
              'image': item['image'],
              'quantity': 1,
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = FavoriteManager().favorites;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: favorites.isEmpty
                ? const Center(
                    child: Text(
                      'No favorite products',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final product = favorites[index];
                      final Uint8List image = product['image'] ?? Uint8List(0);
                      final name = product['name'] ?? 'No Name';
                      final price = product['price'] ?? 0.0;

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
                                      image: image.isNotEmpty
                                          ? MemoryImage(image)
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
                                        name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₱${(price as double).toStringAsFixed(2)}',
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
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              final existingIndex = cartItems
                                                  .indexWhere((item) =>
                                                      item['id'] ==
                                                      product['id']);
                                              if (existingIndex != -1) {
                                                cartItems[existingIndex]
                                                    ['quantity']++;
                                              } else {
                                                cartItems.add({
                                                  'id': product['id'],
                                                  'name': name,
                                                  'price': price,
                                                  'image': image,
                                                  'quantity': 1,
                                                });
                                              }
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
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 12,
                            top: 12,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  FavoriteManager().toggleFavorite(product);
                                  cartItems
                                      .removeWhere((item) => item['id'] == product['id']);
                                });
                              },
                              child: const Icon(
                                Icons.favorite,
                                size: 30,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
                                            (i) => DropdownMenuItem(value: i + 1, child: Text("${i + 1}")),
                                          ),
                                          onChanged: (v) => setDialogState(() => month = v!),
                                        ),
                                        const Text("Month"),
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
                                            (i) => DropdownMenuItem(value: i + 1, child: Text("${i + 1}")),
                                          ),
                                          onChanged: (v) => setDialogState(() => day = v!),
                                        ),
                                        const Text("Day"),
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
                                                child: Text("${DateTime.now().year + i}")),
                                          ),
                                          onChanged: (v) => setDialogState(() => year = v!),
                                        ),
                                        const Text("Year"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        DropdownButton<int>(
                                          value: hour,
                                          items: List.generate(
                                            12,
                                            (i) => DropdownMenuItem(value: i + 1, child: Text("${i + 1}")),
                                          ),
                                          onChanged: (v) => setDialogState(() => hour = v!),
                                        ),
                                        const Text("Hour"),
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
                                                value: i, child: Text(i.toString().padLeft(2, '0'))),
                                          ),
                                          onChanged: (v) => setDialogState(() => minute = v!),
                                        ),
                                        const Text("Min"),
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
                                        const Text("AM/PM"),
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
                                  image: item['image'] != null
                                      ? MemoryImage(item['image'])
                                      : const AssetImage('assets/no_image.png')
                                          as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(item['name'])),
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
                    Text('₱${subTotal.toStringAsFixed(2)}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Tax"),
                    Text('₱${tax.toStringAsFixed(2)}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Discount"),
                    Text('₱${discount.toStringAsFixed(2)}'),
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
                      '₱${total.toStringAsFixed(2)}',
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
                              color: selectedPayment == 'Cash'
                                  ? Colors.green
                                  : Colors.grey),
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
                              color: selectedPayment == 'Credit'
                                  ? Colors.green
                                  : Colors.grey),
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
