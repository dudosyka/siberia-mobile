import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app_slb/data/models/assembly_model.dart';
import 'package:mobile_app_slb/data/models/stock_model.dart';
import 'package:mobile_app_slb/presentation/states/bulk_state.dart';
import '../states/auth_state.dart';
import '../widgets/app_drawer.dart';
import '../widgets/backButton.dart';
import '../widgets/exit_dialog.dart';
import 'auth_page.dart';
import 'bulklist_page.dart';
import 'home_page.dart';
import 'dart:io' show Platform;

class BulkPage extends ConsumerStatefulWidget {
  const BulkPage(
      {super.key, required this.currentStorehouse, required this.stockModel});

  final String currentStorehouse;
  final StockModel stockModel;

  @override
  ConsumerState<BulkPage> createState() => _BulkPageState();
}

class _BulkPageState extends ConsumerState<BulkPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  bool isAscendingDate = true;
  bool isTappedDate = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        final navigator = Navigator.of(context);

        showDialog(
            context: context,
            builder: (context) {
              return exitDialog(
                  context, AppLocalizations.of(context)!.areYouSure);
            }).then((returned) {
          if (returned) {
            ref.read(bulkProvider).deleteAssemblies();
            navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false);
          }
        });
      },
      child: MediaQuery(
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
                            opacity: ref
                                    .watch(bulkProvider)
                                    .selectedAssemblies
                                    .isNotEmpty
                                ? 1.0
                                : 0.2,
                            child: InkWell(
                              onTap: ref
                                      .watch(bulkProvider)
                                      .selectedAssemblies
                                      .isNotEmpty
                                  ? () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return exitDialog(context,
                                                AppLocalizations.of(context)!.areYouSureReturn);
                                          }).then((returned) async {
                                        if (returned) {
                                          final ids = ref
                                              .watch(bulkProvider)
                                              .selectedAssemblies
                                              .map((e) => e.id)
                                              .toList();
                                          final data = await ref
                                              .read(bulkProvider)
                                              .getBulkList();
                                          if (context.mounted) {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        BulkListPage(
                                                          currentStorehouse: widget
                                                              .currentStorehouse,
                                                          cartModels: data,
                                                          ids: ids,
                                                          stockModel:
                                                              widget.stockModel,
                                                        )));
                                          }
                                        }
                                      });
                                    }
                                  : () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        duration: const Duration(seconds: 1),
                                        content:
                                            Text(AppLocalizations.of(context)!.selectAtList),
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
                child: ref.watch(getBulkProvider).when(
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
                      return Column(
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                            ref
                                                .read(bulkProvider)
                                                .deleteAssemblies();
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
                                                borderRadius:
                                                    BorderRadius.circular(5)),
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
                                    AppLocalizations.of(context)!.bulkAssemblyCaps,
                                    style: const TextStyle(
                                        fontSize: 24,
                                        color: Color(0xFF909090),
                                        height: 0.5),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.operations,
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
                            child: getProductListWidget(
                                value.assemblyModels!, width),
                          ),
                          const Center(child: VerticalDivider()),
                        ],
                      );
                    },
                    error: (error, stacktrace) {
                      if (Platform.isAndroid) {
                        return AlertDialog(
                          title: Text(error.toString()),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  //Navigator.pop(context);
                                  SystemChannels.platform
                                      .invokeMethod('SystemNavigator.pop');
                                },
                                child: const Text("Ok"))
                          ],
                        );
                      } else {
                        return AlertDialog(
                          title: Text(
                            AppLocalizations.of(context)!.smtWentWrongReload,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                    },
                    loading: () => const Center(
                          child: CircularProgressIndicator(
                            color: Colors.black,
                          ),
                        )),
              ))),
    );
  }

  Widget getProductListWidget(List<AssemblyModel> data, double width) {
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          isTappedDate = true;
                          data.sort((prod1, prod2) => compareString(
                              isAscendingDate,
                              prod1.timestamp,
                              prod2.timestamp));
                          isAscendingDate = !isAscendingDate;
                        });
                      },
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.dateCaps,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontSize: 16),
                        ),
                      ),
                    ),
                    isTappedDate
                        ? isAscendingDate
                            ? const Icon(
                                Icons.arrow_downward,
                                color: Colors.white,
                                size: 16,
                              )
                            : const Icon(
                                Icons.arrow_upward,
                                color: Colors.white,
                                size: 16,
                              )
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
            flex: 5,
            child: ListView(
              children: data.mapIndexed((index, e) {
                DateTime tempDate =
                    DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").parse(e.timestamp);

                return InkWell(
                  onTap: () {
                    e.isSelected = !e.isSelected;
                    if (e.isSelected) {
                      ref.read(bulkProvider).addToList(e);
                    } else {
                      ref.read(bulkProvider).removeFromList(e);
                    }
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
                                  width: width / 2 - 20 - 18 - 20,
                                  child: Text(
                                    AppLocalizations.of(context)!.saleCaps,
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
                            child: SizedBox(
                              width: width / 2 - 20,
                              child: Center(
                                child: Text(
                                  "${tempDate.day.toString()}/${tempDate.month.toString()}/${tempDate.year.toString()}",
                                  style: const TextStyle(
                                      fontSize: 16, color: Color(0xFF222222)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
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

  int compareString(bool ascending, String value1, String value2) =>
      ascending ? value1.compareTo(value2) : value2.compareTo(value1);
}
