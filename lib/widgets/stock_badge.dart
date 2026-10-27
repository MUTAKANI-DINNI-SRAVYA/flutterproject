import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

class StockBadge extends StatelessWidget {
  final GroceryProduct product;
  final bool compact;

  const StockBadge({
    super.key,
    required this.product,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color borderColor;
    String label;
    IconData icon;

    if (product.isOutOfStock) {
      bgColor = AppTheme.dangerBg;
      textColor = AppTheme.dangerRed;
      borderColor = AppTheme.dangerRed.withOpacity(0.3);
      label = compact ? '0 ${product.unit}' : 'Out of Stock (0 ${product.unit})';
      icon = Icons.cancel_outlined;
    } else if (product.isLowStock) {
      bgColor = AppTheme.warningBg;
      textColor = AppTheme.warningOrange;
      borderColor = AppTheme.warningOrange.withOpacity(0.3);
      label = compact
          ? '${product.stockQuantity} ${product.unit}'
          : 'Low Stock (${product.stockQuantity} ${product.unit})';
      icon = Icons.warning_amber_rounded;
    } else {
      bgColor = AppTheme.surfaceGreen;
      textColor = AppTheme.primaryLight;
      borderColor = AppTheme.primaryLight.withOpacity(0.25);
      label = compact
          ? '${product.stockQuantity} ${product.unit}'
          : '${product.stockQuantity} ${product.unit} in stock';
      icon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 13 : 15, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
