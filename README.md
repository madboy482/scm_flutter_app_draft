# scm_flutter_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

```
lib/
├── main.dart                # Entry point
├── routes.dart              # Navigation routes
├── theme.dart               # App theme
├── models/                  # Data models
├── widgets/                 # Reusable widgets
├── pages/
│   ├── auths/               # Login, CreateAccount
│   ├── dashboards/          # Admin, Supplier, Customer dashboards
│   ├── party/               # Parties, CreateParty, Address
│   ├── purchase/            # PO, PI, PR, etc.
│   ├── proforma/            # ProformaInvoice, CreateProforma
│   └── items/               # Inventory, CreateItem, etc.
├── services/                # API services
└── utils/                   # Utility functions
```