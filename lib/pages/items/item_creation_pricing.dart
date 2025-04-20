import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_button.dart';

class ItemCreationPricing extends StatefulWidget {
  const ItemCreationPricing({super.key});

  @override
  State<ItemCreationPricing> createState() => _ItemCreationPricingState();
}

class _ItemCreationPricingState extends State<ItemCreationPricing> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _costPriceController = TextEditingController(text: '0.00');
  final _sellingPriceController = TextEditingController(text: '0.00');
  final _wholesalePriceController = TextEditingController(text: '0.00');
  final _msrpController = TextEditingController(text: '0.00');
  final _markupController = TextEditingController(text: '30');
  final _minMarginController = TextEditingController(text: '20');
  final _taxRateController = TextEditingController(text: '10');
  
  // Settings
  bool _includeTax = false;
  bool _hasSpecialPricing = false;
  String _discountType = 'Percentage';
  final _discountValueController = TextEditingController(text: '0');
  
  // Price tiers
  final List<Map<String, dynamic>> _priceTiers = [
    {'name': 'Tier 1 (10+ units)', 'price': '0.00'},
    {'name': 'Tier 2 (50+ units)', 'price': '0.00'},
    {'name': 'Tier 3 (100+ units)', 'price': '0.00'},
  ];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Add listeners to update prices automatically
    _costPriceController.addListener(_updatePricesBasedOnCost);
    _markupController.addListener(_updatePricesBasedOnCost);
  }

  @override
  void dispose() {
    _costPriceController.removeListener(_updatePricesBasedOnCost);
    _markupController.removeListener(_updatePricesBasedOnCost);
    
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _wholesalePriceController.dispose();
    _msrpController.dispose();
    _markupController.dispose();
    _minMarginController.dispose();
    _taxRateController.dispose();
    _discountValueController.dispose();
    super.dispose();
  }

  void _updatePricesBasedOnCost() {
    final costPrice = double.tryParse(_costPriceController.text) ?? 0.0;
    final markup = double.tryParse(_markupController.text) ?? 0.0;
    
    if (costPrice > 0 && markup > 0) {
      final sellingPrice = costPrice * (1 + markup / 100);
      final wholesalePrice = costPrice * (1 + (markup / 2) / 100);
      final msrp = sellingPrice * 1.1;  // 10% above selling price
      
      setState(() {
        _sellingPriceController.text = sellingPrice.toStringAsFixed(2);
        _wholesalePriceController.text = wholesalePrice.toStringAsFixed(2);
        _msrpController.text = msrp.toStringAsFixed(2);
        
        // Update tier prices
        _priceTiers[0]['price'] = (sellingPrice * 0.95).toStringAsFixed(2);  // 5% discount
        _priceTiers[1]['price'] = (sellingPrice * 0.9).toStringAsFixed(2);   // 10% discount
        _priceTiers[2]['price'] = (sellingPrice * 0.85).toStringAsFixed(2);  // 15% discount
      });
    }
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
            content: Text('Item pricing information saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to the next step (Custom Fields)
        context.go('/item_creation_fields');
      }
    }
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Your changes may not be saved.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Item - Pricing'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _onWillPop().then((result) {
                if (result) {
                  context.go('/item_creation_stock');
                }
              });
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
                          'Basic Pricing',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _costPriceController,
                          decoration: const InputDecoration(
                            labelText: 'Cost Price *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                            prefixText: '\$ ',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter cost price';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _sellingPriceController,
                          decoration: const InputDecoration(
                            labelText: 'Selling Price *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.sell),
                            prefixText: '\$ ',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter selling price';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _wholesalePriceController,
                                decoration: const InputDecoration(
                                  labelText: 'Wholesale Price',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.business),
                                  prefixText: '\$ ',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _msrpController,
                                decoration: const InputDecoration(
                                  labelText: 'MSRP',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.local_offer),
                                  prefixText: '\$ ',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
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
                          'Pricing Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _markupController,
                                decoration: const InputDecoration(
                                  labelText: 'Markup %',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.trending_up),
                                  suffixText: '%',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter markup';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _minMarginController,
                                decoration: const InputDecoration(
                                  labelText: 'Min. Margin %',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.trending_down),
                                  suffixText: '%',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _taxRateController,
                          decoration: const InputDecoration(
                            labelText: 'Tax Rate %',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.account_balance),
                            suffixText: '%',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          title: const Text('Prices Include Tax'),
                          subtitle: const Text('Toggle if prices already include tax'),
                          value: _includeTax,
                          onChanged: (value) {
                            setState(() {
                              _includeTax = value;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
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
                              'Special Pricing',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Switch(
                              value: _hasSpecialPricing,
                              onChanged: (value) {
                                setState(() {
                                  _hasSpecialPricing = value;
                                });
                              },
                            ),
                          ],
                        ),
                        if (_hasSpecialPricing) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Discount Type',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.discount),
                                  ),
                                  value: _discountType,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Percentage',
                                      child: Text('Percentage (%)'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Amount',
                                      child: Text('Fixed Amount (\$)'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _discountType = value!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  controller: _discountValueController,
                                  decoration: InputDecoration(
                                    labelText: 'Value',
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.confirmation_number),
                                    suffixText: _discountType == 'Percentage' ? '%' : '\$',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Quantity-based Pricing',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _priceTiers.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(_priceTiers[index]['name']),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: TextFormField(
                                        initialValue: _priceTiers[index]['price'],
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          prefixText: '\$ ',
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 12,
                                          ),
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          setState(() {
                                            _priceTiers[index]['price'] = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Back',
                        onPressed: () {
                          context.go('/item_creation_stock');
                        },
                        type: ButtonType.secondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Next: Custom Fields',
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
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Column(
      children: [
        Row(
          children: [
            _buildStepCircle(1, false, true),
            _buildStepLine(true),
            _buildStepCircle(2, false, true),
            _buildStepLine(true),
            _buildStepCircle(3, true, false),
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
                  color: Colors.grey[600],
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
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
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