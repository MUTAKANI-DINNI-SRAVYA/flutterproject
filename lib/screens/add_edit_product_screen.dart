import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../state/inventory_state.dart';
import '../theme/app_theme.dart';

class AddEditProductScreen extends StatefulWidget {
  final GroceryProduct? productToEdit;

  const AddEditProductScreen({super.key, this.productToEdit});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _costPriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _stockController;
  late TextEditingController _thresholdController;
  late TextEditingController _supplierController;
  late TextEditingController _notesController;

  String? _selectedCategoryId;
  String _selectedUnit = 'pcs';
  DateTime? _selectedExpiryDate;

  final List<String> _unitOptions = [
    'pcs',
    'kg',
    'g',
    'pack',
    'bottle',
    'litre',
    'box',
    'can',
    'dozen',
  ];

  bool get isEditing => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;

    _nameController = TextEditingController(text: p?.name ?? '');
    _skuController = TextEditingController(text: p?.sku ?? '');
    _costPriceController = TextEditingController(text: p != null ? p.costPrice.toStringAsFixed(2) : '');
    _sellingPriceController = TextEditingController(text: p != null ? p.sellingPrice.toStringAsFixed(2) : '');
    _stockController = TextEditingController(text: p != null ? p.stockQuantity.toString() : '10');
    _thresholdController = TextEditingController(text: p != null ? p.minStockThreshold.toString() : '5');
    _supplierController = TextEditingController(text: p?.supplier ?? '');
    _notesController = TextEditingController(text: p?.notes ?? '');

    _selectedCategoryId = p?.categoryId;
    _selectedUnit = p?.unit ?? 'pcs';
    _selectedExpiryDate = p?.expiryDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _thresholdController.dispose();
    _supplierController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _generateSku() {
    final name = _nameController.text.trim();
    final prefix = name.length >= 3
        ? name.substring(0, 3).toUpperCase()
        : 'GRC';
    final randomSuffix = (DateTime.now().millisecondsSinceEpoch % 1000).toString().padLeft(3, '0');
    setState(() {
      _skuController.text = 'GRC-$prefix-$randomSuffix';
    });
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? now.add(const Duration(days: 30)),
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedExpiryDate = picked;
      });
    }
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final inventory = InventoryScope.of(context);
    final categoryId = _selectedCategoryId ??
        (inventory.categories.isNotEmpty ? inventory.categories.first.id : 'packaged');

    final cost = double.tryParse(_costPriceController.text.trim()) ?? 0.0;
    final selling = double.tryParse(_sellingPriceController.text.trim()) ?? 0.0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;
    final threshold = int.tryParse(_thresholdController.text.trim()) ?? 5;

    final id = isEditing ? widget.productToEdit!.id : 'prod_${DateTime.now().millisecondsSinceEpoch}';

    final product = GroceryProduct(
      id: id,
      name: _nameController.text.trim(),
      sku: _skuController.text.trim().isEmpty ? 'SKU-$id' : _skuController.text.trim(),
      categoryId: categoryId,
      costPrice: cost,
      sellingPrice: selling,
      stockQuantity: stock,
      minStockThreshold: threshold,
      unit: _selectedUnit,
      expiryDate: _selectedExpiryDate,
      supplier: _supplierController.text.trim().isEmpty
          ? 'General Supplier'
          : _supplierController.text.trim(),
      notes: _notesController.text.trim(),
      lastUpdated: DateTime.now(),
    );

    if (isEditing) {
      inventory.updateProduct(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated "${product.name}" successfully')),
      );
    } else {
      inventory.addProduct(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added "${product.name}" to inventory')),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final inventory = InventoryScope.of(context);

    // Default category if none selected
    if (_selectedCategoryId == null && inventory.categories.isNotEmpty) {
      _selectedCategoryId = inventory.categories.first.id;
    }

    final costVal = double.tryParse(_costPriceController.text) ?? 0.0;
    final sellVal = double.tryParse(_sellingPriceController.text) ?? 0.0;
    final profit = sellVal - costVal;
    final margin = costVal > 0 ? (profit / costVal) * 100 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add New Product'),
        actions: [
          TextButton.icon(
            onPressed: _saveProduct,
            icon: const Icon(Icons.check, color: AppTheme.primaryGreen),
            label: const Text(
              'Save',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic details section
              _buildSectionHeader('Basic Information', Icons.info_outline),
              const SizedBox(height: 12),

              // Product Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name *',
                  hintText: 'e.g. Organic Honeycrisp Apples',
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter product name';
                  }
                  if (val.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),

              // SKU Field with Auto-Generate Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _skuController,
                      decoration: const InputDecoration(
                        labelText: 'SKU / Barcode Code *',
                        hintText: 'GRC-APL-001',
                        prefixIcon: Icon(Icons.qr_code_2_rounded),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'SKU is required';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: OutlinedButton.icon(
                      onPressed: _generateSku,
                      icon: const Icon(Icons.auto_awesome, size: 16),
                      label: const Text('Auto SKU'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Category and Unit Selection
              Row(
                children: [
                  // Category Dropdown
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: inventory.categories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat.id,
                          child: Row(
                            children: [
                              Icon(cat.icon, size: 16, color: cat.color),
                              const SizedBox(width: 8),
                              Text(cat.name, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategoryId = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Measurement Unit Dropdown
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit *',
                        prefixIcon: Icon(Icons.straighten_rounded),
                      ),
                      items: _unitOptions.map((unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedUnit = val;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Pricing & Profit Margin Section
              _buildSectionHeader('Pricing & Profit Margins', Icons.monetization_on_outlined),
              const SizedBox(height: 12),

              Row(
                children: [
                  // Cost Price
                  Expanded(
                    child: TextFormField(
                      controller: _costPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Cost Price (₹) *',
                        hintText: '0.00',
                        prefixIcon: Icon(Icons.receipt_long_outlined),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Enter cost price';
                        }
                        final num = double.tryParse(val.trim());
                        if (num == null || num < 0) {
                          return 'Invalid price';
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Selling Price
                  Expanded(
                    child: TextFormField(
                      controller: _sellingPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Selling Price (₹) *',
                        hintText: '0.00',
                        prefixIcon: Icon(Icons.sell_outlined),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Enter retail price';
                        }
                        final num = double.tryParse(val.trim());
                        if (num == null || num <= 0) {
                          return 'Must be > 0';
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),

              // Live Margin Indicator
              if (costVal > 0 && sellVal > 0)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: profit >= 0 ? AppTheme.surfaceGreen : AppTheme.dangerBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: profit >= 0
                          ? AppTheme.primaryLight.withOpacity(0.3)
                          : AppTheme.dangerRed.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        profit >= 0 ? 'Projected Profit Margin:' : 'Loss Warning:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: profit >= 0 ? AppTheme.primaryLight : AppTheme.dangerRed,
                        ),
                      ),
                      Text(
                        '+₹${profit.toStringAsFixed(2)} (${margin.toStringAsFixed(1)}%) per $_selectedUnit',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: profit >= 0 ? AppTheme.primaryLight : AppTheme.dangerRed,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Stock Management Section
              _buildSectionHeader('Stock & Alert Limits', Icons.inventory_2_outlined),
              const SizedBox(height: 12),

              Row(
                children: [
                  // Stock Quantity
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Current Stock *',
                        hintText: '0',
                        suffixText: _selectedUnit,
                        prefixIcon: const Icon(Icons.warehouse_outlined),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Enter stock';
                        }
                        final num = int.tryParse(val.trim());
                        if (num == null || num < 0) {
                          return 'Cannot be negative';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Low Stock Threshold
                  Expanded(
                    child: TextFormField(
                      controller: _thresholdController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Low Stock Alert At *',
                        hintText: '5',
                        suffixText: _selectedUnit,
                        prefixIcon: const Icon(Icons.notifications_active_outlined),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Enter threshold';
                        }
                        final num = int.tryParse(val.trim());
                        if (num == null || num < 1) {
                          return 'Must be >= 1';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Logistics & Metadata Section
              _buildSectionHeader('Logistics & Expiration', Icons.local_shipping_outlined),
              const SizedBox(height: 12),

              // Expiry Date Picker
              InkWell(
                onTap: _pickExpiryDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_outlined, color: AppTheme.textMuted),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Expiration Date (Optional)',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedExpiryDate != null
                                  ? DateFormat('EEEE, d MMMM yyyy').format(_selectedExpiryDate!)
                                  : 'Not set (tap to pick date)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: _selectedExpiryDate != null ? FontWeight.w600 : FontWeight.normal,
                                color: _selectedExpiryDate != null ? AppTheme.textDark : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedExpiryDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() {
                              _selectedExpiryDate = null;
                            });
                          },
                        )
                      else
                        const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.primaryLight),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Supplier
              TextFormField(
                controller: _supplierController,
                decoration: const InputDecoration(
                  labelText: 'Supplier / Distributor',
                  hintText: 'e.g. FreshValley Distributors',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),

              // Notes / Storage instructions
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Storage Guidelines & Notes',
                  hintText: 'e.g. Keep chilled at 4°C, inspect packaging on arrival.',
                  prefixIcon: Icon(Icons.notes_rounded),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 32),

              // Save Action Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _saveProduct,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(
                    isEditing ? 'Save Changes' : 'Add to Inventory',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryGreen),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryGreen,
          ),
        ),
      ],
    );
  }
}
