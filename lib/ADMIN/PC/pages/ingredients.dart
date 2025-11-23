import 'package:flutter/material.dart';

class IngredientsPage extends StatefulWidget {
  const IngredientsPage({super.key});

  @override
  State<IngredientsPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<IngredientsPage> {
  // Sample data list - will expand dynamically when new items are added
  final List<Map<String, String>> _inventoryItems = [
    {
      'name': 'Sourdough - Regular',
      'id': '001',
      'currentStock': '45',
      'ingredientsReserved': '20',
      'ingredientsAvailable': '69',
      'ingredientsThreshold': '30',
      'status': 'In Stock',
    },
  ];

  // Adjustable spacing and positioning variables
  static const double _tablePadding = 24;
  static const double _headerSpacing = 24;
  static const double _rowSpacing = 16;
  static const double _columnSpacing = 90;
  static const double _itemNameLeftSpacing = 100;
  
  // Adjustable column flex values
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
                onPressed: () {},
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
                onPressed: () {},
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
    // Table rows expand dynamically based on data list
    return Column(
      children: _inventoryItems.map(
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

}
