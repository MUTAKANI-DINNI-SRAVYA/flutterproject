import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/category.dart';

class StorageService {
  static const String _productsKey = 'grocery_inventory_products_v2';
  static const String _categoriesKey = 'grocery_inventory_categories_v2';

  // In-memory fallback in case SharedPreferences is restricted or disabled
  static List<GroceryProduct> _memoryProducts = [];
  static List<GroceryCategory> _memoryCategories = [];

  /// Loads products from persistent storage, or initializes with sample data on first run
  Future<List<GroceryProduct>> loadProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? productsJson = prefs.getString(_productsKey);

      if (productsJson != null && productsJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(productsJson);
        final products = decoded
            .map((item) => GroceryProduct.fromJson(item as Map<String, dynamic>))
            .toList();
        _memoryProducts = products;
        return products;
      }
    } catch (e) {
      // In-memory fallback for sandbox environments
      if (_memoryProducts.isNotEmpty) {
        return _memoryProducts;
      }
    }

    // First time startup: populate with sample grocery inventory
    final defaultProducts = getSampleGroceryProducts();
    await saveProducts(defaultProducts);
    return defaultProducts;
  }

  /// Saves products to persistent storage
  Future<bool> saveProducts(List<GroceryProduct> products) async {
    _memoryProducts = List.from(products);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(
        products.map((p) => p.toJson()).toList(),
      );
      return await prefs.setString(_productsKey, encoded);
    } catch (e) {
      return true; // Memory fallback succeeded
    }
  }

  /// Loads categories from persistent storage
  Future<List<GroceryCategory>> loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? categoriesJson = prefs.getString(_categoriesKey);

      if (categoriesJson != null && categoriesJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(categoriesJson);
        final categories = decoded
            .map((item) => GroceryCategory.fromJson(item as Map<String, dynamic>))
            .toList();
        _memoryCategories = categories;
        return categories;
      }
    } catch (_) {
      if (_memoryCategories.isNotEmpty) {
        return _memoryCategories;
      }
    }

    final defaults = GroceryCategory.defaultCategories;
    _memoryCategories = defaults;
    return defaults;
  }

  /// Saves custom categories to storage
  Future<bool> saveCategories(List<GroceryCategory> categories) async {
    _memoryCategories = List.from(categories);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(
        categories.map((c) => c.toJson()).toList(),
      );
      return await prefs.setString(_categoriesKey, encoded);
    } catch (_) {
      return true;
    }
  }

  /// Sample grocery data for initial demonstration & college testing
  static List<GroceryProduct> getSampleGroceryProducts() {
    final now = DateTime.now();

    return [
      GroceryProduct(
        id: 'p_01',
        name: 'Fresh Gala Apples',
        sku: 'GRC-APL-001',
        categoryId: 'fruits_veg',
        costPrice: 120.00,
        sellingPrice: 160.00,
        stockQuantity: 12,
        minStockThreshold: 15, // Low stock
        unit: 'kg',
        expiryDate: now.add(const Duration(days: 9)),
        supplier: 'Orchard Valley Farms',
        notes: 'Crisp organic red gala apples. Keep refrigerated.',
        lastUpdated: now.subtract(const Duration(hours: 4)),
      ),
      GroceryProduct(
        id: 'p_02',
        name: 'Organic Cavendish Bananas',
        sku: 'GRC-BAN-002',
        categoryId: 'fruits_veg',
        costPrice: 40.00,
        sellingPrice: 60.00,
        stockQuantity: 45,
        minStockThreshold: 10,
        unit: 'kg',
        expiryDate: now.add(const Duration(days: 6)),
        supplier: 'Tropical Imports Co.',
        notes: 'Sustainably farmed Cavendish cluster bananas.',
        lastUpdated: now.subtract(const Duration(hours: 8)),
      ),
      GroceryProduct(
        id: 'p_03',
        name: 'Whole Pasteurized Milk 1 Litre',
        sku: 'GRC-MLK-003',
        categoryId: 'dairy_eggs',
        costPrice: 28.00,
        sellingPrice: 34.00,
        stockQuantity: 4,
        minStockThreshold: 10, // Low stock
        unit: 'bottle',
        expiryDate: now.add(const Duration(days: 5)),
        supplier: 'GreenMeadow Dairy',
        notes: 'Fresh pasteurized whole cow milk.',
        lastUpdated: now.subtract(const Duration(hours: 2)),
      ),
      GroceryProduct(
        id: 'p_04',
        name: 'Farm Fresh Grade-A Eggs',
        sku: 'GRC-EGG-004',
        categoryId: 'dairy_eggs',
        costPrice: 65.00,
        sellingPrice: 85.00,
        stockQuantity: 28,
        minStockThreshold: 8,
        unit: 'pack',
        expiryDate: now.add(const Duration(days: 18)),
        supplier: 'SunnyBrook Poultry',
        notes: '12-pack farm fresh white eggs.',
        lastUpdated: now.subtract(const Duration(days: 1)),
      ),
      GroceryProduct(
        id: 'p_05',
        name: 'Artisan Sourdough Loaf',
        sku: 'GRC-BRD-005',
        categoryId: 'bakery',
        costPrice: 45.00,
        sellingPrice: 65.00,
        stockQuantity: 0,
        minStockThreshold: 6, // Out of stock
        unit: 'pcs',
        expiryDate: now.add(const Duration(days: 3)),
        supplier: 'Golden Crust Bakers',
        notes: 'Naturally fermented rustic sourdough with crisp crust.',
        lastUpdated: now.subtract(const Duration(hours: 1)),
      ),
      GroceryProduct(
        id: 'p_06',
        name: 'Greek Strained Yogurt 500g',
        sku: 'GRC-YOG-006',
        categoryId: 'dairy_eggs',
        costPrice: 75.00,
        sellingPrice: 99.00,
        stockQuantity: 0,
        minStockThreshold: 8, // Out of stock
        unit: 'pcs',
        expiryDate: now.add(const Duration(days: 12)),
        supplier: 'Olympus Dairy Products',
        notes: 'High protein plain traditional Greek yogurt.',
        lastUpdated: now.subtract(const Duration(hours: 3)),
      ),
      GroceryProduct(
        id: 'p_07',
        name: 'Extra Virgin Cold Pressed Olive Oil 750ml',
        sku: 'GRC-OIL-007',
        categoryId: 'packaged',
        costPrice: 480.00,
        sellingPrice: 620.00,
        stockQuantity: 18,
        minStockThreshold: 5,
        unit: 'bottle',
        expiryDate: now.add(const Duration(days: 340)),
        supplier: 'Mediterranean Goods Ltd.',
        notes: 'First cold pressed unfiltered extra virgin oil.',
        lastUpdated: now.subtract(const Duration(days: 2)),
      ),
      GroceryProduct(
        id: 'p_08',
        name: 'Royal Basmati Rice 5kg',
        sku: 'GRC-RCE-008',
        categoryId: 'grains_staples',
        costPrice: 320.00,
        sellingPrice: 420.00,
        stockQuantity: 32,
        minStockThreshold: 10,
        unit: 'pack',
        expiryDate: now.add(const Duration(days: 400)),
        supplier: 'Global Grains Traders',
        notes: 'Aromatic aged long-grain basmati rice.',
        lastUpdated: now.subtract(const Duration(days: 3)),
      ),
      GroceryProduct(
        id: 'p_09',
        name: 'Single Origin Arabica Coffee 250g',
        sku: 'GRC-COF-009',
        categoryId: 'beverages',
        costPrice: 240.00,
        sellingPrice: 320.00,
        stockQuantity: 3,
        minStockThreshold: 6, // Low stock
        unit: 'pack',
        expiryDate: now.add(const Duration(days: 180)),
        supplier: 'Highland Roasters',
        notes: 'Medium roast ground filter coffee.',
        lastUpdated: now.subtract(const Duration(hours: 6)),
      ),
      GroceryProduct(
        id: 'p_10',
        name: 'Sparkling Mineral Water 1L',
        sku: 'GRC-WAT-010',
        categoryId: 'beverages',
        costPrice: 20.00,
        sellingPrice: 30.00,
        stockQuantity: 54,
        minStockThreshold: 15,
        unit: 'bottle',
        expiryDate: now.add(const Duration(days: 250)),
        supplier: 'Alpine Springs Bottling',
        notes: 'Naturally carbonated refreshing table water.',
        lastUpdated: now.subtract(const Duration(days: 1)),
      ),
      GroceryProduct(
        id: 'p_11',
        name: 'Dark Chocolate 70% with Sea Salt',
        sku: 'GRC-CHK-011',
        categoryId: 'snacks',
        costPrice: 80.00,
        sellingPrice: 110.00,
        stockQuantity: 24,
        minStockThreshold: 10,
        unit: 'pcs',
        expiryDate: now.add(const Duration(days: 210)),
        supplier: 'CocoaCraft Confectionery',
        notes: 'Fairtrade certified artisan dark chocolate bar.',
        lastUpdated: now.subtract(const Duration(days: 2)),
      ),
      GroceryProduct(
        id: 'p_12',
        name: 'Eco Multipurpose Surface Cleaner 1L',
        sku: 'GRC-CLN-012',
        categoryId: 'household',
        costPrice: 130.00,
        sellingPrice: 175.00,
        stockQuantity: 15,
        minStockThreshold: 5,
        unit: 'bottle',
        expiryDate: now.add(const Duration(days: 500)),
        supplier: 'CleanEarth Solutions',
        notes: 'Biodegradable citrus-based antibacterial cleaner.',
        lastUpdated: now.subtract(const Duration(days: 4)),
      ),
    ];
  }
}
