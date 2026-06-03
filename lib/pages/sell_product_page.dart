import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';

import '../services/product_service.dart';
import '../services/sales_service.dart';
import 'invoice_page.dart';

class SellProductPage extends StatefulWidget {
  const SellProductPage({super.key});

  @override
  State<SellProductPage> createState() => _SellProductPageState();
}

class _SellProductPageState extends State<SellProductPage> {

  // ================= VARIABLES =================

  List<Map> cart = [];
  List<Map> suggestions = [];

  final AudioPlayer audioPlayer = AudioPlayer();

  final MobileScannerController scannerController =
      MobileScannerController(
    formats: [BarcodeFormat.ean13],
  );

  // ================= TOTAL =================

  double get total =>
      cart.fold(
        0,
        (sum, item) =>
            sum + ((item["sellPrice"] ?? 0) as num),
      );

  // ================= CHECK CART =================

  bool isInCart(String barcode) {
    return cart.any(
      (item) => item["barcode"] == barcode,
    );
  }

  // ================= SOUND =================

  Future<void> cartAddSound() async {
    try {
      await audioPlayer.play(
        AssetSource('sounds/add.mp3'),
      );
    } catch (_) {}
  }

  // ================= SCAN PRODUCT =================

  void scanProduct() {

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.black,

      builder: (_) {

        bool scanned = false;

        return Container(
          height: 430,

          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0F2027),
                Color(0xFF203A43),
                Color(0xFF2C5364),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),

          child: Column(
            children: [

              const SizedBox(height: 14),

              Container(
                width: 70,
                height: 5,

                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "বারকোড স্ক্যান করুন",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18),

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),

                    child: MobileScanner(
                      controller: scannerController,

                      onDetect: (capture) async {

                        if (scanned) return;

                        scanned = true;

                        final code =
                            capture.barcodes.first.rawValue;

                        Navigator.pop(context);

                        if (code == null) return;

                        final product =
                            ProductService.getProductByBarcode(code);

                        // ❌ NOT FOUND
                        if (product == null) {

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Product not found"),
                            ),
                          );

                          return;
                        }

                        // ❌ DUPLICATE
                        if (isInCart(code)) {

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Already in cart"),
                            ),
                          );

                          return;
                        }

                        // ✅ ADD PRODUCT
                        setState(() {
                          cart.add(product);
                        });

                        cartAddSound();
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // ================= SEARCH PRODUCT =================

  void addByInvoiceNumber() {

    TextEditingController searchController =
        TextEditingController();

    showDialog(
      context: context,

      builder: (_) {

        return StatefulBuilder(
          builder: (context, setStateDialog) {

            return AlertDialog(

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),

              title: const Text(
                "পন্য খুঁজুন",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              content: SizedBox(
                width: double.maxFinite,

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [

                    // ================= SEARCH FIELD =================

                    TextField(
                      controller: searchController,

                      onChanged: (value) {

                        try {

                          final result =
                              ProductService.searchByQuery(value);

                          setStateDialog(() {
                            suggestions = result;
                          });

                        } catch (e) {

                          debugPrint(e.toString());

                          setStateDialog(() {
                            suggestions = [];
                          });
                        }
                      },

                      decoration: InputDecoration(
                        hintText:
                            "Name / Barcode লিখুন",

                        prefixIcon:
                            const Icon(Icons.search),

                        filled: true,
                        fillColor: Colors.grey.shade100,

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),

                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ================= RESULT LIST =================

                    SizedBox(
                      height: 250,

                      child: suggestions.isEmpty

                          ? const Center(
                              child: Text("No Product Found"),
                            )

                          : ListView.builder(
                              itemCount: suggestions.length,

                              itemBuilder: (context, index) {

                                final item =
                                    suggestions[index];

                                return Container(
                                  margin:
                                      const EdgeInsets.only(
                                    bottom: 10,
                                  ),

                                  decoration: BoxDecoration(
                                    color: Colors.white,

                                    borderRadius:
                                        BorderRadius.circular(
                                      16,
                                    ),

                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.05),

                                        blurRadius: 10,
                                        offset:
                                            const Offset(0, 4),
                                      ),
                                    ],
                                  ),

                                  child: ListTile(

                                    leading: Container(
                                      width: 45,
                                      height: 45,

                                      decoration: BoxDecoration(
                                        color: Colors.green
                                            .withOpacity(0.12),

                                        borderRadius:
                                            BorderRadius.circular(
                                          12,
                                        ),
                                      ),

                                      child: const Icon(
                                        Icons.inventory_2,
                                        color: Colors.green,
                                      ),
                                    ),

                                    title: Text(
                                      item["name"]
                                              ?.toString() ??
                                          "No Name",

                                      style: const TextStyle(
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),

                                    subtitle: Text(
                                      item["barcode"]
                                              ?.toString() ??
                                          "",
                                    ),

                                    trailing: Text(
                                      "৳${item["sellPrice"]?.toString() ?? "0"}",

                                      style: const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),

                                    onTap: () {

                                      Navigator.pop(context);

                                      if (isInCart(
                                          item["barcode"])) {

                                        ScaffoldMessenger.of(
                                                context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Already added",
                                            ),
                                          ),
                                        );

                                        return;
                                      }

                                      setState(() {
                                        cart.add(item);
                                      });

                                      cartAddSound();
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),

              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= REMOVE ITEM =================

  void removeItem(int index) {

    setState(() {
      cart.removeAt(index);
    });
  }

  // ================= CHECKOUT =================

  void checkout() async {

    if (cart.isEmpty) return;

    double totalAmount = 0;
    double profit = 0;

    for (var item in cart) {

      totalAmount += item["sellPrice"];

      profit +=
          (item["sellPrice"] - item["buyPrice"]);
    }

    // REDUCE STOCK
    for (var item in cart) {

      await ProductService.reduceStock(
        item["barcode"],
      );
    }

    // SAVE SALE
    await SalesService.saveSale(
      cart: cart,
      total: totalAmount,
      profit: profit,
    );

    final sales =
        SalesService.getAllSales();

    final lastSale = sales.last;

    // OPEN INVOICE
    await Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) => InvoicePage(
          cart: List.from(cart),
          total: totalAmount,
          invoiceNo: lastSale["invoiceNo"],
          time: lastSale["time"],
        ),
      ),
    );

    // CLEAR CART
    setState(() {
      cart.clear();
    });
  }

  // ================= DISPOSE =================

  @override
  void dispose() {

    scannerController.dispose();

    super.dispose();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF4F7FB),

      // ================= APPBAR =================

      appBar: AppBar(
        elevation: 0,

        title: const Text(
          "পন্য বিক্রি করুন",
        ),

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF00C853),
                Color(0xFF43A047),
              ],
            ),
          ),
        ),
      ),

      // ================= BODY =================

      body: Column(
        children: [

          // ================= TOTAL CARD =================

          Container(
            width: double.infinity,

            margin: const EdgeInsets.all(14),

            padding: const EdgeInsets.all(22),

            decoration: BoxDecoration(

              gradient: const LinearGradient(
                colors: [
                  Color(0xFF00C853),
                  Color(0xFF43A047),
                ],
              ),

              borderRadius:
                  BorderRadius.circular(24),

              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),

            child: Column(
              children: [

                const Text(
                  "মোট বিল",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "৳ ${total.toStringAsFixed(2)}",

                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // ================= CART LIST =================

          Expanded(
            child: cart.isEmpty

                ? const Center(
                    child: Text(
                      "কার্টে কোন পন্য নেই",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  )

                : ListView.builder(
                    itemCount: cart.length,

                    itemBuilder: (context, i) {

                      final item = cart[i];

                      return Container(

                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(18),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.05),

                              blurRadius: 10,

                              offset:
                                  const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: ListTile(

                          leading: Container(
                            width: 50,
                            height: 50,

                            decoration: BoxDecoration(
                              color: Colors.green
                                  .withOpacity(0.12),

                              borderRadius:
                                  BorderRadius.circular(
                                14,
                              ),
                            ),

                            child: const Icon(
                              Icons.shopping_bag,
                              color: Colors.green,
                            ),
                          ),

                          title: Text(
                            item["name"]
                                    ?.toString() ??
                                "",

                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          subtitle: Text(
                            item["barcode"]
                                    ?.toString() ??
                                "",
                          ),

                          trailing: Row(
                            mainAxisSize:
                                MainAxisSize.min,

                            children: [

                              Text(
                                "৳${item["sellPrice"]}",

                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,

                                  fontSize: 16,
                                ),
                              ),

                              IconButton(
                                onPressed: () {
                                  removeItem(i);
                                },

                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // ================= BUTTONS =================

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),

            child: Row(
              children: [

                // SCAN BUTTON
                Expanded(
                  child: ElevatedButton.icon(

                    onPressed: scanProduct,

                    icon: const Icon(
                      Icons.qr_code_scanner,
                    ),

                    label: const Text(
                      "স্ক্যান",
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF00C853),

                      foregroundColor: Colors.white,

                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 15,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // SEARCH BUTTON
                Expanded(
                  child: ElevatedButton.icon(

                    onPressed: addByInvoiceNumber,

                    icon: const Icon(Icons.search),

                    label: const Text(
                      "খুঁজুন",
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.greenAccent,

                      foregroundColor:
                          Colors.black87,

                      elevation: 0,

                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 15,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),

                        side: BorderSide(
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // CHECKOUT BUTTON
                Expanded(
                  child: ElevatedButton.icon(

                    onPressed: checkout,

                    icon: const Icon(Icons.payment),

                    label: const Text(
                      "চেকআউট",
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.black87,

                      foregroundColor:
                          Colors.white,

                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 15,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}