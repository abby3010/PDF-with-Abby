import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:pdf_with_abby/utils/primary_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class QRScanScreen extends StatefulWidget {
  final String qrDecoded; // receives the value

  QRScanScreen({this.qrDecoded = ""});

  @override
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  bool _buttonVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan QR Code"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //Decoded data displayed over here
                Text(
                  "Decoded Data",
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      width: 1,
                      color: Theme.of(context).primaryColor,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Linkify(
                    onOpen: (link) async {
                      if (await canLaunch(link.url)) {
                        await launch(link.url);
                      } else {
                        throw 'Could not launch $link';
                      }
                    },
                    textAlign: TextAlign.center,
                    text: widget.qrDecoded,
                    linkStyle: TextStyle(color: Colors.blueAccent),
                  ),
                ),

                // Share Button
                PrimaryButton(
                  btnText: "Share",
                  onPressed: () async {
                    await Share.share(
                      widget.qrDecoded +
                          "\n\nDecoded using QR & Barcode Scanner \n \n https://play.google.com/store/apps/details?id=com.codingabby.qr_code_scanner",
                      subject: "Sharing with love from QR & Barcode Scanner",
                    ).whenComplete(() {
                      setState(() {
                        _buttonVisible = true;
                      });
                    });
                  },
                  icon: Icons.share,
                ),

                if (_buttonVisible)
                  PrimaryButton(
                    btnText: "Go to Home",
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
                    },
                    icon: Icons.home,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
