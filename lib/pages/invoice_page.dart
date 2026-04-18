import 'package:flutter/material.dart';

class InvoicePage extends StatelessWidget {
  final List<Map> cart;
  final double total;

  const InvoicePage({
    super.key,
    required this.cart,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoice"),
        automaticallyImplyLeading: false,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            const Text(
              "হালখাতা POS",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text("Date: ${DateTime.now()}"),

            const Divider(),

            Expanded(
              child: cart.isEmpty
                  ? const Center(child: Text("No Items"))
                  : ListView.builder(
                      itemCount: cart.length,
                      itemBuilder: (context, index) {
                        final item = cart[index];

                        return ListTile(
                          title: Text(
                            item["name"]?.toString() ?? "Unknown",
                          ),
                          subtitle: Text(
                            item["barcode"]?.toString() ?? "-",
                          ),
                          trailing: Text(
                            "৳${item["sellPrice"]?.toString() ?? "0"}",
                          ),
                        );
                      },
                    ),
            ),

            const Divider(),

            Text(
              "Total: ৳${total.toString()}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Print coming soon"),
                      ),
                    );
                  },
                  child: const Text("Print"),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text("Home"),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}