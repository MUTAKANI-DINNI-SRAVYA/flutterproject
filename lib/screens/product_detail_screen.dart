import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../state/inventory_state.dart';
import '../theme/app_theme.dart';
import '../widgets/stock_badge.dart';
import '../widgets/quick_stock_dialog.dart';
import 'add_edit_product_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final inventory = InventoryScope.of(context);

    // Look up live product
    final matching = inventory.products.where((p) => p.id == productId).toList();

    if (matching.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 50, color: AppTheme.dangerRed),
              const SizedBox(height: 12),
              const Text('Product not found or has been deleted.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Inventory'),
              ),
            ],
          ),
        ),
      );
    }

    final product = matching.first;

    final category = inventory.getCategoryById(product.categoryId) ??
        const GroceryCategory(
          id: 'other',
          name: 'General',
          icon: Icons.inventory_2_outlined,
          color: AppTheme.primaryLight,
        );

    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('EEEE, d MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            tooltip: 'Edit Product',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditProductScreen(productToEdit: product),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Delete Product',
            icon: const Icon(Icons.delete_outline, color: AppTheme.dangerRed),
            onPressed: () => _showDeleteConfirm(context, product),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(category.icon, size: 28, color: category.color),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    product.sku,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: category.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Retail Price',
                            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                currencyFormat.format(product.sellingPrice),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                              Text(
                                ' / ${product.unit}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      StockBadge(product: product),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Stock Management & Quick Action Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Stock Level & Replenishment',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => QuickStockDialog(product: product),
                          );
                        },
                        icon: const Icon(Icons.edit_note, size: 18),
                        label: const Text('Set Stock'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Inventory: ${product.stockQuantity} ${product.unit}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Alert Threshold: ${product.minStockThreshold} ${product.unit}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Visual stock progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: product.minStockThreshold > 0
                          ? (product.stockQuantity / (product.minStockThreshold * 2.5)).clamp(0.0, 1.0)
                          : 1.0,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        product.isOutOfStock
                            ? AppTheme.dangerRed
                            : product.isLowStock
                                ? AppTheme.warningOrange
                                : AppTheme.primaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: product.stockQuantity > 0
                              ? () => inventory.adjustStock(product.id, -1)
                              : null,
                          icon: const Icon(Icons.remove, size: 16),
                          label: Text('-1 ${product.unit}'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => inventory.adjustStock(product.id, 1),
                          icon: const Icon(Icons.add, size: 16),
                          label: Text('+1 ${product.unit}'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Financial & Margin Analysis Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Financial & Valuation Breakdown',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  _buildFinancialRow('Cost Price (per ${product.unit})', currencyFormat.format(product.costPrice)),
                  const SizedBox(height: 8),
                  _buildFinancialRow('Retail Price (per ${product.unit})', currencyFormat.format(product.sellingPrice)),
                  const SizedBox(height: 8),
                  _buildFinancialRow(
                    'Gross Profit Margin',
                    '${currencyFormat.format(product.profitPerUnit)} (${product.profitMarginPercent.toStringAsFixed(1)}%)',
                    highlightColor: AppTheme.primaryLight,
                  ),
                  const Divider(height: 20),
                  _buildFinancialRow(
                    'Total Batch Retail Value',
                    currencyFormat.format(product.totalInventoryRetailValue),
                    isBold: true,
                  ),
                  const SizedBox(height: 8),
                  _buildFinancialRow(
                    'Total Batch Investment Cost',
                    currencyFormat.format(product.totalInventoryCostValue),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Logistics & Shelf Life Details
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Logistics & Shelf Life',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow(
                    'Supplier',
                    product.supplier,
                    Icons.business_outlined,
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    'Expiration Date',
                    product.expiryDate != null ? dateFormat.format(product.expiryDate!) : 'Not Specified',
                    Icons.event_outlined,
                    warning: product.isExpired
                        ? 'EXPIRED'
                        : product.isExpiringSoon
                            ? 'Expiring soon!'
                            : null,
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    'Last Updated',
                    DateFormat('d MMM yyyy, h:mm a').format(product.lastUpdated),
                    Icons.history_rounded,
                  ),
                  if (product.notes.isNotEmpty) ...[
                    const Divider(height: 20),
                    const Text(
                      'Storage Instructions & Notes',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.notes,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow(String label, String value, {bool isBold = false, Color? highlightColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isBold ? AppTheme.textDark : Colors.grey.shade600,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            color: highlightColor ?? (isBold ? AppTheme.textDark : Colors.grey.shade800),
            fontWeight: isBold || highlightColor != null ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {String? warning}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 1),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                  if (warning != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.warningBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        warning,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.warningOrange,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirm(BuildContext context, GroceryProduct product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to permanently remove "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            onPressed: () {
              InventoryScope.of(context).deleteProduct(product.id);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close detail screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted "${product.name}"'),
                  backgroundColor: AppTheme.dangerRed,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
