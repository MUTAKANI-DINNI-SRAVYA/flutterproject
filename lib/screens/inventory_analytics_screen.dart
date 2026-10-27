import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../state/inventory_state.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';

class InventoryAnalyticsScreen extends StatelessWidget {
  const InventoryAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = InventoryScope.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    final totalRetail = inventory.totalInventoryRetailValue;
    final totalCost = inventory.totalInventoryCostValue;
    final totalProfit = inventory.totalPotentialProfit;
    final grossMargin = totalCost > 0 ? (totalProfit / totalCost) * 100 : 0.0;

    final totalItems = inventory.totalProductsCount;
    final healthyCount = totalItems - inventory.lowStockCount - inventory.outOfStockCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top High-Level Valuation Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL INVENTORY RETAIL VALUE',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currencyFormat.format(totalRetail),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildValuationMetric(
                        'Total Cost',
                        currencyFormat.format(totalCost),
                        Colors.white,
                      ),
                      _buildValuationMetric(
                        'Projected Profit',
                        currencyFormat.format(totalProfit),
                        const Color(0xFF81C784),
                      ),
                      _buildValuationMetric(
                        'Margin %',
                        '${grossMargin.toStringAsFixed(1)}%',
                        Colors.amber.shade200,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Stock Health Status Section
            const Text(
              'Stock Health Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Multi-segmented bar
                  if (totalItems > 0)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 12,
                        child: Row(
                          children: [
                            if (healthyCount > 0)
                              Expanded(
                                flex: healthyCount,
                                child: Container(color: AppTheme.primaryLight),
                              ),
                            if (inventory.lowStockCount > 0)
                              Expanded(
                                flex: inventory.lowStockCount,
                                child: Container(color: AppTheme.warningOrange),
                              ),
                            if (inventory.outOfStockCount > 0)
                              Expanded(
                                flex: inventory.outOfStockCount,
                                child: Container(color: AppTheme.dangerRed),
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHealthLegend('Healthy', healthyCount, AppTheme.primaryLight, totalItems),
                      _buildHealthLegend('Low Stock', inventory.lowStockCount, AppTheme.warningOrange, totalItems),
                      _buildHealthLegend('Out of Stock', inventory.outOfStockCount, AppTheme.dangerRed, totalItems),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Key Counts Grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                StatCard(
                  title: 'Unique SKUs',
                  value: '$totalItems',
                  subtitle: 'Active product items',
                  icon: Icons.qr_code_rounded,
                  accentColor: AppTheme.primaryLight,
                ),
                StatCard(
                  title: 'Stock Units',
                  value: '${inventory.totalUnitsInStock}',
                  subtitle: 'Physical items stored',
                  icon: Icons.layers_rounded,
                  accentColor: const Color(0xFF00838F),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Category Valuation Table / Breakdown
            const Text(
              'Valuation by Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: inventory.categories.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, index) {
                  final cat = inventory.categories[index];
                  final catProducts = inventory.products.where((p) => p.categoryId == cat.id).toList();
                  final catUnits = catProducts.fold(0, (sum, p) => sum + p.stockQuantity);
                  final catValuation = catProducts.fold(0.0, (sum, p) => sum + p.totalInventoryRetailValue);
                  final percentOfTotal = totalRetail > 0 ? (catValuation / totalRetail) * 100 : 0.0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cat.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(cat.icon, size: 20, color: cat.color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                '${catProducts.length} items • $catUnits units',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currencyFormat.format(catValuation),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              '${percentOfTotal.toStringAsFixed(1)}% of total',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildValuationMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthLegend(String label, int count, Color color, int total) {
    final pct = total > 0 ? ((count / total) * 100).toStringAsFixed(0) : '0';
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$count ($pct%)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color),
        ),
      ],
    );
  }
}
