import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/data/models/assortment_model.dart';
import 'package:mobile_app_slb/data/models/cart_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_app_slb/data/models/stock_model.dart';
import 'package:mobile_app_slb/presentation/pages/scanbarcode_page.dart';
import '../widgets/app_drawer.dart';
import '../widgets/backButton.dart';
import '../widgets/exit_dialog.dart';
import 'home_page.dart';

class NewArrivalPage extends ConsumerStatefulWidget {
  const NewArrivalPage({super.key, required this.stockModel});

  final StockModel stockModel;

  @override
  ConsumerState<NewArrivalPage> createState() => _BulkListPageState();
}

class _BulkListPageState extends ConsumerState<NewArrivalPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
        data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).size.shortestSide > 650
                ? const TextScaler.linear(1.1)
                : const TextScaler.linear(1.0)),
        child: Scaffold(
            key: scaffoldKey,
            resizeToAvoidBottomInset: false,
            drawer: AppDrawer(
              isAbleToNavigate: false,
              isAssembly: false,
              isHomePage: false,
              stockModel: widget.stockModel,
            ),
            bottomNavigationBar: SafeArea(
              child: Container(
                  height: 80,
                  decoration: const BoxDecoration(
                      border: Border(
                          top: BorderSide(color: Color(0xFFD9D9D9), width: 1))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Opacity(
                          opacity: 1.0,
                          child: InkWell(
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ScanBarcodePage(
                                            stockModel: widget.stockModel,
                                          )),
                                  (route) => false);
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Center(
                                  child: Container(
                                    width: 68,
                                    height: 68,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: const Color(0xFFDFDFDF)),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color: Colors.black),
                                      child: Center(
                                        child: Image.asset(
                                          "assets/images/qr_scanner_icon.png",
                                          scale: 4,
                                        ),
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 40, right: 40, left: 40, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              backButton(() {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return exitDialog(
                                          context,
                                          AppLocalizations.of(context)!
                                              .areYouSure);
                                    }).then((returned) {
                                  if (returned) {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const HomePage()),
                                        (route) => false);
                                  }
                                });
                              }, AppLocalizations.of(context)!.cancelCaps,
                                  false),
                              Builder(builder: (context) {
                                return InkWell(
                                  onTap: () {
                                    Scaffold.of(context).openDrawer();
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
                                );
                              }),
                            ],
                          ),
                          const Spacer(),
                          const Text(
                            "NEW ARRIVAL",
                            style: TextStyle(
                                fontSize: 24,
                                color: Color(0xFF909090),
                                height: 0.5),
                          ),
                          const Text(
                            "Arrival list",
                            style: TextStyle(
                                fontSize: 36,
                                color: Color(0xFF363636),
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    height: 1,
                  ),
                  // Expanded(
                  //   flex: 6,
                  //   child: Center(
                  //     child: Column(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Image.asset(
                  //           "assets/images/new_arrival_list_icon.png",
                  //           scale: 4,
                  //         ),
                  //         const SizedBox(height: 12),
                  //         const Text("NO ITEMS YET",
                  //             style: TextStyle(
                  //                 color: Color(0xFF888888),
                  //                 fontWeight: FontWeight.bold,
                  //                 fontSize: 20)),
                  //         const Text("Start with scanning below",
                  //             style: TextStyle(
                  //                 color: Color(0xFF888888),
                  //                 fontWeight: FontWeight.w600,
                  //                 fontSize: 20)),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  Expanded(
                    flex: 6,
                    child: getProductListWidget(Theme.of(context), [
                      CartModel(
                          AssortmentModel(
                              0, "name", "vendorCode", 100, [], "eanCode", 10),
                          10,
                          {},
                          100)
                    ]),
                  ),
                  const Center(child: VerticalDivider()),
                ],
              ),
            )));
  }

  Widget getProductListWidget(ThemeData theme, List<CartModel> data) {
    return Column(
      children: [
        Container(
          height: 56,
          decoration: const BoxDecoration(color: Colors.black),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.nameCaps,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 16),
                  ),
                ),
              ),
              const VerticalDivider(
                color: Color(0xFFD9D9D9),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.quantityCaps,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 16),
                  ),
                ),
              ),
              const VerticalDivider(
                color: Color(0xFFD9D9D9),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.priceCaps,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
            flex: 5,
            child: ListView(
              children: data.mapIndexed((index, e) {
                return Container(
                  height: 58,
                  decoration: BoxDecoration(
                      color: index % 2 == 0
                          ? const Color(0xFFF9F9F9)
                          : Colors.white),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            e.model.name,
                            style: const TextStyle(
                                fontSize: 16, color: Color(0xFF222222)),
                          ),
                        ),
                      ),
                      const VerticalDivider(),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            e.quantity.toString(),
                            style: const TextStyle(
                                fontSize: 16, color: Color(0xFF222222)),
                          ),
                        ),
                      ),
                      const VerticalDivider(),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              e.quantity.toString(),
                              style: const TextStyle(
                                  fontSize: 16, color: Color(0xFF222222)),
                            ),
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.edit_note)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }

  bool allSelected(List<CartModel> cartList) {
    for (var cartItem in cartList) {
      if (!cartItem.isSelected) {
        return false;
      }
    }
    return true;
  }
}
