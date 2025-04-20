import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_button.dart';

class CreateProforma extends StatefulWidget {
  const CreateProforma({super.key});

  @override
  State<CreateProforma> createState() => _CreateProformaState();
}

class _CreateProformaState extends State<CreateProforma> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _proformaNumberController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Date controllers
  DateTime _invoiceDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  DateTime _validUntil = DateTime.now().add(const Duration(days: 30));
  
  // Selected customer
  String? _selectedCustomerId;
  String _selectedCustomerName = 'Select Customer';
  
  // Items in the proforma invoice
  final List<Map<String, dynamic>> _items = [];
  
  // Terms and payment
  String _paymentTerms = 'Net 30';
  final List<String> _paymentTermsOptions = [
    'Net 15',
    'Net 30',
    'Net 45',
    'Net 60',
    'Due on Receipt',
  ];
  
  // Shipping info
  bool _includeShipping = false;
  double _shippingCost = 0.0;
  
  bool _isLoading = false;

  // Mock data for customers
  final List<Map<String, dynamic>> _customers = [
    {'id': '1', 'name': 'Acme Inc.'},
    {'id': '2', 'name': 'Global Retail'},
    {'id': '3', 'name': 'Tech Solutions'},
    {'id': '4', 'name': 'Enterprise Corp'},
  ];

  // Mock data for products
  final List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'name': 'Laptop',
      'sku': 'LAP-001',
      'price': 999.99,
      'availableQuantity': 50,
    },
    {
      'id': '2',
      'name': 'Desktop Computer',
      'sku': 'DSK-001',
      'price': 1299.99,
      'availableQuantity': 25,
    },
    {
      'id': '3',
      'name': 'Monitor',
      'sku': 'MON-001',
      'price': 299.99,
      'availableQuantity': 100,
    },
    {
      'id': '4',
      'name': 'Keyboard',
      'sku': 'KEY-001',
      'price': 49.99,
      'availableQuantity': 200,
    },
    {
      'id': '5',
      'name': 'Mouse',
      'sku': 'MOU-001',
      'price': 29.99,
      'availableQuantity': 300,
    },
  ];

  @override
  void initState() {
    super.initState();
    _generateProformaNumber();
  }

  @override
  void dispose() {
    _proformaNumberController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _generateProformaNumber() {
    // Generate a proforma invoice number based on current date and a random number
    final now = DateTime.now();
    final proformaNumber = 'PI-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch % 1000}';
    _proformaNumberController.text = proformaNumber;
  }

  Future<void> _selectDate(BuildContext context, int dateType) async {
    DateTime initialDate;
    String title;
    
    switch (dateType) {
      case 0:
        initialDate = _invoiceDate;
        title = 'Select Invoice Date';
        break;
      case 1:
        initialDate = _dueDate;
        title = 'Select Due Date';
        break;
      case 2:
        initialDate = _validUntil;
        title = 'Select Valid Until Date';
        break;
      default:
        initialDate = DateTime.now();
        title = 'Select Date';
    }
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: title,
    );
    
    if (pickedDate != null) {
      setState(() {
        switch (dateType) {
          case 0:
            _invoiceDate = pickedDate;
            break;
          case 1:
            _dueDate = pickedDate;
            break;
          case 2:
            _validUntil = pickedDate;
            break;
        }
      });
    }
  }

  void _showCustomerSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Customer'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _customers.length,
              itemBuilder: (context, index) {
                final customer = _customers[index];
                return ListTile(
                  title: Text(customer['name']),
                  onTap: () {
                    setState(() {
                      _selectedCustomerId = customer['id'];
                      _selectedCustomerName = customer['name'];
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

  void _showAddItemDialog() {
    String? selectedProductId;
    int quantity = 1;
    double discount = 0.0;
    double tax = 0.0;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Product',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Select Product'),
                      value: selectedProductId,
                      items: _products.map((product) {
                        return DropdownMenuItem<String>(
                          value: product['id'],
                          child: Text(product['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedProductId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (selectedProductId != null) ...[
                      TextFormField(
                        initialValue: quantity.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          quantity = int.tryParse(value) ?? 1;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: discount.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Discount (\$)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          discount = double.tryParse(value) ?? 0.0;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: tax.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Tax (\$)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          tax = double.tryParse(value) ?? 0.0;
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Available: ${_products.firstWhere((p) => p['id'] == selectedProductId)['availableQuantity']}',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: selectedProductId == null
                      ? null
                      : () {
                          final product = _products.firstWhere(
                            (p) => p['id'] == selectedProductId,
                          );
                          
                          final newItem = {
                            'productId': product['id'],
                            'name': product['name'],
                            'sku': product['sku'],
                            'quantity': quantity,
                            'price': product['price'],
                            'tax': tax,
                            'discount': discount,
                          };
                          
                          this.setState(() {
                            _items.add(newItem);
                          });
                          
                          Navigator.pop(context);
                        },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
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

  double get _grandTotal {
    double total = _subtotal + _totalTax - _totalDiscount;
    if (_includeShipping) {
      total += _shippingCost;
    }
    return total;
  }

  Future<void> _saveProformaInvoice() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCustomerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a customer'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one item'),
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
            content: Text('Proforma Invoice ${_proformaNumberController.text} created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        context.go('/proforma-invoice');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Proforma Invoice'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/proforma-invoice');
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
                        controller: _proformaNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Proforma Number *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Proforma number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectDate(context, 0),
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
                        onTap: () => _selectDate(context, 1),
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
                      InkWell(
                        onTap: () => _selectDate(context, 2),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Valid Until *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.timer),
                          ),
                          child: Text(dateFormat.format(_validUntil)),
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
                        'Customer Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _showCustomerSelectionDialog,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Customer *',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.business),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: _showCustomerSelectionDialog,
                            ),
                          ),
                          child: Text(_selectedCustomerName),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Items',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          CustomButton(
                            text: 'Add Item',
                            onPressed: _showAddItemDialog,
                            type: ButtonType.primary,
                            icon: Icons.add,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_items.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No items added yet. Click "Add Item" to add products to this proforma invoice.',
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
                                  if ((item['tax'] as double) > 0)
                                    Text('Tax: \$${(item['tax'] as double).toStringAsFixed(2)}'),
                                  if ((item['discount'] as double) > 0)
                                    Text('Discount: \$${(item['discount'] as double).toStringAsFixed(2)}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '\$${total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeItem(index),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      if (_items.isNotEmpty) ...[
                        const Divider(thickness: 2),
                        SwitchListTile(
                          title: const Text('Include Shipping'),
                          value: _includeShipping,
                          onChanged: (value) {
                            setState(() {
                              _includeShipping = value;
                            });
                          },
                        ),
                        if (_includeShipping) ...[
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Shipping Cost (\$)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: _shippingCost.toString(),
                            onChanged: (value) {
                              setState(() {
                                _shippingCost = double.tryParse(value) ?? 0.0;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
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
                        if (_includeShipping)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Shipping:'),
                                Text(
                                  '\$${_shippingCost.toStringAsFixed(2)}',
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
                        'Terms & Notes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Payment Terms',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.payment),
                        ),
                        value: _paymentTerms,
                        items: _paymentTermsOptions.map((term) {
                          return DropdownMenuItem<String>(
                            value: term,
                            child: Text(term),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _paymentTerms = value!;
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
                        context.go('/proforma-invoice');
                      },
                      type: ButtonType.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Save Proforma',
                      onPressed: _saveProformaInvoice,
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