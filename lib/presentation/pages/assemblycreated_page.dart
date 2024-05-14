import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/presentation/pages/auth_page.dart';
import '../states/auth_state.dart';
import 'home_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AssemblyCreatedPage extends ConsumerStatefulWidget {
  const AssemblyCreatedPage({super.key, required this.isQr});

  final bool isQr;

  @override
  ConsumerState<AssemblyCreatedPage> createState() => _AssemblyCreatedPageState();
}

class _AssemblyCreatedPageState extends ConsumerState<AssemblyCreatedPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 5), () {
      if (widget.isQr) {
        Future.microtask(() => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const AuthPage())));
      } else {
        Future.microtask(() => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomePage())));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
                  flex: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Center(
                              child: Container(
                                width: 194,
                                height: 194,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: const Color(0xFFDFDFDF)),
                              ),
                            ),
                            Center(
                              child: Container(
                                  width: 186,
                                  height: 186,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: Colors.black),
                                  child: Center(
                                    child: Image.asset(
                                      "assets/images/sale_complete_icon.png",
                                      scale: 4,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 36),
                        Text(
                          AppLocalizations.of(context)!.saleCreatedScreen,
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF424242)),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          widget.isQr
                              ? AppLocalizations.of(context)!.youWillGetAuth
                              : AppLocalizations.of(context)!.youWillGetBack,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Color(0xFFAAAAAA)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: InkWell(
                      onTap: () {
                        if (widget.isQr) {
                          ref.read(deleteAuthProvider).deleteAuth();
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AuthPage()),
                                  (route) => false);
                        } else {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomePage()));
                        }
                      },
                      child: Container(
                          width: 192,
                          height: 48,
                          decoration: BoxDecoration(
                              color: const Color(0xFF3C3C3C),
                              borderRadius: BorderRadius.circular(8)),
                          child: Center(
                            child: Text(
                              widget.isQr
                                  ? AppLocalizations.of(context)!.authCaps
                                  : AppLocalizations.of(context)!.homeCaps,
                              style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          )),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
