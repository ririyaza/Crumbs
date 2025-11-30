import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../database_service.dart';

class IngredientsPage extends StatefulWidget {
  const IngredientsPage({super.key});

  @override
  State<IngredientsPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<IngredientsPage> {
  final dbServices = DatabaseService();
  late DatabaseReference productRef;

  List<Map<String, String>> _ingredientsItems =[];
  bool isLoading = true;

   void initState() {
    super.initState();
    productRef = dbServices.firebaseDatabase.child('Ingredients');
    fetchIngredients();
  }

  static const double _tablePadding = 24;
  static const double _headerSpacing = 24;
  static const double _rowSpacing = 16;
  static const double _columnSpacing = 90;
  static const double _itemNameLeftSpacing = 100;
  
  static const int _itemNameFlex = 3;
  static const int _idFlex = 1;
  static const int _currentStockFlex = 1;
  static const int _isReservedFlex = 1;
  static const int _isAvailableFlex = 1;
  static const int _ingredientsThresholdFlex = 1;
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
                  'Ingredients Inventory Management',
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
                  _showAddNewIngredientDialog(context);
                },
                child: const Text(
                  '+ New Ingredient',
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
                'Recently Added (${_ingredientsItems.length} items)',
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
        SizedBox(width: _itemNameLeftSpacing),
        _buildHeaderCell('Item Name', flex: _itemNameFlex),
        SizedBox(width: _columnSpacing),
        _buildHeaderCell('ID', flex: _idFlex),
        SizedBox(width: _columnSpacing),
        _buildHeaderCell('Current Stock', flex: _currentStockFlex),
        SizedBox(width: _columnSpacing),
        _buildHeaderCell('Reserved', flex: _isReservedFlex),
        SizedBox(width: _columnSpacing),
        _buildHeaderCell('Available', flex: _isAvailableFlex),
        SizedBox(width: _columnSpacing),
        _buildHeaderCell('Threshold', flex: _ingredientsThresholdFlex),
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
      children: _ingredientsItems.map(
        (item) => Padding(
          padding: EdgeInsets.symmetric(vertical: _rowSpacing),
          child: Row(
            children: [
              SizedBox(width: _itemNameLeftSpacing),
              _buildTableCell(item['name'] ?? '', flex: _itemNameFlex),
              SizedBox(width: _columnSpacing),
              _buildTableCell(item['id'] ?? '', flex: _idFlex),
              SizedBox(width: _columnSpacing),
              _buildTableCell(item['currentStock'] ?? '', flex: _currentStockFlex),
              SizedBox(width: _columnSpacing),
              _buildTableCell(item['ingredientsReserved'] ?? '', flex: _isReservedFlex),
              SizedBox(width: _columnSpacing),
              _buildTableCell(item['ingredientsAvailable'] ?? '', flex: _isAvailableFlex),
              SizedBox(width: _columnSpacing),
              _buildTableCell(item['ingredientsThreshold'] ?? '', flex: _ingredientsThresholdFlex),
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
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController reservedController = TextEditingController();
  final TextEditingController availableController = TextEditingController();
  final TextEditingController thresholdController = TextEditingController();

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
                                children: const [
                                  Text(
                                    'Add Stock',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Note: fill up all the information needed',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
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

                        const Text('Ingredient ID', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: idController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter Ingredient ID';
                            if (int.tryParse(value) == null) return 'ID must be a number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        const Text('Ingredient Name', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter Ingredient Name';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: qtyController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter Quantity';
                            if (int.tryParse(value) == null) return 'Quantity must be a number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        const Text('Reserved', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: reservedController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter Reserved quantity';
                            if (int.tryParse(value) == null) return 'Reserved must be a number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        const Text('Available', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: availableController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter Available quantity';
                            if (int.tryParse(value) == null) return 'Available must be a number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        const Text('Threshold', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: thresholdController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter Threshold';
                            if (int.tryParse(value) == null) return 'Threshold must be a number';
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                           onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final id = idController.text.trim();
                              final name = nameController.text.trim();
                              final qty = qtyController.text.trim();
                              final reserved = reservedController.text.trim();
                              final available = availableController.text.trim();
                              final threshold = thresholdController.text.trim();

                              final index = _ingredientsItems.indexWhere((item) => item['id'] == id);

                              if (index != -1) {
                                if (_ingredientsItems[index]['name'] != name) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Ingredient name does not match the ID!'),
                                    ),
                                  );
                                  return; 
                                }

                                await dbServices.update(
                                  path: "Ingredients/$id",
                                  data: {
                                    "ingredient_id": id,
                                    "ingredient_name": name,
                                    "quantity": qty,
                                    "reserved": reserved,
                                    "available": available,
                                    "threshold": threshold,
                                    "status": 'In Stock',
                                  },
                                );

                                setState(() {
                                  _ingredientsItems[index] = {
                                    'id': id,
                                    'name': name,
                                    'currentStock': qty,
                                    'ingredientsReserved': reserved,
                                    'ingredientsAvailable': available,
                                    'ingredientsThreshold': threshold,
                                    'status': 'In Stock',
                                  };
                                });

                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Stock updated successfully!')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Ingredient ID not found! Cannot add stock.')),
                                );
                              }
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


void _showAddNewIngredientDialog(BuildContext context) {
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

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
                                  'Add Ingredient',
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

                      const Text('Ingredient ID', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: idController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Ingredient ID';
                          }
                          if (int.tryParse(value) == null) {
                            return 'ID must be a number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      const Text('Ingredient Name', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter Ingredient Name';
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
                              await dbServices.create(
                                path: "Ingredients/${idController.text}",
                                data: {
                                  "ingredient_id": idController.text,
                                  "ingredient_name": nameController.text,
                                  "status": 'In Stock',
                                  "quantity": '0',
                                  "reserved": '0',
                                  "available": '0',
                                  "threshold": '0',
                                },
                              );

                              Navigator.of(context).pop();
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

void fetchIngredients() {
  setState(() => isLoading = true);

  productRef.onValue.listen((event) {
    final snapshot = event.snapshot;

    if (snapshot.exists) {
      List<Map<String, String>> products = [];
      for (var child in snapshot.children) {
        final data = child.value as Map<dynamic, dynamic>;
        products.add({
          'id': data['ingredient_id'].toString(),
          'name': data['ingredient_name'].toString(),
          'currentStock': data['quantity'].toString(),
          'ingredientsReserved': data['reserved']?.toString() ?? '0',
          'status': data['status'].toString(),
          'ingredientsAvailable': data['available']?.toString() ?? '0',
          'ingredientsThreshold': data['threshold']?.toString() ?? '0',
        });
      }

      setState(() {
        _ingredientsItems = products;
        isLoading = false;
      });
    } else {
      setState(() => _ingredientsItems = []);
    }
  });
}
  
}
