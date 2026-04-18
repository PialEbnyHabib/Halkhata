import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/product_service.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final category = TextEditingController();
  final name = TextEditingController();
  final buy = TextEditingController();
  final sell = TextEditingController();
  final qty = TextEditingController();

  List<String> scanned = [];
  bool scanning = false;

  void startScan() {
    final total = int.tryParse(qty.text) ?? 0;

    if (total <= 0) return;

    scanned.clear();

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: 500,
              child: Column(
                children: [

                  const SizedBox(height: 10),

                  // 📊 COUNTER UI
                  Text(
                    "Scanned: ${scanned.length} / $total\nRemaining: ${total - scanned.length}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: MobileScanner(
                      onDetect: (capture) async {
                        if (scanning) return;
                        scanning = true;

                        final code = capture.barcodes.first.rawValue;

                        if (code == null) {
                          scanning = false;
                          return;
                        }

                        // ❌ prevent duplicate scan
                        if (scanned.contains(code)) {
                          scanning = false;
                          return;
                        }

                        scanned.add(code);

                        setModalState(() {});

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Added: $code"),
                            duration: const Duration(milliseconds: 600),
                          ),
                        );

                        await Future.delayed(
                          const Duration(milliseconds: 500),
                        );

                        scanning = false;

                        // ✅ FINISH CONDITION
                        if (scanned.length >= total) {
  await ProductService.saveProductGroup(
    category: category.text,
    name: name.text,
    buyPrice: double.parse(buy.text),
    sellPrice: double.parse(sell.text),
    barcodes: scanned,
  );

  // 1️⃣ close scanner bottom sheet FIRST
  Navigator.pop(context);

  // 2️⃣ go back to home safely (delay avoids black screen)
  Future.delayed(const Duration(milliseconds: 200), () {
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("পন্য যোগ সম্পন্ন হয়েছে"),
      ),
    );
  });
}
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("পন্য যোগ করুন")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: category,
              decoration: const InputDecoration(labelText: "Category"),
            ),

            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "Name"),
            ),

            TextField(
              controller: buy,
              decoration: const InputDecoration(labelText: "Buy Price"),
            ),

            TextField(
              controller: sell,
              decoration: const InputDecoration(labelText: "Sell Price"),
            ),

            TextField(
              controller: qty,
              decoration: const InputDecoration(labelText: "Stock Quantity"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: startScan,
              child: const Text("Start Scanning"),
            ),
          ],
        ),
      ),
    );
  }
}