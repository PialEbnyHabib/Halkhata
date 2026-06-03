import 'package:flutter/material.dart';

import 'add_product_page.dart';
import 'sell_product_page.dart';
import 'stocks_page.dart';
import 'sales_history_page.dart';
import 'dashboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {

  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  // 🔵 BIG BUTTON
  Widget bigButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required Widget page,
    required List<Color> colors,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        width: 165,
        height: 180,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),

          borderRadius: BorderRadius.circular(30),

          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.35),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              icon,
              size: 50,
              color: Colors.white,
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                text,
                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⚪ SMALL BUTTON
  Widget smallButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required Widget page,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },

      child: Container(
        width: 105,
        height: 95,

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              icon,
              color: Colors.black87,
              size: 28,
            ),

            const SizedBox(height: 10),

            Text(
              text,
              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 FLOATING MINI ICON
  Widget animatedMiniIcon(
    IconData icon,
    Color color,
    double move,
  ) {
    return Transform.translate(
      offset: Offset(0, move),

      child: Container(
        width: 60,
        height: 60,

        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),

        child: Icon(
          icon,
          color: color,
          size: 30,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Stack(
          children: [

            // 🔵 ANIMATED BACKGROUND
            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                return Stack(
                  children: [

                    Positioned(
                      top: 80 + (animationController.value * 20),
                      left: -40,
                      child: Container(
                        width: 140,
                        height: 140,

                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    Positioned(
                      top: 350 - (animationController.value * 25),
                      right: -30,
                      child: Container(
                        width: 120,
                        height: 120,

                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 100 + (animationController.value * 15),
                      left: 50,
                      child: Container(
                        width: 90,
                        height: 90,

                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.07),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 180 - (animationController.value * 20),
                      right: 60,
                      child: Container(
                        width: 70,
                        height: 70,

                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // 🔥 MAIN UI
            Column(
              children: [

                // 🔵 HEADER
                Container(
                  width: double.infinity,
                  height: 240,

                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 42, 255, 188),
                        Color.fromARGB(255, 20, 201, 144),
                      ],

                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),

                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(45),
                      bottomRight: Radius.circular(45),
                    ),
                  ),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      // ✅ LOGO
                      Image.asset(
                        'assets/images/Logo.png',
                        height: 140,
                        width: 140,
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "ব্যবসা সফল হোক সহজ ব্যবস্থায়",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                // 🔥 BIG BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                  children: [

                    bigButton(
                      context: context,
                      text: "পন্য যোগ করুন",
                      icon: Icons.add_box_rounded,
                      page: const AddProductPage(),

                      colors: const [
                        Color(0xFF00C853),
                        Color(0xFF43A047),
                      ],
                    ),

                    bigButton(
                      context: context,
                      text: "পন্য বিক্রয় করুন",
                      icon: Icons.point_of_sale_rounded,
                      page: const SellProductPage(),

                      colors: const [
                        Color(0xFF2962FF),
                        Color(0xFF1565C0),
                      ],
                    ),
                  ],
                ),

                // 🔥 ANIMATED MIDDLE SECTION
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: animationController,
                      builder: (context, child) {

                        double move =
                            animationController.value * 15;

                        return Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [

                            // 🔥 STATUS CARD
                            Transform.translate(
                              offset: Offset(0, move),

                              child: Container(
                                width:
                                    MediaQuery.of(context)
                                            .size
                                            .width *
                                        0.82,

                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),

                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withOpacity(0.92),

                                  borderRadius:
                                      BorderRadius.circular(25),

                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.08),

                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),

                                child: Row(
                                  children: [

                                    // 🟢 LIVE DOT
                                    Container(
                                      width: 14,
                                      height: 14,

                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,

                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.green
                                                .withOpacity(0.5),

                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 15),

                                    // 📊 STATUS TEXT
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [

                                          Text(
                                            "POS System Active",

                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),

                                          SizedBox(height: 4),

                                          Text(
                                            "Inventory • Sales • Analytics Running",

                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // ⚡ ICON
                                    Icon(
                                      Icons.bolt_rounded,
                                      color:
                                          Colors.orange.shade600,

                                      size: 30,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // 🔵 FLOATING ICONS
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,

                              children: [

                                animatedMiniIcon(
                                  Icons.inventory_2_rounded,
                                  Colors.blue,
                                  move,
                                ),

                                const SizedBox(width: 25),

                                animatedMiniIcon(
                                  Icons.point_of_sale_rounded,
                                  Colors.green,
                                  -move,
                                ),

                                const SizedBox(width: 25),

                                animatedMiniIcon(
                                  Icons.bar_chart_rounded,
                                  Colors.orange,
                                  move,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // ⚪ SECTION TITLE
                const Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Text(
                    "Quick Access",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),

                // ⚪ SMALL BUTTONS
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),

                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,

                    children: [

                      smallButton(
                        context: context,
                        text: "স্টক",
                        icon: Icons.inventory_2_rounded,
                        page: StocksPage(),
                      ),

                      smallButton(
                        context: context,
                        text: "বিক্রিত পন্য",
                        icon: Icons.receipt_long_rounded,
                        page: const SalesHistoryPage(),
                      ),

                      smallButton(
                        context: context,
                        text: "ড্যাশবোর্ড",
                        icon: Icons.bar_chart_rounded,
                        page: const DashboardPage(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}