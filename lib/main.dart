import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'utils/theme.dart';
import 'views/cmd.dart';

void main() {
  runApp(
    // For widgets to be able to read providers, we need to wrap the entire
    // application in a "ProviderScope" widget.
    // This is where the state of our providers will be stored.
    Phoenix(
      child: (ProviderScope(
        child: MyApp(),
      )),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZTerminal',
      theme: themeData(context),
      debugShowCheckedModeBanner: false,
      color: Colors.red,
      home: CMD(),
    );
  }
}
