import 'package:flutter/material.dart';
import '../models/product.dart';
import '../state/inventory_state.dart';
import '../theme/app_theme.dart';

class QuickStockDialog extends StatefulWidget {
  final GroceryProduct product;

  const QuickStockDialog({super.key, required this.product});

  @override
  State<QuickStockDialog> createState() => _QuickStockDialogState();
}

class _QuickStockDialogState extends State<QuickStockDialog> {
  late int _quantity;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _quantity = widget.product.stockQuantity;
    _controller = TextEditingController(text: _quantity.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateQuantity(int newQty) {
    setState(() {
      _quantity = newQty < 0 ? 0 : newQty;
      _controller.text = _quantity.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.swap_vert_rounded, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Stock Update',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.product.name,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'Current Units: ${widget.product.stockQuantity} ${widget.product.unit}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        onPressed: _quantity > 0 ? () => _updateQuantity(_quantity - 1) : null,
                        icon: const Icon(Icons.remove),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 90,
                        child: TextField(
                          controller: _controller,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryGreen,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            isDense: true,
                            suffixText: widget.product.unit,
                            suffixStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          onChanged: (val) {
                            final parsed = int.tryParse(val);
                            if (parsed != null) {
                              setState(() {
                                _quantity = parsed < 0 ? 0 : parsed;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton.filledTonal(
                        onPressed: () => _updateQuantity(_quantity + 1),
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.surfaceGreen,
                          foregroundColor: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Quick Increment / Decrement',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildQuickChip('-10', -10),
                _buildQuickChip('-5', -5),
                _buildQuickChip('+5', 5),
                _buildQuickChip('+10', 10),
                _buildQuickChip('+25', 25),
              ],
            ),
            const SizedBox(height: 12),
            if (_quantity <= widget.product.minStockThreshold && _quantity > 0)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.warningBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.warningOrange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: AppTheme.warningOrange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This will trigger low stock alert (threshold: ${widget.product.minStockThreshold} ${widget.product.unit}).',
                        style: const TextStyle(fontSize: 12, color: AppTheme.warningOrange),
                      ),
                    ),
                  ],
                ),
              )
            else if (_quantity == 0)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.dangerBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.dangerRed.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 18, color: AppTheme.dangerRed),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Item will be marked as Out of Stock!',
                        style: TextStyle(fontSize: 12, color: AppTheme.dangerRed, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            InventoryScope.of(context).updateStock(widget.product.id, _quantity);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Updated "${widget.product.name}" stock to $_quantity ${widget.product.unit}',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: const Text('Save Stock'),
        ),
      ],
    );
  }

  Widget _buildQuickChip(String label, int delta) {
    return ActionChip(
      label: Text(label),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      onPressed: () {
        _updateQuantity(_quantity + delta);
      },
    );
  }
}
