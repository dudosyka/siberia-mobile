import 'package:flutter/material.dart';
import 'package:mobile_app_slb/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../states/network_state.dart';

class NoNetworkPage extends StatefulWidget {
  const NoNetworkPage({super.key});

  @override
  State<NoNetworkPage> createState() => _NoNetworkPageState();
}

class _NoNetworkPageState extends State<NoNetworkPage> {
  @override
  Widget build(BuildContext context) {
    var networkStatus = context.read<NetworkService>();

    return Scaffold(
      body: StreamBuilder(
          stream: networkStatus.controller.stream,
          builder: (context, snapshot) {
            if (snapshot.data == NetworkStatus.online) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MyApp()),
                    (route) => false);
              });
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.noInet,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }),
    );
  }
}
