import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_button.dart';

class PaymentOut extends StatefulWidget {
  const PaymentOut({super.key});

  @override
  State<PaymentOut> createState() => _PaymentOutState();
}

class _PaymentOutState extends State<PaymentOut> {
  final TextEditingController _searchController = TextEditingController();
  
  // Mock data for payments
  final List<Map<String, dynamic>> _payments = [
    {
      'id': '1',
      'number': 'PAY-001',
      'supplier': 'ABC Suppliers',
      'date': DateTime(2025, 3, 20),
      'amount': 2500.00,
      'method': 'Bank Transfer',
      'reference': 'INV-00123',
    },
    {
      'id': '2',
      'number': 'PAY-002',
      'supplier': 'XYZ Manufacturing',
      'date': DateTime(2025, 3, 25),
      'amount': 4200.00,
      'method': 'Check',
      'reference': 'INV-00145',
    },
    {
      'id': '3',
      'number': 'PAY-003',
      'supplier': 'Tech Solutions',
      'date': DateTime(2025, 4, 5),
      'amount': 1800.00,
      'method': 'Credit Card',
      'reference': 'INV-00156',
    },
  ];

  List<Map<String, dynamic>> _filteredPayments = [];

  @override
  void initState() {
    super.initState();
    _filteredPayments = List.from(_payments);
    _searchController.addListener(_filterPayments);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPayments);
    _searchController.dispose();
    super.dispose();
  }

  void _filterPayments() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        _filteredPayments = List.from(_payments);
      } else {
        _filteredPayments = _payments.where((payment) {
          return payment['number'].toLowerCase().contains(query) ||
              payment['supplier'].toLowerCase().contains(query) ||
              payment['reference'].toLowerCase().contains(query) ||
              payment['method'].toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Color _getMethodColor(String method) {
    switch (method) {
      case 'Bank Transfer':
        return Colors.blue;
      case 'Check':
        return Colors.purple;
      case 'Credit Card':
        return Colors.orange;
      case 'Cash':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _createNewPayment() {
    // In a real app, navigate to create new payment
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create new payment (not implemented)'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
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
                    hintText: 'Search payments...',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Payment History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CustomButton(
                      text: 'Export',
                      onPressed: () {
                        // Export functionality
                      },
                      type: ButtonType.secondary,
                      icon: Icons.download,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredPayments.isEmpty
                ? const Center(
                    child: Text(
                      'No payments found',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredPayments.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final payment = _filteredPayments[index];
                      
                      return Card(
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            _showPaymentDetails(context, payment);
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
                                      payment['number'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        payment['method'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      backgroundColor: _getMethodColor(payment['method']),
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
                                      payment['supplier'],
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
                                            dateFormat.format(payment['date']),
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
                                            'Reference',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            payment['reference'],
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
                                            currencyFormat.format(payment['amount']),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
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
        onPressed: _createNewPayment,
        icon: const Icon(Icons.add),
        label: const Text('New Payment'),
      ),
    );
  }

  void _showPaymentDetails(BuildContext context, Map<String, dynamic> payment) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    
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
                'Payment ${payment['number']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Supplier', payment['supplier']),
              _buildDetailRow('Date', DateFormat('MMM dd, yyyy').format(payment['date'])),
              _buildDetailRow('Amount', currencyFormat.format(payment['amount'])),
              _buildDetailRow('Method', payment['method']),
              _buildDetailRow('Reference', payment['reference']),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    context,
                    'Print Receipt',
                    Icons.print,
                    () {
                      Navigator.pop(context);
                      // Print functionality
                    },
                  ),
                  _buildActionButton(
                    context,
                    'Email Receipt',
                    Icons.email,
                    () {
                      Navigator.pop(context);
                      // Email functionality
                    },
                  ),
                  _buildActionButton(
                    context,
                    'View Invoice',
                    Icons.receipt,
                    () {
                      Navigator.pop(context);
                      // View invoice functionality
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

  Widget _buildDetailRow(String label, String value) {
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
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
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