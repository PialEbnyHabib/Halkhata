import 'package:flutter/material.dart';
import '../services/product_service.dart';

class StocksPage extends StatefulWidget {
  const StocksPage({super.key});

  @override
  State<StocksPage> createState() => _StocksPageState();
}

class _StocksPageState extends State<StocksPage> {
  List<Map> products = [];

  int lowStockLimit = 3;

  String? selectedCategory;
  Map? selectedProduct;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    products = ProductService.getAllProducts();
    setState(() {});
  }

  Future<void> deleteProduct(String category, String name) async {
    await ProductService.deleteProductGroup(
      category: category,
      name: name,
    );

    loadData();
  }

  // ================= GROUP BY CATEGORY =================
  Map<String, List<Map>> get groupedByCategory {
    Map<String, List<Map>> map = {};

    for (var p in products) {
      String category = p["category"];

      map.putIfAbsent(category, () => []);
      map[category]!.add(p);
    }

    return map;
  }

  // ================= BARCODE VIEW =================
  void showBarcodes(List barcodes, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Barcodes - $name"),
        content: SizedBox(
          width: double.maxFinite,
          child: barcodes.isEmpty
              ? const Text("No stock available")
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: barcodes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.qr_code),
                      title: Text(barcodes[index].toString()),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedCategory == null
              ? "Stock Categories"
              : selectedProduct == null
                  ? "Products"
                  : "Barcodes",
        ),

        leading: selectedCategory != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    if (selectedProduct != null) {
                      selectedProduct = null;
                    } else {
                      selectedCategory = null;
                    }
                  });
                },
              )
            : null,
      ),

      body: products.isEmpty
          ? const Center(child: Text("No Products"))
          : selectedCategory == null
              ? _buildCategoryView()
              : selectedProduct == null
                  ? _buildProductView()
                  : _buildBarcodeView(),
    );
  }

  // ================= 1. CATEGORY VIEW =================
  Widget _buildCategoryView() {
    final categories = groupedByCategory.keys.toList();

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: ListTile(
            leading: const Icon(Icons.category),
            title: Text(cat),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              setState(() {
                selectedCategory = cat;
              });
            },
          ),
        );
      },
    );
  }

  // ================= 2. PRODUCT VIEW (WITH DELETE) =================
  Widget _buildProductView() {
    final productsInCategory =
        groupedByCategory[selectedCategory] ?? [];

    return ListView.builder(
      itemCount: productsInCategory.length,
      itemBuilder: (context, index) {
        final p = productsInCategory[index];

        final name = p["name"];
        final category = p["category"];
        final barcodes = p["barcodes"] as List;

        bool isLow = barcodes.length < lowStockLimit;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          color: isLow ? Colors.red.shade50 : null,

          child: ListTile(
            title: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isLow ? Colors.red : Colors.black,
              ),
            ),

            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Stock: ${barcodes.length}"),

                if (isLow)
                  const Text(
                    "⚠️ Low Stock",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),

            // CLICK PRODUCT → BARCODE VIEW
            onTap: () {
              setState(() {
                selectedProduct = p;
              });
            },

            // DELETE BUTTON + NAV ICON
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await deleteProduct(category, name);

                    setState(() {
                      selectedProduct = null;
                    });
                  },
                ),

                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= 3. BARCODE VIEW =================
  Widget _buildBarcodeView() {
    final barcodes = selectedProduct!["barcodes"] as List;

    return ListView.builder(
      itemCount: barcodes.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.qr_code),
          title: Text(barcodes[index].toString()),
        );
      },
    );
  }
}