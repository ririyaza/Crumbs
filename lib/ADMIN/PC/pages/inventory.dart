import 'dart:convert';

import 'package:final_project/database_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final dbServices = DatabaseService();
  late DatabaseReference productRef;
  List<Map<String, dynamic>> _inventoryItems = [];
  bool isLoading = true;

  void initState() {
    super.initState();
    productRef = dbServices.firebaseDatabase.child('Product');
    fetchProducts();
  }

  static const double _tablePadding = 24;
  static const double _headerSpacing = 24;
  static const double _rowSpacing = 32;
  
  static const int _productNameFlex = 2;
  static const int _itemSoldFlex = 1;
  static const int _inStockFlex = 1;
  static const int _unitPriceFlex = 1;
  static const int _totalValueFlex = 1;
  static const int _statusFlex = 2;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Product Inventory Management',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B027),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  _showAddNewProductDialog(context);
                },
                child: const Text(
                  '+ New Product',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInventoryTable(),
        ],
      ),
    );
  }

  Widget _buildInventoryTable() {
  return Container(
    padding: const EdgeInsets.fromLTRB(16, _tablePadding, _tablePadding, _tablePadding),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recently Added (${_inventoryItems.length} items)',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'View All Recent Items',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),  
        SizedBox(height: _headerSpacing),
        _buildTableHeader(),
        const Divider(height: 32),
        _buildTableRows()
      ],
    ),
  );
}

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
  
  Widget _buildTableHeader() {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        flex: _productNameFlex,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Product Name',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
      Expanded(
        flex: _itemSoldFlex,
        child: Padding(
          padding: const EdgeInsets.only(left: 83.0, right: 8.0),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              'Item Sold',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
      Expanded(
        flex: _inStockFlex,
        child: Padding(
          padding: const EdgeInsets.only(left: 75.0, right: 8.0),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              'In Stock',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
      Expanded(
        flex: _unitPriceFlex,
        child: Padding(
          padding: const EdgeInsets.only(left: 66.0, right: 8.0),
          child: Text(
            'Unit Price',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
      Expanded(
        flex: _totalValueFlex,
        child: Padding(
          padding: const EdgeInsets.only(left: 86.0, right: 8.0),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              'Total Value',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
      Expanded(
        flex: _statusFlex,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              'Status',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: Align(
          alignment: Alignment.center,
          child: Text(
            'Actions',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    ],
  );
}


 

Widget _buildTableRows() {
  return Column(
    children: _inventoryItems.map((item) {
      bool isEditing = item['isEditing'] == 'true';
      int currentQty = item['inStock'] ?? 0;
      double unitPrice = item['unitPrice'] is double
          ? item['unitPrice']
          : double.tryParse(item['unitPrice'].toString()) ?? 0.0;
      double totalValue = currentQty * unitPrice;

      return Padding(
        padding: EdgeInsets.symmetric(vertical: _rowSpacing / 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 6.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: (item['product_image'] != null && item['product_image'] != '')
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            base64Decode(item['product_image']),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.image_not_supported, size: 40),
                ),
              ),
            ),
            Expanded(
              flex: _productNameFlex,
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 6.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item['name'] ?? '',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: _itemSoldFlex,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    '${item['itemSold'] ?? 0}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: _inStockFlex,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Align(
                  alignment: Alignment.center,
                  child: isEditing
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                setState(() {
                                  if (currentQty > 0) currentQty--;
                                  item['inStock'] = currentQty;
                                  item['totalValue'] = currentQty * unitPrice;
                                });
                              },
                            ),
                            SizedBox(
                              width: 28,
                              child: Center(
                                child: Text(
                                  '$currentQty',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                setState(() {
                                  currentQty++;
                                  item['inStock'] = currentQty;
                                  item['totalValue'] = currentQty * unitPrice;
                                });
                              },
                            ),
                          ],
                        )
                      : Text(
                          '$currentQty',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                ),
              ),
            ),
            Expanded(
              flex: _unitPriceFlex,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    '₱${unitPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: _totalValueFlex,
              child: Padding(
                padding: const EdgeInsets.only(left: 44.0, right: 4.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    '₱${totalValue.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: _statusFlex,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Align(
                  alignment: Alignment.center,
                  child: _buildStockStatus(int.tryParse(item['inStock'].toString()) ?? 0),
                ),
              ),
            ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isEditing)
                  IconButton(
                    icon: const Icon(Icons.edit_square, size: 24),
                    onPressed: () {
                      setState(() => item['isEditing'] = 'true');
                    },
                    tooltip: "Edit Quantity",
                  ),
                if (isEditing)
                  IconButton(
                    icon: const Icon(Icons.check_circle, size: 26, color: Colors.green),
                    tooltip: "Save Quantity",
                    onPressed: () async {
                      setState(() => item['isEditing'] = 'false');

                      int qty = item['inStock'];
                      double unitPrice = item['unitPrice'] is double
                          ? item['unitPrice']
                          : double.tryParse(item['unitPrice'].toString()) ?? 0.0;

                      String newStatus;
                      if (qty == 0) {
                        newStatus = 'Out of Stock';
                      } else if (qty < 10) {
                        newStatus = 'Low Stock';
                      } else {
                        newStatus = 'In Stock';
                      }

                      await dbServices.update(
                        path: "Product/${item['id']}",
                        data: {
                          'quantity': qty,
                          'total_value': qty * unitPrice,
                          'status': newStatus,
                        },
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Quantity updated!")),
                      );
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 24, color: Colors.red),
                  onPressed: () async {
                    await dbServices.delete(path: "Product/${item['id']}");
                    setState(() => _inventoryItems.remove(item));

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Product deleted!")),
                    );
                  },
                  tooltip: "Delete Product",
                ),
              ],
            ),
          ),
          ],
        ),
      );
    }).toList(),
  );
}



void fetchProducts() {
  setState(() => isLoading = true);

  productRef.onValue.listen((event) {
    final snapshot = event.snapshot;

    if (snapshot.exists) {
      List<Map<String, dynamic>> products = [];
      for (var child in snapshot.children) {
        final data = child.value as Map<dynamic, dynamic>;
        final int inStock = int.tryParse(data['quantity'].toString()) ?? 0;
        final double unitPrice = (data['unit_price'] is String) ? double.tryParse(data['unit_price']) ?? 0.0 : (data['unit_price'] as double?) ?? 0.0;
        
        products.add({
        'id': data['product_id'].toString(),
        'name': data['product_name'].toString(),
        'inStock': data['quantity'] ?? 0,
        'unitPrice': (data['unit_price'] is String) ? double.tryParse(data['unit_price']) ?? 0.0 : (data['unit_price'] as double?) ?? 0.0,
        'status': data['status'].toString(),
        'product_image': data['product_image']?.toString() ?? '',
        'itemSold': data['item_sold'] ?? 0,
        'totalValue': inStock * unitPrice,
      });
      }

      setState(() {
        _inventoryItems = products;
        isLoading = false;
      });
    } else {
      setState(() => _inventoryItems = []);
    }
  });
}

void _showAddNewProductDialog(BuildContext context) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController flavorController = TextEditingController();

  String selectedCategory = 'Please choose a category';
  final List<String> categories = [
    'Please choose a category',
    'Bread',
    'Sourdough',
    'Biscotti',
    'Cookies',
    'Cakes',
    'Pie',
    'Soft Bread'
  ];

  Uint8List? selectedImageBytes;
  String? selectedImagePath;
  bool _isHovering = false;
  final _formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SizedBox(
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) => Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Add Product',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Note: fill up all the information needed',
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                                SizedBox(height: 24),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Icon(Icons.close, size: 28),
                            ),
                          ),
                        ],
                      ),
                      const Text('Product Name', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter Product Name';
                          if (_inventoryItems.any((p) => p['name'].toString().toLowerCase() == value.toLowerCase())) {
                            return 'Product already exists';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Product Category', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => selectedCategory = value);
                        },
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty || value == 'Please choose a category') {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Product Image', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      MouseRegion(
                        onEnter: (_) => setState(() => _isHovering = true),
                        onExit: (_) => setState(() => _isHovering = false),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade100,
                                image: selectedImageBytes != null
                                    ? DecorationImage(
                                        image: MemoryImage(selectedImageBytes!),
                                        fit: BoxFit.cover,
                                        colorFilter: ColorFilter.mode(
                                          Colors.black.withOpacity(0.3),
                                          BlendMode.darken,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            if (selectedImageBytes != null && selectedImagePath != null)
                              Center(
                                child: Text(
                                  selectedImagePath!,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            if (_isHovering)
                              Positioned(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                                    if (result != null && result.files.isNotEmpty) {
                                      setState(() {
                                        selectedImagePath = result.files.single.name;
                                        selectedImageBytes = result.files.single.bytes;
                                      });
                                    }
                                  },
                                  child: const Text("Select an image"),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Product Price', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter Product Price';
                          if (double.tryParse(value) == null) return 'Price must be a number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Flavor', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: flavorController,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter Flavor';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00B027),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;
                            if (selectedImageBytes == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select a product image')),
                              );
                              return;
                            }

                            try {
                              String base64Image = base64Encode(selectedImageBytes!);
                              double unitPrice = double.tryParse(priceController.text) ?? 0.0;

                              DatabaseReference newProductRef = productRef.push();
                              String newProductId = newProductRef.key!;

                              await newProductRef.set({
                                'product_id': newProductId,
                                'product_name': nameController.text,
                                'product_category': selectedCategory,
                                'product_image': base64Image,
                                'unit_price': unitPrice,
                                'flavor': flavorController.text,
                                'status': 'In Stock',
                                'quantity': 0,
                                'item_sold': 0,
                                'total_value': 0.0,
                              });

                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('New product added successfully!')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error adding product: $e')),
                              );
                            }
                          },
                          child: const Text(
                            'Add',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
}
