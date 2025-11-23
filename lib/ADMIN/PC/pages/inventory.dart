import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  // Sample data list - will expand dynamically when new items are added
  final List<Map<String, String>> _inventoryItems = [
    {
      'name': 'Sourdough - Regular',
      'id': '001',
      'itemSold': '45',
      'inStock': '20',
      'unitPrice': '₱120.00',
      'totalValue': '₱5,400.00',
      'status': 'In Stock',
    },
  ];

  // Adjustable spacing and positioning variables
  static const double _tablePadding = 24;
  static const double _headerSpacing = 24;
  static const double _rowSpacing = 16;
  static const double _columnSpacing = 120;
  static const double _productNameLeftSpacing = 100;
  
  // Adjustable column flex values
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
    // Table rows expand dynamically based on data list
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

}
