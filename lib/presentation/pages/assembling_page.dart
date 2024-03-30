import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/presentation/pages/salecomplete_page.dart';
import 'package:mobile_app_slb/presentation/states/newsale_state.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/stock_model.dart';
import '../states/auth_state.dart';
import '../widgets/app_drawer.dart';
import '../widgets/backButton.dart';
import '../widgets/exit_dialog.dart';
import '../widgets/gray_button.dart';
import '../widgets/outlined_gray_button.dart';
import 'auth_page.dart';
import 'home_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AssemblingPage extends ConsumerStatefulWidget {
  const AssemblingPage(
      {super.key,
      required this.transactionId,
      required this.cartData,
      required this.isTransaction, required this.stockModel});

  final int transactionId;
  final List<CartModel> cartData;
  final bool isTransaction;
  final StockModel stockModel;

  @override
  ConsumerState<AssemblingPage> createState() => _AssemblingPageState();
}

class _AssemblingPageState extends ConsumerState<AssemblingPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isAllSelected = allSelected(widget.cartData);

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
              ref.read(cartDataProvider).deleteCart();
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
              isAssembly: true,
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
                          opacity: isAllSelected ? 1.0 : 0.2,
                          child: InkWell(
                            onTap: isAllSelected
                                ? () {
                                    showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              backgroundColor: Colors.white,
                                              surfaceTintColor:
                                                  Colors.transparent,
                                              content: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .wouldAddress,
                                                    style: const TextStyle(
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 10),
                                                  const Divider(),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      outlinedGrayButton(() {
                                                        showDialog(
                                                            context: context,
                                                            builder: (context) =>
                                                                addressModal());
                                                      },
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .addAddressCaps),
                                                      const SizedBox(
                                                        width: 18,
                                                      ),
                                                      grayButton(() {
                                                        ref
                                                            .read(
                                                                cartDataProvider)
                                                            .approveAssembly();
                                                        Navigator
                                                            .pushAndRemoveUntil(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            SaleCompletePage(
                                                                              isTransaction: widget.isTransaction,
                                                                            )),
                                                                (route) =>
                                                                    false);
                                                      },
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .endSaleCaps),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ));
                                  }
                                : () {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
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
                                          "assets/images/approve_assembly_icon.png",
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
                                  //ref.read(cartDataProvider).deleteAssembly(widget.transactionId);
                                  if (widget.isTransaction) {
                                    ref.read(deleteAuthProvider).deleteAuth();
                                    Future.microtask(() =>
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const AuthPage()),
                                            (route) => false));
                                  } else {
                                    ref.read(cartDataProvider).deleteCart();
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const HomePage()),
                                        (route) => false);
                                  }
                                }
                              });
                            }, AppLocalizations.of(context)!.cancelCaps, false),
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
                        Text(
                          AppLocalizations.of(context)!.cartCaps,
                          style: const TextStyle(
                              fontSize: 24,
                              color: Color(0xFF909090),
                              height: 0.5),
                        ),
                        Text(
                          AppLocalizations.of(context)!.assemblingCaps,
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
                  child:
                      getProductListWidget(Theme.of(context), widget.cartData),
                ),
                const Center(child: VerticalDivider())
              ],
            )),
          ),
        ));
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
                                Text(
                                  e.model.name,
                                  style: const TextStyle(
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
                                  e.quantity.toString(),
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

  bool allSelected(List<CartModel> cartList) {
    for (var cartItem in cartList) {
      if (!cartItem.isSelected) {
        return false;
      }
    }
    return true;
  }

  Widget addressModal() {
    final TextEditingController zipCont = TextEditingController();
    final TextEditingController cityCont = TextEditingController();
    final TextEditingController regionCont = TextEditingController();
    final TextEditingController addressCont = TextEditingController();
    final TextEditingController personCont = TextEditingController();

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      content: SingleChildScrollView(
        padding: MediaQuery.of(context).viewInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.addAddressInfo,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.zipCode,
                  style:
                      const TextStyle(fontSize: 16, color: Color(0xFF3A3A3A)),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  width: 290,
                  child: TextFormField(
                    controller: zipCont,
                    cursorColor: Colors.black,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      fillColor: Color(0xFFFCFCFC),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFC8C8C8)),
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFC8C8C8)),
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFC8C8C8)),
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.city,
                  style:
                      const TextStyle(fontSize: 16, color: Color(0xFF3A3A3A)),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  width: 290,
                  child: TextFormField(
                    controller: cityCont,
                    cursorColor: Colors.black,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      fillColor: Color(0xFFFCFCFC),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFC8C8C8)),
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFC8C8C8)),
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFC8C8C8)),
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.region,
                  style:
                      const TextStyle(fontSize: 16, color: Color(0xFF3A3A3A)),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  width: 290,
                  child: TextFormField(
                    controller: regionCont,
                    cursorColor: Colors.black,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      fillColor: Color(0xFFFCFCFC),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFC8C8C8)),
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFC8C8C8)),
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFC8C8C8)),
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.address,
                  style:
                      const TextStyle(fontSize: 16, color: Color(0xFF3A3A3A)),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  width: 290,
                  child: TextFormField(
                    controller: addressCont,
                    cursorColor: Colors.black,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      fillColor: Color(0xFFFCFCFC),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFC8C8C8)),
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFC8C8C8)),
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFC8C8C8)),
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.person,
                  style:
                      const TextStyle(fontSize: 16, color: Color(0xFF3A3A3A)),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  width: 290,
                  child: TextFormField(
                    controller: personCont,
                    cursorColor: Colors.black,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      fillColor: Color(0xFFFCFCFC),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFC8C8C8)),
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFC8C8C8)),
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFC8C8C8)),
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                outlinedGrayButton(() {
                  Navigator.pop(context, false);
                }, AppLocalizations.of(context)!.backCaps),
                const SizedBox(
                  width: 18,
                ),
                grayButton(() {
                  ref.read(cartDataProvider).approveAssembly();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SaleCompletePage(
                                isTransaction: widget.isTransaction,
                              )),
                      (route) => false);
                }, AppLocalizations.of(context)!.endSaleCaps),
              ],
            )
          ],
        ),
      ),
    );
  }
}
