import 'package:hive/hive.dart';

class SalesService {
  static final Box box = Hive.box('sales');

  // 💾 SAVE SALE
  static Future<void> saveSale({
    required List<Map> cart,
    required double total,
  }) async {
    final sale = {
      "items": cart,
      "total": total,
      "time": DateTime.now().toString(),
    };

    await box.add(sale);
  }

  // 📊 GET ALL SALES
  static List<Map> getAllSales() {
    return box.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // 🧹 CLEAR SALES (optional)
  static Future<void> clearSales() async {
    await box.clear();
  }
}