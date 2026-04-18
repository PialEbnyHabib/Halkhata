import 'package:flutter/material.dart';
import '../services/product_service.dart';

class StocksPage extends StatefulWidget {
  const StocksPage({super.key});

  @override
  State<StocksPage> createState() => _StocksPageState();
}

class _StocksPageState extends State<StocksPage> {
  List<Map> products = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    products = ProductService.getAllProducts();
    setState(() {});
  }

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

  Future<void> deleteProduct(String category, String name) async {
    await ProductService.deleteProductGroup(
      category: category,
      name: name,
    );

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("স্টক")),

      body: products.isEmpty
          ? const Center(child: Text("No Products"))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];

                final category = p["category"].toString();
                final name = p["name"].toString();
                final barcodes = (p["barcodes"] as List?) ?? [];

                return Card(
                  child: ListTile(
                    title: Text("$category → $name"),
                    subtitle: Text("Stock: ${barcodes.length}"),

                    // 👇 CLICK TO SEE ALL BARCODES
                    onTap: () => showBarcodes(barcodes, name),

                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await deleteProduct(category, name);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}