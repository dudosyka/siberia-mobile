import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/data/repository/auth_repository.dart';
import 'package:mobile_app_slb/presentation/pages/selectaddress_page.dart';
import 'package:mobile_app_slb/presentation/states/home_state.dart';
import 'package:mobile_app_slb/presentation/widgets/black_button.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import '../states/auth_state.dart';
import '../states/transfer_state.dart';
import 'gettransfer_page.dart';
import 'home_page.dart';
import 'newsale_page.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  MobileScannerController cameraController =
      MobileScannerController(detectionSpeed: DetectionSpeed.normal);
  double _currentSliderValue = 0;
  bool isError = false;
  bool isLoading = false;
  bool isScanned = false;
  List<String> errorQrs = [];

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
            body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Center(
                    child: Image.asset(
                  "assets/images/logo.png",
                  scale: 4,
                )),
              ),
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MobileScanner(
                          fit: BoxFit.cover,
                          controller: cameraController,
                          placeholderBuilder: (context, widget) => const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                ),
                              ),
                          onDetect: (capture) async {
                            final List<Barcode> barcodes = capture.barcodes;
                            setState(() {
                              isLoading = true;
                            });
                            if(errorQrs.contains(barcodes[0].rawValue!)) {
                              setState(() {
                                isLoading = false;
                              });
                            }
                            if (!isScanned &&
                                !errorQrs.contains(barcodes[0].rawValue!)) {
                              setState(() {
                                isScanned = true;
                              });
                              AuthRepository()
                                  .loginUser(barcodes[0].rawValue!)
                                  .then((value) async {
                                if (value.errorModel == null &&
                                    value.authModel != null) {
                                  if (value.authModel!.type == "stock") {
                                    final data =
                                        await AuthRepository().getStock();
                                    if (data.stockModel != null) {
                                      if (data.stockModel!.salesManaging ||
                                          data.stockModel!.arrivalsManaging ||
                                          data.stockModel!.transfersManaging) {
                                        ref.refresh(getHomeProvider).value;
                                        Future.microtask(() =>
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (builder) =>
                                                        const HomePage()),
                                                (route) => false));
                                      } else {
                                        setState(() {
                                          isScanned = false;
                                        });
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            duration: Duration(seconds: 1),
                                            content: Text(
                                                "You don't have enough permissions"),
                                          ));
                                        }
                                        ref
                                            .read(deleteAuthProvider)
                                            .deleteAuth();
                                      }
                                    } else {
                                      setState(() {
                                        isError = true;
                                        isScanned = false;
                                      });
                                      errorQrs.add(barcodes[0].rawValue!);
                                      ref.read(deleteAuthProvider).deleteAuth();
                                    }
                                  } else if (value.authModel!.type ==
                                      "transaction") {
                                    final data =
                                        await AuthRepository().getStock();

                                    if (data.stockModel != null) {
                                      if (data.stockModel!.typeId == 3 &&
                                          data.stockModel!.statusId == 2 &&
                                          data.stockModel!
                                              .transfersProcessing) {
                                        final newData = await ref
                                            .read(transferProvider)
                                            .getCurrentStock();
                                        if (newData.errorModel == null) {
                                          Future.microtask(() =>
                                              Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (builder) =>
                                                          SelectAddressPage(
                                                            stockModel: data
                                                                .stockModel!,
                                                            currentStock: newData
                                                                .currentStock!,
                                                          )),
                                                  (route) => false));
                                        } else {
                                          setState(() {
                                            isError = true;
                                            isScanned = false;
                                          });
                                          errorQrs.add(barcodes[0].rawValue!);
                                          ref
                                              .read(deleteAuthProvider)
                                              .deleteAuth();
                                        }
                                      } else if (data.stockModel!.typeId == 3 &&
                                          data.stockModel!.statusId == 4 &&
                                          data.stockModel!.transfersManaging) {
                                        final newData = await ref
                                            .read(transferProvider)
                                            .getCurrentStock();
                                        if (newData.errorModel == null) {
                                          Future.microtask(() =>
                                              Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (builder) =>
                                                          GetTransferPage(
                                                            stockModel: data
                                                                .stockModel!,
                                                            cartModels: newData
                                                                .currentStock!
                                                                .cartModels,
                                                            transactionId: newData
                                                                .currentStock!
                                                                .id,
                                                            stockId: data
                                                                .stockModel!.id,
                                                          )),
                                                  (route) => false));
                                        } else {
                                          setState(() {
                                            isError = true;
                                            isScanned = false;
                                          });
                                          errorQrs.add(barcodes[0].rawValue!);
                                          ref
                                              .read(deleteAuthProvider)
                                              .deleteAuth();
                                        }
                                      } else if (data.stockModel!.typeId == 2 &&
                                          data.stockModel!.salesManaging) {
                                        Future.microtask(() =>
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (builder) =>
                                                        NewSalePage(
                                                          currentStorehouse:
                                                              data.stockModel!
                                                                  .name,
                                                          storehouseId: data
                                                              .stockModel!.id,
                                                          isTransaction: true,
                                                          stockModel:
                                                              data.stockModel!,
                                                        )),
                                                (route) => false));
                                      } else {
                                        setState(() {
                                          isScanned = false;
                                        });
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            duration: Duration(seconds: 1),
                                            content: Text(
                                                "You don't have enough permissions"),
                                          ));
                                        }
                                        ref
                                            .read(deleteAuthProvider)
                                            .deleteAuth();
                                      }
                                    } else {
                                      setState(() {
                                        isError = true;
                                        isScanned = false;
                                      });
                                      errorQrs.add(barcodes[0].rawValue!);
                                      ref.read(deleteAuthProvider).deleteAuth();
                                    }
                                  } else {
                                    setState(() {
                                      isError = true;
                                      isScanned = false;
                                    });
                                    errorQrs.add(barcodes[0].rawValue!);
                                    ref.read(deleteAuthProvider).deleteAuth();
                                  }
                                } else {
                                  setState(() {
                                    isError = true;
                                    isScanned = false;
                                  });
                                  errorQrs.add(barcodes[0].rawValue!);
                                  ref.read(deleteAuthProvider).deleteAuth();
                                }
                                setState(() {
                                  isLoading = false;
                                });
                              });
                            }
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
                      isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                              "Scan auth code",
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
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 50, right: 50),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "-",
                                style:
                                    TextStyle(fontSize: 40, color: Colors.grey),
                              ),
                              Expanded(
                                child: Slider(
                                  value: _currentSliderValue,
                                  min: 0,
                                  max: 1,
                                  activeColor: Colors.black,
                                  inactiveColor: Colors.grey,
                                  label: _currentSliderValue.round().toString(),
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
                      Padding(
                        padding: const EdgeInsets.only(left: 50, right: 50),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: blackButton(
                              null,
                              ValueListenableBuilder(
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
                                        "assets/images/torch_enabled_white_icon.png",
                                        scale: 4,
                                      );
                                  }
                                },
                              ), () {
                            cameraController.toggleTorch();
                          }),
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        )));
  }
}
