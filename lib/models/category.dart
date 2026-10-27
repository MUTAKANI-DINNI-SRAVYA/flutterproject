import 'package:flutter/material.dart';

class GroceryCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const GroceryCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<IconData> availableIcons = [
    Icons.inventory_2_rounded,
    Icons.eco_rounded,
    Icons.egg_alt_rounded,
    Icons.bakery_dining_rounded,
    Icons.local_cafe_rounded,
    Icons.grain_rounded,
    Icons.cookie_rounded,
    Icons.cleaning_services_rounded,
    Icons.fastfood_rounded,
    Icons.restaurant_rounded,
    Icons.shopping_basket_rounded,
    Icons.local_grocery_store_rounded,
    Icons.category_rounded,
  ];

  static IconData _iconFromCodePoint(int? codePoint) {
    if (codePoint == null) return Icons.category_rounded;
    for (final icon in availableIcons) {
      if (icon.codePoint == codePoint) {
        return icon;
      }
    }
    return Icons.category_rounded;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      // ignore: deprecated_member_use
      'colorValue': color.value,
    };
  }

  factory GroceryCategory.fromJson(Map<String, dynamic> json) {
    return GroceryCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: _iconFromCodePoint(json['iconCodePoint'] as int?),
      color: Color(json['colorValue'] as int? ?? 0xFF2E7D32),
    );
  }

  static List<GroceryCategory> get defaultCategories => [
    const GroceryCategory(
      id: 'fruits_veg',
      name: 'Fruits & Veggies',
      icon: Icons.eco_rounded,
      color: Color(0xFF2E7D32),
    ),
    const GroceryCategory(
      id: 'dairy_eggs',
      name: 'Dairy & Eggs',
      icon: Icons.egg_alt_rounded,
      color: Color(0xFF0277BD),
    ),
    const GroceryCategory(
      id: 'bakery',
      name: 'Bakery & Bread',
      icon: Icons.bakery_dining_rounded,
      color: Color(0xFFE65100),
    ),
    const GroceryCategory(
      id: 'beverages',
      name: 'Beverages',
      icon: Icons.local_cafe_rounded,
      color: Color(0xFF00838F),
    ),
    const GroceryCategory(
      id: 'grains_staples',
      name: 'Grains & Staples',
      icon: Icons.grain_rounded,
      color: Color(0xFF8D6E63),
    ),
    const GroceryCategory(
      id: 'snacks',
      name: 'Snacks & Sweets',
      icon: Icons.cookie_rounded,
      color: Color(0xFFAD1457),
    ),
    const GroceryCategory(
      id: 'packaged',
      name: 'Packaged & Canned',
      icon: Icons.inventory_2_rounded,
      color: Color(0xFF558B2F),
    ),
    const GroceryCategory(
      id: 'household',
      name: 'Household & Cleaning',
      icon: Icons.cleaning_services_rounded,
      color: Color(0xFF4527A0),
    ),
  ];
}
