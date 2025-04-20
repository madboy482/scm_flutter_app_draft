import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_button.dart';
import 'package:flutter/services.dart';
import 'package:dotted_border/dotted_border.dart';

class ItemCreationFields extends StatefulWidget {
  const ItemCreationFields({super.key});

  @override
  State<ItemCreationFields> createState() => _ItemCreationFieldsState();
}

class _ItemCreationFieldsState extends State<ItemCreationFields> {
  final _formKey = GlobalKey<FormState>();
  
  // Custom fields
  final List<Map<String, dynamic>> _customFields = [
    {
      'id': '1',
      'name': 'Color',
      'type': 'Text',
      'value': '',
      'options': <String>[],
      'isRequired': false,
    },
    {
      'id': '2',
      'name': 'Size',
      'type': 'Select',
      'value': '',
      'options': ['Small', 'Medium', 'Large'],
      'isRequired': false,
    },
    {
      'id': '3',
      'name': 'Weight (kg)',
      'type': 'Number',
      'value': '',
      'options': <String>[],
      'isRequired': true,
    },
    {
      'id': '4',
      'name': 'Warranty (months)',
      'type': 'Number',
      'value': '',
      'options': <String>[],
      'isRequired': false,
    },
  ];
  
  // Create a form field controller for each custom field
  late List<TextEditingController> _controllers;
  
  // Section navigation
  String _activeSection = 'custom-fields';
  bool _showAddField = false;
  final TextEditingController _newFieldNameController = TextEditingController();
  final TextEditingController _newFieldValueController = TextEditingController();

  // Attributes
  bool _useAttributes = false;
  final List<String> _selectedAttributes = [];
  final List<Map<String, dynamic>> _availableAttributes = [
    {'id': '1', 'name': 'Color', 'values': ['Red', 'Blue', 'Green', 'Black', 'White']},
    {'id': '2', 'name': 'Size', 'values': ['Small', 'Medium', 'Large', 'XL', 'XXL']},
    {'id': '3', 'name': 'Material', 'values': ['Plastic', 'Metal', 'Wood', 'Glass', 'Fabric']},
  ];
  
  // Generate variants
  bool _generateVariants = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers for each custom field
    _controllers = List.generate(
      _customFields.length,
      (index) => TextEditingController(text: _customFields[index]['value']),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _newFieldNameController.dispose();
    _newFieldValueController.dispose();
    super.dispose();
  }

  void _toggleAttribute(String attributeName) {
    setState(() {
      if (_selectedAttributes.contains(attributeName)) {
        _selectedAttributes.remove(attributeName);
      } else {
        _selectedAttributes.add(attributeName);
      }
    });
  }

  Future<void> _saveAndFinish() async {
    if (_formKey.currentState!.validate()) {
      // Update custom field values from controllers
      for (int i = 0; i < _customFields.length; i++) {
        _customFields[i]['value'] = _controllers[i].text;
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
          const SnackBar(
            content: Text('Item created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back to inventory
        context.go('/parties-inventory');
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

  void _addCustomField() {
    if (_newFieldNameController.text.trim().isNotEmpty) {
      setState(() {
        _customFields.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'name': _newFieldNameController.text,
          'type': 'Text',
          'value': _newFieldValueController.text,
          'options': <String>[],
          'isRequired': false,
        });
        
        _controllers.add(TextEditingController(text: _newFieldValueController.text));
        _newFieldNameController.clear();
        _newFieldValueController.clear();
        _showAddField = false;
      });
    }
  }

  void _removeField(int index) {
    setState(() {
      _customFields.removeAt(index);
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
  }

  void _handleSectionClick(String sectionId, String? path) {
    if (path != null && path.isNotEmpty) {
      context.go(path);
    } else {
      setState(() {
        _activeSection = sectionId;
      });
    }
  }

  String _generateItemCode() {
    return (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
  }

  Widget _buildFieldInput(int index) {
    final field = _customFields[index];
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                field['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              TextButton(
                onPressed: () => _removeField(index),
                child: const Text(
                  'Remove',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: _controllers[index],
            decoration: const InputDecoration(
              hintText: 'Enter value',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            keyboardType: field['type'] == 'Number' 
                ? TextInputType.number 
                : TextInputType.text,
            validator: field['isRequired']
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    if (field['type'] == 'Number' && double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionNavigation() {
    final sections = [
      {
        'id': 'basic-details', 
        'label': 'Basic Details', 
        'icon': Icons.file_copy_outlined,
        'path': '/item_creation_basic'
      },
      {
        'id': 'stock-details', 
        'label': 'Stock Details', 
        'icon': Icons.bar_chart,
        'path': '/item_creation_stock'
      },
      {
        'id': 'pricing-details', 
        'label': 'Pricing Details', 
        'icon': Icons.credit_card,
        'path': '/item_creation_pricing'
      },
      {
        'id': 'custom-fields', 
        'label': 'Custom Fields', 
        'icon': Icons.home,
        'path': ''
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: sections.map((section) {
          final isActive = _activeSection == section['id'];
          return Expanded(
            child: InkWell(
              onTap: () => _handleSectionClick(
                section['id'] as String,
                section['path'] as String,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isActive ? Colors.purple.shade50 : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      section['icon'] as IconData,
                      color: isActive ? Colors.purple : Colors.grey.shade600,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      section['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive ? Colors.purple : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddFieldForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple.shade200, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: Colors.purple.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Custom Field',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Field Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _newFieldNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter field name',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Field Value',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _newFieldValueController,
                decoration: const InputDecoration(
                  hintText: 'Enter field value',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                onPressed: _addCustomField,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Add Field'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _showAddField = false;
                    _newFieldNameController.clear();
                    _newFieldValueController.clear();
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.file_copy_outlined,
                size: 40,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "You don't have any custom fields create yet",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _showAddField = true;
                });
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create Custom fields'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.purple,
                side: BorderSide(color: Colors.purple.shade300),
                backgroundColor: Colors.purple.shade50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddFieldButton() {
  return InkWell(
    onTap: () {
      setState(() {
        _showAddField = true;
      });
    },
    child: DottedBorder(
      color: Colors.purple.shade300,
      strokeWidth: 2,
      borderType: BorderType.RRect,
      radius: const Radius.circular(8),
      dashPattern: const [6, 3],
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: Colors.purple,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Add another custom field',
              style: TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final bool showEmptyState = _customFields.isEmpty && !_showAddField;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () {
                  context.go('/parties-inventory');
                },
              ),
              const SizedBox(width: 8),
              const Text(
                'Custom Fields',
                style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Cancel action
                context.go('/parties-inventory');
              },
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _saveAndFinish,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildSectionNavigation(),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: showEmptyState 
                        ? _buildEmptyState()
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                if (!showEmptyState && !_showAddField && _customFields.isNotEmpty)
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _customFields.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                                    itemBuilder: (context, index) {
                                      return _buildFieldInput(index);
                                    },
                                  ),
                                
                                if (_showAddField)
                                  _buildAddFieldForm()
                                else if (!showEmptyState)
                                  Column(
                                    children: [
                                      if (_customFields.isNotEmpty) 
                                        const SizedBox(height: 16),
                                      _buildAddFieldButton(),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.home_outlined),
                  onPressed: () => context.go('/dashboard'),
                ),
                IconButton(
                  icon: const Icon(Icons.receipt_long_outlined),
                  onPressed: () => context.go('/invoices'),
                ),
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  onPressed: () => context.go('/purchase'),
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () => context.go('/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}