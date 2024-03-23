import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/data/repository/auth_repository.dart';
import 'package:timezone/standalone.dart' as tz2;
import 'package:timezone/data/latest_all.dart' as tz;

final getHomeProvider = FutureProvider((ref) async {
  final data = await AuthRepository().getStock();

  return data;
});

final timeProvider = ChangeNotifierProvider((ref) => TimeNotifier());

class TimeNotifier extends ChangeNotifier {
  String spainTime = "";

  Future<void> updateTime() async {
    tz.initializeTimeZones();
    var madrid = tz2.getLocation('Europe/Madrid');
    final DateTime timeSpainTZ = tz2.TZDateTime.now(madrid);
    spainTime =
        "${timeSpainTZ.day}/${timeSpainTZ.month}/${timeSpainTZ.year} | ${timeSpainTZ.hour}.${timeSpainTZ.minute}";
    notifyListeners();
  }

  Future<void> updatePeriodic() async {
    updateTime();
    var now = DateTime.now();
    var nextMinute =
        DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
    Timer(nextMinute.difference(now), () {
      Timer.periodic(const Duration(minutes: 1), (timer) {
        updateTime();
      });
      updateTime();
    });
  }
}
