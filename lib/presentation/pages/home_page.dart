import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/presentation/pages/assortment_page.dart';
import 'package:mobile_app_slb/presentation/pages/bulk_page.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(timeProvider).updatePeriodic(),
    );
  }

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
                if (value.errorModel == null && value.stockModel != null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
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
                              padding: const EdgeInsets.only(
                                  left: 30, right: 30, top: 10, bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ref.watch(timeProvider).spainTime,
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
                                    value.stockModel!.name,
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
                          child: GridView.builder(
                              itemCount: 4,
                              padding: const EdgeInsets.all(25),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 25,
                                      mainAxisSpacing: 25,
                                      mainAxisExtent: 138),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return homeCard(
                                      "assets/images/boxes_icon.png",
                                      AppLocalizations.of(context)!.assortment,
                                      () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (builder) =>
                                                AssortmentPage(
                                                  currentStorehouse:
                                                      value.stockModel!.name,
                                                )));
                                  });
                                } else if (index == 1) {
                                  return homeCard(
                                      "assets/images/calculator_icon.png",
                                      AppLocalizations.of(context)!.newSale,
                                      () {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (builder) => NewSalePage(
                                                  currentStorehouse:
                                                      value.stockModel!.name,
                                                  storehouseId:
                                                      value.stockModel!.id,
                                                  isTransaction: false,
                                                )),
                                        (route) => false);
                                  });
                                } else if (index == 2) {
                                  return homeCard(
                                      "assets/images/bulk_icon.png",
                                      AppLocalizations.of(context)!
                                          .bulkAssembling, () {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (builder) => BulkPage(
                                                  currentStorehouse:
                                                      value.stockModel!.name,
                                                )),
                                        (route) => false);
                                  });
                                } else {
                                  return homeCard(
                                      "assets/images/monitor_icon.png",
                                      AppLocalizations.of(context)!.newArrival,
                                      () {});
                                }
                              })),
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
