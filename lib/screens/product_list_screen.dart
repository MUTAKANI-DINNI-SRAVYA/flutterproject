import 'package:flutter/material.dart';
import '../state/inventory_state.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../widgets/empty_state_widget.dart';
import 'add_edit_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventory = InventoryScope.of(context);
    final filtered = inventory.filteredProducts;

    // Keep controller synced with search query state
    if (_searchController.text != inventory.searchQuery) {
      _searchController.text = inventory.searchQuery;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Inventory'),
        actions: [
          IconButton(
            tooltip: 'Sort Options',
            icon: const Icon(Icons.sort_rounded),
            onPressed: () => _showSortModal(context, inventory),
          ),
          if (inventory.searchQuery.isNotEmpty || inventory.selectedCategoryId != null)
            IconButton(
              tooltip: 'Clear Filters',
              icon: const Icon(Icons.filter_alt_off_rounded),
              onPressed: () {
                _searchController.clear();
                inventory.clearFilters();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products by name, SKU, or supplier...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                suffixIcon: inventory.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          inventory.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) => inventory.setSearchQuery(val),
            ),
          ),

          // Horizontal Category Filter Chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: inventory.selectedCategoryId == null,
                    label: Text('All (${inventory.products.length})'),
                    onSelected: (_) => inventory.setSelectedCategory(null),
                  ),
                ),
                ...inventory.categories.map((cat) {
                  final count = inventory.getProductCountByCategory(cat.id);
                  final isSelected = inventory.selectedCategoryId == cat.id;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      avatar: Icon(
                        cat.icon,
                        size: 14,
                        color: isSelected ? AppTheme.primaryGreen : cat.color,
                      ),
                      label: Text('${cat.name} ($count)'),
                      onSelected: (_) {
                        inventory.setSelectedCategory(isSelected ? null : cat.id);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Count and Active Sort Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${filtered.length} products',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                InkWell(
                  onTap: () => _showSortModal(context, inventory),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      children: [
                        Text(
                          _getSortLabel(inventory.sortBy),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, size: 16, color: AppTheme.primaryGreen),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Product List or Empty State
          Expanded(
            child: filtered.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: 'No Products Found',
                    message: inventory.searchQuery.isNotEmpty || inventory.selectedCategoryId != null
                        ? 'Try adjusting your search query or selecting a different category filter.'
                        : 'Your grocery inventory is currently empty. Add your first item to start!',
                    buttonText: inventory.searchQuery.isNotEmpty || inventory.selectedCategoryId != null
                        ? 'Clear All Filters'
                        : 'Add New Product',
                    onButtonPressed: () {
                      if (inventory.searchQuery.isNotEmpty || inventory.selectedCategoryId != null) {
                        _searchController.clear();
                        inventory.clearFilters();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
                        );
                      }
                    },
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, index) {
                      return ProductCard(product: filtered[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
          );
        },
      ),
    );
  }

  String _getSortLabel(String sortKey) {
    switch (sortKey) {
      case 'price_asc':
        return 'Price: Low to High';
      case 'price_desc':
        return 'Price: High to Low';
      case 'stock_asc':
        return 'Stock: Low to High';
      case 'stock_desc':
        return 'Stock: High to Low';
      case 'name':
      default:
        return 'Name: A to Z';
    }
  }

  void _showSortModal(BuildContext context, InventoryNotifier inventory) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Sort Products By',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildSortOption(ctx, inventory, 'name', 'Product Name (A - Z)', Icons.sort_by_alpha),
                _buildSortOption(ctx, inventory, 'price_asc', 'Price: Low to High', Icons.arrow_upward_rounded),
                _buildSortOption(ctx, inventory, 'price_desc', 'Price: High to Low', Icons.arrow_downward_rounded),
                _buildSortOption(ctx, inventory, 'stock_asc', 'Stock Level: Low to High', Icons.production_quantity_limits_rounded),
                _buildSortOption(ctx, inventory, 'stock_desc', 'Stock Level: High to Low', Icons.inventory_rounded),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    InventoryNotifier inventory,
    String key,
    String title,
    IconData icon,
  ) {
    final isSelected = inventory.sortBy == key;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade600),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppTheme.primaryGreen : AppTheme.textDark,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryGreen) : null,
      onTap: () {
        inventory.setSortBy(key);
        Navigator.pop(context);
      },
    );
  }
}
