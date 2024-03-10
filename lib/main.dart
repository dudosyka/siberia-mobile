import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/presentation/pages/auth_page.dart';
import 'package:mobile_app_slb/presentation/pages/home_page.dart';
import 'package:mobile_app_slb/presentation/states/auth_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_app_slb/presentation/states/main_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('ru')
      ],
      locale: ref.watch(localeChangeProvider).locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
        fontFamily: "Lato",
        scaffoldBackgroundColor: Colors.white,
        drawerTheme: const DrawerThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder()
        ),
        dividerTheme: const DividerThemeData(color: Color(0xFFD9D9D9))
      ),
      home: Scaffold(
        body: ref.watch(loadAuthProvider).when(
                data: (value) {
                  if(value.authModel == null) {
                    return const AuthPage();
                  } else {
                    if(value.authModel!.type == "stock") {
                      return const HomePage();
                    } else {
                      return const HomePage();
                    }
                  }
                },
                error: (error, stacktrace) {
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
                },
            loading: () {
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
  }
}
