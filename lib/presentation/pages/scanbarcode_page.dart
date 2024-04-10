import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/presentation/pages/newarrival_page.dart';
import 'package:mobile_app_slb/presentation/states/newarrival_state.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../data/models/assortment_model.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/productinfo_model.dart';
import '../../data/models/stock_model.dart';
import '../../domain/usecases/productinfo_usecase.dart';
import '../widgets/app_drawer.dart';
import '../widgets/backButton.dart';
import '../widgets/exit_dialog.dart';
import '../widgets/gray_button.dart';
import '../widgets/outlined_gray_button.dart';
import 'home_page.dart';

class ScanBarcodePage extends ConsumerStatefulWidget {
  const ScanBarcodePage({super.key, required this.stockModel});

  final StockModel stockModel;

  @override
  ConsumerState<ScanBarcodePage> createState() => _ScanBarcodePageState();
}

class _ScanBarcodePageState extends ConsumerState<ScanBarcodePage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  MobileScannerController cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates, detectionTimeoutMs: 250);
  double _currentSliderValue = 0;
  bool isError = false;
  bool isLoading = false;

  @override
  void initState() {
    cameraController.stop();
    super.initState();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

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
              child: SizedBox(
                  height: 80,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: SizedBox(
                            height: 40,
                            width: 40,
                            child: IconButton(
                                onPressed: () {
                                  cameraController.toggleTorch();
                                },
                                icon: ValueListenableBuilder(
                                  valueListenable: cameraController.torchState,
                                  builder: (context, state, child) {
                                    switch (state) {
                                      case TorchState.off:
                                        return Image.asset(
                                          "assets/images/torch_disabled_icon.png",
                                          scale: 4,
                                        );
                                      case TorchState.on:
                                        return Image.asset(
                                          "assets/images/torch_enabled_icon.png",
                                          scale: 4,
                                        );
                                    }
                                  },
                                )),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return exitDialog(context,
                                                AppLocalizations.of(context)!.areYouSureReturn);
                                          }).then((returned) {
                                        if (returned) {
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      NewArrivalPage(
                                                          stockModel: widget
                                                              .stockModel)),
                                              (route) => false);
                                        }
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.menu,
                                      size: 32,
                                      color: Color(0xFF505050),
                                    )),
                                ref.watch(newArrivalProvider).cartData.isEmpty
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: const Color(0xFFD9D9D9)),
                                            child: Center(
                                              child: Text(
                                                  ref
                                                      .watch(newArrivalProvider)
                                                      .cartData
                                                      .length
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14)),
                                            ),
                                          ),
                                        ),
                                      )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  )),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 40, right: 40, left: 40, bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
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
                                    false)
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Builder(builder: (context) {
                              return Row(
                                children: [
                                  const Spacer(),
                                  InkWell(
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
                                  ),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: MobileScanner(
                                    fit: BoxFit.cover,
                                    controller: cameraController,
                                    placeholderBuilder: (context, widget) =>
                                        const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.black,
                                          ),
                                        ),
                                    onDetect: (capture) async {
                                      final List<Barcode> barcodes =
                                          capture.barcodes;

                                      setState(() {
                                        isLoading = true;
                                      });

                                      ref
                                          .read(newArrivalProvider)
                                          .getProductBarcode(
                                              barcodes.last.rawValue!)
                                          .then((value) {
                                        cameraController.stop();
                                        if (value.errorModel != null) {
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
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child:
                                                              const Text("Ok"))
                                                    ],
                                                  );
                                                }).then((value) async {
                                              await Future.delayed(
                                                  const Duration(
                                                      milliseconds: 500));
                                              cameraController.start();
                                            });
                                          }
                                        } else {
                                          if (value
                                              .arrivalProductModels!.isEmpty) {
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
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: const Text(
                                                                "Ok"))
                                                      ],
                                                    );
                                                  }).then((value) async {
                                                await Future.delayed(
                                                    const Duration(
                                                        milliseconds: 500));
                                                cameraController.start();
                                              });
                                            }
                                          } else {
                                            if (context.mounted) {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      backgroundColor:
                                                          Colors.white,
                                                      surfaceTintColor:
                                                          Colors.transparent,
                                                      title: Text(
                                                        AppLocalizations.of(context)!.selectProduct,
                                                        style: const TextStyle(
                                                            fontSize: 24,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      content: SizedBox(
                                                        width: double.maxFinite,
                                                        height: 300,
                                                        child: ListView(
                                                          shrinkWrap: true,
                                                          children: value
                                                              .arrivalProductModels!
                                                              .mapIndexed(
                                                                  (index, e) =>
                                                                      ListTile(
                                                                        title: Text(
                                                                            e.name),
                                                                        tileColor: index % 2 !=
                                                                                0
                                                                            ? const Color(0xFFF6F6F6)
                                                                            : Colors.white,
                                                                        onTap:
                                                                            () async {
                                                                          final productData = await ref
                                                                              .read(newArrivalProvider)
                                                                              .getProductInfo(e.id);

                                                                          if (context
                                                                              .mounted) {
                                                                            Navigator.pop(context,
                                                                                productData);
                                                                          }
                                                                        },
                                                                      ))
                                                              .toList(),
                                                        ),
                                                      ),
                                                    );
                                                  }).then((value) async {
                                                if (value != null) {
                                                  if (value
                                                      is ProductInfoUseCase) {
                                                    if (value.errorModel ==
                                                        null) {
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return addToCartModal(
                                                                value
                                                                    .productModel!);
                                                          }).then((value) async {
                                                        await Future.delayed(
                                                            const Duration(
                                                                milliseconds:
                                                                    500));
                                                        cameraController
                                                            .start();
                                                      });
                                                    } else {
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  AppLocalizations.of(context)!.anErrorOccured),
                                                              actions: [
                                                                ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                            "Ok"))
                                                              ],
                                                            );
                                                          }).then((value) async {
                                                        await Future.delayed(
                                                            const Duration(
                                                                milliseconds:
                                                                    500));
                                                        cameraController
                                                            .start();
                                                      });
                                                    }
                                                  } else {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            title: Text(
                                                                AppLocalizations.of(context)!.anErrorOccured),
                                                            actions: [
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                          "Ok"))
                                                            ],
                                                          );
                                                        }).then((value) async {
                                                      await Future.delayed(
                                                          const Duration(
                                                              milliseconds:
                                                                  500));
                                                      cameraController.start();
                                                    });
                                                  }
                                                } else {
                                                  await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 500));
                                                  cameraController.start();
                                                }
                                              });
                                            }
                                          }
                                        }
                                      });

                                      setState(() {
                                        isLoading = false;
                                      });
                                    }),
                              ),
                              QRScannerOverlay(
                                overlayColor: Colors.white,
                                borderColor: Colors.black,
                                scanAreaHeight: 320,
                                scanAreaWidth: 320,
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 50, right: 50),
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 320),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "-",
                                        style: TextStyle(
                                            fontSize: 40, color: Colors.grey),
                                      ),
                                      Expanded(
                                        child: Slider(
                                          value: _currentSliderValue,
                                          min: 0,
                                          max: 1,
                                          activeColor: Colors.black,
                                          inactiveColor: Colors.grey,
                                          label: _currentSliderValue
                                              .round()
                                              .toString(),
                                          onChanged: (double value) {
                                            if (value < 0.1) {
                                              cameraController.resetZoomScale();
                                            } else {
                                              cameraController
                                                  .setZoomScale(value);
                                            }
                                            setState(() {
                                              _currentSliderValue = value;
                                            });
                                          },
                                        ),
                                      ),
                                      const Text("+",
                                          style: TextStyle(
                                              fontSize: 40, color: Colors.grey))
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                      ),
                                    )
                                  : Text(
                                AppLocalizations.of(context)!.scanProduct,
                                      style: TextStyle(fontSize: 17),
                                    ),
                              isError && !isLoading
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(left: 50, right: 50),
                                      child: Text(
                                        AppLocalizations.of(context)!.reScan,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 17,
                                            color: Color(0xFFFF0000)),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }

  Widget addToCartModal(ProductInfoModel productInfo) {
    final TextEditingController quantityCont = TextEditingController();
    final TextEditingController priceCont = TextEditingController();
    final pricesData = {
      "Distribution": productInfo.distributionPrice,
      "Professional": productInfo.professionalPrice,
      "Oferta": productInfo.offertaPrice,
      "Other": 0.0
    };
    String curPrice = "Distribution";

    return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          AppLocalizations.of(context)!.cartItemEditCaps,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        content: StatefulBuilder(builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${AppLocalizations.of(context)!.product} \"${productInfo.name}\"",
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
                            child: Text(AppLocalizations.of(context)!.oferta,
                                style: TextStyle(
                                  color: productInfo.offertaPrice != 0.0
                                      ? Colors.black
                                      : const Color(0xFF969696),
                                )),
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
                            ref.read(newArrivalProvider).addToCart(CartModel(
                                AssortmentModel(
                                    productInfo.id,
                                    productInfo.name,
                                    productInfo.vendorCode,
                                    productInfo.professionalPrice,
                                    productInfo.photos,
                                    productInfo.eanCode,
                                    productInfo.quantity),
                                int.parse(quantityCont.text),
                                {curPrice: pricesData[curPrice]!},
                                pricesData[curPrice]!));
                            Navigator.pop(context);
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
