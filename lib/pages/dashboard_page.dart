import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double todaySales = 0;
  double todayProfit = 0;
  int soldItems = 0;
  int lowStock = 0;

  double yesterdaySales = 0;

  List<Map> topProducts = [];
  List<Map> lowStockProducts = [];

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  void loadDashboard() {
    todaySales = DashboardService.getTodaySales();
    todayProfit = DashboardService.getTodayProfit();
    soldItems = DashboardService.getTodaySoldItems();
    lowStock = DashboardService.getLowStockCount();

    yesterdaySales = DashboardService.getYesterdaySales();

    topProducts = DashboardService.getTopProducts();
    lowStockProducts = DashboardService.getLowStockProducts(5);

    setState(() {});
  }

  Widget dashboardCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.42,
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.blue),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget sectionBox({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double growth = todaySales - yesterdaySales;

    return Scaffold(
      appBar: AppBar(
        title: const Text("ড্যাশবোর্ড"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔥 MAIN STATS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                dashboardCard(
                  title: "আজকের বিক্রি",
                  value: "৳${todaySales.toStringAsFixed(0)}",
                  icon: Icons.attach_money,
                ),
                dashboardCard(
                  title: "আজকের লাভ",
                  value: "৳${todayProfit.toStringAsFixed(0)}",
                  icon: Icons.trending_up,
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                dashboardCard(
                  title: "বিক্রিত পণ্য",
                  value: "$soldItems",
                  icon: Icons.shopping_cart,
                ),
                dashboardCard(
                  title: "লো স্টক",
                  value: "$lowStock",
                  icon: Icons.warning,
                ),
              ],
            ),

            // 📈 GROWTH PANEL
            sectionBox(
              title: "Sales Growth",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Yesterday: ৳${yesterdaySales.toStringAsFixed(0)}"),
                  Text(
                    "Growth: ৳${growth.toStringAsFixed(0)}",
                    style: TextStyle(
                      color: growth >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 🏆 TOP PRODUCTS
            sectionBox(
              title: "Top Selling Products",
              child: Column(
                children: topProducts.isEmpty
                    ? [const Text("No sales yet")]
                    : topProducts.map((p) {
                        return ListTile(
                          leading: const Icon(Icons.star),
                          title: Text(p["name"]),
                          trailing: Text("${p["count"]} sold"),
                        );
                      }).toList(),
              ),
            ),

            // ⚠ LOW STOCK DETAILS
            sectionBox(
              title: "Low Stock Products",
              child: Column(
                children: lowStockProducts.isEmpty
                    ? [const Text("All stock OK")]
                    : lowStockProducts.map((p) {
                        return ListTile(
                          leading: const Icon(
                            Icons.warning,
                            color: Colors.red,
                          ),
                          title: Text(p["name"]),
                          trailing: Text("Stock: ${p["stock"]}"),
                        );
                      }).toList(),
              ),
            ),

            // 📝 SUMMARY
            sectionBox(
              title: "ব্যবসার সারাংশ",
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(("• আজকের বিক্রি ও লাভ উপরে দেখানো হয়েছে।"),),
                  SizedBox(height: 5),
                  Text(("• লো স্টক পণ্য দ্রুত রিস্টক করুন।"),),
                  SizedBox(height: 5),
                  Text( ("• আগামী আপডেটে গ্রাফ ও টপ সেলিং পণ্য যোগ হবে।"),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}