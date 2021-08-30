import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pdf_with_abby/screens/homepage.dart';
import 'package:pdf_with_abby/screens/qrCodePage.dart';

import 'notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Notifications().initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF with Abby',
      theme: ThemeData(primarySwatch: Colors.indigo, appBarTheme: AppBarTheme(brightness: Brightness.dark)),
      initialRoute: "/",
      routes: {
        "/": (context) => HomePage(),
        "/qr" : (context) => QRCodePage(),
      },
    );
  }
}
