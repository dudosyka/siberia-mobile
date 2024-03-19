import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/presentation/pages/home_page.dart';
import 'package:mobile_app_slb/presentation/states/newsale_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SaleCompletePage extends ConsumerStatefulWidget {
  const SaleCompletePage({super.key});

  @override
  ConsumerState<SaleCompletePage> createState() => _SaleCompletePageState();
}

class _SaleCompletePageState extends ConsumerState<SaleCompletePage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 5), () {
      ref.read(cartDataProvider).deleteCart();
      Future.microtask(() => Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomePage())));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 10,
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
                    AppLocalizations.of(context)!.saleCompletedCaps,
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF424242)),
                  ),
                  Text(
                    AppLocalizations.of(context)!.youWillGetBack,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Color(0xFFAAAAAA)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: InkWell(
                  onTap: () {
                    ref.read(cartDataProvider).deleteCart();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()));
                  },
                  child: Container(
                      width: 152,
                      height: 48,
                      decoration: BoxDecoration(
                          color: const Color(0xFF3C3C3C),
                          borderRadius: BorderRadius.circular(8)),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.homeCaps,
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
    );
  }
}
