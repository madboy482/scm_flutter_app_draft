import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  final String currentUserType;

  const AppDrawer({
    super.key,
    required this.currentUserType,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SCM App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Supply Chain Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Menu items based on user type
          if (currentUserType == 'admin') _buildAdminMenu(context),
          if (currentUserType == 'supplier') _buildSupplierMenu(context),
          if (currentUserType == 'customer') _buildCustomerMenu(context),
          
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Provider.of<AuthService>(context, listen: false).logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminMenu(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          'Dashboard',
          Icons.dashboard,
          '/admin-dashboard',
        ),
        _buildMenuItem(
          context,
          'Parties',
          Icons.people,
          '/parties',
        ),
        _buildMenuItem(
          context,
          'Purchase Orders',
          Icons.shopping_cart,
          '/purchase-orders',
        ),
        _buildMenuItem(
          context,
          'Proforma Invoices',
          Icons.description,
          '/proforma-invoice',
        ),
        _buildMenuItem(
          context,
          'Inventory',
          Icons.inventory,
          '/parties-inventory',
        ),
        _buildMenuItem(
          context,
          'Delivery Challan',
          Icons.local_shipping,
          '/delivery-challan',
        ),
        _buildMenuItem(
          context,
          'Debit Notes',
          Icons.note,
          '/debit-notes',
        ),
        _buildMenuItem(
          context,
          'Payments',
          Icons.payment,
          '/payment-out',
        ),
      ],
    );
  }

  Widget _buildSupplierMenu(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          'Dashboard',
          Icons.dashboard,
          '/supplier-dashboard',
        ),
        _buildMenuItem(
          context,
          'Purchase Orders',
          Icons.shopping_cart,
          '/purchase-orders',
        ),
        _buildMenuItem(
          context,
          'Delivery Challan',
          Icons.local_shipping,
          '/delivery-challan',
        ),
      ],
    );
  }

  Widget _buildCustomerMenu(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          'Dashboard',
          Icons.dashboard,
          '/customer-dashboard',
        ),
        _buildMenuItem(
          context,
          'Proforma Invoices',
          Icons.description,
          '/proforma-invoice',
        ),
        _buildMenuItem(
          context,
          'Inventory',
          Icons.inventory,
          '/parties-inventory',
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        context.go(route);
      },
    );
  }
}