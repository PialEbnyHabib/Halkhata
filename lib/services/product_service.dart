import 'package:hive/hive.dart';

class ProductService {
  static final Box box = Hive.box('products');

  // 📦 SAVE PRODUCT GROUP (ADD PRODUCT)
  static Future<void> saveProductGroup({
    required String category,
    required String name,
    required double buyPrice,
    required double sellPrice,
    required List<String> barcodes,
  }) async {
    String key = "${category}_$name";

    Map existing = box.get(key, defaultValue: {
      "category": category,
      "name": name,
      "buyPrice": buyPrice,
      "sellPrice": sellPrice,
      "barcodes": [],
    });

    List existingBarcodes = List.from(existing["barcodes"]);

    for (var code in barcodes) {
      if (!existingBarcodes.contains(code)) {
        existingBarcodes.add(code);
      }
    }

    existing["category"] = category;
    existing["name"] = name;
    existing["buyPrice"] = buyPrice;
    existing["sellPrice"] = sellPrice;
    existing["barcodes"] = existingBarcodes;

    await box.put(key, existing);
  }

  // 📦 GET ALL PRODUCTS
  static List<Map> getAllProducts() {
    return box.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // 🔍 GET PRODUCT BY BARCODE (FOR CART - NO STOCK CHANGE)
  static Map? getProductByBarcode(String code) {
    final all = getAllProducts();

    for (var p in all) {
      List barcodes = p["barcodes"] ?? [];

      if (barcodes.contains(code)) {
        return {
          "category": p["category"],
          "name": p["name"],
          "sellPrice": p["sellPrice"],
          "buyPrice": p["buyPrice"], // ✅ NEW 
          "barcode": code,
        };
      }
    }
    return null;
  }

  // 🧾 REDUCE STOCK (ONLY ON CHECKOUT)
  static Future<void> reduceStock(String code) async {
    final keys = box.keys.toList();

    for (var key in keys) {
      final product = box.get(key);

      if (product == null) continue;

      List barcodes = List.from(product["barcodes"] ?? []);

      if (barcodes.contains(code)) {
        barcodes.remove(code);
        product["barcodes"] = barcodes;

        if (barcodes.isEmpty) {
          await box.delete(key);
        } else {
          await box.put(key, product);
        }
        return;
      }
    }
  }

  // 🗑 DELETE FULL PRODUCT GROUP
  static Future<void> deleteProductGroup({
    required String category,
    required String name,
  }) async {
    String key = "${category}_$name";
    await box.delete(key);
  }

  // 🧹 CLEAR ALL DATA (OPTIONAL DEBUG)
  static Future<void> clearAll() async {
    await box.clear();
  }

  
  // 🔍 SEARCH PRODUCTS BY PARTIAL INVOICE / BARCODE  
  static List<Map> searchByQuery(String query) {
  final all = getAllProducts();

  List<Map> results = [];

  for (var p in all) {
    List barcodes = p["barcodes"] ?? [];

    // match category + name + barcode
    String key = "${p["category"]}_${p["name"]}".toLowerCase();

    if (key.contains(query.toLowerCase())) {
      results.add({
        "category": p["category"],
        "name": p["name"],
        "sellPrice": p["sellPrice"],
        "buyPrice": p["buyPrice"],
        "barcode": barcodes.isNotEmpty ? barcodes.first : "",
      });
      continue;
    }

    for (var code in barcodes) {
      if (code.toString().contains(query)) {
        results.add({
          "category": p["category"],
          "name": p["name"],
          "sellPrice": p["sellPrice"],
          "buyPrice": p["buyPrice"],
          "barcode": code,
        });
        break;
      }
    }
  }

  return results;
}

}

