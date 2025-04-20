import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_button.dart';

class CreatePR extends StatefulWidget {
  const CreatePR({super.key});

  @override
  State<CreatePR> createState() => _CreatePRState();
}

class _CreatePRState extends State<CreatePR> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _prNumberController = TextEditingController();
  final _poNumberController = TextEditingController();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Date controllers
  DateTime _returnDate = DateTime.now();
  
  // Selected supplier
  String? _selectedSupplierId;
  String _selectedSupplierName = 'Select Supplier';
  
  // Selected items for return
  final List<Map<String, dynamic>> _returnItems = [];
  
  bool _isLoading = false;

  // Mock data for suppliers
  final List<Map<String, dynamic>> _suppliers = [
    {'id': '1', 'name': 'ABC Suppliers'},
    {'id': '2', 'name': 'XYZ Manufacturing'},
    {'id': '3', 'name': 'Tech Solutions'},
    {'id': '4', 'name': 'Global Components'},
  ];

  // Mock data for purchase orders
  final List<Map<String, dynamic>> _purchaseOrders = [
    {'id': '1', 'number': 'PO-001', 'supplier': 'ABC Suppliers', 'total': 2500.00},
    {'id': '2', 'number': 'PO-002', 'supplier': 'XYZ Manufacturing', 'total': 4200.00},
    {'id': '3', 'number': 'PO-003', 'supplier': 'Tech Solutions', 'total': 1800.00},
  ];

  @override
  void initState() {
    super.initState();
    _generatePRNumber();
  }

  @override
  void dispose() {
    _prNumberController.dispose();
    _poNumberController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _generatePRNumber() {
    // Generate a PR number based on current date and a random number
    final now = DateTime.now();
    final prNumber = 'PR-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch % 1000}';
    _prNumberController.text = prNumber;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _returnDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (pickedDate != null) {
      setState(() {
        _returnDate = pickedDate;
      });
    }
  }

  void _showSupplierSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Supplier'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suppliers.length,
              itemBuilder: (context, index) {
                final supplier = _suppliers[index];
                return ListTile(
                  title: Text(supplier['name']),
                  onTap: () {
                    setState(() {
                      _selectedSupplierId = supplier['id'];
                      _selectedSupplierName = supplier['name'];
                      // Clear the PO selection when supplier changes
                      _poNumberController.clear();
                      _returnItems.clear();
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showPOSelectionDialog() {
    if (_selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a supplier first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Filter POs by selected supplier
    final supplierPOs = _purchaseOrders.where(
      (po) => po['supplier'] == _selectedSupplierName
    ).toList();

    if (supplierPOs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No purchase orders found for this supplier'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Purchase Order'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: supplierPOs.length,
              itemBuilder: (context, index) {
                final po = supplierPOs[index];
                return ListTile(
                  title: Text(po['number']),
                  subtitle: Text('Total: \$${po['total'].toStringAsFixed(2)}'),
                  onTap: () {
                    setState(() {
                      _poNumberController.text = po['number'];
                      // Load items from the selected PO
                      _loadItemsFromPO(po['id']);
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _loadItemsFromPO(String poId) {
    // In a real app, you would fetch items from the API
    // For this example, we'll use mock data
    setState(() {
      _returnItems.clear();
      
      // Mock items based on PO ID
      if (poId == '1') {
        _returnItems.addAll([
          {
            'id': '1',
            'name': 'Laptop',
            'sku': 'LAP-001',
            'originalQuantity': 5,
            'returnQuantity': 0,
            'maxReturnQuantity': 2,
            'price': 999.99,
            'reason': '',
          },
          {
            'id': '2',
            'name': 'Mouse',
            'sku': 'MOU-001',
            'originalQuantity': 10,
            'returnQuantity': 0,
            'maxReturnQuantity': 5,
            'price': 29.99,
            'reason': '',
          },
        ]);
      } else if (poId == '2') {
        _returnItems.addAll([
          {
            'id': '3',
            'name': 'Desktop Computer',
            'sku': 'DSK-001',
            'originalQuantity': 3,
            'returnQuantity': 0,
            'maxReturnQuantity': 1,
            'price': 1299.99,
            'reason': '',
          },
          {
            'id': '4',
            'name': 'Monitor',
            'sku': 'MON-001',
            'originalQuantity': 3,
            'returnQuantity': 0,
            'maxReturnQuantity': 1,
            'price': 299.99,
            'reason': '',
          },
        ]);
      } else if (poId == '3') {
        _returnItems.addAll([
          {
            'id': '5',
            'name': 'Keyboard',
            'sku': 'KEY-001',
            'originalQuantity': 20,
            'returnQuantity': 0,
            'maxReturnQuantity': 10,
            'price': 49.99,
            'reason': '',
          },
          {
            'id': '6',
            'name': 'Mouse',
            'sku': 'MOU-001',
            'originalQuantity': 20,
            'returnQuantity': 0,
            'maxReturnQuantity': 10,
            'price': 29.99,
            'reason': '',
          },
        ]);
      }
    });
  }

  void _updateReturnQuantity(int index, int value) {
    final item = _returnItems[index];
    final maxReturn = item['maxReturnQuantity'] as int;
    
    if (value >= 0 && value <= maxReturn) {
      setState(() {
        _returnItems[index]['returnQuantity'] = value;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Return quantity cannot exceed $maxReturn'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showReasonDialog(int index) {
    final reasonController = TextEditingController(text: _returnItems[index]['reason']);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Return Reason for ${_returnItems[index]['name']}'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: 'Reason for Return',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _returnItems[index]['reason'] = reasonController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  double get _subtotal {
    double total = 0;
    for (var item in _returnItems) {
      total += (item['price'] as double) * (item['returnQuantity'] as int);
    }
    return total;
  }

  bool get _hasItemsToReturn {
    return _returnItems.any((item) => (item['returnQuantity'] as int) > 0);
  }

  Future<void> _savePurchaseReturn() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedSupplierId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a supplier'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (_poNumberController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a purchase order'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (!_hasItemsToReturn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one item to return'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (_reasonController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please provide a return reason'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      setState(() {
        _isLoading = true;
      });
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase Return ${_prNumberController.text} created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        context.go('/purchase-return-list');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Purchase Return'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/purchase-return-list');
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _prNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Return Number *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Return number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Return Date *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(dateFormat.format(_returnDate)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Supplier & PO Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _showSupplierSelectionDialog,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Supplier *',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.business),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: _showSupplierSelectionDialog,
                            ),
                          ),
                          child: Text(_selectedSupplierName),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _showPOSelectionDialog,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Purchase Order *',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.shopping_cart),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: _showPOSelectionDialog,
                            ),
                          ),
                          child: Text(_poNumberController.text.isNotEmpty
                              ? _poNumberController.text
                              : 'Select Purchase Order'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Items to Return',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_returnItems.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No items found. Please select a purchase order to load items.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _returnItems.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = _returnItems[index];
                            final total = (item['price'] as double) * (item['returnQuantity'] as int);
                            
                            return ListTile(
                              title: Text(
                                item['name'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('SKU: ${item['sku']}'),
                                  Text('Original Qty: ${item['originalQuantity']}'),
                                  if (item['reason'].isNotEmpty)
                                    Text(
                                      'Reason: ${item['reason']}',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle),
                                    color: Colors.red,
                                    onPressed: () {
                                      _updateReturnQuantity(
                                        index,
                                        (item['returnQuantity'] as int) - 1,
                                      );
                                    },
                                  ),
                                  Text(
                                    '${item['returnQuantity']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle),
                                    color: Colors.green,
                                    onPressed: () {
                                      _updateReturnQuantity(
                                        index,
                                        (item['returnQuantity'] as int) + 1,
                                      );
                                    },
                                  ),
                                  TextButton(
                                    onPressed: () => _showReasonDialog(index),
                                    child: const Text('Reason'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      if (_returnItems.isNotEmpty) ...[
                        const Divider(thickness: 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Return Amount:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '\$${_subtotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Return Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _reasonController,
                        decoration: const InputDecoration(
                          labelText: 'Return Reason *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.assignment_return),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please provide a return reason';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Additional Notes',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      onPressed: () {
                        context.go('/purchase-return-list');
                      },
                      type: ButtonType.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Save Return',
                      onPressed: _savePurchaseReturn,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}