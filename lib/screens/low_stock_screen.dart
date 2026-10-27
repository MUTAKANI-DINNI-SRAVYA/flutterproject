import 'package:flutter/material.dart';
import '../state/inventory_state.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../widgets/empty_state_widget.dart';

class LowStockScreen extends StatefulWidget {
  final int initialTab;

  const LowStockScreen({super.key, this.initialTab = 0});

  @override
  State<LowStockScreen> createState() => _LowStockScreenState();
}

class _LowStockScreenState extends State<LowStockScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventory = InventoryScope.of(context);
    final allAlerts = inventory.alertProducts;
    final outOfStock = inventory.outOfStockProducts;
    final lowStock = inventory.lowStockProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Low-Stock & Reorder Alerts'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.primaryGreen,
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'All (${allAlerts.length})'),
            Tab(text: 'Out of Stock (${outOfStock.length})'),
            Tab(text: 'Low Stock (${lowStock.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: All Alerts
          allAlerts.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Inventory Levels Healthy',
                  message: 'None of your grocery products are currently below their minimum safety thresholds.',
                )
              : _buildAlertList(allAlerts),

          // Tab 2: Out of Stock
          outOfStock.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.verified_rounded,
                  title: 'Zero Stockouts!',
                  message: 'All your tracked grocery products currently have available stock units.',
                )
              : _buildAlertList(outOfStock),

          // Tab 3: Low Stock
          lowStock.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.inventory_rounded,
                  title: 'No Low-Stock Warnings',
                  message: 'All in-stock products are above their respective minimum reorder thresholds.',
                )
              : _buildAlertList(lowStock),
        ],
      ),
    );
  }

  Widget _buildAlertList(List<dynamic> items) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, index) {
        return ProductCard(product: items[index]);
      },
    );
  }
}
