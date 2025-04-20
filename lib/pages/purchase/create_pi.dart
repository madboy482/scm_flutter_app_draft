import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_button.dart';

class CreatePI extends StatefulWidget {
  const CreatePI({super.key});

  @override
  State<CreatePI> createState() => _CreatePIState();
}

class _CreatePIState extends State<CreatePI> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _invoiceNumberController = TextEditingController();
  final _poNumberController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Date controllers
  DateTime _invoiceDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  
  // Selected supplier
  String? _selectedSupplierId;
  String _selectedSupplierName = 'Select Supplier';
  
  // Payment details
  String _paymentMethod = 'Bank Transfer';
  final List<String> _paymentMethods = [
    'Cash',
    'Check',
    'Bank Transfer',
    'Credit Card',
    'PayPal',
  ];
  
  // Status
  String _status = 'Draft';
  final List<String> _statusOptions = [
    'Draft',
    'Pending',
    'Paid',
    'Partially Paid',
  ];
  
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

  // Items from the selected PO
  final List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _generateInvoiceNumber();
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _poNumberController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _generateInvoiceNumber() {
    // Generate an invoice number based on current date and a random number
    final now = DateTime.now();
    final invoiceNumber = 'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch % 1000}';
    _invoiceNumberController.text = invoiceNumber;
  }

  Future<void> _selectDate(BuildContext context, bool isInvoiceDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isInvoiceDate ? _invoiceDate : _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (pickedDate != null) {
      setState(() {
        if (isInvoiceDate) {
          _invoiceDate = pickedDate;
        } else {
          _dueDate = pickedDate;
        }
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
                      _items.clear();
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
      _items.clear();
      
      // Mock items based on PO ID
      if (poId == '1') {
        _items.addAll([
          {
            'name': 'Laptop',
            'sku': 'LAP-001',
            'quantity': 5,
            'price': 999.99,
            'tax': 100.00,
            'discount': 0.00,
          },
          {
            'name': 'Mouse',
            'sku': 'MOU-001',
            'quantity': 10,
            'price': 29.99,
            'tax': 15.00,
            'discount': 0.00,
          },
        ]);
      } else if (poId == '2') {
        _items.addAll([
          {
            'name': 'Desktop Computer',
            'sku': 'DSK-001',
            'quantity': 3,
            'price': 1299.99,
            'tax': 195.00,
            'discount': 0.00,
          },
          {
            'name': 'Monitor',
            'sku': 'MON-001',
            'quantity': 3,
            'price': 299.99,
            'tax': 45.00,
            'discount': 0.00,
          },
        ]);
      } else if (poId == '3') {
        _items.addAll([
          {
            'name': 'Keyboard',
            'sku': 'KEY-001',
            'quantity': 20,
            'price': 49.99,
            'tax': 50.00,
            'discount': 0.00,
          },
          {
            'name': 'Mouse',
            'sku': 'MOU-001',
            'quantity': 20,
            'price': 29.99,
            'tax': 30.00,
            'discount': 0.00,
          },
        ]);
      }
    });
  }

  double get _subtotal {
    double total = 0;
    for (var item in _items) {
      total += (item['price'] as double) * (item['quantity'] as int);
    }
    return total;
  }

  double get _totalTax {
    double total = 0;
    for (var item in _items) {
      total += item['tax'] as double;
    }
    return total;
  }

  double get _totalDiscount {
    double total = 0;
    for (var item in _items) {
      total += item['discount'] as double;
    }
    return total;
  }

  double get _grandTotal => _subtotal + _totalTax - _totalDiscount;

  Future<void> _saveInvoice() async {
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
      
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No items found for this purchase order'),
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
            content: Text('Invoice ${_invoiceNumberController.text} created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        context.go('/purchase-orders');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Purchase Invoice'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/purchase-orders');
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
                        controller: _invoiceNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Invoice Number *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Invoice number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Invoice Date *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(dateFormat.format(_invoiceDate)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectDate(context, false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Due Date *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_month),
                          ),
                          child: Text(dateFormat.format(_dueDate)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.fact_check),
                        ),
                        value: _status,
                        items: _statusOptions.map((status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _status = value!;
                          });
                        },
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
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _referenceController,
                        decoration: const InputDecoration(
                          labelText: 'Reference',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
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
                        'Items',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_items.isEmpty)
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
                          itemCount: _items.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            final subtotal = (item['price'] as double) * (item['quantity'] as int);
                            final total = subtotal + (item['tax'] as double) - (item['discount'] as double);
                            
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
                                  Text('Price: \$${(item['price'] as double).toStringAsFixed(2)} × ${item['quantity']}'),
                                  Text('Tax: \$${(item['tax'] as double).toStringAsFixed(2)}'),
                                ],
                              ),
                              trailing: Text(
                                '\$${total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      if (_items.isNotEmpty) ...[
                        const Divider(thickness: 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal:'),
                              Text(
                                '\$${_subtotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tax:'),
                              Text(
                                '\$${_totalTax.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Discount:'),
                              Text(
                                '\$${_totalDiscount.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Grand Total:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '\$${_grandTotal.toStringAsFixed(2)}',
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
                        'Payment Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Payment Method',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.payment),
                        ),
                        value: _paymentMethod,
                        items: _paymentMethods.map((method) {
                          return DropdownMenuItem<String>(
                            value: method,
                            child: Text(method),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _paymentMethod = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
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
                        context.go('/purchase-orders');
                      },
                      type: ButtonType.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Save Invoice',
                      onPressed: _saveInvoice,
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