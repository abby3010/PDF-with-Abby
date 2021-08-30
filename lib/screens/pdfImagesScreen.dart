import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../notifications.dart';

class PDFImagesScreen extends StatefulWidget {
  final String filename;
  final int imageQuality;
  const PDFImagesScreen({Key? key, required this.filename, required this.imageQuality}) : super(key: key);

  @override
  _PDFImagesScreenState createState() => _PDFImagesScreenState();
}

class _PDFImagesScreenState extends State<PDFImagesScreen> {
  final picker = ImagePicker();
  List<String> images = [];
  bool loading = false;
  InterstitialAd? _interstitialAd;

  Future getImage(ImageSource imgSource) async {
    if (imgSource == ImageSource.camera) {
      var pickedImg = await picker.pickImage(source: imgSource, imageQuality: widget.imageQuality);
      if (pickedImg != null) {
        setState(() {
          images.add(pickedImg.path);
        });
      } else {
        Fluttertoast.showToast(
          msg: "No image selected. Try again",
          backgroundColor: Colors.redAccent,
        );
      }
    } else {
      var pickedFiles = await picker.pickMultiImage(imageQuality: widget.imageQuality);
      if (pickedFiles != null) {
        for (int i = 0; i < pickedFiles.length; i++) {
          setState(() {
            images.add(pickedFiles[i].path);
          });
        }
      } else {
        Fluttertoast.showToast(
          msg: "No image selected. Try again",
          backgroundColor: Colors.redAccent,
        );
      }
    }
  }

  Future<File?> cropImage(String path) async {
    File? croppedFile = await ImageCropper.cropImage(
      sourcePath: path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Cropper',
        toolbarColor: Colors.indigo,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
    );
    if (croppedFile != null) {
      return croppedFile;
    }
  }

  @override
  void initState() {
    super.initState();
    Notifications().foreGroundNotification();
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-2589257874108853/3996365739',
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          // Keep a reference to the ad so you can show it later.
          this._interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Images for PDF"),
        centerTitle: true,
        actions: [
          if (images.length > 0)
            IconButton(
              icon: Icon(
                Icons.check,
                size: 30,
              ),
              onPressed: () async {
                final success = await createAndSavePDF(context);
                if (success) {
                  await _interstitialAd?.show();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/",
                    (route) => false,
                  );
                  Fluttertoast.showToast(msg: "🎉 PDF created successfully! 🎉");
                } else {
                  Fluttertoast.showToast(msg: "Oops, something went wrong!", backgroundColor: Colors.red);
                }
              },
            )
        ],
      ),
      body: Column(
        children: [
          if (images.length == 0)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/pdfImagesPage.png"),
                    Text("Select images from Camera or Gallery"),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Instruction Heading
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Drag and drop to Reorder",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Image Panel List
                  Container(
                    height: MediaQuery.of(context).size.height * 0.50,
                    child: ReorderableListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final items = images.removeAt(oldIndex);
                          images.insert(newIndex, items);
                        });
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          key: Key(index.toString()),
                          elevation: 4,
                          color: Colors.blueGrey[50],
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.file(
                                  new File(images[index]),
                                  width: MediaQuery.of(context).size.width * 0.45,
                                ),
                              ),
                              SizedBox(
                                height: 35,
                                width: MediaQuery.of(context).size.width * 0.45,
                                child: Container(
                                  color: Colors.amber[300],
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Edit Image Button
                                      TextButton(
                                        child: Text(
                                          "Edit",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        onPressed: () async {
                                          File? croppedFile = await cropImage(images[index]);
                                          setState(() {
                                            images[index] = croppedFile!.path;
                                          });
                                        },
                                      ),

                                      // Remove image button
                                      IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            images.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Image Picker Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  await getImage(ImageSource.camera);
                },
                icon: Icon(Icons.camera_alt),
                label: Text("Camera"),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await getImage(ImageSource.gallery);
                },
                icon: Icon(Icons.image),
                label: Text("Gallery"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> createAndSavePDF(BuildContext ct) async {
    final pdf = pw.Document();
    for (int i = 0; i < images.length; i++) {
      final imgFile = new File(images[i]);
      final image = pw.MemoryImage(imgFile.readAsBytesSync());

      // Add each image to the pdf
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.undefined,
          build: (pw.Context context) {
            return pw.Image(image, width: MediaQuery.of(ct).size.width);
          },
        ),
      );
    }

    try {
      final dir = new Directory("storage/emulated/0/PDF with Abby");
      final file = new File(dir.path + "/" + widget.filename + ".pdf");
      await file.writeAsBytes(await pdf.save());
      return true;
    } catch (e) {
      print("ERROR in Making PDF :::: $e");
      Fluttertoast.showToast(msg: "Something went wrong, try again!");
      return false;
    }
  }
}
