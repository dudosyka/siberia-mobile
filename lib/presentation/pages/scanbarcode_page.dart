import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../data/models/stock_model.dart';
import '../widgets/app_drawer.dart';
import '../widgets/backButton.dart';
import '../widgets/exit_dialog.dart';
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
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
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.menu,
                            size: 32,
                          ))
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
                                Image.asset(
                                  "assets/images/logo.png",
                                  scale: 4,
                                )
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
                    flex: 5,
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
                                      final List<Barcode> barcodes = capture.barcodes;
                                      setState(() {
                                        isLoading = true;
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
                                padding: const EdgeInsets.only(left: 50, right: 50),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 320),
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
                                              cameraController.setZoomScale(value);
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
                                  : const Text(
                                "Scan product code",
                                style: TextStyle(fontSize: 17),
                              ),
                              isError && !isLoading
                                  ? const Padding(
                                padding: EdgeInsets.only(left: 50, right: 50),
                                child: Text(
                                  "Something went wrong. Try to re-scan again",
                                  style: TextStyle(
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
}
