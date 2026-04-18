import 'package:flutter/material.dart';
import '../services/sales_service.dart';

class SalesHistoryPage extends StatefulWidget {
  const SalesHistoryPage({super.key});

  @override
  State<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends State<SalesHistoryPage> {
  List<Map> sales = [];

  @override
  void initState() {
    super.initState();
    loadSales();
  }

  void loadSales() {
    sales = SalesService.getAllSales().reversed.toList();
    setState(() {});
  }

  void showInvoice(Map sale) {
    final items = (sale["items"] as List?) ?? [];

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Invoice Details"),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Date: ${sale["time"]}"),
                const SizedBox(height: 10),

                const Divider(),

                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return ListTile(
                        leading: const Icon(Icons.qr_code),
                        title: Text(item["name"] ?? ""),
                        subtitle: Text(item["barcode"] ?? ""),
                        trailing: Text("৳${item["sellPrice"]}"),
                      );
                    },
                  ),
                ),

                const Divider(),

                Text(
                  "Total: ৳${sale["total"]}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Future<void> clearAllSales() async {
    await SalesService.clearSales();
    loadSales();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("বিক্রিত মালামাল"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: clearAllSales,
          )
        ],
      ),

      body: sales.isEmpty
          ? const Center(child: Text("No Sales Yet"))
          : ListView.builder(
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final sale = sales[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long),

                    title: Text("Total: ৳${sale["total"]}"),
                    subtitle: Text("Time: ${sale["time"]}"),

                    // 👇 CLICK TO VIEW INVOICE
                    onTap: () => showInvoice(sale),
                  ),
                );
              },
            ),
    );
  }
}