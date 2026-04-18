import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../services/product_service.dart';
import '../services/sales_service.dart';
import 'invoice_page.dart';

class SellProductPage extends StatefulWidget {
  const SellProductPage({super.key});

  @override
  State<SellProductPage> createState() => _SellProductPageState();
}

class _SellProductPageState extends State<SellProductPage> {
  List<Map> cart = [];

  final MobileScannerController controller =
      MobileScannerController(formats: [BarcodeFormat.ean13]);

  double get total =>
      cart.fold(0, (sum, item) => sum + (item["sellPrice"] ?? 0));

  // ✅ CHECK DUPLICATE
  bool isInCart(String barcode) {
    return cart.any((item) => item["barcode"] == barcode);
  }

  // 📦 SCAN PRODUCT (ONE AT A TIME)
  void scanProduct() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) {
        bool scanned = false;

        return SizedBox(
          height: 400,
          child: MobileScanner(
            controller: controller,

            onDetect: (capture) async {
              if (scanned) return;
              scanned = true;

              final code = capture.barcodes.first.rawValue;

              Navigator.pop(context); // close scanner immediately

              if (code == null) return;

              final product =
                  ProductService.getProductByBarcode(code);

              if (product == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Product not found")),
                );
                return;
              }

              // ❌ duplicate check
              if (isInCart(code)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("আপনি এই পন্য কার্টে যোগ করেছেন"),
                  ),
                );
                return;
              }

              setState(() {
                cart.add(product);
              });
            },
          ),
        );
      },
    );
  }

  // ❌ REMOVE ITEM FROM CART
  void removeItem(int index) {
    setState(() {
      cart.removeAt(index);
    });
  }

  // 💳 CHECKOUT → INVOICE PAGE
  void checkout() async {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cart is empty")),
      );
      return;
    }

    double finalTotal = total;

    // 🔥 reduce stock ONLY on checkout
    for (var item in cart) {
      await ProductService.reduceStock(item["barcode"]);
    }

    // 💾 save sale
    await SalesService.saveSale(
      cart: cart,
      total: finalTotal,
    );

    // 🧾 go to invoice page
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvoicePage(
          cart: List.from(cart),
          total: finalTotal,
        ),
      ),
    );

    // 🧹 clear cart AFTER returning
    setState(() {
      cart.clear();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("বিক্রি করুন")),

      body: Column(
        children: [
          // 🛒 CART LIST
          Expanded(
            child: cart.isEmpty
                ? const Center(child: Text("Cart is empty"))
                : ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, i) {
                      final item = cart[i];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          title: Text(item["name"]),
                          subtitle: Text(item["barcode"]),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("৳${item["sellPrice"]}"),

                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => removeItem(i),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 5),

          // 💰 TOTAL
          Text(
            "Total: ৳$total",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          // 🎯 ACTION BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: scanProduct,
                child: const Text("SCAN"),
              ),
              ElevatedButton(
                onPressed: checkout,
                child: const Text("CHECKOUT"),
              ),
            ],
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}