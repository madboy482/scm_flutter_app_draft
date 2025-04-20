import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_button.dart';

class PurchaseReturn {
  final String id;
  final String returnNumber;
  final String supplierName;
  final DateTime returnDate;
  final double totalAmount;
  final String status;
  final String relatedPO;

  PurchaseReturn({
    required this.id,
    required this.returnNumber,
    required this.supplierName,
    required this.returnDate,
    required this.totalAmount,
    required this.status,
    required this.relatedPO,
  });
}

class PRList extends StatefulWidget {
  const PRList({super.key});

  @override
  State<PRList> createState() => _PRListState();
}

class _PRListState extends State<PRList> {
  final TextEditingController _searchController = TextEditingController();
  
  // Mock data for purchase returns
  final List<PurchaseReturn> _purchaseReturns = [
    PurchaseReturn(
      id: '1',
      returnNumber: 'PR-001',
      supplierName: 'ABC Suppliers',
      returnDate: DateTime(2025, 3, 20),
      totalAmount: 500.00,
      status: 'Completed',
      relatedPO: 'PO-001',
    ),
    PurchaseReturn(
      id: '2',
      returnNumber: 'PR-002',
      supplierName: 'XYZ Manufacturing',
      returnDate: DateTime(2025, 3, 25),
      totalAmount: 800.00,
      status: 'Pending',
      relatedPO: 'PO-002',
    ),
    PurchaseReturn(
      id: '3',
      returnNumber: 'PR-003',
      supplierName: 'Tech Solutions',
      returnDate: DateTime(2025, 4, 5),
      totalAmount: 350.00,
      status: 'Completed',
      relatedPO: 'PO-003',
    ),
  ];

  List<PurchaseReturn> _filteredPRs = [];
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _filteredPRs = List.from(_purchaseReturns);
    _searchController.addListener(_filterPRs);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPRs);
    _searchController.dispose();
    super.dispose();
  }

  void _filterPRs() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty && _filterStatus == 'All') {
        _filteredPRs = List.from(_purchaseReturns);
      } else {
        _filteredPRs = _purchaseReturns.where((pr) {
          final matchesQuery = query.isEmpty || 
              pr.returnNumber.toLowerCase().contains(query) ||
              pr.supplierName.toLowerCase().contains(query) ||
              pr.relatedPO.toLowerCase().contains(query);
          
          final matchesStatus = _filterStatus == 'All' || pr.status == _filterStatus;
          
          return matchesQuery && matchesStatus;
        }).toList();
      }
    });
  }

  void _filterByStatus(String status) {
    setState(() {
      _filterStatus = status;
      _filterPRs();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Pending':
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
        title: const Text('Purchase Returns'),
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
                    hintText: 'Search returns by number or supplier...',
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
                      _buildFilterChip('Completed', _filterStatus == 'Completed'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Cancelled', _filterStatus == 'Cancelled'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredPRs.isEmpty
                ? const Center(
                    child: Text(
                      'No purchase returns found',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredPRs.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final pr = _filteredPRs[index];
                      final dateFormat = DateFormat('MMM dd, yyyy');
                      
                      return Card(
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            _showPRActionSheet(context, pr);
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
                                      pr.returnNumber,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        pr.status,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      backgroundColor: _getStatusColor(pr.status),
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
                                      pr.supplierName,
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
                                            'Return Date',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            dateFormat.format(pr.returnDate),
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
                                            'Related PO',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            pr.relatedPO,
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
                                            '\$${pr.totalAmount.toStringAsFixed(2)}',
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
          context.go('/create-purchase-return');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Return'),
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

  void _showPRActionSheet(BuildContext context, PurchaseReturn pr) {
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
                'Purchase Return ${pr.returnNumber}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                pr.supplierName,
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
                      // Navigate to view PR details
                    },
                  ),
                  _buildActionButton(
                    context,
                    'Edit',
                    Icons.edit,
                    () {
                      Navigator.pop(context);
                      context.go('/create-purchase-return');
                    },
                  ),
                  _buildActionButton(
                    context,
                    'Print',
                    Icons.print,
                    () {
                      Navigator.pop(context);
                      // Print PR functionality
                    },
                  ),
                  _buildActionButton(
                    context,
                    'Email',
                    Icons.email,
                    () {
                      Navigator.pop(context);
                      // Email PR functionality
                    },
                  ),
                  if (pr.status == 'Pending')
                    _buildActionButton(
                      context,
                      'Mark Complete',
                      Icons.check_circle,
                      () {
                        Navigator.pop(context);
                        // Mark PR as complete
                      },
                    ),
                  if (pr.status == 'Pending')
                    _buildActionButton(
                      context,
                      'Cancel',
                      Icons.cancel,
                      () {
                        Navigator.pop(context);
                        // Cancel PR
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