import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_app_slb/presentation/pages/auth_page.dart';
import 'package:mobile_app_slb/presentation/pages/productinfo_page.dart';
import 'package:mobile_app_slb/presentation/pages/transfercomplete_page.dart';
import 'package:mobile_app_slb/presentation/states/transfer_state.dart';
import 'package:mobile_app_slb/presentation/widgets/app_drawer_qr.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/stock_model.dart';
import '../states/assortment_state.dart';
import '../states/auth_state.dart';
import '../widgets/backButton.dart';
import '../widgets/exit_dialog.dart';

class TransferAssemblyPage extends ConsumerStatefulWidget {
  const TransferAssemblyPage(
      {super.key,
      required this.stockModel,
      required this.cartModels,
      required this.transactionId,
      required this.stockId});

  final StockModel stockModel;
  final int transactionId;
  final int stockId;
  final List<CartModel> cartModels;

  @override
  ConsumerState<TransferAssemblyPage> createState() =>
      _TransferAssemblyPageState();
}

class _TransferAssemblyPageState extends ConsumerState<TransferAssemblyPage>
    with WidgetsBindingObserver {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool isExitOpened = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      if (!isExitOpened) {
        setState(() {
          isExitOpened = true;
        });
        showDialog(
            context: context,
            builder: (context) {
              return exitDialog(
                  context, AppLocalizations.of(context)!.areYouSure);
            }).then((returned) {
          if (returned) {
            ref.read(deleteAuthProvider).deleteAuth();
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const AuthPage()),
                (route) => false);
          }
        }).then((value) => setState(() {
              isExitOpened = false;
            }));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAllSelected = allSelected(widget.cartModels);
    double width = MediaQuery.of(context).size.width;

    return MediaQuery(
        data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).size.shortestSide > 650
                ? const TextScaler.linear(1.1)
                : const TextScaler.linear(1.0)),
        child: Scaffold(
            key: scaffoldKey,
            resizeToAvoidBottomInset: false,
            endDrawer: AppDrawerQr(
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
                          opacity: isAllSelected ? 1.0 : 0.2,
                          child: InkWell(
                            onTap: isAllSelected
                                ? () async {
                                    final data = await ref
                                        .read(transferProvider)
                                        .completeTransferAssembly(
                                            widget.transactionId,
                                            widget.stockId);
                                    if (data.errorModel == null) {
                                      if (context.mounted) {
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const TransferCompletePage(
                                                        isQr: true,
                                                        isNew: false,
                                                        isAssembling: true,
                                                        isEnd: false)),
                                            (route) => false);
                                      }
                                    } else {
                                      if (context.mounted) {
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const AuthPage()),
                                            (route) => false);
                                      }
                                    }
                                  }
                                : () {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      duration: const Duration(seconds: 1),
                                      content: Text(
                                          AppLocalizations.of(context)!
                                              .notAllProducts),
                                    ));
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
                                          "assets/images/bulk_boxes_icon.png",
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
                                    ref.read(deleteAuthProvider).deleteAuth();
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const AuthPage()),
                                        (route) => false);
                                  }
                                });
                              }, AppLocalizations.of(context)!.cancelCaps,
                                  false),
                              Builder(builder: (context) {
                                return InkWell(
                                  onTap: () {
                                    Scaffold.of(context).openEndDrawer();
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
                          Text(
                            AppLocalizations.of(context)!.transferCaps,
                            style: const TextStyle(
                                fontSize: 24,
                                color: Color(0xFF909090),
                                height: 0.5),
                          ),
                          Text(
                            AppLocalizations.of(context)!.transferAssembly,
                            style: const TextStyle(
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
                  Expanded(
                    flex: 6,
                    child: getProductListWidget(widget.cartModels, width),
                  ),
                  const Center(child: VerticalDivider()),
                ],
              ),
            )));
  }

  Widget getProductListWidget(List<CartModel> data, double width) {
    bool isProductOpened = false;

    return Column(
      children: [
        Container(
          height: 56,
          decoration: const BoxDecoration(color: Colors.black),
          child: Row(
            children: [
              Expanded(
                flex: 1,
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
            ],
          ),
        ),
        Expanded(
            flex: 5,
            child: ListView(
              children: data.mapIndexed((index, e) {
                return InkWell(
                  onTap: () {
                    e.isSelected = !e.isSelected;
                    setState(() {});
                  },
                  child: Container(
                    height: 58,
                    decoration: BoxDecoration(
                        color: index % 2 == 0
                            ? const Color(0xFFF9F9F9)
                            : Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color: const Color(0xFFDFDFDF)),
                                    ),
                                    Container(
                                      width: 15,
                                      height: 15,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color: !e.isSelected
                                              ? const Color(0xFFD6D6D6)
                                              : const Color(0xFF5FFF95)),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                SizedBox(
                                  width: width / 2 - 18 - 20 - 20,
                                  child: Text(
                                    e.model.name,
                                    style: const TextStyle(
                                        fontSize: 16, color: Color(0xFF222222)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const VerticalDivider(),
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: width / 2 - 66,
                                  child: Text(
                                    e.quantity.toString(),
                                    style: const TextStyle(
                                        fontSize: 16, color: Color(0xFF222222)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                    onPressed: () async {
                                      final availability = await ref
                                          .read(getAvailabilityProvider)
                                          .getAvailability(e.model.id);
                                      if (availability.errorModel == null) {
                                        if (mounted) {
                                          if (!isProductOpened) {
                                            setState(() {
                                              isProductOpened = true;
                                            });
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProductInfoPage(
                                                          productId: e.model.id,
                                                          name: e.model.name,
                                                          photos:
                                                              e.model.fileNames,
                                                          sku: e
                                                              .model.vendorCode,
                                                          ean: e.model.eanCode,
                                                          count: e.model
                                                                  .quantity ??
                                                              0.0,
                                                          availabilityModel:
                                                              availability
                                                                  .availabilityModel!,
                                                          stockModel:
                                                              widget.stockModel,
                                                          isQr: true,
                                                        )));
                                          }
                                        } else {
                                          ref
                                              .read(deleteAuthProvider)
                                              .deleteAuth();
                                          Future.microtask(() =>
                                              Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const AuthPage()),
                                                  (route) => false));
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.info))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
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
