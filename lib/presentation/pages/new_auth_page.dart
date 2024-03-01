import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/presentation/widgets/black_button.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';

import '../states/auth_state.dart';
import 'home_page.dart';

class NewAuthPage extends ConsumerStatefulWidget {
  const NewAuthPage({super.key});

  @override
  ConsumerState<NewAuthPage> createState() => _NewAuthPageState();
}

class _NewAuthPageState extends ConsumerState<NewAuthPage> {
  MobileScannerController cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 500);
  double _currentSliderValue = 0;
  bool isError = false;

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
    return Scaffold(
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
                      fit: BoxFit.contain,
                      controller: cameraController,
                      placeholderBuilder: (context, widget) =>
                          const CircularProgressIndicator(
                            color: Colors.black,
                          ),
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        ref.watch(authProvider(barcodes[0].rawValue!)).when(
                            data: (value) {
                          if (value.errorModel == null &&
                              value.authModel != null) {
                            Future.microtask(() => Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => const HomePage()),
                                (route) => false));
                            return Container();
                          } else {
                            setState(() {
                              isError = true;
                            });
                            return Container();
                          }
                        }, error: (error, stacktrace) {
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
                        }, loading: () {
                          return Column(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Center(
                                    child: Image.asset(
                                  "assets/images/logo.png",
                                  scale: 4,
                                )),
                              ),
                              const Expanded(
                                flex: 3,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      color: Colors.black,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
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
                  isError
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "-",
                          style: TextStyle(fontSize: 40, color: Colors.grey),
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
                              cameraController.setZoomScale(value);
                              setState(() {
                                _currentSliderValue = value;
                              });
                            },
                          ),
                        ),
                        const Text("+",
                            style: TextStyle(fontSize: 40, color: Colors.grey))
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    child: blackButton(
                        null,
                        ValueListenableBuilder(
                          valueListenable: cameraController.torchState,
                          builder: (context, state, child) {
                            switch (state) {
                              case TorchState.off:
                                return const Icon(Icons.flash_off,
                                    color: Colors.grey);
                              case TorchState.on:
                                return const Icon(Icons.flash_on,
                                    color: Colors.white);
                            }
                          },
                        ), () {
                      cameraController.toggleTorch();
                    }),
                  ),
                ],
              ))
        ],
      ),
    ));
  }
}
