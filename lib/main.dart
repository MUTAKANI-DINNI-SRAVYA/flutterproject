import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'state/inventory_state.dart';
import 'theme/app_theme.dart';
import 'screens/home_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for a sleek modern look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const GroceryInventoryApp());
}

class GroceryInventoryApp extends StatefulWidget {
  const GroceryInventoryApp({super.key});

  @override
  State<GroceryInventoryApp> createState() => _GroceryInventoryAppState();
}

class _GroceryInventoryAppState extends State<GroceryInventoryApp> {
  late final InventoryNotifier _inventoryNotifier;

  @override
  void initState() {
    super.initState();
    _inventoryNotifier = InventoryNotifier();
  }

  @override
  void dispose() {
    _inventoryNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InventoryScope(
      notifier: _inventoryNotifier,
      child: MaterialApp(
        title: 'StockBasket - Grocery Inventory System',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeDashboardScreen(),
      ),
    );
  }
}
