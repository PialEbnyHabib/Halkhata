import 'package:hive/hive.dart';

class DashboardService {
  static final Box salesBox = Hive.box('sales');
  static final Box productBox = Hive.box('products');

  // 📊 TODAY SALES
  static double getTodaySales() {
    double total = 0;

    DateTime now = DateTime.now();

    for (var sale in salesBox.values) {
      DateTime time = DateTime.parse(sale["time"]);

      if (time.year == now.year &&
          time.month == now.month &&
          time.day == now.day) {
        total += (sale["total"] ?? 0);
      }
    }

    return total;
  }

  // 💰 TODAY PROFIT
  static double getTodayProfit() {
    double profit = 0;

    DateTime now = DateTime.now();

    for (var sale in salesBox.values) {
      DateTime time = DateTime.parse(sale["time"]);

      if (time.year == now.year &&
          time.month == now.month &&
          time.day == now.day) {
        profit += (sale["profit"] ?? 0);
      }
    }

    return profit;
  }

  // 🛒 TOTAL SOLD ITEMS TODAY
  static int getTodaySoldItems() {
    int count = 0;

    DateTime now = DateTime.now();

    for (var sale in salesBox.values) {
      DateTime time = DateTime.parse(sale["time"]);

      if (time.year == now.year &&
          time.month == now.month &&
          time.day == now.day) {
        List items = sale["items"] ?? [];
        count += items.length;
      }
    }

    return count;
  }

  // ⚠ LOW STOCK COUNT
  static int getLowStockCount({int limit = 3}) {
    int count = 0;

    for (var p in productBox.values) {
      List barcodes = p["barcodes"] ?? [];

      if (barcodes.length <= limit) {
        count++;
      }
    }

    return count;
  }

  // 📉 YESTERDAY SALES (FOR GROWTH)
  static double getYesterdaySales() {
    double total = 0;

    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(const Duration(days: 1));

    for (var sale in salesBox.values) {
      DateTime time = DateTime.parse(sale["time"]);

      if (time.year == yesterday.year &&
          time.month == yesterday.month &&
          time.day == yesterday.day) {
        total += (sale["total"] ?? 0);
      }
    }

    return total;
  }

  // 🏆 TOP SELLING PRODUCTS
  static List<Map> getTopProducts() {
    Map<String, int> counter = {};

    for (var sale in salesBox.values) {
      List items = sale["items"] ?? [];

      for (var item in items) {
        String name = item["name"] ?? "Unknown";

        counter[name] = (counter[name] ?? 0) + 1;
      }
    }

    var sorted = counter.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(3).map((e) {
      return {
        "name": e.key,
        "count": e.value,
      };
    }).toList();
  }

  // ⚠ LOW STOCK PRODUCTS LIST
  static List<Map> getLowStockProducts(int limit) {
    List<Map> low = [];

    for (var p in productBox.values) {
      List barcodes = p["barcodes"] ?? [];

      if (barcodes.length <= limit) {
        low.add({
          "name": p["name"],
          "stock": barcodes.length,
        });
      }
    }

    return low;
  }
}