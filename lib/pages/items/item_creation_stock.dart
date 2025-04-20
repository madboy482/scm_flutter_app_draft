import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_button.dart';

class ItemCreationStock extends StatefulWidget {
  const ItemCreationStock({super.key});

  @override
  State<ItemCreationStock> createState() => _ItemCreationStockState();
}

class _ItemCreationStockState extends State<ItemCreationStock> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _initialStockController = TextEditingController(text: '0');
  final _minStockLevelController = TextEditingController(text: '5');
  final _reorderLevelController = TextEditingController(text: '10');
  final _reorderQuantityController = TextEditingController(text: '20');
  final _locationController = TextEditingController();
  final _binController = TextEditingController();
  final _rackController = TextEditingController();
  final _rowController = TextEditingController();
  
  // Settings
  bool _trackInventory = true;
  bool _allowBackorders = false;
  bool _showLowStockAlert = true;
  bool _useMultipleLocations = false;
  bool _isExpirable = false;
  
  bool _isLoading = false;

  @override
  void dispose() {
    _initialStockController.dispose();
    _minStockLevelController.dispose();
    _reorderLevelController.dispose();
    _reorderQuantityController.dispose();
    _locationController.dispose();
    _binController.dispose();
    _rackController.dispose();
    _rowController.dispose();
    super.dispose();
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
            content: Text('Item stock information saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to the next step (Pricing)
        context.go('/item_creation_pricing');
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
          title: const Text('Create Item - Stock Info'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _onWillPop().then((result) {
                if (result) {
                  context.go('/item_creation_basic');
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
                          'Inventory Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Track Inventory'),
                          subtitle: const Text('Keep track of stock levels'),
                          value: _trackInventory,
                          onChanged: (value) {
                            setState(() {
                              _trackInventory = value;
                            });
                          },
                        ),
                        SwitchListTile(
                          title: const Text('Allow Backorders'),
                          subtitle: const Text('Allow orders when out of stock'),
                          value: _allowBackorders,
                          onChanged: (value) {
                            setState(() {
                              _allowBackorders = value;
                            });
                          },
                        ),
                        SwitchListTile(
                          title: const Text('Show Low Stock Alert'),
                          subtitle: const Text('Get notified when stock is low'),
                          value: _showLowStockAlert,
                          onChanged: (value) {
                            setState(() {
                              _showLowStockAlert = value;
                            });
                          },
                        ),
                        SwitchListTile(
                          title: const Text('Use Multiple Locations'),
                          subtitle: const Text('Track stock in different locations'),
                          value: _useMultipleLocations,
                          onChanged: (value) {
                            setState(() {
                              _useMultipleLocations = value;
                            });
                          },
                        ),
                        SwitchListTile(
                          title: const Text('Expirable Item'),
                          subtitle: const Text('Track expiry dates'),
                          value: _isExpirable,
                          onChanged: (value) {
                            setState(() {
                              _isExpirable = value;
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
                          'Stock Levels',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _initialStockController,
                          decoration: const InputDecoration(
                            labelText: 'Initial Stock',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.inventory),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter initial stock';
                            }
                            if (int.tryParse(value) == null) {
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
                                controller: _minStockLevelController,
                                decoration: const InputDecoration(
                                  labelText: 'Minimum Stock Level',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.warning),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter min stock';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _reorderLevelController,
                                decoration: const InputDecoration(
                                  labelText: 'Reorder Level',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.refresh),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter reorder level';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _reorderQuantityController,
                          decoration: const InputDecoration(
                            labelText: 'Reorder Quantity',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.add_shopping_cart),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter reorder quantity';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
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
                          'Storage Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _binController,
                                decoration: const InputDecoration(
                                  labelText: 'Bin',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.shelves),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _rackController,
                                decoration: const InputDecoration(
                                  labelText: 'Rack',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.grid_4x4),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _rowController,
                          decoration: const InputDecoration(
                            labelText: 'Row',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.view_week),
                          ),
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
                        text: 'Back',
                        onPressed: () {
                          context.go('/item_creation_basic');
                        },
                        type: ButtonType.secondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Next: Pricing',
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
            _buildStepCircle(2, true, false),
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
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                'Stock',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
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