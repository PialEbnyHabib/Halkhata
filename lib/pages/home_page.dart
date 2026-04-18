import 'package:flutter/material.dart';
import 'add_product_page.dart';
import 'sell_product_page.dart';
import 'stocks_page.dart';
import 'sales_history_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Image.asset('assets/images/Logo.png', height: 180, width: 180,),
        centerTitle: true,
        toolbarHeight: 200,
        shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(90),
      ),
    ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // ➕ ADD PRODUCT BUTTON
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddProductPage(),
                    ),
                  );
                },
                child: const Text("পন্য যোগ করুন"),
              ),
            ),

            const SizedBox(height: 20),

            // 💰 SELL PRODUCT BUTTON
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SellProductPage(),
                    ),
                  );
                },
                child: const Text("পন্য বিক্রয় করুন"),
              ),
            ),

            const SizedBox(height: 20),

            // 📦 STOCKS BUTTON (NEW)
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StocksPage(),
                    ),
                  );
                },
                child: const Text("স্টক দেখুন"),
              ),
            ),
           
           const SizedBox(height: 20),

            SizedBox(
  width: 200,
  height: 50,
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SalesHistoryPage(),
        ),
      );
    },
    child: const Text("বিক্রিত মালামাল"),
  ),
),

          ],
        ),
      ),
    );
  }
}

