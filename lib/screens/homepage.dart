import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:pdf_with_abby/screens/pdfShowScreen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../notifications.dart';
import 'fileNameScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? directory;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    Notifications().foreGroundNotification();
    // InterstitialAd.load(
    //   adUnitId: 'ca-app-pub-2589257874108853/2473732205',
    //   request: AdRequest(),
    //   adLoadCallback: InterstitialAdLoadCallback(
    //     onAdLoaded: (InterstitialAd ad) {
    //       // Keep a reference to the ad so you can show it later.
    //       this._interstitialAd = ad;
    //     },
    //     onAdFailedToLoad: (LoadAdError error) {
    //       print('InterstitialAd failed to load: $error');
    //     },
    //   ),
    // );
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
  }

  Future<String> getFolder() async {
    final dir = Directory("storage/emulated/0/PDF with Abby");
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if (await dir.exists()) {
      return dir.path;
    } else {
      await dir.create(recursive: true);
      return dir.path;
    }
  }

  getFormattedDate(_date) {
    var inputFormat = DateFormat('yyyy-MM-dd HH:mm');
    var inputDate = inputFormat.parse(_date);
    var outputFormat = DateFormat('dd MMM yyyy HH:mm');
    return outputFormat.format(inputDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF with Abby"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner_rounded),
            onPressed: () {
              Navigator.pushNamed(context, "/qr");
            },

          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: FutureBuilder(
          future: getFolder(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              // Get the files from the directory and display in a ListView
              String? path = snapshot.data;
              Directory dir = new Directory(path!);
              List<FileSystemEntity> files = dir.listSync();

              if (files.length > 0) {
                return ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    var stats = files[index].statSync();
                    if (stats.type == FileSystemEntityType.file) {
                      File file = new File(files[index].path);
                      final bytes = file.readAsBytesSync().lengthInBytes;
                      final fileSize = bytes / (1024 * 1024);

                      return Card(
                        elevation: 5,
                        child: ListTile(
                          title: Text(file.uri.pathSegments.last),
                          subtitle: Text("${getFormattedDate(file.lastModifiedSync().toString())}\n" + fileSize.toStringAsFixed(2) + " MB"),
                          leading: Icon(
                            Icons.picture_as_pdf,
                            color: Colors.orange,
                            size: 30,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Delete Icon Button
                              IconButton(
                                icon: Icon(Icons.share),
                                onPressed: () async {
                                  await Share.shareFiles(
                                    [file.path],
                                    text: "Made in PDF with Abby",
                                  );
                                },
                              ),

                              // Delete Icon Button
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text("Confirm Delete"),
                                          actions: [
                                            TextButton(
                                              child: Text("Cancel"),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                            TextButton(
                                              child: Text("OK"),
                                              onPressed: () async {
                                                await file.delete();
                                                setState(() {});
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                },
                              ),
                            ],
                          ),
                          onTap: () async {
                            // await _interstitialAd?.show();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PDFScreen(
                                  path: file.path,
                                  filename: file.uri.pathSegments.last,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return SizedBox();
                    }
                  },
                );
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/home.png"),
                      Text("Click plus button to make PDFs"),
                    ],
                  ),
                );
              }
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // _interstitialAd?.show();
          Navigator.push(context, MaterialPageRoute(builder: (context) => FileNameScreen()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
