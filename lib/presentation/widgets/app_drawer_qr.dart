import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/data/models/stock_model.dart';
import 'package:mobile_app_slb/presentation/widgets/round_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../data/repository/auth_repository.dart';
import '../pages/auth_page.dart';
import '../states/main_state.dart';

class AppDrawerQr extends ConsumerStatefulWidget {
  const AppDrawerQr({super.key, required this.stockModel});

  final StockModel stockModel;

  @override
  ConsumerState<AppDrawerQr> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawerQr> {
  @override
  Widget build(BuildContext context) {
    String currentCode = ref.watch(localeChangeProvider).locale.languageCode;

    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                      margin: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Image.asset(
                              "assets/images/logo.png",
                              scale: 4,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                roundButton(
                                    Image.asset(
                                      "assets/images/en_lan_icon.png",
                                      scale: 4,
                                    ),
                                    42, () {
                                  ref
                                      .read(localeChangeProvider)
                                      .changeLocale("en");
                                }, currentCode == "en"),
                                roundButton(
                                    Image.asset(
                                      "assets/images/es_lan_icon.png",
                                      scale: 4,
                                    ),
                                    42, () {
                                  ref
                                      .read(localeChangeProvider)
                                      .changeLocale("es");
                                }, currentCode == "es"),
                                roundButton(
                                    Image.asset(
                                      "assets/images/ru_lan_icon.png",
                                      scale: 4,
                                    ),
                                    42, () {
                                  ref
                                      .read(localeChangeProvider)
                                      .changeLocale("ru");
                                }, currentCode == "ru")
                              ],
                            ),
                          )
                        ],
                      )),
                ],
              ),
            ),
            //const Spacer(),
            const Divider(),
            ListTile(
              horizontalTitleGap: 0,
              title: Text(
                AppLocalizations.of(context)!.logout,
                style: const TextStyle(fontSize: 24, color: Color(0xFF5A5A5A)),
              ),
              leading: Image.asset(
                "assets/images/logout_icon.png",
                scale: 4,
              ),
              onTap: () async {
                await AuthRepository().deleteAuthData().then((value) =>
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => const AuthPage())));
              },
            ),
          ],
        ),
      ),
    );
  }
}
