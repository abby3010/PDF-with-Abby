import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFScreen extends StatefulWidget {
  final String? path;
  final String? filename;
  PDFScreen({Key? key, this.path, this.filename}) : super(key: key);

  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {

  @override
  Widget build(BuildContext context) {
    final file = File(widget.path!);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.filename ?? "Document"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              await Share.shareFiles(
                [widget.path!],
                text: "Made in PDF with Abby",
              );
            },
          ),
        ],
      ),
      body: Container(
        child: SfPdfViewer.file(file),
      ),
    );
  }
}
