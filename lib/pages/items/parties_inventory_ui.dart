import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_button.dart';

class InventoryItem {
  final String id;
  final String name;
  final String sku;
  final String category;
  final int quantity;
  final double cost;
  final double price;

  InventoryItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.quantity,
    required this.cost,
    required this.price,
  });
}

class PartiesInventoryUI extends StatefulWidget {
  const PartiesInventoryUI({super.key});

  @override
  State<PartiesInventoryUI> createState() => _PartiesInventoryUIState();
}

class _PartiesInventoryUIState extends State<PartiesInventoryUI> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  // Mock data for inventory items
  final List<InventoryItem> _items = [
    InventoryItem(
      id: '1',
      name: 'Laptop',
      sku: 'LAP-001',
      category: 'Electronics',
      quantity: 50,
      cost: 800.00,
      price: 999.99,
    ),
    InventoryItem(
      id: '2',
      name: 'Desktop Computer',
      sku: 'DSK-001',
      category: 'Electronics',
      quantity: 25,
      cost: 1000.00,
      price: 1299.99,
    ),
    InventoryItem(
      id: '3',
      name: 'Monitor',
      sku: 'MON-001',
      category: 'Electronics',
      quantity: 100,
      cost: 200.00,
      price: 299.99,
    ),
    InventoryItem(
      id: '4',
      name: 'Keyboard',
      sku: 'KEY-001',
      category: 'Accessories',
      quantity: 200,
      cost: 30.00,
      price: 49.99,
    ),
    InventoryItem(
      id: '5',
      name: 'Mouse',
      sku: 'MOU-001',
      category: 'Accessories',
      quantity: 300,
      cost: 15.00,
      price: 29.99,
    ),
  ];

  List<InventoryItem> _filteredItems = [];
  String _filterCategory = 'All';
  String _currentView = 'Grid';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filteredItems = List.from(_items);
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _filterItemsByStatus();
      }
    });
    
    _searchController.addListener(() {
      _filterItems();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterItemsByStatus() {
    setState(() {
      switch (_tabController.index) {
        case 0:
          _filteredItems = List.from(_items);
          break;
        case 1:
          _filteredItems = _items.where((item) => item.quantity > 0).toList();
          break;
        case 2:
          _filteredItems = _items.where((item) => item.quantity <= 5).toList();
          break;
      }
      
      if (_filterCategory != 'All') {
        _filteredItems = _filteredItems.where((item) => item.category == _filterCategory).toList();
      }
      
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        _filteredItems = _filteredItems.where((item) => 
          item.name.toLowerCase().contains(query) || 
          item.sku.toLowerCase().contains(query)
        ).toList();
      }
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _filterCategory = category;
      _filterItemsByStatus();
    });
  }

  void _filterItems() {
    _filterItemsByStatus();
  }

  List<String> get _categories {
    final categories = _items.map((item) => item.category).toSet().toList();
    categories.insert(0, 'All');
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Items'),
            Tab(text: 'In Stock'),
            Tab(text: 'Low Stock'),
          ],
        ),
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
                    hintText: 'Search items...',
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: _filterCategory == category,
                              onSelected: (selected) {
                                if (selected) {
                                  _filterByCategory(category);
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'Grid',
                          icon: Icon(Icons.grid_view),
                        ),
                        ButtonSegment(
                          value: 'List',
                          icon: Icon(Icons.view_list),
                        ),
                      ],
                      selected: {_currentView},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _currentView = newSelection.first;
                        });
                      },
                      style: const ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredItems.isEmpty
                ? const Center(
                    child: Text(
                      'No items found',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : _currentView == 'Grid'
                    ? _buildGridView()
                    : _buildListView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/item_creation_basic');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return Card(
          elevation: 2,
          child: InkWell(
            onTap: () {
              _showItemDetails(context, item);
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.inventory_2,
                        size: 48,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'SKU: ${item.sku}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.quantity > 5 ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Qty: ${item.quantity}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
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
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredItems.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return Card(
          elevation: 2,
          child: ListTile(
            title: Text(
              item.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SKU: ${item.sku}'),
                Text('Category: ${item.category}'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.quantity > 5 ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Qty: ${item.quantity}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {
              _showItemDetails(context, item);
            },
          ),
        );
      },
    );
  }

  void _showItemDetails(BuildContext context, InventoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 5,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'SKU: ${item.sku}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow('Category', item.category),
                    _buildDetailRow('Quantity in Stock', item.quantity.toString()),
                    _buildDetailRow('Cost Price', '\$${item.cost.toStringAsFixed(2)}'),
                    _buildDetailRow('Selling Price', '\$${item.price.toStringAsFixed(2)}'),
                    _buildDetailRow('Profit Margin', '${((item.price - item.cost) / item.cost * 100).toStringAsFixed(2)}%'),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionButton(
                          context,
                          'Edit',
                          Icons.edit,
                          () {
                            Navigator.pop(context);
                            context.go('/item_creation_basic');
                          },
                        ),
                        _buildActionButton(
                          context,
                          'Adjust Stock',
                          Icons.inventory,
                          () {
                            Navigator.pop(context);
                            context.go('/item_creation_stock');
                          },
                        ),
                        _buildActionButton(
                          context,
                          'Price',
                          Icons.attach_money,
                          () {
                            Navigator.pop(context);
                            context.go('/item_creation_pricing');
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
              ),
            );
          },
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
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
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