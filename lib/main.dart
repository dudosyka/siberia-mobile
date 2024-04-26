import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/presentation/pages/auth_page.dart';
import 'package:mobile_app_slb/presentation/pages/gettransfer_page.dart';
import 'package:mobile_app_slb/presentation/pages/home_page.dart';
import 'package:mobile_app_slb/presentation/pages/newsale_page.dart';
import 'package:mobile_app_slb/presentation/pages/nonetwork_page.dart';
import 'package:mobile_app_slb/presentation/pages/selectaddress_page.dart';
import 'package:mobile_app_slb/presentation/states/auth_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_app_slb/presentation/states/main_state.dart';
import 'package:mobile_app_slb/presentation/states/network_state.dart';
import 'package:provider/provider.dart' as provider;
import 'dart:io' show Platform;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(provider.MultiProvider(providers: [
    provider.ChangeNotifierProvider(
      create: (context) => NetworkService(),
    ),
  ], child: const ProviderScope(child: MyApp())));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    ref.read(localeChangeProvider).getLocale();
  }

  @override
  Widget build(BuildContext context) {
    var networkStatus = context.read<NetworkService>();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MaterialApp(
        title: 'Flutter Demo',
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('es'), Locale('ru')],
        locale: ref.watch(localeChangeProvider).locale,
        theme: ThemeData(
            colorScheme: const ColorScheme(
              brightness: Brightness.light,
              primary: Colors.black,
              onPrimary: Colors.white,
              secondary: Colors.white,
              onSecondary: Colors.black,
              error: Colors.red,
              onError: Colors.white,
              background: Colors.white,
              onBackground: Colors.black,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            useMaterial3: true,
            fontFamily: "Lato",
            scaffoldBackgroundColor: Colors.white,
            drawerTheme: const DrawerThemeData(
                backgroundColor: Colors.white, shape: RoundedRectangleBorder()),
            dividerTheme: const DividerThemeData(color: Color(0xFFD9D9D9))),
        home: StreamBuilder<Object>(
            stream: networkStatus.controller.stream,
            builder: (context, snapshot) {
              if (snapshot.data == NetworkStatus.offline) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NoNetworkPage()),
                      (route) => false);
                });
              }
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                    textScaler: MediaQuery.of(context).size.shortestSide > 650
                        ? const TextScaler.linear(2)
                        : const TextScaler.linear(1.0)),
                child: Scaffold(
                  body: ref.watch(loadAuthProvider).when(data: (value) {
                    if (value.$1.authModel == null ||
                        value.$2.errorModel != null ||
                        value.$3.errorModel != null) {
                      return const AuthPage();
                    } else if (!value.$2.stockModel!.transfersManaging &&
                        !value.$2.stockModel!.arrivalsManaging &&
                        !value.$2.stockModel!.salesManaging) {
                      return const AuthPage();
                    } else {
                      if (value.$1.authModel!.type == "stock") {
                        return const HomePage();
                      } else if (value.$1.authModel!.type == "transaction") {
                        if (value.$2.stockModel!.statusId == 2 &&
                                value.$2.stockModel!.typeId == 3 &&
                                value.$2.stockModel!.transfersProcessing) {
                          return SelectAddressPage(
                            stockModel: value.$2.stockModel!,
                            currentStock: value.$3.currentStock!,
                          );
                        } else if (value.$2.stockModel!.typeId == 3 &&
                            value.$2.stockModel!.statusId == 4 &&
                            value.$2.stockModel!.transfersManaging) {
                          return GetTransferPage(
                            stockModel: value.$2.stockModel!,
                            cartModels: value.$3.currentStock!.cartModels,
                            transactionId: value.$3.currentStock!.id,
                            stockId: value.$2.stockModel!.id,
                          );
                        } else if (value.$2.stockModel!.typeId == 2 &&
                            value.$2.stockModel!.salesManaging) {
                          return NewSalePage(
                            currentStorehouse: value.$2.stockModel!.name,
                            storehouseId: value.$2.stockModel!.id,
                            isTransaction: true,
                            stockModel: value.$2.stockModel!,
                          );
                        }
                      } else {
                        return const AuthPage();
                      }
                    }
                    return const AuthPage();
                  }, error: (error, stacktrace) {
                    if (Platform.isAndroid) {
                      return AlertDialog(
                        title: Text(error.toString()),
                        actions: [
                          ElevatedButton(
                              onPressed: () {
                                //Navigator.pop(context);
                                SystemChannels.platform
                                    .invokeMethod('SystemNavigator.pop');
                              },
                              child: const Text("Ok"))
                        ],
                      );
                    } else {
                      return const AlertDialog(
                        title: Text(
                          "Something went wrong:(\nPlease reload app",
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
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
                  }),
                ),
              );
            }));
  }
}
