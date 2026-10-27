class GroceryProduct {
  final String id;
  final String name;
  final String sku;
  final String categoryId;
  final double costPrice;
  final double sellingPrice;
  final int stockQuantity;
  final int minStockThreshold;
  final String unit;
  final DateTime? expiryDate;
  final String supplier;
  final String notes;
  final DateTime lastUpdated;

  const GroceryProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.categoryId,
    required this.costPrice,
    required this.sellingPrice,
    required this.stockQuantity,
    this.minStockThreshold = 10,
    this.unit = 'pcs',
    this.expiryDate,
    this.supplier = 'General Supplier',
    this.notes = '',
    required this.lastUpdated,
  });

  bool get isOutOfStock => stockQuantity <= 0;
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= minStockThreshold;
  bool get isHealthyStock => stockQuantity > minStockThreshold;

  String get stockStatusText {
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'In Stock';
  }

  double get totalInventoryRetailValue => sellingPrice * stockQuantity;
  double get totalInventoryCostValue => costPrice * stockQuantity;
  double get profitPerUnit => sellingPrice - costPrice;
  double get profitMarginPercent {
    if (costPrice <= 0) return 0.0;
    return ((sellingPrice - costPrice) / costPrice) * 100.0;
  }

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final difference = expiryDate!.difference(DateTime.now()).inDays;
    return difference >= 0 && difference <= 14;
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  GroceryProduct copyWith({
    String? id,
    String? name,
    String? sku,
    String? categoryId,
    double? costPrice,
    double? sellingPrice,
    int? stockQuantity,
    int? minStockThreshold,
    String? unit,
    DateTime? expiryDate,
    String? supplier,
    String? notes,
    DateTime? lastUpdated,
  }) {
    return GroceryProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      categoryId: categoryId ?? this.categoryId,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockThreshold: minStockThreshold ?? this.minStockThreshold,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      supplier: supplier ?? this.supplier,
      notes: notes ?? this.notes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'categoryId': categoryId,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'stockQuantity': stockQuantity,
      'minStockThreshold': minStockThreshold,
      'unit': unit,
      'expiryDate': expiryDate?.toIso8601String(),
      'supplier': supplier,
      'notes': notes,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory GroceryProduct.fromJson(Map<String, dynamic> json) {
    return GroceryProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String? ?? 'SKU-${json['id']}',
      categoryId: json['categoryId'] as String? ?? 'packaged',
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
      minStockThreshold: (json['minStockThreshold'] as num?)?.toInt() ?? 10,
      unit: json['unit'] as String? ?? 'pcs',
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'] as String)
          : null,
      supplier: json['supplier'] as String? ?? 'General Supplier',
      notes: json['notes'] as String? ?? '',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
