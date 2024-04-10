import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@override
Widget exitDialog(BuildContext context, String text) {
  return AlertDialog(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    title: Text(text),
    actions: [
      TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: Text(
            AppLocalizations.of(context)!.no,
            style: const TextStyle(color: Colors.black),
          )),
      TextButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: Text(
            AppLocalizations.of(context)!.yes,
            style: const TextStyle(color: Colors.redAccent),
          ))
    ],
  );
}
