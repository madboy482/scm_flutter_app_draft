import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import page screens
import 'pages/auths/login.dart';
import 'pages/auths/create_account.dart';
import 'pages/dashboards/admin_dashboard.dart';
import 'pages/dashboards/supplier_dashboard.dart';
import 'pages/dashboards/customer_dashboard.dart';
import 'pages/party/parties_page.dart';
import 'pages/party/create_party_page.dart';
import 'pages/party/address_page.dart';
import 'pages/purchase/purchase_orders.dart';
import 'pages/purchase/create_purchase_order.dart';
import 'pages/purchase/create_pi.dart';
import 'pages/purchase/pr_list.dart';
import 'pages/purchase/create_pr.dart';
import 'pages/purchase/delivery_challan.dart';
import 'pages/purchase/debit_note.dart';
import 'pages/purchase/payment_out.dart';
import 'pages/proforma/proforma_invoice.dart';
import 'pages/proforma/create_proforma.dart';
import 'pages/items/parties_inventory_ui.dart';
import 'pages/items/create_item_form.dart';
import 'pages/items/item_creation_stock.dart';
import 'pages/items/item_creation_pricing.dart';
import 'pages/items/item_creation_fields.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    // Authentication routes
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const CreateAccountPage(),
    ),
    
    // Dashboard routes
    GoRoute(
      path: '/admin-dashboard',
      builder: (context, state) => const AdminDashboardPage(),
    ),
    GoRoute(
      path: '/supplier-dashboard',
      builder: (context, state) => const SupplierDashboardPage(),
    ),
    GoRoute(
      path: '/customer-dashboard',
      builder: (context, state) => const CustomerDashboardPage(),
    ),
    
    // Party routes
    GoRoute(
      path: '/parties',
      builder: (context, state) => const PartiesPage(),
    ),
    GoRoute(
      path: '/create-party',
      builder: (context, state) => const CreatePartyPage(),
    ),
    GoRoute(
      path: '/party-address',
      builder: (context, state) => const AddressPage(),
    ),
    
    // Purchase routes
    GoRoute(
      path: '/purchase-orders',
      builder: (context, state) => const POs(),
    ),
    GoRoute(
      path: '/create-po',
      builder: (context, state) => const CreatePurchaseOrderPage(),
    ),
    GoRoute(
      path: '/create-purchase-invoice',
      builder: (context, state) => const CreatePI(),
    ),
    GoRoute(
      path: '/purchase-return-list',
      builder: (context, state) => const PRList(),
    ),
    GoRoute(
      path: '/create-purchase-return',
      builder: (context, state) => const CreatePR(),
    ),
    GoRoute(
      path: '/delivery-challan',
      builder: (context, state) => const DeliveryChallan(),
    ),
    GoRoute(
      path: '/debit-notes',
      builder: (context, state) => const DebitNote(),
    ),
    GoRoute(
      path: '/payment-out',
      builder: (context, state) => const PaymentOut(),
    ),
    
    // Proforma routes
    GoRoute(
      path: '/proforma-invoice',
      builder: (context, state) => const ProformaInvoice(),
    ),
    GoRoute(
      path: '/create-proforma-invoice',
      builder: (context, state) => const CreateProforma(),
    ),
    
    // Items routes
    GoRoute(
      path: '/parties-inventory',
      builder: (context, state) => const PartiesInventoryUI(),
    ),
    GoRoute(
      path: '/item_creation_basic',
      builder: (context, state) => const CreateItemForm(),
    ),
    GoRoute(
      path: '/item_creation_stock',
      builder: (context, state) => const ItemCreationStock(),
    ),
    GoRoute(
      path: '/item_creation_pricing',
      builder: (context, state) => const ItemCreationPricing(),
    ),
    GoRoute(
      path: '/item_creation_fields',
      builder: (context, state) => const ItemCreationFields(),
    ),
    
    // Root route
    GoRoute(
      path: '/',
      builder: (context, state) => const CreateAccountPage(),
    ),
  ],
);