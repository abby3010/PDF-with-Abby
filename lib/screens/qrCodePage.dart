import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pdf_with_abby/screens/qr_create.dart';
import 'package:pdf_with_abby/screens/qr_scan.dart';
import 'package:pdf_with_abby/utils/primary_button.dart';

class QRCodePage extends StatefulWidget {
  const QRCodePage({Key? key}) : super(key: key);

  @override
  _QRCodePageState createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("QR & Barcodes"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image center
            Image(
              image: AssetImage("assets/qr_home_img.png"),
            ),

            // Scan and Create button
            PrimaryButton(
              btnText: "Scan QR or Barcode",
              icon: Icons.qr_code_scanner,
              onPressed: () async {
                try {
                  final qrDecoded = await FlutterBarcodeScanner.scanBarcode(
                    "#E91E63",
                    "Cancel",
                    true,
                    ScanMode.DEFAULT,
                  );
                  if (!mounted) {
                    Fluttertoast.showToast(msg: "QR or Barcode was not found!");
                    return;
                  }

                  if (qrDecoded != "-1") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            QRScanScreen(qrDecoded: qrDecoded),
                      ),
                    );
                  }else{
                    Fluttertoast.showToast(
                        msg: "QR or Barcode was not found!");
                  }
                } on PlatformException {
                  Fluttertoast.showToast(
                      msg: "Something went wrong. Try again!");
                }
              },
            ),

            PrimaryButton(
              btnText: "Create QR code",
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => QRCreateScreen()));
              },
              icon: Icons.qr_code,
            ),
          ],
        ),
      ),
    );
  }
}
