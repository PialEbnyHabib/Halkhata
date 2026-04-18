import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/product_service.dart';

class SellProductPage extends StatefulWidget {
  const SellProductPage({super.key});

  @override
  State<SellProductPage> createState() => _SellProductPageState();
}

class _SellProductPageState extends State<SellProductPage> {
  List<Map> cart = [];
  bool scanning = false;

  double get total =>
      cart.fold(0, (sum, item) => sum + (item["sellPrice"] ?? 0));

  void scan() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (_) {
        return SizedBox(
          height: 400,
          child: MobileScanner(
            onDetect: (capture) async {
              if (scanning) return;
              scanning = true;

              final code = capture.barcodes.first.rawValue;

              if (code == null) {
                scanning = false;
                return;
              }

              final product =
                  ProductService.getProductByBarcode(code);

              // ❌ NOT FOUND
              if (product == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Product not found")),
                );

                scanning = false;
                return;
              }

              // ✅ ADD ONLY ONCE
              setState(() {
                cart.add(product);
              });

              await Future.delayed(const Duration(milliseconds: 800));
              scanning = false;
            },
          ),
        );
      },
    );
  }

  void checkout() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Total: ৳$total")),
    );
    setState(() => cart.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sell")),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, i) {
                final item = cart[i];

                return ListTile(
                  title: Text(item["name"]),
                  subtitle: Text(item["barcode"]),
                  trailing: Text("৳${item["sellPrice"]}"),
                );
              },
            ),
          ),

          Text("Total: ৳$total"),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: scan,
                child: const Text("Scan"),
              ),
              ElevatedButton(
                onPressed: checkout,
                child: const Text("Checkout"),
              ),
            ],
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}