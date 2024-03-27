import 'package:flutter/material.dart';
import 'package:mobile_app_slb/main.dart';
import 'package:provider/provider.dart';

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
                    MaterialPageRoute(builder: (context) => MyApp()),
                    (route) => false);
              });
            }
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  "No internet connection. Please turn on internet and you will be redirected back",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }),
    );
  }
}
