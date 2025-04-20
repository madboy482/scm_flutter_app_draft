import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_button.dart';

class DeliveryChallan extends StatefulWidget {
  const DeliveryChallan({super.key});

  @override
  State<DeliveryChallan> createState() => _DeliveryChallanState();
}

class _DeliveryChallanState extends State<DeliveryChallan> {
  final TextEditingController _searchController = TextEditingController();
  
  // Mock data for delivery challans
  final List<Map<String, dynamic>> _challans = [
    {
      'id': '1',
      'number': 'DC-001',
      'supplier': 'ABC Suppliers',
      'date': DateTime(2025, 3, 20),
      'poNumber': 'PO-001',
      'status': 'Delivered',
    },
    {
      'id': '2',
      'number': 'DC-002',
      'supplier': 'XYZ Manufacturing',
      'date': DateTime(2025, 3, 25),
      'poNumber': 'PO-002',
      'status': 'In Transit',
    },
    {
      'id': '3',
      'number': 'DC-003',
      'supplier': 'Tech Solutions',
      'date': DateTime(2025, 4, 5),
      'poNumber': 'PO-003',
      'status': 'Pending',
    },
  ];

  List<Map<String, dynamic>> _filteredChallans = [];
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _filteredChallans = List.from(_challans);
    _searchController.addListener(_filterChallans);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterChallans);
    _searchController.dispose();
    super.dispose();
  }

  void _filterChallans() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty && _filterStatus == 'All') {
        _filteredChallans = List.from(_challans);
      } else {
        _filteredChallans = _challans.where((challan) {
          final matchesQuery = query.isEmpty || 
              challan['number'].toLowerCase().contains(query) ||
              challan['supplier'].toLowerCase().contains(query) ||
              challan['poNumber'].toLowerCase().contains(query);
          
          final matchesStatus = _filterStatus == 'All' || challan['status'] == _filterStatus;
          
          return matchesQuery && matchesStatus;
        }).toList();
      }
    });
  }

  void _filterByStatus(String status) {
    setState(() {
      _filterStatus = status;
      _filterChallans();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'In Transit':
        return Colors.orange;
      case 'Pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _createNewChallan() {
    // In a real app, navigate to create new challan
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create new delivery challan (not implemented)'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Challans'),
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
                    hintText: 'Search by number or supplier...',
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredChallans.isEmpty
                ? const Center(
                    child: Text(
                      'No delivery challans found',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredChallans.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final challan = _filteredChallans[index];
                      
                      return Card(
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            _showChallanDetails(context, challan);
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
                                      challan['number'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        challan['status'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      backgroundColor: _getStatusColor(challan['status']),
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
                                      challan['supplier'],
                                      style: const TextStyle(fontSize: 14),
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
                                            'Date',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            dateFormat.format(challan['date']),
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
                                            'PO Number',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            challan['poNumber'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
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
        onPressed: _createNewChallan,
        icon: const Icon(Icons.add),
        label: const Text('New Challan'),
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

  void _showChallanDetails(BuildContext context, Map<String, dynamic> challan) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery Challan ${challan['number']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Supplier', challan['supplier']),
              _buildDetailRow('Date', DateFormat('MMM dd, yyyy').format(challan['date'])),
              _buildDetailRow('PO Number', challan['poNumber']),
              _buildDetailRow('Status', challan['status'], _getStatusColor(challan['status'])),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    context,
                    'View Items',
                    Icons.list,
                    () {
                      Navigator.pop(context);
                      // Show items
                    },
                  ),
                  _buildActionButton(
                    context,
                    'Print',
                    Icons.print,
                    () {
                      Navigator.pop(context);
                      // Print functionality
                    },
                  ),
                  if (challan['status'] == 'Pending' || challan['status'] == 'In Transit')
                    _buildActionButton(
                      context,
                      'Mark Delivered',
                      Icons.check_circle,
                      () {
                        Navigator.pop(context);
                        // Update status
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
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

  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
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
        mainAxisSize: MainAxisSize.min,
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