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
  
  List<Map<String, String>> _inventoryItems =[];
  bool isLoading = true;

  void initState() {
    super.initState();
    productRef = dbServices.firebaseDatabase.child('Product');
    fetchProducts();
  }

  static const double _tablePadding = 24;
  static const double _headerSpacing = 24;
  static const double _rowSpacing = 16;
  static const double _columnSpacing = 120;
  static const double _productNameLeftSpacing = 100;
  
  static const int _productNameFlex = 3;
  static const int _idFlex = 1;
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
                  _showAddStockDialog(context);
                },
                child: const Text(
                  '+ Add Stock',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
      padding: const EdgeInsets.all(_tablePadding),
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

  Widget _buildTableHeader() {
    return Row(
      children: [
        SizedBox(width: _productNameLeftSpacing),
        _buildHeaderCell('Product Name', flex: _productNameFlex),
        SizedBox(width: _columnSpacing),
        _buildHeaderCell('ID', flex: _idFlex),
        SizedBox(width: _columnSpacing),
        _buildHeaderCell('Item Sold', flex: _itemSoldFlex),
        SizedBox(width: _columnSpacing),
        _buildHeaderCell('In Stock', flex: _inStockFlex),
        SizedBox(width: _columnSpacing),
        _buildHeaderCell('Unit Price', flex: _unitPriceFlex),
        SizedBox(width: _columnSpacing),
        _buildHeaderCell('Total Value', flex: _totalValueFlex),
        SizedBox(width: _columnSpacing),
        _buildHeaderCell('Status', flex: _statusFlex),
      ],
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTableRows() {
    return Column(
      children: _inventoryItems.map(
        (item) => Padding(
          padding: EdgeInsets.symmetric(vertical: _rowSpacing),
          child: Row(
            children: [
              SizedBox(width: _productNameLeftSpacing),
              _buildTableCell(item['name'] ?? '', flex: _productNameFlex),
              SizedBox(width: _columnSpacing),
              _buildTableCell(item['id'] ?? '', flex: _idFlex),
              SizedBox(width: _columnSpacing),
              _buildTableCell(item['itemSold'] ?? '', flex: _itemSoldFlex),
              SizedBox(width: _columnSpacing),
              _buildTableCell(item['inStock'] ?? '', flex: _inStockFlex),
              SizedBox(width: _columnSpacing),
              _buildTableCell(item['unitPrice'] ?? '', flex: _unitPriceFlex),
              SizedBox(width: _columnSpacing),
              _buildTableCell(item['totalValue'] ?? '', flex: _totalValueFlex),
              SizedBox(width: _columnSpacing),
              _buildTableCell(item['status'] ?? '', flex: _statusFlex),
            ],
          ),
        ),
      ).toList(),
    );
  }

  Widget _buildTableCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showAddStockDialog(BuildContext context) {
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController flavorController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  final List<String> categories = ['Please choose a category', 'Bread', 'Sourdough', 'Biscotti', 'Cookies', 'Cakes', 'Pie'];
  String? selectedCategory = "Please choose a category";

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
            child: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: Form(
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
                                    'Add Stock',
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

                        const Text('Product ID', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: idController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter Product ID';
                            if (int.tryParse(value) == null) return 'ID must be a number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        const Text('Product Name', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter Product Name';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        const Text('Product Category', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          items: categories.map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          )).toList(),
                          onChanged: (value) => setState(() => selectedCategory = value),
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          validator: (value) => value == null || value.isEmpty ? 'Please select a category' : null,
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
                        const SizedBox(height: 16),

                        const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter Quantity';
                            if (int.tryParse(value) == null) return 'Quantity must be a number';
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
                             if (_formKey.currentState!.validate()) {
                              final productId = idController.text;
                              final productName = nameController.text;
                              final category = selectedCategory!;
                              final flavor = flavorController.text;
                              final quantityToAdd = int.parse(quantityController.text);

                              final snapshot = await dbServices.read(path: 'Product/$productId');

                              if (snapshot == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Product not found in database!')),
                                );
                                return;
                              }

                              final data = snapshot.value as Map<dynamic, dynamic>;

                              if (data['product_name'] != productName ||
                                  data['product_category'] != category ||
                                  data['flavor'] != flavor) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Product details do not match database!')),
                                );
                                return;
                              }

                              int currentStock = int.tryParse(data['quantity'].toString()) ?? 0;
                              int newStock = currentStock + quantityToAdd;

                              double unitPrice = double.tryParse(data['unit_price'].toString().replaceAll('₱', '')) ?? 0;
                              double totalValue = unitPrice * newStock;

                              await dbServices.update(path: 'Product/$productId', data: {
                                'quantity': newStock.toString(),
                                'total_value': '₱${totalValue.toStringAsFixed(2)}',
                              });

                              setState(() {
                                int index = _inventoryItems.indexWhere((item) => item['id'] == productId);
                                if (index != -1) {
                                  _inventoryItems[index]['inStock'] = newStock.toString();
                                  _inventoryItems[index]['totalValue'] = '₱${totalValue.toStringAsFixed(2)}';
                                }
                              });

                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Stock updated successfully!')),
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
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

void fetchProducts() {
  setState(() => isLoading = true);

  productRef.onValue.listen((event) {
    final snapshot = event.snapshot;

    if (snapshot.exists) {
      List<Map<String, String>> products = [];
      for (var child in snapshot.children) {
        final data = child.value as Map<dynamic, dynamic>;
        products.add({
          'id': data['product_id'].toString(),
          'name': data['product_name'].toString(),
          'inStock': data['quantity'].toString(),
          'unitPrice': '₱${data['unit_price'].toString()}',
          'status': data['status'].toString(),
          'product_image': data['product_image']?.toString() ?? '',
          'itemSold': data['item_sold']?.toString() ?? '0',
          'totalValue': data['total_value']?.toString() ?? '₱0.00',
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
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController flavorController = TextEditingController();
  String selectedCategory = 'Please choose a category';
  final List<String> categories = ['Please choose a category', 'Bread', 'Sourdough', 'Biscotti', 'Cookies', 'Cakes', 'Pie'];

  String? selectedImagePath;
  Uint8List? selectedImageBytes;
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
                      const Text('Product ID', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: idController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter Product ID';
                          if (int.tryParse(value) == null) return 'ID must be a number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Product Name', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter Product Name';
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
                          if (value == null || value.isEmpty) return 'Please select a category';
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
                            if (selectedImageBytes != null)
                              Center(
                                child: Text(
                                  selectedImagePath!,
                                  style: const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            if (_isHovering)
                              Positioned(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                                      type: FileType.image,
                                    );

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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.green,
                            child: const Icon(Icons.check, size: 16, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          const Text('Valid format: Document name.png'),
                          const Spacer(),
                          if (selectedImageBytes != null)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedImageBytes = null;
                                  selectedImagePath = null;
                                });
                              },
                              child: const Icon(Icons.delete, color: Colors.red),
                            ),
                        ],
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
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.green,
                            child: Icon(Icons.check, size: 16, color: Colors.white),
                          ),
                          SizedBox(width: 8),
                          Text('Charged with tax'),
                        ],
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
                            if (_formKey.currentState!.validate()) {
                              if (selectedImageBytes == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please select a product image')),
                                );
                                return;
                              }

                              final String path = 'Product/${idController.text}';
                              await dbServices.create(path: path, data: {
                                'product_id': idController.text,
                                'product_name': nameController.text,
                                'product_category': selectedCategory,
                                'product_image': selectedImagePath,
                                'unit_price': priceController.text,
                                'flavor': flavorController.text,
                                'status': 'In Stock',
                                'quantity': '0',
                              });

                              Navigator.of(context).pop();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('New product added successfully!')),
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
