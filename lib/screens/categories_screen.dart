import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../state/inventory_state.dart';
import '../theme/app_theme.dart';
import 'product_list_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = InventoryScope.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery Categories'),
        actions: [
          IconButton(
            tooltip: 'Add Category',
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(context, inventory),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: inventory.categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, index) {
          final cat = inventory.categories[index];
          final productCount = inventory.getProductCountByCategory(cat.id);

          // Calculate category retail valuation
          final categoryValuation = inventory.products
              .where((p) => p.categoryId == cat.id)
              .fold(0.0, (sum, p) => sum + p.totalInventoryRetailValue);

          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                inventory.setSelectedCategory(cat.id);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductListScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cat.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(cat.icon, size: 26, color: cat.color),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$productCount items • Valuation: ${currencyFormat.format(categoryValuation)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
        onPressed: () => _showAddCategoryDialog(context, inventory),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, InventoryNotifier inventory) {
    final nameController = TextEditingController();
    Color selectedColor = const Color(0xFF2E7D32);
    IconData selectedIcon = Icons.inventory_2_rounded;

    final colorOptions = [
      const Color(0xFF2E7D32),
      const Color(0xFF0277BD),
      const Color(0xFFE65100),
      const Color(0xFF00838F),
      const Color(0xFF8D6E63),
      const Color(0xFFAD1457),
      const Color(0xFF558B2F),
      const Color(0xFF4527A0),
      const Color(0xFFD84315),
    ];

    final iconOptions = [
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
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Grocery Category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        hintText: 'e.g. Frozen Foods',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Select Icon', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: iconOptions.map((icon) {
                        final isSel = selectedIcon == icon;
                        return InkWell(
                          onTap: () => setDialogState(() => selectedIcon = icon),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSel ? AppTheme.surfaceGreen : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSel ? AppTheme.primaryGreen : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Icon(icon, size: 20, color: isSel ? AppTheme.primaryGreen : Colors.grey.shade700),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Select Accent Color', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: colorOptions.map((c) {
                        final isSel = selectedColor.value == c.value;
                        return InkWell(
                          onTap: () => setDialogState(() => selectedColor = c),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel ? Colors.black87 : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: isSel ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      final id = name.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
                      inventory.addCategory(
                        GroceryCategory(
                          id: id,
                          name: name,
                          icon: selectedIcon,
                          color: selectedColor,
                        ),
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added category "$name"')),
                      );
                    }
                  },
                  child: const Text('Add Category'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
