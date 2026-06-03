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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(
              maxHeight: 600,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long),
                    const SizedBox(width: 10),
                    const Text(
                      "Invoice Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          sale["time"].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                Expanded(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 20),
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.shopping_bag),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["name"] ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  item["barcode"] ?? "",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Text(
                            "৳${item["sellPrice"]}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const Divider(thickness: 1.2),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "মোট বিল",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      "৳${sale["total"]}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("বন্ধ করুন"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> clearAllSales() async {
    await SalesService.clearSales();
    loadSales();
  }

  Map<String, List<Map>> groupSalesByDate() {
    Map<String, List<Map>> grouped = {};

    for (var sale in sales) {
      String fullTime = sale["time"].toString();

      String date = fullTime.split(",").first;

      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }

      grouped[date]!.add(sale);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedSales = groupSalesByDate();
    final dates = groupedSales.keys.toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "বিক্রির হিসাব",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: clearAllSales,
          )
        ],
      ),

      body: sales.isEmpty
          ? const Center(
              child: Text(
                "এখনও কোনো বিক্রি হয়নি",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final dailySales = groupedSales[date]!;

                double dailyTotal = 0;
                double dailyProfit = 0;

                for (var sale in dailySales) {
                  dailyTotal +=
                      (sale["total"] as num?)?.toDouble() ?? 0;

                  dailyProfit +=
                      (sale["profit"] as num?)?.toDouble() ?? 0;
                }

                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month),
                          const SizedBox(width: 8),

                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),

                      child: Column(
                        children: [

                         

                          const SizedBox(height: 15),

                          ListView.builder(
                            itemCount: dailySales.length,
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, saleIndex) {
                              final sale =
                                  dailySales[saleIndex];

                              return InkWell(
                                borderRadius:
                                    BorderRadius.circular(14),

                                onTap: () =>
                                    showInvoice(sale),

                                child: Container(
                                  margin:
                                      const EdgeInsets.only(
                                    bottom: 10,
                                  ),
                                  padding:
                                      const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.grey.shade50,
                                    borderRadius:
                                        BorderRadius.circular(
                                            14),
                                  ),

                                  child: Row(
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets
                                                .all(10),
                                        decoration:
                                            BoxDecoration(
                                          color: Colors
                                              .green.shade50,
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                                      12),
                                        ),
                                        child: const Icon(
                                          Icons.receipt,
                                          color: Colors.green,
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              "৳${sale["total"]}",
                                              style:
                                                  const TextStyle(
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                                fontSize: 16,
                                              ),
                                            ),

                                            const SizedBox(
                                                height: 4),

                                            Text(
                                              sale["time"]
                                                  .toString(),
                                              style: TextStyle(
                                                color: Colors
                                                    .grey
                                                    .shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .end,
                                        children: [
                                          const Text(
                                            "লাভ",
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),

                                          Text(
                                            "৳${sale["profit"] ?? 0}",
                                            style:
                                                const TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              color: Colors
                                                  .blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}