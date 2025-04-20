import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_button.dart';

class Party {
  final String id;
  final String name;
  final String type;
  final String email;
  final String phone;
  final double balance;

  Party({
    required this.id,
    required this.name,
    required this.type, 
    required this.email,
    required this.phone,
    required this.balance,
  });
}

class PartiesPage extends StatefulWidget {
  const PartiesPage({super.key});

  @override
  State<PartiesPage> createState() => _PartiesPageState();
}

class _PartiesPageState extends State<PartiesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  // Mock data for parties
  final List<Party> _parties = [
    Party(
      id: '1',
      name: 'ABC Suppliers',
      type: 'Supplier',
      email: 'info@abcsuppliers.com',
      phone: '+1 (555) 123-4567',
      balance: 2500.00,
    ),
    Party(
      id: '2',
      name: 'XYZ Manufacturing',
      type: 'Supplier',
      email: 'contact@xyzmanufacturing.com',
      phone: '+1 (555) 987-6543',
      balance: 4200.00,
    ),
    Party(
      id: '3',
      name: 'Acme Inc.',
      type: 'Customer',
      email: 'sales@acmeinc.com',
      phone: '+1 (555) 456-7890',
      balance: 1800.00,
    ),
    Party(
      id: '4',
      name: 'Global Retail',
      type: 'Customer',
      email: 'info@globalretail.com',
      phone: '+1 (555) 789-0123',
      balance: 3600.00,
    ),
    Party(
      id: '5',
      name: 'Tech Solutions',
      type: 'Supplier',
      email: 'support@techsolutions.com',
      phone: '+1 (555) 321-0987',
      balance: 1200.00,
    ),
  ];

  List<Party> _filteredParties = [];
  String _filterType = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filteredParties = List.from(_parties);
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _filterPartiesByType();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterPartiesByType() {
    setState(() {
      switch (_tabController.index) {
        case 0:
          _filterType = 'All';
          _filteredParties = List.from(_parties);
          break;
        case 1:
          _filterType = 'Supplier';
          _filteredParties = _parties.where((party) => party.type == 'Supplier').toList();
          break;
        case 2:
          _filterType = 'Customer';
          _filteredParties = _parties.where((party) => party.type == 'Customer').toList();
          break;
      }
    });
  }

  void _searchParties(String query) {
    final searchQuery = query.toLowerCase();
    
    setState(() {
      if (searchQuery.isEmpty) {
        _filterPartiesByType();
      } else {
        // Filter based on current tab and search query
        if (_filterType == 'All') {
          _filteredParties = _parties
              .where((party) => 
                  party.name.toLowerCase().contains(searchQuery) ||
                  party.email.toLowerCase().contains(searchQuery))
              .toList();
        } else {
          _filteredParties = _parties
              .where((party) => 
                  party.type == _filterType &&
                  (party.name.toLowerCase().contains(searchQuery) ||
                  party.email.toLowerCase().contains(searchQuery)))
              .toList();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parties'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Suppliers'),
            Tab(text: 'Customers'),
          ],
        ),
      ),
      drawer: const AppDrawer(currentUserType: 'admin'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchParties,
              decoration: InputDecoration(
                hintText: 'Search parties...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchParties('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredParties.isEmpty
                ? const Center(
                    child: Text(
                      'No parties found',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredParties.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final party = _filteredParties[index];
                      
                      return Card(
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          title: Row(
                            children: [
                              Text(
                                party.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Chip(
                                label: Text(
                                  party.type,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: party.type == 'Supplier'
                                    ? Colors.blue
                                    : Colors.green,
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.email, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(party.email),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(party.phone),
                                ],
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${party.balance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Balance',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Navigate to party details or actions
                            _showPartyActionSheet(context, party);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/create-party');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Party'),
      ),
    );
  }

  void _showPartyActionSheet(BuildContext context, Party party) {
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
            children: [
              Text(
                party.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                party.type,
                style: TextStyle(
                  fontSize: 16,
                  color: party.type == 'Supplier' ? Colors.blue : Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildActionButton(
                    context,
                    'Edit',
                    Icons.edit,
                    () {
                      Navigator.pop(context);
                      // Navigate to edit party page
                    },
                  ),
                  _buildActionButton(
                    context,
                    'Address',
                    Icons.location_on,
                    () {
                      Navigator.pop(context);
                      context.go('/party-address');
                    },
                  ),
                  if (party.type == 'Supplier')
                    _buildActionButton(
                      context,
                      'Orders',
                      Icons.shopping_cart,
                      () {
                        Navigator.pop(context);
                        context.go('/purchase-orders');
                      },
                    )
                  else
                    _buildActionButton(
                      context,
                      'Invoices',
                      Icons.receipt,
                      () {
                        Navigator.pop(context);
                        context.go('/proforma-invoice');
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
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

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          ),
        ],
      ),
    );
  }
}