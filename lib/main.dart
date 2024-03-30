import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/presentation/pages/auth_page.dart';
import 'package:mobile_app_slb/presentation/pages/home_page.dart';
import 'package:mobile_app_slb/presentation/pages/newsale_page.dart';
import 'package:mobile_app_slb/presentation/pages/nonetwork_page.dart';
import 'package:mobile_app_slb/presentation/pages/transferassembly_page.dart';
import 'package:mobile_app_slb/presentation/states/auth_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_app_slb/presentation/states/main_state.dart';
import 'package:mobile_app_slb/presentation/states/network_state.dart';
import 'package:mobile_app_slb/presentation/states/transfer_state.dart';
import 'package:provider/provider.dart' as provider;

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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NoNetworkPage()));
                });
              }
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                    textScaler: MediaQuery.of(context).size.shortestSide > 650
                        ? const TextScaler.linear(2)
                        : const TextScaler.linear(1.0)),
                child: Scaffold(
                  body: ref.watch(loadAuthProvider).when(data: (value) {
                    if (value.authModel == null) {
                      return const AuthPage();
                    } else {
                      if (value.authModel!.type == "stock") {
                        return const HomePage();
                      } else if (value.authModel!.type == "transaction") {
                        final data =
                            ref.read(localeChangeProvider).getCurrentStock();
                        data.then((value) {
                          if (value.errorModel != null) {
                            return const AuthPage();
                          }
                          if (value.stockModel!.typeId == 3 &&
                              value.stockModel!.statusId == 2) {
                            ref
                                .read(transferProvider)
                                .getCurrentStock()
                                .then((value2) {
                              if (value2.errorModel != null) {
                                return const AuthPage();
                              }
                              return TransferAssemblyPage(
                                stockModel: value.stockModel!,
                                cartModels: value2.currentStock!.cartModels,
                              );
                            });
                          }
                          return NewSalePage(
                            currentStorehouse: value.stockModel!.name,
                            storehouseId: value.stockModel!.id,
                            isTransaction: true,
                            stockModel: value.stockModel!,
                          );
                        });
                      } else {
                        return Container();
                      }
                    }
                    return const AuthPage();
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
                  }),
                ),
              );
            }));
  }
}
