import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_button.dart';

class DebitNote extends StatefulWidget {
  const DebitNote({super.key});

  @override
  State<DebitNote> createState() => _DebitNoteState();
}

class _DebitNoteState extends State<DebitNote> {
  final TextEditingController _searchController = TextEditingController();
  
  // Mock data for debit notes
  final List<Map<String, dynamic>> _debitNotes = [
    {
      'id': '1',
      'number': 'DN-001',
      'supplier': 'ABC Suppliers',
      'date': DateTime(2025, 3, 20),
      'amount': 500.00,
      'status': 'Paid',
    },
    {
      'id': '2',
      'number': 'DN-002',
      'supplier': 'XYZ Manufacturing',
      'date': DateTime(2025, 3, 25),
      'amount': 800.00,
      'status': 'Pending',
    },
    {
      'id': '3',
      'number': 'DN-003',
      'supplier': 'Tech Solutions',
      'date': DateTime(2025, 4, 5),
      'amount': 350.00,
      'status': 'Paid',
    },
  ];

  List<Map<String, dynamic>> _filteredDebitNotes = [];
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _filteredDebitNotes = List.from(_debitNotes);
    _searchController.addListener(_filterDebitNotes);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterDebitNotes);
    _searchController.dispose();
    super.dispose();
  }

  void _filterDebitNotes() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty && _filterStatus == 'All') {
        _filteredDebitNotes = List.from(_debitNotes);
      } else {
        _filteredDebitNotes = _debitNotes.where((note) {
          final matchesQuery = query.isEmpty || 
              note['number'].toLowerCase().contains(query) ||
              note['supplier'].toLowerCase().contains(query);
          
          final matchesStatus = _filterStatus == 'All' || note['status'] == _filterStatus;
          
          return matchesQuery && matchesStatus;
        }).toList();
      }
    });
  }

  void _filterByStatus(String status) {
    setState(() {
      _filterStatus = status;
      _filterDebitNotes();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _createNewDebitNote() {
    // In a real app, navigate to create new debit note
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create new debit note (not implemented)'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debit Notes'),
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
                      _buildFilterChip('Paid', _filterStatus == 'Paid'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredDebitNotes.isEmpty
                ? const Center(
                    child: Text(
                      'No debit notes found',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredDebitNotes.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final note = _filteredDebitNotes[index];
                      
                      return Card(
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            _showDebitNoteDetails(context, note);
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
                                      note['number'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        note['status'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      backgroundColor: _getStatusColor(note['status']),
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
                                      note['supplier'],
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
                                            dateFormat.format(note['date']),
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
                                            '\$${note['amount'].toStringAsFixed(2)}',
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
        onPressed: _createNewDebitNote,
        icon: const Icon(Icons.add),
        label: const Text('New Debit Note'),
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

  void _showDebitNoteDetails(BuildContext context, Map<String, dynamic> note) {
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
                'Debit Note ${note['number']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Supplier', note['supplier']),
              _buildDetailRow('Date', DateFormat('MMM dd, yyyy').format(note['date'])),
              _buildDetailRow('Amount', '\$${note['amount'].toStringAsFixed(2)}'),
              _buildDetailRow('Status', note['status'], _getStatusColor(note['status'])),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    context,
                    'View Details',
                    Icons.visibility,
                    () {
                      Navigator.pop(context);
                      // Show details
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
                  if (note['status'] == 'Pending')
                    _buildActionButton(
                      context,
                      'Mark as Paid',
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