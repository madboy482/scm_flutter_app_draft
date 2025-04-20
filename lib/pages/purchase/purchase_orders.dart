import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_button.dart';

class PurchaseOrder {
  final String id;
  final String orderNumber;
  final String supplierName;
  final DateTime orderDate;
  final DateTime expectedDeliveryDate;
  final double totalAmount;
  final String status;

  PurchaseOrder({
    required this.id,
    required this.orderNumber,
    required this.supplierName,
    required this.orderDate,
    required this.expectedDeliveryDate,
    required this.totalAmount,
    required this.status,
  });
}

class POs extends StatefulWidget {
  const POs({super.key});

  @override
  State<POs> createState() => _POsState();
}

class _POsState extends State<POs> {
  final TextEditingController _searchController = TextEditingController();
  
  // Mock data for purchase orders
  final List<PurchaseOrder> _purchaseOrders = [
    PurchaseOrder(
      id: '1',
      orderNumber: 'PO-001',
      supplierName: 'ABC Suppliers',
      orderDate: DateTime(2025, 3, 15),
      expectedDeliveryDate: DateTime(2025, 3, 25),
      totalAmount: 2500.00,
      status: 'Pending',
    ),
    PurchaseOrder(
      id: '2',
      orderNumber: 'PO-002',
      supplierName: 'XYZ Manufacturing',
      orderDate: DateTime(2025, 3, 20),
      expectedDeliveryDate: DateTime(2025, 4, 1),
      totalAmount: 4200.00,
      status: 'Delivered',
    ),
    PurchaseOrder(
      id: '3',
      orderNumber: 'PO-003',
      supplierName: 'Tech Solutions',
      orderDate: DateTime(2025, 4, 2),
      expectedDeliveryDate: DateTime(2025, 4, 12),
      totalAmount: 1800.00,
      status: 'In Transit',
    ),
    PurchaseOrder(
      id: '4',
      orderNumber: 'PO-004',
      supplierName: 'Global Components',
      orderDate: DateTime(2025, 4, 5),
      expectedDeliveryDate: DateTime(2025, 4, 15),
      totalAmount: 3600.00,
      status: 'Pending',
    ),
    PurchaseOrder(
      id: '5',
      orderNumber: 'PO-005',
      supplierName: 'ABC Suppliers',
      orderDate: DateTime(2025, 4, 10),
      expectedDeliveryDate: DateTime(2025, 4, 20),
      totalAmount: 1200.00,
      status: 'Cancelled',
    ),
  ];

  List<PurchaseOrder> _filteredPOs = [];
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _filteredPOs = List.from(_purchaseOrders);
    _searchController.addListener(_filterPOs);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPOs);
    _searchController.dispose();
    super.dispose();
  }

  void _filterPOs() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty && _filterStatus == 'All') {
        _filteredPOs = List.from(_purchaseOrders);
      } else {
        _filteredPOs = _purchaseOrders.where((po) {
          final matchesQuery = query.isEmpty || 
              po.orderNumber.toLowerCase().contains(query) ||
              po.supplierName.toLowerCase().contains(query);
          
          final matchesStatus = _filterStatus == 'All' || po.status == _filterStatus;
          
          return matchesQuery && matchesStatus;
        }).toList();
      }
    });
  }

  void _filterByStatus(String status) {
    setState(() {
      _filterStatus = status;
      _filterPOs();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.blue;
      case 'Delivered':
        return Colors.green;
      case 'In Transit':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Orders'),
      ),
      drawer: const AppDrawer(currentUserType: 'admin'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search POs by number or supplier...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', _filterStatus == 'All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pending', _filterStatus == 'Pending'),
                      const SizedBox(width: 8),
                      _buildFilterChip('In Transit', _filterStatus == 'In Transit'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Delivered', _filterStatus == 'Delivered'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Cancelled', _filterStatus == 'Cancelled'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredPOs.isEmpty
                ? const Center(
                    child: Text(
                      'No purchase orders found',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredPOs.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final po = _filteredPOs[index];
                      final dateFormat = DateFormat('MMM dd, yyyy');
                      
                      return Card(
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            _showPOActionSheet(context, po);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      po.orderNumber,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        po.status,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      backgroundColor: _getStatusColor(po.status),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.business, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      po.supplierName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Order Date',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            dateFormat.format(po.orderDate),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Delivery Date',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            dateFormat.format(po.expectedDeliveryDate),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text(
                                            'Amount',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            '\$${po.totalAmount.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/create-po');
        },
        icon: const Icon(Icons.add),
        label: const Text('New PO'),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _filterByStatus(label);
        }
      },
    );
  }

    void _showPOActionSheet(BuildContext context, PurchaseOrder po) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Purchase Order ${po.orderNumber}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                po.supplierName,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildActionButton(
                    context,
                    'View',
                    Icons.visibility,
                    () {
                      Navigator.pop(context);
                      // Navigate to view PO details
                    },
                  ),
                  _buildActionButton(
                    context,
                    'Edit',
                    Icons.edit,
                    () {
                      Navigator.pop(context);
                      context.go('/create-po');
                    },
                  ),
                  _buildActionButton(
                    context,
                    'Print',
                    Icons.print,
                    () {
                      Navigator.pop(context);
                      // Print PO functionality
                    },
                  ),
                  _buildActionButton(
                    context,
                    'Create Bill',
                    Icons.receipt,
                    () {
                      Navigator.pop(context);
                      context.go('/create-purchase-invoice');
                    },
                  ),
                  _buildActionButton(
                    context,
                    'Create Return',
                    Icons.assignment_return,
                    () {
                      Navigator.pop(context);
                      context.go('/create-purchase-return');
                    },
                  ),
                  _buildActionButton(
                    context,
                    'Email',
                    Icons.email,
                    () {
                      Navigator.pop(context);
                      // Email PO functionality
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Close',
                onPressed: () => Navigator.pop(context),
                type: ButtonType.secondary,
                isFullWidth: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}