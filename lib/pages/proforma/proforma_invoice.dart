import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_button.dart';

class ProformaInvoice extends StatefulWidget {
  const ProformaInvoice({super.key});

  @override
  State<ProformaInvoice> createState() => _ProformaInvoiceState();
}

class _ProformaInvoiceState extends State<ProformaInvoice> {
  final TextEditingController _searchController = TextEditingController();
  
  // Mock data for proforma invoices
  final List<Map<String, dynamic>> _proformaInvoices = [
    {
      'id': '1',
      'number': 'PI-001',
      'customer': 'Acme Inc.',
      'date': DateTime(2025, 3, 15),
      'dueDate': DateTime(2025, 4, 15),
      'amount': 3500.00,
      'status': 'Pending',
    },
    {
      'id': '2',
      'number': 'PI-002',
      'customer': 'Global Retail',
      'date': DateTime(2025, 3, 22),
      'dueDate': DateTime(2025, 4, 22),
      'amount': 5200.00,
      'status': 'Approved',
    },
    {
      'id': '3',
      'number': 'PI-003',
      'customer': 'Tech Solutions',
      'date': DateTime(2025, 4, 5),
      'dueDate': DateTime(2025, 5, 5),
      'amount': 1800.00,
      'status': 'Converted',
    },
  ];

  List<Map<String, dynamic>> _filteredInvoices = [];
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _filteredInvoices = List.from(_proformaInvoices);
    _searchController.addListener(_filterInvoices);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterInvoices);
    _searchController.dispose();
    super.dispose();
  }

  void _filterInvoices() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty && _filterStatus == 'All') {
        _filteredInvoices = List.from(_proformaInvoices);
      } else {
        _filteredInvoices = _proformaInvoices.where((invoice) {
          final matchesQuery = query.isEmpty || 
              invoice['number'].toLowerCase().contains(query) ||
              invoice['customer'].toLowerCase().contains(query);
          
          final matchesStatus = _filterStatus == 'All' || invoice['status'] == _filterStatus;
          
          return matchesQuery && matchesStatus;
        }).toList();
      }
    });
  }

  void _filterByStatus(String status) {
    setState(() {
      _filterStatus = status;
      _filterInvoices();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Approved':
        return Colors.green;
      case 'Converted':
        return Colors.blue;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proforma Invoices'),
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
                    hintText: 'Search by number or customer...',
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
                      _buildFilterChip('Approved', _filterStatus == 'Approved'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Converted', _filterStatus == 'Converted'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Rejected', _filterStatus == 'Rejected'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredInvoices.isEmpty
                ? const Center(
                    child: Text(
                      'No proforma invoices found',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredInvoices.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final invoice = _filteredInvoices[index];
                      
                      return Card(
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            _showInvoiceActionSheet(context, invoice);
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
                                      invoice['number'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        invoice['status'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      backgroundColor: _getStatusColor(invoice['status']),
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
                                      invoice['customer'],
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
                                            'Date',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            dateFormat.format(invoice['date']),
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
                                            'Due Date',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            dateFormat.format(invoice['dueDate']),
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
                                            '\$${invoice['amount'].toStringAsFixed(2)}',
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
          context.go('/create-proforma-invoice');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Proforma'),
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

  void _showInvoiceActionSheet(BuildContext context, Map<String, dynamic> invoice) {
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
                'Proforma Invoice ${invoice['number']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                invoice['customer'],
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
                      // View proforma details
                    },
                  ),
                  _buildActionButton(
                    context,
                    'Edit',
                    Icons.edit,
                    () {
                      Navigator.pop(context);
                      context.go('/create-proforma-invoice');
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
                  _buildActionButton(
                    context,
                    'Email',
                    Icons.email,
                    () {
                      Navigator.pop(context);
                      // Email functionality
                    },
                  ),
                  if (invoice['status'] == 'Pending')
                    _buildActionButton(
                      context,
                      'Approve',
                      Icons.check_circle,
                      () {
                        Navigator.pop(context);
                        // Approve proforma
                      },
                    ),
                  if (invoice['status'] == 'Pending')
                    _buildActionButton(
                      context,
                      'Reject',
                      Icons.cancel,
                      () {
                        Navigator.pop(context);
                        // Reject proforma
                      },
                    ),
                  if (invoice['status'] == 'Approved')
                    _buildActionButton(
                      context,
                      'Convert',
                      Icons.transform,
                      () {
                        Navigator.pop(context);
                        // Convert to invoice
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