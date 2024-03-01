import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/data/repository/auth_repository.dart';
import 'package:mobile_app_slb/presentation/pages/new_auth_page.dart';
import 'package:mobile_app_slb/presentation/states/auth_state.dart';
import 'package:mobile_app_slb/presentation/widgets/home_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 60),
                    child: Image.asset(
                      "assets/images/logo.png",
                      scale: 4,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: const Color(0xFF3C3C3C),
                        borderRadius: BorderRadius.circular(5)),
                    child: const Icon(
                      Icons.menu,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          const Divider(),
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "12/12/2024 | 13.00",
                    style: TextStyle(fontSize: 16, color: Color(0xFFCACACA)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Current storehouse:",
                    style: TextStyle(
                        fontSize: 24, color: Color(0xFF909090), height: 0.3),
                  ),
                  Text(
                    "Storehouse name",
                    style: TextStyle(
                        fontSize: 36,
                        color: Color(0xFF363636),
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            flex: 2,
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 166 / 122,
              crossAxisSpacing: 25,
              mainAxisSpacing: 25,
              primary: false,
              padding: const EdgeInsets.all(25),
              crossAxisCount: 2,
              children: [
                homeCard("assets/images/boxes_icon.png", "Assortment", () {}),
                homeCard(
                    "assets/images/calculator_icon.png", "+ New sale", () {}),
                homeCard(
                    "assets/images/bulk_icon.png", "Bulk assembling", () {}),
                homeCard(
                    "assets/images/monitor_icon.png", "+ New arrival", () {})
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () async {
                          await AuthRepository().deleteAuthData().then((value) => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) =>
                                  const NewAuthPage()),
                                  (route) => false));
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 66,
                              height: 66,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: const Color(0xFFDFDFDF)),
                            ),
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.black),
                              child: Image.asset(
                                "assets/images/qr_icon.png",
                                scale: 4,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
