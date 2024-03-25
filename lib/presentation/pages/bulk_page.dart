import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app_slb/data/models/assembly_model.dart';
import 'package:mobile_app_slb/presentation/states/bulk_state.dart';
import '../states/auth_state.dart';
import '../widgets/app_drawer.dart';
import '../widgets/backButton.dart';
import '../widgets/exit_dialog.dart';
import 'auth_page.dart';
import 'bulklist_page.dart';
import 'home_page.dart';

class BulkPage extends ConsumerStatefulWidget {
  const BulkPage({super.key, required this.currentStorehouse});

  final String currentStorehouse;

  @override
  ConsumerState<BulkPage> createState() => _BulkPageState();
}

class _BulkPageState extends ConsumerState<BulkPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        drawer: const AppDrawer(
          isAbleToNavigate: false,
          isAssembly: false,
          isHomePage: false,
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
                      opacity:
                          ref.watch(bulkProvider).selectedAssemblies.isNotEmpty
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
                                          "Are you sure? You wouldn't be able to return");
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
                                                  )));
                                    }
                                  }
                                });
                              }
                            : () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Select at least one product"),
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
                                      borderRadius: BorderRadius.circular(50),
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
                      MaterialPageRoute(builder: (context) => const AuthPage()),
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
                                      ref.read(bulkProvider).deleteAssemblies();
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
                                InkWell(
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
                              ],
                            ),
                            const Spacer(),
                            const Text(
                              "BULK ASSEMBLY",
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Color(0xFF909090),
                                  height: 0.5),
                            ),
                            const Text(
                              "Operations",
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
                    Expanded(
                      flex: 6,
                      child: getProductListWidget(
                          Theme.of(context), value.assemblyModels!),
                    ),
                    const Center(child: VerticalDivider()),
                  ],
                );
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
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  )),
        ));
  }

  Widget getProductListWidget(ThemeData theme, List<AssemblyModel> data) {
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
              const Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    "DATE",
                    style: TextStyle(
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
                                const Text(
                                  "SALE",
                                  style: TextStyle(
                                      fontSize: 16, color: Color(0xFF222222)),
                                ),
                              ],
                            ),
                          ),
                          const VerticalDivider(),
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${tempDate.day.toString()}/${tempDate.month.toString()}/${tempDate.year.toString()}",
                                  style: const TextStyle(
                                      fontSize: 16, color: Color(0xFF222222)),
                                ),
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
}
