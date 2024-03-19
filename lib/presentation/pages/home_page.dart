import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/presentation/pages/assortment_page.dart';
import 'package:mobile_app_slb/presentation/pages/newsale_page.dart';
import 'package:mobile_app_slb/presentation/states/home_state.dart';
import 'package:mobile_app_slb/presentation/widgets/app_drawer.dart';
import 'package:mobile_app_slb/presentation/widgets/home_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../states/auth_state.dart';
import 'auth_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const AppDrawer(
        isAbleToNavigate: true,
        isAssembly: false,
        isHomePage: true,
      ),
      body: SafeArea(
          child: ref.watch(getHomeProvider).when(
              data: (value) {
                if (value.$1.errorModel == null &&
                    value.$1.stockModel != null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
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
                              child: InkWell(
                                onTap: () {
                                  scaffoldKey.currentState?.openDrawer();
                                },
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
                              ),
                            )
                          ],
                        ),
                      ),
                      const Divider(),
                      Expanded(
                          flex: 3,
                          child: Padding(
                              padding: const EdgeInsets.all(30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    value.$2,
                                    style: const TextStyle(
                                        fontSize: 16, color: Color(0xFFCACACA)),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .currentStorehouse,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: Color(0xFF909090),
                                    ),
                                  ),
                                  Text(
                                    value.$1.stockModel!.name,
                                    style: const TextStyle(
                                        fontSize: 36,
                                        color: Color(0xFF363636),
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ))),
                      const Divider(),
                      Expanded(
                        flex: 7,
                        child: GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 166 / 122,
                          crossAxisSpacing: 25,
                          mainAxisSpacing: 25,
                          primary: false,
                          padding: const EdgeInsets.all(25),
                          crossAxisCount: 2,
                          children: [
                            homeCard("assets/images/boxes_icon.png",
                                AppLocalizations.of(context)!.assortment, () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => AssortmentPage(
                                            currentStorehouse:
                                                value.$1.stockModel!.name,
                                          )));
                            }),
                            homeCard("assets/images/calculator_icon.png",
                                AppLocalizations.of(context)!.newSale, () {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => NewSalePage(
                                            currentStorehouse:
                                                value.$1.stockModel!.name,
                                            storehouseId:
                                                value.$1.stockModel!.id,
                                        isTransaction: false,
                                          )),
                                  (route) => false);
                            }),
                            homeCard(
                                "assets/images/bulk_icon.png",
                                AppLocalizations.of(context)!.bulkAssembling,
                                () {}),
                            homeCard("assets/images/monitor_icon.png",
                                AppLocalizations.of(context)!.newArrival, () {})
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  ref.read(deleteAuthProvider).deleteAuth();
                  Future.microtask(() => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthPage()),
                      (route) => false));

                  return Container();
                }
              },
              error: (error, stacktrace) {
                return AlertDialog(
                  title: Text(error.toString()),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(AppLocalizations.of(context)!.ok))
                  ],
                );
              },
              loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  ))),
    );
  }
}
