# 🛒 Grocery Inventory System (Flutter Mini Project)

A clean, modern, and production-ready **Grocery Inventory Management System** built with **Flutter** and **Dart**. Designed specifically for retail shop owners, supermarket store managers, and college mini-project evaluation.

---

## 🌟 Key Features

### 1. 📊 Interactive Dashboard & KPI Metrics
- **Real-time Metrics**: Total items in stock, total units count, total retail valuation, projected gross profit, and critical stockout alerts.
- **Visual Alert Banner**: Instant notice when products fall below their designated safety reorder thresholds.
- **Category Carousel**: Quick snapshot of categories with active product counts.
- **Recent Inventory Preview**: Quick-access cards with one-tap stock adjustments.

### 2. 🔍 Advanced Product Directory & Search
- **Live Search**: Instant filtering by product name, SKU / barcode, or supplier name.
- **Category Filter Chips**: Filter by individual grocery departments (Fruits & Veggies, Dairy & Eggs, Bakery, Beverages, Grains, Snacks, etc.).
- **Multi-Criterion Sorting**:
  - Name (A - Z)
  - Price: Low to High & High to Low
  - Stock Level: Low to High & High to Low
- **Zero-State Handling**: Contextual empty states with clear calls-to-action.

### 3. 📦 Stock Management & Quick Actions
- **In-Line Adjustments**: Increment (`+1`) and decrement (`-1`) units directly on the card without opening edit forms.
- **Quick Stock Dialog**: Modal for bulk adjustments (`+5`, `+10`, `+25`, `-5`, `-10`) or direct numerical entry.
- **Visual Stock Status Badges**:
  - 🟢 **In Stock** (Safe stock level)
  - 🟠 **Low Stock** (At or below minimum threshold)
  - 🔴 **Out of Stock** (Zero units remaining)

### 4. 📝 Add & Edit Product Suite
- **Complete Input Validation**: Ensures valid pricing, non-negative stock counts, and required fields.
- **Smart SKU Generator**: One-tap button that generates standardized retail SKUs (e.g. `GRC-APL-482`) based on the item name.
- **Real-Time Margin Calculator**: Computes projected profit in dollars and gross margin percentage as cost and retail prices are typed.
- **Logistics & Shelf-Life**: Expiry date picker with visual warnings for items expiring within 14 days or expired items.
- **Department & Unit Selector**: Supports `pcs`, `kg`, `g`, `pack`, `bottle`, `litre`, `box`, `can`, and `dozen`.

### 5. ⚠️ Dedicated Low-Stock & Reorder Screen
- Tabbed interface separating:
  - **All Alerts**
  - **Out of Stock (Critical - 0 units)**
  - **Low Stock (Below Threshold)**
- Direct replenishment shortcuts to reorder and update quantities immediately.

### 6. 🏷️ Category Management
- View inventory distribution and retail valuation grouped by category.
- **Custom Category Creator**: Add custom categories with custom icons and accent colors.

### 7. 📈 Inventory Analytics & Executive Summary
- Total inventory retail valuation vs. total investment cost.
- Projected gross profit and overall store profit margin.
- **Stock Health Breakdown**: Proportional visual bar comparing Healthy vs. Low vs. Out of Stock.
- Category share breakdown showing dollar value and percentage contribution.

### 8. 💾 Persistent Local Storage
- Implemented with `shared_preferences` using JSON serialization.
- **Fail-Safe In-Memory Fallback**: If running inside an iframe or browser sandbox with restricted localStorage, the app falls back seamlessly to memory storage without crashing.
- **Prepopulated Sample Data**: Comes with 12 diverse, realistic grocery items and 8 categories so the application is presentation-ready on first launch.
- **Reset Demo Data**: Easily restore original sample dataset anytime via the top-right menu.

---

## 📁 Project Architecture & Structure

```text
flutter/
├── pubspec.yaml                  # Project dependencies & Flutter metadata
├── analysis_options.yaml         # Linting and code analysis configuration
├── README.md                     # Project documentation & presentation guide
├── web/
│   ├── index.html                # HTML entry point for browser-based Flutter lab
│   └── manifest.json             # PWA web manifest
└── lib/
    ├── main.dart                 # Application entry point & theme initialization
    ├── models/
    │   ├── product.dart          # GroceryProduct data model & business logic
    │   └── category.dart         # GroceryCategory data model & default categories
    ├── services/
    │   └── storage_service.dart  # SharedPreferences persistence & sample dataset
    ├── state/
    │   └── inventory_state.dart  # InventoryNotifier & InventoryScope (State Management)
    ├── theme/
    │   └── app_theme.dart        # Fresh grocery-inspired Material 3 theme palette
    ├── screens/
    │   ├── home_dashboard_screen.dart    # Main dashboard with KPI cards
    │   ├── product_list_screen.dart      # Search, filter chips, and product cards
    │   ├── product_detail_screen.dart    # Detailed product specs & shelf-life
    │   ├── add_edit_product_screen.dart  # Form validation & auto-SKU generator
    │   ├── low_stock_screen.dart         # Reorder alerts & threshold monitoring
    │   ├── categories_screen.dart        # Category directory & custom category maker
    │   └── inventory_analytics_screen.dart # Financial valuations & stock health
    └── widgets/
        ├── product_card.dart             # Reusable card with quick counter actions
        ├── stat_card.dart                # Metric card with icons and trends
        ├── stock_badge.dart              # Status-coded badge (In Stock/Low/Out)
        ├── quick_stock_dialog.dart       # Modal for quick stock increments
        └── empty_state_widget.dart       # Zero-state illustration widget
```

---

## 🚀 How to Run the Application

### Option A: In a Browser-Based Flutter Lab (College Lab, FlutLab, Project IDX, Gitpod)
1. Compress or copy the project folder into your browser lab workspace.
2. Ensure the package dependencies in `pubspec.yaml` are fetched:
   ```bash
   flutter pub get
   ```
3. Run the project in the browser environment:
   ```bash
   flutter run -d chrome
   # or click "Run" / "Web Preview" in your online IDE
   ```

### Option B: On Any System with Flutter Installed
1. Open terminal inside the project directory:
   ```bash
   cd flutter
   flutter pub get
   flutter run
   ```
2. Select your preferred target: Chrome (Web), Android Emulator, Windows, or iOS Simulator.

---

## 🎓 College Viva & Examination Q&A

**Q1: What state management approach is used in this project?**
> **Answer**: The application utilizes Flutter's built-in `ChangeNotifier` (`InventoryNotifier`) combined with an `InheritedNotifier` (`InventoryScope`). This provides reactive, single-source-of-truth state updates without heavy external third-party dependencies, making it universally portable across all Flutter environments.

**Q2: How does data persistence work?**
> **Answer**: Products and categories are serialized to JSON strings and stored locally using `shared_preferences`. A resilience layer is implemented in `StorageService` where an in-memory buffer serves as a fallback in case browser sandbox storage is constrained.

**Q3: How are low stock alerts triggered?**
> **Answer**: Each product contains a customizable `minStockThreshold` property. If `stockQuantity <= minStockThreshold` and `> 0`, the item enters the **Low Stock** state. If `stockQuantity == 0`, it enters the **Out of Stock** state. The dashboard and dedicated alerts screen filter and aggregate these dynamically.

**Q4: How is profit margin calculated?**
> **Answer**: 
> $$\text{Profit Margin \%} = \frac{\text{Selling Price} - \text{Cost Price}}{\text{Cost Price}} \times 100$$
> This is dynamically calculated on the fly in `GroceryProduct.profitMarginPercent` and previewed live inside the Add/Edit Product form.

---

## 📄 License
Created for academic mini-project submission and demonstration purposes.
