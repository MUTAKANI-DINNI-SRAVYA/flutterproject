import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../state/inventory_state.dart';
import '../theme/app_theme.dart';

class SdgImpactScreen extends StatelessWidget {
  const SdgImpactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = InventoryScope.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    // Calculate real-time SDG metrics from current inventory
    final productsWithExpiry = inventory.products.where((p) => p.expiryDate != null).toList();
    final expiringSoonProducts = inventory.products.where((p) => p.isExpiringSoon).toList();
    final expiredProducts = inventory.products.where((p) => p.isExpired).toList();

    // Value of monitored perishable inventory saved from waste
    final monitoredPerishableValue = productsWithExpiry.fold<double>(
      0.0,
      (sum, p) => sum + p.totalInventoryRetailValue,
    );

    // Food waste prevention efficiency score
    final totalCount = inventory.totalProductsCount;
    final healthyCount = inventory.products.where((p) => p.isHealthyStock).length;
    final efficiencyRate = totalCount > 0 ? ((healthyCount / totalCount) * 100).round() : 100;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SDG & Social Impact',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Text(
              'UN Sustainable Development Goals Alignment',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero SDG Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00796B), Color(0xFF004D40)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF004D40).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.public_rounded, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UN Global Goals for 2030',
                          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Sustainable Grocery Logistics',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'StockBasket empowers retailers to prevent food waste, support food security, and drive inclusive local commerce.',
                          style: TextStyle(color: Colors.white, fontSize: 11.5, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Live Impact Metrics Header
            const Text(
              'Live Social Impact Metrics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 10),

            // 4 Impact Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Food Waste Shield',
                    value: currencyFormat.format(monitoredPerishableValue),
                    subtitle: '${productsWithExpiry.length} perishable items actively tracked',
                    icon: Icons.shield_rounded,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Stock Health Score',
                    value: '$efficiencyRate%',
                    subtitle: 'Optimum inventory without over-purchasing',
                    icon: Icons.eco_rounded,
                    color: const Color(0xFF0288D1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Near-Expiry Alerts',
                    value: '${expiringSoonProducts.length}',
                    subtitle: expiringSoonProducts.isEmpty
                        ? 'Zero imminent spoilage'
                        : 'Candidate items for discount sale / food bank donation',
                    icon: Icons.alarm_on_rounded,
                    color: AppTheme.warningOrange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Zero-Spoilage Loss',
                    value: '${expiredProducts.length}',
                    subtitle: expiredProducts.isEmpty ? '100% fresh inventory maintained' : 'Critical discard items',
                    icon: Icons.delete_sweep_rounded,
                    color: expiredProducts.isEmpty ? AppTheme.primaryGreen : AppTheme.dangerRed,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // UN SDG Pillar Cards
            const Text(
              'Primary UN SDG Alignments',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 12),

            _buildSdgCard(
              sdgNumber: '12',
              title: 'Responsible Consumption & Production',
              target: 'Target 12.3: Halve per capita food waste at retail & reduce supply chain losses.',
              description:
                  'Every year, over 1.3 billion tons of food is wasted globally. StockBasket utilizes real-time reorder thresholds and shelf-life tracking so grocery stores never over-order perishable goods and sell food before it spoils.',
              badgeColor: const Color(0xFFBF8B2E),
              icon: Icons.recycling_rounded,
            ),

            const SizedBox(height: 12),

            _buildSdgCard(
              sdgNumber: '2',
              title: 'Zero Hunger & Food Security',
              target: 'Target 2.1: End hunger and ensure access to safe, nutritious food all year.',
              description:
                  'By identifying products approaching expiration up to 14 days in advance, shop owners can route approaching-expiry stock to community kitchens, food drives, or offer deep discounts to lower-income families instead of discarding edible nutrition.',
              badgeColor: const Color(0xFFDDA63A),
              icon: Icons.volunteer_activism_rounded,
            ),

            const SizedBox(height: 12),

            _buildSdgCard(
              sdgNumber: '8',
              title: 'Decent Work & Economic Growth',
              target: 'Target 8.3: Promote entrepreneurship and growth of micro, small & medium enterprises (MSMEs).',
              description:
                  'Small family-run kirana shops, bodegas, and local supermarkets often lose 15-25% of their working capital to inventory mismanagement. StockBasket provides enterprise-grade analytics, margin calculations, and inventory tools entirely free.',
              badgeColor: const Color(0xFFA21942),
              icon: Icons.trending_up_rounded,
            ),

            const SizedBox(height: 24),

            // Sustainable Retail Best Practices
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
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_rounded, color: Color(0xFFF57F17), size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Green Retail Recommendations',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTipRow(Icons.check_circle_outline_rounded, 'Apply FIFO (First In, First Out) restocking using the Expiry Date tracker.'),
                  _buildTipRow(Icons.check_circle_outline_rounded, 'Review the Low Stock screen weekly to prevent bulk over-ordering of slow-moving items.'),
                  _buildTipRow(Icons.check_circle_outline_rounded, 'Partner with local charity food banks to donate near-expiry grocery items.'),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted, height: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildSdgCard({
    required String sdgNumber,
    required String title,
    required String target,
    required String description,
    required Color badgeColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  sdgNumber,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UN SDG $sdgNumber',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor),
                    ),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                  ],
                ),
              ),
              Icon(icon, color: badgeColor, size: 24),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              target,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: badgeColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: AppTheme.textDark, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildTipRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12.5, color: AppTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
