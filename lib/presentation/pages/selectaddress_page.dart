import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/data/models/currentstock_model.dart';
import 'package:mobile_app_slb/presentation/pages/transferassembly_page.dart';
import 'package:mobile_app_slb/presentation/states/transfer_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../data/models/shop_model.dart';
import '../../data/models/stock_model.dart';
import '../states/auth_state.dart';
import '../widgets/app_drawer_qr.dart';
import '../widgets/backButton.dart';
import '../widgets/exit_dialog.dart';
import 'auth_page.dart';

class SelectAddressPage extends ConsumerStatefulWidget {
  const SelectAddressPage(
      {super.key, required this.stockModel, required this.currentStock});

  final StockModel stockModel;
  final CurrentStockModel currentStock;

  @override
  ConsumerState<SelectAddressPage> createState() => _SelectAddressPageState();
}

class _SelectAddressPageState extends ConsumerState<SelectAddressPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController searchCont = TextEditingController();

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
          drawer: AppDrawerQr(
            stockModel: widget.stockModel,
          ),
          body: SafeArea(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40, right: 40, left: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
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
                            }, AppLocalizations.of(context)!.cancelCaps, false),
                            Builder(
                              builder: (context) {
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
                              }
                            ),
                          ],
                        ),
                      ),
                      const Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ADDRESS",
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Color(0xFF909090),
                                  height: 0.5),
                            ),
                            Text(
                              "Select address",
                              style: TextStyle(
                                  fontSize: 36,
                                  color: Color(0xFF363636),
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(
                height: 1,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 40, right: 40, top: 10, bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: SizedBox(
                        height: 40,
                        child: TextFormField(
                          controller: searchCont,
                          textCapitalization: TextCapitalization.words,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            fillColor: const Color(0xFFFCFCFC),
                            border: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Color(0xFFCFCFCF)),
                                borderRadius: BorderRadius.circular(5)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(5)),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF5F5F5F),
                            ),
                            hintText: AppLocalizations.of(context)!.search,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              ref
                                  .refresh(
                                      getAddressesProvider(searchCont.text))
                                  .value;
                              setState(() {

                              });
                            },
                            style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                elevation: 0,
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            child: const Icon(
                              Icons.search,
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 1,
              ),
              Expanded(
                flex: 5,
                child: ref.watch(getAddressesProvider(searchCont.text)).when(
                    data: (value) {
                      if (value.errorModel != null) {
                        ref.read(deleteAuthProvider).deleteAuth();
                        Future.microtask(() => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AuthPage()),
                            (route) => false));

                        return Container();
                      }
                      return addressListWidget(value.shopModels!);
                    },
                    error: (error, stacktrace) {
                      return AlertDialog(
                        title: Text(error.toString()),
                        actions: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Ok"))
                        ],
                      );
                    },
                    loading: () => const Center(
                          child: CircularProgressIndicator(),
                        )),
              ),
            ],
          ))),
    );
  }

  Widget addressListWidget(List<ShopModel> shopModels) {
    return ListView(
      shrinkWrap: true,
      children: shopModels
          .where((element) => element.id != widget.stockModel.id)
          .mapIndexed((index, e) => ListTile(
                title: Text(e.name),
                subtitle: Text(e.address),
                contentPadding: const EdgeInsets.only(left: 40, right: 40),
                tileColor:
                    index % 2 == 0 ? const Color(0xFFF6F6F6) : Colors.white,
                onTap: () async {
                  final data = await ref
                      .read(transferProvider)
                      .selectAddress(widget.currentStock.id, e.id);
                  if (data.errorModel == null) {
                    if (mounted) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              surfaceTintColor: Colors.transparent,
                              title: const Text(
                                  "Are you sure you want continue with selected store"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: const Text(
                                      "No",
                                      style: TextStyle(color: Colors.black),
                                    )),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: const Text(
                                      "Yes",
                                      style: TextStyle(color: Colors.green),
                                    ))
                              ],
                            );
                          }).then((returned) {
                        if (returned) {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TransferAssemblyPage(
                                        stockModel: widget.stockModel,
                                        transactionId: widget.currentStock.id,
                                        stockId: e.id,
                                        cartModels:
                                            widget.currentStock.cartModels,
                                      )),
                              (route) => false);
                        }
                      });
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(duration: Duration(seconds: 1),
                        content: Text("An error occured"),
                      ));
                    }
                  }
                },
              ))
          .toList(),
    );
  }

  List<ShopModel> searchObjectsByName(String query, List<ShopModel> models) {
    return models
        .where((obj) => obj.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
