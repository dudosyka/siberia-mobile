import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/presentation/pages/home_page.dart';
import 'package:mobile_app_slb/presentation/states/auth_state.dart';
import 'package:mobile_app_slb/presentation/widgets/black_button.dart';

class AuthPage extends ConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ref.watch(scanProvider).when(data: (value) {
            return ref.watch(authProvider(value)).when(data: (value) {
              if (value.errorModel == null && value.authModel != null) {
                Future.microtask(() => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (builder) => const HomePage()),
                    (route) => false));
                return Container();
              } else {
                return Padding(
                  padding: const EdgeInsets.all(50),
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Something went wrong. Try to re-scan again",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 17,
                                  color: Color(0xFFFF0000)),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                            blackButton("Re-scan", null, () {
                              ref.refresh(scanProvider).value;
                            })
                          ],
                        ),
                      ),
                    ],
                  ),
                );
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
      ),
    );
  }
}
