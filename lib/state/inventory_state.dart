import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/storage_service.dart';

class InventoryNotifier extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<GroceryProduct> _products = [];
  List<GroceryCategory> _categories = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategoryId;
  String _sortBy = 'name'; // 'name', 'price_asc', 'price_desc', 'stock_asc', 'stock_desc'

  List<GroceryProduct> get products => List.unmodifiable(_products);
  List<GroceryCategory> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  String get sortBy => _sortBy;

  InventoryNotifier() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _categories = await _storageService.loadCategories();
    _products = await _storageService.loadProducts();

    _isLoading = false;
    notifyListeners();
  }

  // --- Filtered and Sorted Products ---
  List<GroceryProduct> get filteredProducts {
    List<GroceryProduct> list = _products.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.sku.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.supplier.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategoryId == null ||
          item.categoryId == _selectedCategoryId;

      return matchesSearch && matchesCategory;
    }).toList();

    switch (_sortBy) {
      case 'price_asc':
        list.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
        break;
      case 'price_desc':
        list.sort((a, b) => b.sellingPrice.compareTo(a.sellingPrice));
        break;
      case 'stock_asc':
        list.sort((a, b) => a.stockQuantity.compareTo(b.stockQuantity));
        break;
      case 'stock_desc':
        list.sort((a, b) => b.stockQuantity.compareTo(a.stockQuantity));
        break;
      case 'name':
      default:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
    }

    return list;
  }

  // Stock status getters
  List<GroceryProduct> get lowStockProducts =>
      _products.where((p) => p.isLowStock).toList();

  List<GroceryProduct> get outOfStockProducts =>
      _products.where((p) => p.isOutOfStock).toList();

  List<GroceryProduct> get alertProducts =>
      _products.where((p) => p.isLowStock || p.isOutOfStock).toList();

  // --- Statistics and KPI Metrics ---
  int get totalProductsCount => _products.length;

  int get totalUnitsInStock =>
      _products.fold(0, (sum, item) => sum + (item.stockQuantity > 0 ? item.stockQuantity : 0));

  double get totalInventoryRetailValue =>
      _products.fold(0.0, (sum, item) => sum + item.totalInventoryRetailValue);

  double get totalInventoryCostValue =>
      _products.fold(0.0, (sum, item) => sum + item.totalInventoryCostValue);

  double get totalPotentialProfit =>
      totalInventoryRetailValue - totalInventoryCostValue;

  int get lowStockCount => lowStockProducts.length;
  int get outOfStockCount => outOfStockProducts.length;

  // --- Filter and Search Controls ---
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSortBy(String sortOption) {
    _sortBy = sortOption;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    _sortBy = 'name';
    notifyListeners();
  }

  // --- Product CRUD Operations ---
  Future<void> addProduct(GroceryProduct product) async {
    _products.insert(0, product);
    notifyListeners();
    await _storageService.saveProducts(_products);
  }

  Future<void> updateProduct(GroceryProduct updatedProduct) async {
    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners();
      await _storageService.saveProducts(_products);
    }
  }

  Future<void> deleteProduct(String productId) async {
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
    await _storageService.saveProducts(_products);
  }

  // --- Quick Stock Adjustments ---
  Future<void> updateStock(String productId, int newQuantity) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final safeQty = newQuantity < 0 ? 0 : newQuantity;
      _products[index] = _products[index].copyWith(
        stockQuantity: safeQty,
        lastUpdated: DateTime.now(),
      );
      notifyListeners();
      await _storageService.saveProducts(_products);
    }
  }

  Future<void> adjustStock(String productId, int delta) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final current = _products[index].stockQuantity;
      final newQty = (current + delta) < 0 ? 0 : (current + delta);
      _products[index] = _products[index].copyWith(
        stockQuantity: newQty,
        lastUpdated: DateTime.now(),
      );
      notifyListeners();
      await _storageService.saveProducts(_products);
    }
  }

  // --- Category Operations ---
  Future<void> addCategory(GroceryCategory category) async {
    _categories.add(category);
    notifyListeners();
    await _storageService.saveCategories(_categories);
  }

  GroceryCategory? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  int getProductCountByCategory(String categoryId) {
    return _products.where((p) => p.categoryId == categoryId).length;
  }

  /// Reset to sample dataset (useful for testing and demo reset)
  Future<void> resetToSampleData() async {
    _isLoading = true;
    notifyListeners();

    _products = StorageService.getSampleGroceryProducts();
    _categories = GroceryCategory.defaultCategories;
    await _storageService.saveProducts(_products);
    await _storageService.saveCategories(_categories);

    _isLoading = false;
    notifyListeners();
  }
}

/// An InheritedNotifier that gives descendants easy access to the [InventoryNotifier].
class InventoryScope extends InheritedNotifier<InventoryNotifier> {
  const InventoryScope({
    super.key,
    required InventoryNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static InventoryNotifier of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<InventoryScope>();
    assert(scope != null, 'No InventoryScope found in context');
    return scope!.notifier!;
  }
}
