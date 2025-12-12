import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../database_service.dart';

class IngredientsPage extends StatefulWidget {
  const IngredientsPage({super.key});

  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  final dbServices = DatabaseService();
  late DatabaseReference productRef;

  List<Map<String, dynamic>> _ingredientsItems = [];
  bool isLoading = true;

  static const double _tablePadding = 24;
  static const double _headerSpacing = 24;
  static const double _rowSpacing = 16;
  static const double _itemNameLeftSpacing = 100;

  static const int _itemNameFlex = 3;
  static const int _currentStockFlex = 1;
  static const int _isReservedFlex = 1;
  static const int _isAvailableFlex = 1;
  static const int _ingredientsThresholdFlex = 1;
  static const int _statusFlex = 2;

  @override
  void initState() {
    super.initState();
    productRef = dbServices.firebaseDatabase.child('Ingredients');
    fetchIngredients();
  }

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

   Widget _buildEditableCell({
  required int value,
  required bool isEditing,
  required Function(int) onChanged,
}) {
  if (!isEditing) {
    return Center(child: Text(value.toString(), style: const TextStyle(fontSize: 15)));
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      GestureDetector(
        onTap: () => onChanged(value - 1 < 0 ? 0 : value - 1),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: const Icon(Icons.remove, size: 16),
        ),
      ),
      const SizedBox(width: 4),
      Text(value.toString(), style: const TextStyle(fontSize: 15)),
      const SizedBox(width: 4),
      GestureDetector(
        onTap: () => onChanged(value + 1),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: const Icon(Icons.add, size: 16),
        ),
      ),
    ],
  );
}


  String getStatus(int available) {
  if (available > 0 && available < 20) {
    return 'Re-stock';
  } else if (available >= 20 && available <= 30) {
    return 'Low on Stock';
  } else if (available > 30) {
    return 'OK';
  } else {
    return 'Out of Stock';
  }
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
        _buildTableRows(),
      ],
    ),
  );
}

Widget _buildTableHeader() {
  return Row(
    children: [
      SizedBox(width: _itemNameLeftSpacing),
      Expanded(
        flex: _itemNameFlex,
        child: Text(
          'Item Name',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      Expanded(
        flex: _currentStockFlex,
        child: Text(
          'Current Stock',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      Expanded(
        flex: _isReservedFlex,
        child: Text(
          'Reserved',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      Expanded(
        flex: _isAvailableFlex,
        child: Text(
          'Available',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      Expanded(
        flex: _ingredientsThresholdFlex,
        child: Text(
          'Threshold',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      Expanded(
        flex: _statusFlex,
        child: Text(
          'Status',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      Expanded(
        flex: 1,
        child: Text(
          'Actions',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ],
  );
}

Widget _buildTableRows() {
  return Column(
    children: _ingredientsItems.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> item = entry.value;
      bool isEditing = item['isEditing'] == true;

      int currentStock = int.tryParse(item['currentStock'] ?? '0') ?? 0;
      int reserved = int.tryParse(item['ingredientsReserved'] ?? '0') ?? 0;
      int available = int.tryParse(item['ingredientsAvailable'] ?? '0') ?? 0;
      int threshold = int.tryParse(item['ingredientsThreshold'] ?? '0') ?? 0;

      String statusText;
      Color statusColor;

      if (currentStock > 0 && currentStock < 20) {
        statusText = 'Re-stock';
        statusColor = Colors.red;
      } else if (currentStock >= 20 && currentStock <= 30) {
        statusText = 'LOW';
        statusColor = Colors.orange;
      } else if (currentStock > 30) {
        statusText = 'OK';
        statusColor = Colors.green;
      } else {
        statusText = 'Out of Stock';
        statusColor = Colors.grey;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: _rowSpacing / 2),
        child: Row(
          children: [
            SizedBox(width: _itemNameLeftSpacing),
            Expanded(flex: _itemNameFlex, child: Text(item['name'] ?? '')),
            Expanded(
              flex: _currentStockFlex,
              child: Center(
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
                                currentStock = (currentStock - 1).clamp(0, 9999);
                                _ingredientsItems[index]['currentStock'] = currentStock.toString();
                              });
                            },
                          ),
                          SizedBox(
                            width: 28,
                            child: Center(
                              child: Text(
                                '$currentStock',
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
                                currentStock++;
                                _ingredientsItems[index]['currentStock'] = currentStock.toString();
                              });
                            },
                          ),
                        ],
                      )
                    : Text(
                        '$currentStock',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
              ),
            ),
            Expanded(
              flex: _isReservedFlex,
              child: Center(
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
                                reserved = (reserved - 1).clamp(0, 9999);
                                _ingredientsItems[index]['ingredientsReserved'] = reserved.toString();
                              });
                            },
                          ),
                          SizedBox(
                            width: 28,
                            child: Center(
                              child: Text(
                                '$reserved',
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
                                reserved++;
                                _ingredientsItems[index]['ingredientsReserved'] = reserved.toString();
                              });
                            },
                          ),
                        ],
                      )
                    : Text(
                        '$reserved',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
              ),
            ),
            Expanded(
              flex: _isAvailableFlex,
              child: Center(
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
                                available = (available - 1).clamp(0, 9999);
                                _ingredientsItems[index]['ingredientsAvailable'] = available.toString();
                              });
                            },
                          ),
                          SizedBox(
                            width: 28,
                            child: Center(
                              child: Text(
                                '$available',
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
                                available++;
                                _ingredientsItems[index]['ingredientsAvailable'] = available.toString();
                              });
                            },
                          ),
                        ],
                      )
                    : Text(
                        '$available',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
              ),
            ),
            Expanded(
              flex: _ingredientsThresholdFlex,
              child: Center(
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
                                threshold = (threshold - 1).clamp(0, 9999);
                                _ingredientsItems[index]['ingredientsThreshold'] = threshold.toString();
                              });
                            },
                          ),
                          SizedBox(
                            width: 28,
                            child: Center(
                              child: Text(
                                '$threshold',
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
                                threshold++;
                                _ingredientsItems[index]['ingredientsThreshold'] = threshold.toString();
                              });
                            },
                          ),
                        ],
                      )
                    : Text(
                        '$threshold',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
              ),
            ),
          Expanded(
            flex: _statusFlex,
            child: Center(
              child: _buildStockStatus(currentStock), 
            ),
          ),
            Expanded(
  flex: 1,
  child: Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(isEditing ? Icons.check : Icons.edit_square, size: 22),
          onPressed: () async {
            if (!isEditing) {
              setState(() => _ingredientsItems[index]['isEditing'] = true);
            } else {
              setState(() => _ingredientsItems[index]['isEditing'] = false);
              String status = getStatus(currentStock);
              _ingredientsItems[index]['status'] = status;
              await dbServices.update(
                path: "Ingredients/${item['id']}",
                data: {
                  "quantity": currentStock,
                  "reserved": reserved,
                  "available": available,
                  "threshold": threshold,
                  "status": status,
                },
              );
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete, size: 22, color: Colors.red),
          onPressed: () async {
            await dbServices.delete(path: "Ingredients/${item['id']}");
            setState(() => _ingredientsItems.removeAt(index));
          },
        ),
      ],
    ),
  ),
),
          ],
        ),
      );
    }).toList(),
  );
}


Widget _buildStockStatus(int currentStock) {
  Color bgColor;
  Color borderColor;
  String statusText;

  if (currentStock == 0) {
    bgColor = Colors.grey.shade100;
    borderColor = Colors.grey;
    statusText = 'Out of Stock';
  } else if (currentStock < 20) {
    bgColor = Colors.red.shade100;
    borderColor = Colors.red;
    statusText = 'Re-stock';
  } else if (currentStock <= 30) {
    bgColor = Colors.yellow.shade100;
    borderColor = Colors.orange;
    statusText = 'Low on Stock';
  } else {
    bgColor = Colors.green.shade100;
    borderColor = Colors.green;
    statusText = 'OK';
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
      textAlign: TextAlign.center,
      style: TextStyle(
        color: borderColor,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    ),
  );
}

  void _showAddNewIngredientDialog(BuildContext context) {
  final TextEditingController nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) => Dialog(
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
                          String newName = nameController.text.trim();

                          bool exists = _ingredientsItems.any((item) =>
                              item['name'].toString().toLowerCase() == newName.toLowerCase());

                          if (exists) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Ingredient "$newName" already exists.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          int newId = 1;
                          if (_ingredientsItems.isNotEmpty) {
                            newId = _ingredientsItems
                                .map((item) => int.tryParse(item['id']) ?? 0)
                                .reduce((curr, next) => curr > next ? curr : next) + 1;
                          }

                          final newRef = productRef.child(newId.toString());
                          await newRef.set({
                            "ingredient_id": newId.toString(),
                            "ingredient_name": newName,
                            "quantity": '0',
                            "reserved": '0',
                            "available": '0',
                            "threshold": '0',
                            "status": getStatus(0),
                          });

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
    ),
  );
}


  void fetchIngredients() {
    setState(() => isLoading = true);

    productRef.onValue.listen((event) {
      final snapshot = event.snapshot;

      if (snapshot.exists) {
        List<Map<String, dynamic>> products = [];
        for (var child in snapshot.children) {
          final data = child.value as Map<dynamic, dynamic>;
          products.add({
            'id': data['ingredient_id'].toString(),
            'name': data['ingredient_name'].toString(),
            'currentStock': data['quantity'].toString(),
            'ingredientsReserved': data['reserved']?.toString() ?? '0',
            'ingredientsAvailable': data['available']?.toString() ?? '0',
            'ingredientsThreshold': data['threshold']?.toString() ?? '0',
            'status': data['status'].toString(),
            'isEditing': false,
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
