import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_button.dart';
import 'dart:math' as math;

class CreateItemForm extends StatefulWidget {
  const CreateItemForm({super.key});

  @override
  State<CreateItemForm> createState() => _CreateItemFormState();
}

class _CreateItemFormState extends State<CreateItemForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _barcodeController = TextEditingController();
  
  // Dropdown values
  String _selectedCategory = 'Electronics';
  String _selectedUnit = 'Each';
  String _selectedTaxType = 'Standard';
  bool _isActive = true;
  bool _isSellable = true;
  bool _isPurchasable = true;
  
  bool _isLoading = false;

  final List<String> _categories = [
    'Electronics',
    'Accessories',
    'Furniture',
    'Office Supplies',
    'Software',
    'Hardware',
    'Other',
  ];

  final List<String> _units = [
    'Each',
    'Box',
    'Set',
    'Dozen',
    'Pair',
    'Pack',
    'Case',
  ];

  final List<String> _taxTypes = [
    'Standard',
    'Reduced',
    'Zero',
    'Exempt',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  String _generateSKU() {
    // Generate a SKU based on category and name
    if (_nameController.text.isEmpty) {
      return '';
    }
    
    // Take the first 3 letters of the category
    final categoryPrefix = _selectedCategory.substring(0, math.min(3, _selectedCategory.length)).toUpperCase();
    
    // Take the first 3 letters of the name
    final namePrefix = _nameController.text.substring(0, math.min(3, _nameController.text.length)).toUpperCase();
    
    // Add a random number
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    
    return '$categoryPrefix-$namePrefix-$random';
  }

  void _generateSKUAndUpdate() {
    setState(() {
      _skuController.text = _generateSKU();
    });
  }

  Future<void> _saveAndContinue() async {
    if (_formKey.currentState!.validate()) {
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
          const SnackBar(
            content: Text('Item basic information saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to the next step (Stock)
        context.go('/item_creation_stock');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Item - Basic Info'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/parties-inventory');
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
              _buildStepIndicator(),
              const SizedBox(height: 24),
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
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Item Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.inventory),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the item name';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (_skuController.text.isEmpty) {
                            _generateSKUAndUpdate();
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _skuController,
                              decoration: InputDecoration(
                                labelText: 'SKU *',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.qr_code),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.refresh),
                                  tooltip: 'Generate SKU',
                                  onPressed: _generateSKUAndUpdate,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter or generate a SKU';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Unit *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.straighten),
                              ),
                              value: _selectedUnit,
                              items: _units.map((unit) {
                                return DropdownMenuItem<String>(
                                  value: unit,
                                  child: Text(unit),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedUnit = value!;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a unit';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Category *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        value: _selectedCategory,
                        items: _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
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
                        'Additional Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _brandController,
                              decoration: const InputDecoration(
                                labelText: 'Brand',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.branding_watermark),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _modelController,
                              decoration: const InputDecoration(
                                labelText: 'Model',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.model_training),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _barcodeController,
                        decoration: const InputDecoration(
                          labelText: 'Barcode',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.qr_code_scanner),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Tax Type',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_balance),
                        ),
                        value: _selectedTaxType,
                        items: _taxTypes.map((taxType) {
                          return DropdownMenuItem<String>(
                            value: taxType,
                            child: Text(taxType),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTaxType = value!;
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
                        'Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Active'),
                        subtitle: const Text('Enable/disable this item'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Sellable'),
                        subtitle: const Text('Can this item be sold?'),
                        value: _isSellable,
                        onChanged: (value) {
                          setState(() {
                            _isSellable = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Purchasable'),
                        subtitle: const Text('Can this item be purchased?'),
                        value: _isPurchasable,
                        onChanged: (value) {
                          setState(() {
                            _isPurchasable = value;
                          });
                        },
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
                        context.go('/parties-inventory');
                      },
                      type: ButtonType.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Next: Stock Info',
                      onPressed: _saveAndContinue,
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

  Widget _buildStepIndicator() {
    return Column(
      children: [
        Row(
          children: [
            _buildStepCircle(1, true, true),
            _buildStepLine(true),
            _buildStepCircle(2, false, false),
            _buildStepLine(false),
            _buildStepCircle(3, false, false),
            _buildStepLine(false),
            _buildStepCircle(4, false, false),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                'Basic Info',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                'Stock',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                'Pricing',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                'Custom Fields',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepCircle(int step, bool isActive, bool isCompleted) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isActive || isCompleted
            ? Theme.of(context).primaryColor
            : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              )
            : Text(
                step.toString(),
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
      ),
    );
  }
}