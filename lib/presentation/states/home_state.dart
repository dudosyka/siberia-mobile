import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_slb/data/repository/auth_repository.dart';
import 'package:timezone/standalone.dart' as tz2;
import 'package:timezone/data/latest_all.dart' as tz;

final getHomeProvider = FutureProvider((ref) async {
   final data = await AuthRepository().getStock();
   tz.initializeTimeZones();
   var madrid = tz2.getLocation('Europe/Madrid');
   final DateTime timeSpainTZ = tz2.TZDateTime.now(madrid);
   String spainTime =
   "${timeSpainTZ.day}/${timeSpainTZ.month}/${timeSpainTZ.year} | ${timeSpainTZ.hour}.${timeSpainTZ.minute}";
   return (data, spainTime);
});