
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/product_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'home_page.dart';


class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage>
    with SingleTickerProviderStateMixin {

  final category = TextEditingController();
  final name = TextEditingController();
  final buy = TextEditingController();
  final sell = TextEditingController();
  final qty = TextEditingController();
  
 final AudioPlayer audioPlayer = AudioPlayer();

//.......................................................success feedback
Future<void> successFeedback() async {
  try {
    await audioPlayer.play(AssetSource('sounds/success.mp3'));
  } catch (_) {}

  HapticFeedback.lightImpact();
}

//.........................................................error feedback
Future<void> errorFeedback() async {
  try {
    await audioPlayer.play(AssetSource('sounds/eror.mp3'));
  } catch (_) {}

  HapticFeedback.heavyImpact();
}



String? duplicateCode;
  List<String> scanned = [];
  bool scanning = false;

  // 🔥 suggestions
  List<String> categories = [];
  List<String> productNames = [];

  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    loadSuggestions();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    animationController.dispose();

    category.dispose();
    name.dispose();
    buy.dispose();
    sell.dispose();
    qty.dispose();

    super.dispose();
  }

  // 🔍 LOAD EXISTING DATA
  void loadSuggestions() {
    final products = ProductService.getAllProducts();

    categories = products
        .map((e) => e["category"].toString())
        .toSet()
        .toList();

    productNames = products
        .map((e) => e["name"].toString())
        .toSet()
        .toList();
  }

  // 🔍 FILTER
  Iterable<String> filterList(
    String input,
    List<String> list,
  ) {
    return list.where(
      (item) => item
          .toLowerCase()
          .startsWith(input.toLowerCase()),
    );
  }
  
  // showScanMessage......................................

  void showScanMessage(String msg, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: color,
      duration: const Duration(milliseconds: 1000),
    ),
  );
}


// CUSTOM message ...................................................

void showCustomMessage(BuildContext context, String message) {
  OverlayState? overlayState = Overlay.of(context);

  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 550,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 230, 223, 223),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            message,
            style: TextStyle(color: const Color.fromARGB(255, 8, 8, 8)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );

  overlayState.insert(overlayEntry);

  Future.delayed(Duration(seconds: 2))
      .then((value) => overlayEntry.remove());
}

  // 📦 START SCANNING
  void startScan() {

    final total = int.tryParse(qty.text) ?? 0;
    final parentContext = context;

    if (total <= 0) return;

    scanned.clear();

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,

      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {

            return Container(
              height: 580,

              decoration: const BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(35),
                ),
              ),

              child: Column(
                children: [

                  const SizedBox(height: 12),

                  Container(
                    width: 70,
                    height: 6,

                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "বারকোড স্ক্যান করুন",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 🔥 COUNTER CARD
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 20),

                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade400,
                          Colors.green.shade700,
                        ],
                      ),

                      borderRadius: BorderRadius.circular(32),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),

                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,

                      children: [

                        Column(
                          children: [

                            const Text(
                              "Scanned",
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "${scanned.length}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        Container(
                          width: 5,
                          height: 55,
                          color: Colors.white24,
                        ),

                        Column(
                          children: [

                            const Text(
                              "Remaining",
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "${total - scanned.length}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                      
                  ),

                  const SizedBox(height: 20),



                  // 📷 SCANNER BOX
                  Expanded(
                    child: Container(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 18),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),

                        border: Border.all(
                        color: duplicateCode != null ? Colors.red : Colors.green,
                        width: 3,
                      ),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.15),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),

                      clipBehavior: Clip.hardEdge,

                      child: MobileScanner(
                        onDetect: (capture) async {
                          setState(() {
                        duplicateCode = null;
                      });

                      HapticFeedback.heavyImpact();
                      errorFeedback();
                          if (scanning) return;

                          scanning = true;

                          final code =
                              capture.barcodes.first.rawValue;

                          if (code == null) {
                            Future.delayed(const Duration(seconds: 2), () {
                              scanning = false;
                            });
                            return;
                          }

                          // ❌ DUPLICATE INSIDE CURRENT SCAN
                          if (scanned.contains(code)) {

                            //showScanMessage("পন্যটি স্টকে আছে", Colors.orange);..................previous message

                            //showCustomMessage(context,"ops");

                            Future.delayed(const Duration(seconds: 3), () {
                              scanning = false;
                            });
                            return;
                          }

                          // ❌ CHECK EXISTING STOCK
                          final existing =
                              ProductService.getProductByBarcode(
                            code,
                          );

                          if (existing != null) {

                           setState(() {
                          duplicateCode = code;
                           });

                          errorFeedback();
                          showCustomMessage(context,"এই পন্যটি ইতোমধ্যে স্টকে আছে");

                //                 showScanMessage("পন্যটি স্টকে আছে", Colors.orange);   later

                            Future.delayed(const Duration(seconds: 3), () {
                              scanning = false;
                            });
                            return;
                          }

                          // ✅ ADD
                          scanned.add(code);

                          setModalState(() {});

                          successFeedback();

                          //showScanMessage("পন্যটি যোগ হয়েছে", Colors.green);
                          showCustomMessage(context,"পন্যটি স্টকে যোগ হয়েছে");
                          Future.delayed(const Duration(milliseconds: 900), () {
                            if (mounted) {
                              setState(() {
                                duplicateCode = null;
                              });
                            }
                          });

                          Future.delayed(const Duration(seconds: 3), () {
                              scanning = false;
                            });

                          // ✅ FINISH
                        if (scanned.length >= total) {

                          await ProductService.saveProductGroup(
                            category: category.text,
                            name: name.text,
                            buyPrice: double.parse(buy.text),
                            sellPrice: double.parse(sell.text),
                            barcodes: scanned,
                          );

                          // stop scanner
                          scanning = true;

                          // close bottom sheet first
                          Navigator.pop(context);

                          // wait a little
                          await Future.delayed(const Duration(milliseconds: 300));

                          if (!mounted) return;

                          // go to home page
                          Navigator.pushAndRemoveUntil(
                            this.context,
                            MaterialPageRoute(
                              builder: (_) => const HomePage(),
                            ),
                            (route) => false,
                          );

                          // message
                          Future.delayed(const Duration(milliseconds: 300), () {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text("পন্যগুলো স্টকে যোগ সম্পন্ন হয়েছে"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          });
                        }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ❌ CANCEL
                  SizedBox(
                    width: 180,
                    height: 52,

                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                      ),

                      onPressed: () {
                        Navigator.pop(context);
                      },

                      icon: const Icon(Icons.close),

                      label: const Text(
                        "Cancel",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 🔥 CUSTOM FIELD UI
  Widget customField({
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),

      child: child,
    );
  }


//-----------------------------------------------------------------UI--------------------------------------------------


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF4F7FB),

      body: SafeArea(
        child: Stack(
          children: [

            // 🔥 FLOATING BACKGROUND ANIMATION
            AnimatedBuilder(
              animation: animationController,

              builder: (context, child) {

                double move =
                    animationController.value * 25;

                return Stack(
                  children: [

                    Positioned(
                      top: 80 + move,
                      left: -40,

                      child: Container(
                        width: 140,
                        height: 140,

                        decoration: BoxDecoration(
                          color:
                              Colors.green.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    Positioned(
                      top: 350 - move,
                      right: -30,

                      child: Container(
                        width: 110,
                        height: 110,

                        decoration: BoxDecoration(
                          color:
                              Colors.blue.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 100 + move,
                      left: 40,

                      child: Container(
                        width: 90,
                        height: 90,

                        decoration: BoxDecoration(
                          color:
                              Colors.orange.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),






            // -----------------------------------------------------🔥 MAIN UI 🔥 --------------------------------------------
            SingleChildScrollView(
              padding: const EdgeInsets.all(18),

              child: Column(
                children: [

                  // 🔵 HEADER CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF00C853),
                          Color(0xFF43A047),
                        ],

                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),

                      borderRadius:
                          BorderRadius.circular(35),

                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.green.withOpacity(0.3),

                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),

                    child: Column(
                      children: [

                        Container(
                          width: 85,
                          height: 85,

                          decoration: BoxDecoration(
                            color:
                                Colors.white.withOpacity(0.2),

                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.inventory_2_rounded,
                            size: 45,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          "পন্য যোগ করুন",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Scan products quickly and manage inventory smarter",
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🔥 CATEGORY
                  customField(
                    child: Autocomplete<String>(
                      optionsBuilder:
                          (TextEditingValue value) {

                        if (value.text.isEmpty) {
                          return const Iterable<String>
                              .empty();
                        }

                        return filterList(
                          value.text,
                          categories,
                        );
                      },

                      onSelected: (selection) {

                        category.text = selection;

                        FocusScope.of(context).unfocus();

                        setState(() {});
                      },

                      fieldViewBuilder:
                          (
                            context,
                            controller,
                            focusNode,
                            onEditingComplete,
                          ) {

                        controller.value =
                            TextEditingValue(
                          text: category.text,

                          selection:
                              TextSelection.collapsed(
                            offset:
                                category.text.length,
                          ),
                        );

                        return TextField(
                          controller: controller,
                          focusNode: focusNode,

                          decoration: InputDecoration(
                            labelText: "Category",

                            prefixIcon: const Icon(
                              Icons.category_rounded,
                            ),

                            filled: true,
                            fillColor: Colors.white,

                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(22),

                              borderSide:
                                  BorderSide.none,
                            ),
                          ),

                          onChanged: (value) {
                            category.text = value;
                          },
                        );
                      },
                    ),
                  ),

                  // 🔥 PRODUCT NAME
                  customField(
                    child: Autocomplete<String>(
                      optionsBuilder:
                          (TextEditingValue value) {

                        if (value.text.isEmpty) {
                          return const Iterable<String>
                              .empty();
                        }

                        return filterList(
                          value.text,
                          productNames,
                        );
                      },

                      onSelected: (selection) {

                        name.text = selection;

                        FocusScope.of(context).unfocus();

                        setState(() {});
                      },

                      fieldViewBuilder:
                          (
                            context,
                            controller,
                            focusNode,
                            onEditingComplete,
                          ) {

                        controller.value =
                            TextEditingValue(
                          text: name.text,

                          selection:
                              TextSelection.collapsed(
                            offset: name.text.length,
                          ),
                        );

                        return TextField(
                          controller: controller,
                          focusNode: focusNode,

                          decoration: InputDecoration(
                            labelText: "Product Name",

                            prefixIcon: const Icon(
                              Icons.shopping_bag_rounded,
                            ),

                            filled: true,
                            fillColor: Colors.white,

                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(22),

                              borderSide:
                                  BorderSide.none,
                            ),
                          ),

                          onChanged: (value) {
                            name.text = value;
                          },
                        );
                      },
                    ),
                  ),

                  // 💰 BUY PRICE
                  customField(
                    child: TextField(
                      controller: buy,
                      keyboardType:
                          TextInputType.number,

                      decoration: InputDecoration(
                        labelText: "Buy Price",

                        prefixIcon: const Icon(
                          Icons.currency_exchange_rounded,
                        ),

                        filled: true,
                        fillColor: Colors.white,

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(22),

                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  // 💵 SELL PRICE
                  customField(
                    child: TextField(
                      controller: sell,
                      keyboardType:
                          TextInputType.number,

                      decoration: InputDecoration(
                        labelText: "Sell Price",

                        prefixIcon: const Icon(
                          Icons.sell_rounded,
                        ),

                        filled: true,
                        fillColor: Colors.white,

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(22),

                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  // 📦 STOCK QTY
                  customField(
                    child: TextField(
                      controller: qty,
                      keyboardType:
                          TextInputType.number,

                      decoration: InputDecoration(
                        labelText: "Stock Quantity",

                        prefixIcon: const Icon(
                          Icons.numbers_rounded,
                        ),

                        filled: true,
                        fillColor: Colors.white,

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(22),

                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 🔥 START SCAN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 62,

                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF00C853),

                        foregroundColor: Colors.white,

                        elevation: 6,

                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(22),
                        ),
                      ),

                      onPressed: startScan,

                      icon: const Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 30,
                      ),

                      label: const Text(
                        "Start Scanning",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

