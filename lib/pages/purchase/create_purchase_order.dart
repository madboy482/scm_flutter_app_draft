import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_button.dart';

class Product {
  final String id;
  final String name;
  final String sku;
  final double price;
  final int availableQuantity;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.availableQuantity,
  });
}

class POItem {
  final String productId;
  final String productName;
  final String sku;
  int quantity;
  double price;
  double tax;
  double discount;

  POItem({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.price,
    this.tax = 0,
    this.discount = 0,
  });

  double get total => (price * quantity) + tax - discount;
}

class CreatePurchaseOrderPage extends StatefulWidget {
  const CreatePurchaseOrderPage({super.key});

  @override
  State<CreatePurchaseOrderPage> createState() => _CreatePurchaseOrderPageState();
}

class _CreatePurchaseOrderPageState extends State<CreatePurchaseOrderPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _poNumberController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Date controllers
  DateTime _orderDate = DateTime.now();
  DateTime _expectedDeliveryDate = DateTime.now().add(const Duration(days: 7));
  
  // Selected supplier
  String? _selectedSupplierId;
  String _selectedSupplierName = 'Select Supplier';
  
  // Items in the purchase order
  final List<POItem> _poItems = [];
  
  // Terms and payment
  String _paymentTerms = 'Net 30';
  final List<String> _paymentTermsOptions = [
    'Net 15',
    'Net 30',
    'Net 45',
    'Net 60',
    'Due on Receipt',
  ];
  
  bool _isLoading = false;

  // Mock data for suppliers
  final List<Map<String, dynamic>> _suppliers = [
    {'id': '1', 'name': 'ABC Suppliers'},
    {'id': '2', 'name': 'XYZ Manufacturing'},
    {'id': '3', 'name': 'Tech Solutions'},
    {'id': '4', 'name': 'Global Components'},
  ];

  // Mock data for products
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Laptop',
      sku: 'LAP-001',
      price: 999.99,
      availableQuantity: 50,
    ),
    Product(
      id: '2',
      name: 'Desktop Computer',
      sku: 'DSK-001',
      price: 1299.99,
      availableQuantity: 25,
    ),
    Product(
      id: '3',
      name: 'Monitor',
      sku: 'MON-001',
      price: 299.99,
      availableQuantity: 100,
    ),
    Product(
      id: '4',
      name: 'Keyboard',
      sku: 'KEY-001',
      price: 49.99,
      availableQuantity: 200,
    ),
    Product(
      id: '5',
      name: 'Mouse',
      sku: 'MOU-001',
      price: 29.99,
      availableQuantity: 300,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _generatePONumber();
  }

  @override
  void dispose() {
    _poNumberController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _generatePONumber() {
    // Generate a PO number based on current date and a random number
    final now = DateTime.now();
    final poNumber = 'PO-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch % 1000}';
    _poNumberController.text = poNumber;
  }

  Future<void> _selectDate(BuildContext context, bool isOrderDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isOrderDate ? _orderDate : _expectedDeliveryDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (pickedDate != null) {
      setState(() {
        if (isOrderDate) {
          _orderDate = pickedDate;
        } else {
          _expectedDeliveryDate = pickedDate;
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
                          value: product.id,
                          child: Text(product.name),
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
                      Text(
                        'Available: ${_products.firstWhere((p) => p.id == selectedProductId).availableQuantity}',
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
                            (p) => p.id == selectedProductId,
                          );
                          
                          final newItem = POItem(
                            productId: product.id,
                            productName: product.name,
                            sku: product.sku,
                            quantity: quantity,
                            price: product.price,
                          );
                          
                          this.setState(() {
                            _poItems.add(newItem);
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
      _poItems.removeAt(index);
    });
  }

  double get _subtotal => _poItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get _totalTax => _poItems.fold(0, (sum, item) => sum + item.tax);
  double get _totalDiscount => _poItems.fold(0, (sum, item) => sum + item.discount);
  double get _grandTotal => _subtotal + _totalTax - _totalDiscount;

  Future<void> _savePurchaseOrder() async {
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
      
      if (_poItems.isEmpty) {
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
            content: Text('Purchase Order ${_poNumberController.text} created successfully'),
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
        title: const Text('Create Purchase Order'),
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
                        controller: _poNumberController,
                        decoration: const InputDecoration(
                          labelText: 'PO Number *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'PO number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Order Date *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(dateFormat.format(_orderDate)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectDate(context, false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Expected Delivery Date *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_month),
                          ),
                          child: Text(dateFormat.format(_expectedDeliveryDate)),
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
                        'Supplier Information',
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
                      if (_poItems.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No items added yet. Click "Add Item" to add products to this purchase order.',
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
                          itemCount: _poItems.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = _poItems[index];
                            return ListTile(
                              title: Text(
                                item.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('SKU: ${item.sku}'),
                                  Text('Price: \$${item.price.toStringAsFixed(2)} × ${item.quantity}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '\$${item.total.toStringAsFixed(2)}',
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
                      if (_poItems.isNotEmpty) ...[
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
                        context.go('/purchase-orders');
                      },
                      type: ButtonType.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Save Purchase Order',
                      onPressed: _savePurchaseOrder,
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