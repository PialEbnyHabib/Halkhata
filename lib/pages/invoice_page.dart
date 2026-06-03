import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class InvoicePage extends StatelessWidget {
  final List<Map> cart;
  final double total;
  final String invoiceNo;
  final String time;

  const InvoicePage({
    super.key,
    required this.cart,
    required this.total,
    required this.invoiceNo,
    required this.time,
  });

  // ================= PDF GENERATOR =================
  Future<File> generatePdf() async {

  final pdf = pw.Document();

  // 🔥 LOAD BANGLA FONT
  final fontData = await rootBundle.load(
    'assets/fonts/NotoSansBengali-SemiBold.ttf',
  );

  final banglaFont = pw.Font.ttf(
    fontData,
  );

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {

        return pw.Padding(
          padding: const pw.EdgeInsets.all(24),

          child: pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.start,

            children: [

              pw.Center(
                child: pw.Text(
                  "হালখাতা POS",

                  style: pw.TextStyle(
                    font: banglaFont,
                    fontSize: 28,
                    fontWeight:
                        pw.FontWeight.bold,
                  ),
                ),

              ),

              pw.SizedBox(height: 20),

              pw.Text(
                "ইনভয়েস নং: $invoiceNo",

                style: pw.TextStyle(
                  font: banglaFont,
                ),
              ),

              pw.Text(
                "তারিখ: $time",

                style: pw.TextStyle(
                  font: banglaFont,
                ),
              ),

              pw.SizedBox(height: 15),

              pw.Divider(),

              pw.SizedBox(height: 10),

              // 🔥 PRODUCTS
              ...cart.map((item) {

                return pw.Padding(
                  padding:
                      const pw.EdgeInsets.only(
                    bottom: 12,
                  ),

                  child: pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment
                            .spaceBetween,

                    children: [

                      pw.Expanded(
                        child: pw.Text(
                          item["name"],

                          style: pw.TextStyle(
                            font: banglaFont,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      pw.Text(
                        "৳${item["sellPrice"]}",

                        style: pw.TextStyle(
                          font: banglaFont,
                          fontWeight:
                              pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              pw.Divider(),

              pw.SizedBox(height: 15),

              pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment
                        .spaceBetween,

                children: [

                  pw.Text(
                    "Items",

                    style: pw.TextStyle(
                      font: banglaFont,
                      fontWeight:
                          pw.FontWeight.bold,
                    ),
                  ),

                  pw.Text(
                    "${cart.length}",

                    style: pw.TextStyle(
                      font: banglaFont,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment
                        .spaceBetween,

                children: [

                  pw.Text(
                    "Total",

                    style: pw.TextStyle(
                      font: banglaFont,
                      fontWeight:
                          pw.FontWeight.bold,

                      fontSize: 18,
                    ),
                  ),

                  pw.Text(
                    "৳${total.toStringAsFixed(2)}",

                    style: pw.TextStyle(
                      font: banglaFont,
                      fontWeight:
                          pw.FontWeight.bold,

                      fontSize: 18,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 40),

              pw.Center(
                child: pw.Text(
                  "Thank you",

                  style: pw.TextStyle(
                    font: banglaFont,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  final dir =
      await getTemporaryDirectory();

  final file = File(
    "${dir.path}/invoice_$invoiceNo.pdf",
  );

  await file.writeAsBytes(
    await pdf.save(),
  );

  return file;
}

  // ================= SHARE INVOICE =================
 Future<void> shareInvoice(BuildContext context) async {
  try {
    // 1️⃣ Generate PDF
    final pdfFile = await generatePdf();

    if (!await pdfFile.exists()) {
      throw Exception("PDF file not found");
    }

    // 2️⃣ Share directly using system share sheet
    await Share.shareXFiles(
      [XFile(pdfFile.path)],
      text: "Invoice #$invoiceNo",
      subject: "Halkhata Invoice",
    );
  } catch (e) {
    debugPrint("Share Error: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Failed to share invoice: ${e.toString()}"),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F7FB),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,

        title: const Text(
          "Invoice",

          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
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

      body: Column(
        children: [

          // ================= HEADER CARD =================
          Container(
            width: double.infinity,

            margin:
                const EdgeInsets.all(16),

            padding:
                const EdgeInsets.all(24),

            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  Color(0xFF00C853),
                  Color(0xFF43A047),
                ],
              ),

              borderRadius:
                  BorderRadius.circular(24),

              boxShadow: [
                BoxShadow(
                  color: Colors.green
                      .withOpacity(0.25),

                  blurRadius: 14,

                  offset:
                      const Offset(0, 6),
                ),
              ],
            ),

            child: Column(
              children: [

                Container(
                  width: 80,
                  height: 80,

                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.2),

                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.receipt_long,
                    size: 42,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  "হালখাতা POS",

                  style: TextStyle(
                    fontSize: 28,
                    fontWeight:
                        FontWeight.bold,

                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Invoice #$invoiceNo",

                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  time,

                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // ================= ITEMS =================
          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
              ),

              itemCount: cart.length,

              itemBuilder:
                  (context, index) {

                final item =
                    cart[index];

                return Container(
                  margin:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),

                  decoration:
                      BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(
                            18),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.05),

                        blurRadius: 10,

                        offset:
                            const Offset(
                                0, 4),
                      ),
                    ],
                  ),

                  child: ListTile(
                    contentPadding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),

                    leading: Container(
                      width: 52,
                      height: 52,

                      decoration:
                          BoxDecoration(
                        color: Colors
                            .green.shade50,

                        borderRadius:
                            BorderRadius
                                .circular(
                                    14),
                      ),

                      child: const Icon(
                        Icons
                            .inventory_2_rounded,

                        color:
                            Colors.green,
                      ),
                    ),

                    title: Text(
                      item["name"],

                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,

                        fontSize: 16,
                      ),
                    ),

                    subtitle: Padding(
                      padding:
                          const EdgeInsets
                              .only(top: 5),

                      child: Text(
                        "Barcode: ${item["barcode"]}",

                        style: TextStyle(
                          color: Colors
                              .grey.shade600,
                        ),
                      ),
                    ),

                    trailing: Text(
                      "৳${item["sellPrice"]}",

                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,

                        fontSize: 17,

                        color:
                            Colors.green,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ================= TOTAL CARD =================
          Container(
            margin:
                const EdgeInsets.all(16),

            padding:
                const EdgeInsets.all(22),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(22),

              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.06),

                  blurRadius: 12,

                  offset:
                      const Offset(0, 5),
                ),
              ],
            ),

            child: Column(
              children: [

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [

                    const Text(
                      "Total Items",

                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),

                    Text(
                      "${cart.length}",

                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,

                        fontSize: 17,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [

                    const Text(
                      "Grand Total",

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    Text(
                      "৳${total.toStringAsFixed(2)}",

                      style:
                          const TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,

                        color:
                            Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ================= BUTTONS =================
          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            child: Row(
              children: [

                // PRINT
                Expanded(
                  child:
                      ElevatedButton.icon(
                    onPressed: () {

                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Print feature coming soon",
                          ),
                        ),
                      );
                    },

                    icon:
                        const Icon(Icons.print),

                    label:
                        const Text("Print"),

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          Colors.white,

                      foregroundColor:
                          Colors.black,

                      elevation: 0,

                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 16,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                                    18),

                        side: BorderSide(
                          color: Colors
                              .grey.shade300,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // SHARE
                Expanded(
                  child:
                      ElevatedButton.icon(
                    onPressed: () async {
                      await shareInvoice(
                          context);
                    },

                    icon:
                        const Icon(Icons.share),

                    label:
                        const Text("Share"),

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          Colors.green,

                      foregroundColor:
                          Colors.white,

                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 16,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                                    18),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // HOME
                Expanded(
                  child:
                      ElevatedButton.icon(
                    onPressed: () {

                      Navigator.popUntil(
                        context,
                        (route) =>
                            route.isFirst,
                      );
                    },

                    icon:
                        const Icon(Icons.home),

                    label:
                        const Text("Home"),

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          const Color(
                              0xFF00C853),

                      foregroundColor:
                          Colors.white,

                      padding:
                          const EdgeInsets
                          .symmetric(
                        vertical: 16,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                                    18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

