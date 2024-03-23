import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/presentation/pages/home_page.dart';
import 'package:mobile_app_slb/presentation/widgets/exit_dialog.dart';
import 'package:mobile_app_slb/presentation/widgets/round_button.dart';

import '../../data/repository/auth_repository.dart';
import '../pages/auth_page.dart';
import '../states/main_state.dart';
import '../states/newsale_state.dart';

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer(
      {super.key,
      required this.isAbleToNavigate,
      required this.isAssembly,
      required this.isHomePage});

  final bool isAbleToNavigate;
  final bool isAssembly;
  final bool isHomePage;

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
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
                  const Divider(),
                  ListTile(
                    title: const Text(
                      'Home screen',
                      style: TextStyle(fontSize: 24),
                    ),
                    leading: Image.asset(
                      "assets/images/home_screen_icon.png",
                      scale: 4,
                    ),
                    onTap: () {
                      if (widget.isAbleToNavigate) {
                        if (widget.isHomePage) {
                          Navigator.pop(context);
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => const HomePage()));
                        }
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return exitDialog(context,
                                  "Are you sure? All data will be deleted");
                            }).then((returned) {
                          if (returned) {
                            if (widget.isAssembly) {
                              ref.read(cartDataProvider).deleteCart();
                            } else {
                              ref.read(cartDataProvider).deleteOutcome();
                            }
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomePage()),
                                (route) => false);
                          }
                        });
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text(
                      'Transfer',
                      style: TextStyle(fontSize: 24),
                    ),
                    leading: Image.asset(
                      "assets/images/transfer_screen_icon.png",
                      scale: 4,
                    ),
                    onTap: () {},
                  ),
                  const Divider(),
                ],
              ),
            ),
            //const Spacer(),
            const Divider(),
            ListTile(
              horizontalTitleGap: 0,
              title: const Text(
                'Log out',
                style: TextStyle(fontSize: 24, color: Color(0xFF5A5A5A)),
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
