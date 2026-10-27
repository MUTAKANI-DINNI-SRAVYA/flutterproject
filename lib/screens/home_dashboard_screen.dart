import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../state/inventory_state.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/product_card.dart';
import 'product_list_screen.dart';
import 'add_edit_product_screen.dart';
import 'low_stock_screen.dart';
import 'categories_screen.dart';
import 'inventory_analytics_screen.dart';
import 'sdg_impact_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = InventoryScope.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('EEE, d MMM yyyy');

    if (inventory.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
        ),
      );
    }

    final totalValue = currencyFormat.format(inventory.totalInventoryRetailValue);
    final totalUnits = inventory.totalUnitsInStock;
    final lowStock = inventory.lowStockCount;
    final outOfStock = inventory.outOfStockCount;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'StockBasket',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                Text(
                  'Grocery Inventory System',
                  style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'UN SDG & Social Impact',
            icon: const Icon(Icons.public_rounded, color: Color(0xFF00796B)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SdgImpactScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Inventory Analytics',
            icon: const Icon(Icons.insights_rounded, color: AppTheme.primaryLight),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InventoryAnalyticsScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) {
              if (val == 'reset') {
                _confirmResetData(context, inventory);
              } else if (val == 'categories') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                );
              } else if (val == 'sdg') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SdgImpactScreen()),
                );
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'sdg',
                child: Row(
                  children: [
                    Icon(Icons.public_rounded, size: 18, color: Color(0xFF00796B)),
                    SizedBox(width: 8),
                    Text('UN SDG Impact Goals'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'categories',
                child: Row(
                  children: [
                    Icon(Icons.category_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Manage Categories'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.restart_alt_rounded, size: 18, color: AppTheme.warningOrange),
                    SizedBox(width: 8),
                    Text('Reset Demo Data'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryGreen,
        onRefresh: () async {
          await inventory.init();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store status banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormat.format(DateTime.now()),
                          style: TextStyle(
                            color: Colors.green.shade100,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Inventory Overview',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${inventory.totalProductsCount} items tracked in inventory',
                          style: TextStyle(
                            color: Colors.green.shade50,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        'Add Item',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // SDG Alignment Banner
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SdgImpactScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF80CBC4)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF00796B),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.public_rounded, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'UN SDG Alignment: Goals 12, 2 & 8',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF004D40),
                              ),
                            ),
                            Text(
                              'Preventing retail food waste & enabling sustainable local retail',
                              style: TextStyle(fontSize: 10.5, color: Color(0xFF00695C)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFF004D40)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // KPI Stats Grid
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StatCard(
                    title: 'Total Items',
                    value: '${inventory.totalProductsCount}',
                    subtitle: '$totalUnits total units in stock',
                    icon: Icons.inventory_2_rounded,
                    accentColor: AppTheme.primaryLight,
                    onTap: () {
                      inventory.clearFilters();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProductListScreen()),
                      );
                    },
                  ),
                  StatCard(
                    title: 'Retail Valuation',
                    value: totalValue,
                    subtitle: 'Profit: ${currencyFormat.format(inventory.totalPotentialProfit)}',
                    icon: Icons.monetization_on_rounded,
                    accentColor: const Color(0xFF00897B),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const InventoryAnalyticsScreen()),
                      );
                    },
                  ),
                  StatCard(
                    title: 'Low Stock Alerts',
                    value: '$lowStock',
                    subtitle: lowStock > 0 ? 'Requires restocking' : 'Stock level healthy',
                    icon: Icons.warning_amber_rounded,
                    accentColor: AppTheme.warningOrange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LowStockScreen(initialTab: 0),
                        ),
                      );
                    },
                  ),
                  StatCard(
                    title: 'Out of Stock',
                    value: '$outOfStock',
                    subtitle: outOfStock > 0 ? 'Urgent reorder needed' : 'All items in stock',
                    icon: Icons.cancel_outlined,
                    accentColor: AppTheme.dangerRed,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LowStockScreen(initialTab: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Low-Stock alert bar (if any critical items)
              if (lowStock > 0 || outOfStock > 0)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LowStockScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.warningBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.warningOrange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.warningOrange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_active, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${lowStock + outOfStock} Items Require Attention',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFFE65100),
                                ),
                              ),
                              Text(
                                '$outOfStock out of stock, $lowStock running low',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.brown.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppTheme.warningOrange,
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Quick Categories Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                      );
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Horizontal Category Cards
              SizedBox(
                height: 102,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: inventory.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (ctx, index) {
                    final cat = inventory.categories[index];
                    final count = inventory.getProductCountByCategory(cat.id);

                    return InkWell(
                      onTap: () {
                        inventory.setSelectedCategory(cat.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProductListScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 120,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: cat.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(cat.icon, size: 18, color: cat.color),
                            ),
                            const Spacer(),
                            Text(
                              cat.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '$count products',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Recent Inventory items Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Stock Inventory',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      inventory.clearFilters();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProductListScreen()),
                      );
                    },
                    child: const Text('See All Products'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Preview list of top items
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: inventory.products.length > 5 ? 5 : inventory.products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, index) {
                  final product = inventory.products[index];
                  return ProductCard(product: product);
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
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

  void _confirmResetData(BuildContext context, InventoryNotifier inventory) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset to Sample Data'),
        content: const Text(
          'This will restore the original sample grocery items and categories. Any products you added will be replaced with fresh sample data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warningOrange),
            onPressed: () async {
              final nav = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              await inventory.resetToSampleData();
              nav.pop();
              messenger.showSnackBar(
                const SnackBar(content: Text('Inventory reset to sample grocery data.')),
              );
            },
            child: const Text('Reset Data'),
          ),
        ],
      ),
    );
  }
}
