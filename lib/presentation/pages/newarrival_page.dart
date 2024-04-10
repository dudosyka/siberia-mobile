import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/data/models/cart_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_app_slb/data/models/stock_model.dart';
import 'package:mobile_app_slb/presentation/pages/arrivalcomplete_page.dart';
import 'package:mobile_app_slb/presentation/pages/productinfo_page.dart';
import 'package:mobile_app_slb/presentation/pages/scanbarcode_page.dart';
import 'package:mobile_app_slb/presentation/states/newarrival_state.dart';
import '../../data/models/productinfo_model.dart';
import '../states/assortment_state.dart';
import '../states/auth_state.dart';
import '../widgets/app_drawer.dart';
import '../widgets/backButton.dart';
import '../widgets/exit_dialog.dart';
import '../widgets/gray_button.dart';
import '../widgets/outlined_gray_button.dart';
import 'auth_page.dart';
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
    double width = MediaQuery
        .of(context)
        .size
        .width;

    return MediaQuery(
        data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery
                .of(context)
                .size
                .shortestSide > 650
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
                    children: [
                      const Expanded(
                        flex: 2,
                        child: Center(),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Opacity(
                            opacity: 1.0,
                            child: InkWell(
                              onTap:
                              ref
                                  .watch(newArrivalProvider)
                                  .cartData
                                  .isEmpty
                                  ? () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ScanBarcodePage(
                                              stockModel:
                                              widget.stockModel,
                                            )),
                                        (route) => false);
                              }
                                  : () async {
                                final data = await ref
                                    .read(newArrivalProvider)
                                    .setTransactionIncome(
                                    widget.stockModel.id);

                                if (data.errorModel == null) {
                                  ref.read(newArrivalProvider).deleteCart();
                                  if(context.mounted) {
                                    Navigator.pushAndRemoveUntil(context,
                                        MaterialPageRoute(builder: (context) =>
                                            const ArrivalCompletePage()), (
                                            route) => false);
                                  }
                                } else {
                                  if (context.mounted) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text(
                                                AppLocalizations.of(context)!.anErrorOccured),
                                            actions: [
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("Ok"))
                                            ],
                                          );
                                        });
                                  }
                                }
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 68,
                                      height: 68,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(50),
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
                                          child: ref
                                              .watch(newArrivalProvider)
                                              .cartData
                                              .isEmpty
                                              ? Image.asset(
                                            "assets/images/qr_scanner_icon.png",
                                            scale: 4,
                                          )
                                              : Image.asset(
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
                      ),
                      ref
                          .watch(newArrivalProvider)
                          .cartData
                          .isEmpty
                          ? const Expanded(flex: 2, child: Center())
                          : Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ScanBarcodePage(
                                          stockModel: widget.stockModel,
                                        )),
                                    (route) => false);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/dark_scan_icon.png",
                                scale: 4,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppLocalizations.of(context)!.scan,
                                style: const TextStyle(fontSize: 12),
                              )
                            ],
                          ),
                        ),
                      )
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
                                    ref.read(newArrivalProvider).deleteCart();
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
                          Text(
                            AppLocalizations.of(context)!.newArrivalCaps,
                            style: const TextStyle(
                                fontSize: 24,
                                color: Color(0xFF909090),
                                height: 0.5),
                          ),
                          Text(
                            AppLocalizations.of(context)!.arrivalList,
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
                  ref
                      .watch(newArrivalProvider)
                      .cartData
                      .isEmpty
                      ? Expanded(
                    flex: 6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/new_arrival_list_icon.png",
                            scale: 4,
                          ),
                          const SizedBox(height: 12),
                          Text(AppLocalizations.of(context)!.noItemsYetCaps,
                              style: const TextStyle(
                                  color: Color(0xFF888888),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20)),
                          Text(AppLocalizations.of(context)!.startWith,
                              style: TextStyle(
                                  color: Color(0xFF888888),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20)),
                        ],
                      ),
                    ),
                  )
                      : Expanded(
                    flex: 6,
                    child: getProductListWidget(
                        ref
                            .watch(newArrivalProvider)
                            .cartData, width),
                  ),
                  const Center(child: VerticalDivider()),
                ],
              ),
            )));
  }

  Widget getProductListWidget(List<CartModel> data, double width) {
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
                return InkWell(
                  onTap: () async {
                    final productInfo = await ref
                        .read(newArrivalProvider)
                        .getProductInfo(e.model.id);
                    if (productInfo.errorModel == null) {
                      if (mounted) {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                editCartModal(e, productInfo.productModel!));
                      }
                    } else {
                      if (mounted) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(
                                    AppLocalizations.of(context)!.anErrorOccured),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Ok"))
                                ],
                              );
                            });
                      }
                    }
                  },
                  child: Container(
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
                            child: SizedBox(
                              width: 2 * width / 5,
                              child: Text(
                                e.model.name,
                                style: const TextStyle(
                                    fontSize: 16, color: Color(0xFF222222)),
                                overflow: TextOverflow.ellipsis,
                              ),
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
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const VerticalDivider(),
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: width / 6 - 22,
                                child: Text(
                                  e.curPrice.toString(),
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
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProductInfoPage(
                                                      productId: e.model.id,
                                                      name: e.model.name,
                                                      photos: e.model.fileNames,
                                                      sku: e.model.vendorCode,
                                                      ean: e.model.eanCode,
                                                      count: e.model.quantity ??
                                                          0.0,
                                                      availabilityModel:
                                                      availability
                                                          .availabilityModel!,
                                                      stockModel:
                                                      widget.stockModel,
                                                      isQr: false,
                                                    )));
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
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }

  Widget editCartModal(CartModel data, ProductInfoModel productInfo) {
    final TextEditingController quantityCont =
    TextEditingController(text: data.quantity.toString());
    final TextEditingController priceCont =
    TextEditingController(text: data.curPrice.toString());

    final pricesData = {
      "Distribution": productInfo.distributionPrice,
      "Professional": productInfo.professionalPrice,
      "Oferta": productInfo.offertaPrice,
      "Other": data.curPrice
    };
    String curPrice = data.priceType.keys.first.toString();

    return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(6),
        title: Row(
          children: [
            SizedBox(
              width: MediaQuery
                  .of(context)
                  .size
                  .shortestSide > 650 ? 400 : 200,
              child: Text(
                AppLocalizations.of(context)!.cartItemEditCaps,
                style:
                const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(
              width: 18,
            ),
            InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) =>
                        AlertDialog(
                          backgroundColor: Colors.white,
                          surfaceTintColor: Colors.transparent,
                          title: Text(
                            AppLocalizations.of(context)!.deletionCaps,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF151515)),
                          ),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                data.model.name,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Divider(),
                              Text(
                                "${AppLocalizations.of(context)!
                                    .sureDelete} ${data.model.name}?",
                                style: const TextStyle(
                                    fontSize: 16, color: Color(0xFF3A3A3A)),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  outlinedGrayButton(() {
                                    Navigator.pop(context, false);
                                  }, AppLocalizations.of(context)!.cancelCaps),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      ref
                                          .read(newArrivalProvider)
                                          .deleteFromCart(data);
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFFF5F5F),
                                            borderRadius:
                                            BorderRadius.circular(4)),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                              top: 4,
                                              bottom: 4),
                                          child: Center(
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .deleteCaps,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        )),
                                  )
                                ],
                              )
                            ],
                          ),
                        )).then((value) {
                  Navigator.pop(context);
                  setState(() {});
                });
              },
              child: Container(
                  decoration: BoxDecoration(
                      color: const Color(0xFFFF5F5F),
                      borderRadius: BorderRadius.circular(4)),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 4, bottom: 4),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.deleteCaps,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )),
            )
          ],
        ),
        content: StatefulBuilder(builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${AppLocalizations.of(context)!.product} \"${data.model
                      .name}\"",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222222)),
                ),
                const Divider(),
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)!.quantityCaps,
                        style: const TextStyle(
                            fontSize: 16, color: Color(0xFF3A3A3A)),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              if (quantityCont.text != "" &&
                                  int.parse(quantityCont.text) > 1) {
                                quantityCont.text =
                                    (int.parse(quantityCont.text) - 1)
                                        .toString();
                              }
                              setState(() {});
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: const Color(0xFF3C3C3C),
                                  borderRadius: BorderRadius.circular(6)),
                              child: const Center(
                                  child: Text(
                                    "-",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                        height: 1,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          SizedBox(
                            height: 40,
                            width: 100,
                            child: TextFormField(
                              controller: quantityCont,
                              cursorColor: Colors.black,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w300),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                fillColor: const Color(0xFFFCFCFC),
                                border: const OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Color(0xFFC8C8C8)),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(6))),
                                disabledBorder: const OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Color(0xFFC8C8C8)),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(6))),
                                enabledBorder: const OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Color(0xFFC8C8C8)),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(6))),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(6))),
                                hintText:
                                AppLocalizations.of(context)!.countCaps,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          InkWell(
                            onTap: () {
                              if (quantityCont.text == "") {
                                quantityCont.text = "1";
                              } else {
                                quantityCont.text =
                                    (int.parse(quantityCont.text) + 1)
                                        .toString();
                              }
                              setState(() {});
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: const Color(0xFF3C3C3C),
                                  borderRadius: BorderRadius.circular(6)),
                              child: const Center(
                                  child: Text(
                                    "+",
                                    style: TextStyle(
                                        color: Colors.white,
                                        height: 1,
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)!.priceCaps,
                        style: const TextStyle(
                            fontSize: 16, color: Color(0xFF3A3A3A)),
                      ),
                      const SizedBox(height: 10),
                      DropdownButton(
                        value: curPrice,
                        items: [
                          DropdownMenuItem(
                            value: "Distribution",
                            child: Text(AppLocalizations.of(context)!.distribution),
                          ),
                          DropdownMenuItem(
                            value: "Professional",
                            child: Text(AppLocalizations.of(context)!.professional),
                          ),
                          DropdownMenuItem(
                            value: "Oferta",
                            enabled: productInfo.offertaPrice != 0.0,
                            child: Text(
                              AppLocalizations.of(context)!.oferta,
                              style: TextStyle(
                                  color: productInfo.offertaPrice != 0.0
                                      ? Colors.black
                                      : const Color(0xFF969696)),
                            ),
                          ),
                          DropdownMenuItem(
                            value: "Other",
                            child: Text(AppLocalizations.of(context)!.other),
                          ),
                        ],
                        onChanged: (Object? value) {
                          setState(() {
                            curPrice = value.toString();
                          });
                        },
                      ),
                      curPrice == "Other"
                          ? SizedBox(
                        height: 40,
                        width: 195,
                        child: TextFormField(
                          controller: priceCont,
                          cursorColor: Colors.black,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w300),
                          onChanged: (value) {
                            pricesData["Other"] = double.parse(value);
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            fillColor: const Color(0xFFFCFCFC),
                            border: const OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Color(0xFFC8C8C8)),
                                borderRadius:
                                BorderRadius.all(Radius.circular(6))),
                            disabledBorder: const OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Color(0xFFC8C8C8)),
                                borderRadius:
                                BorderRadius.all(Radius.circular(6))),
                            enabledBorder: const OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Color(0xFFC8C8C8)),
                                borderRadius:
                                BorderRadius.all(Radius.circular(6))),
                            focusedBorder: const OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.black),
                                borderRadius:
                                BorderRadius.all(Radius.circular(6))),
                            hintText:
                            AppLocalizations.of(context)!.priceCaps,
                          ),
                        ),
                      )
                          : Container(
                        width: 195,
                        height: 40,
                        decoration: BoxDecoration(
                            color: const Color(0xFFFCFCFC),
                            border: Border.all(
                                color: const Color(0xFFC8C8C8)),
                            borderRadius: BorderRadius.circular(6)),
                        child: Center(
                          child: Text(pricesData[curPrice].toString(),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w300)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          outlinedGrayButton(() {
                            Navigator.pop(context, false);
                          }, AppLocalizations.of(context)!.cancelCaps),
                          const SizedBox(
                            width: 18,
                          ),
                          grayButton(() {
                            data.priceType = {curPrice: pricesData[curPrice]};
                            data.curPrice = pricesData[curPrice]!;
                            ref.read(newArrivalProvider).updateCartModel(
                                data, false, int.parse(quantityCont.text));
                            Navigator.pop(context, true);
                          }, AppLocalizations.of(context)!.saveCaps),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        }));
  }
}
