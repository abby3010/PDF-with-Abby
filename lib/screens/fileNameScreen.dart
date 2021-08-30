import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_with_abby/screens/pdfImagesScreen.dart';

class FileNameScreen extends StatefulWidget {
  const FileNameScreen({Key? key}) : super(key: key);

  @override
  _FileNameScreenState createState() => _FileNameScreenState();
}

class _FileNameScreenState extends State<FileNameScreen> {
  TextEditingController _fileNameController = new TextEditingController();
  double imageQuality = 100;
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Filename of PDF"),
      ),
      body: Center(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Heading
                Text(
                  "Enter the name of your PDF file",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                // Filename input field
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextFormField(
                    controller: _fileNameController,
                    decoration: InputDecoration(
                        hintText: "MyPDFname",
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(10.0)))),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter a filename for PDF!";
                      }
                      try {
                        final dir =
                            Directory("storage/emulated/0/PDF with Abby");
                        final file = new File(
                            dir.path + "/" + _fileNameController.text + ".pdf");
                        if (file.existsSync()) {
                          return "File with the same name already exists!";
                        }
                      } catch (e) {
                        return "Something went wrong, try again!";
                      }
                      return null;
                    },
                  ),
                ),

                //Muted text
                Text(
                  "This will be your file name.",
                  style: TextStyle(color: Colors.grey),
                ),

                // Spacing
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                // Heading
                Text(
                  "PDF Size %",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                // Image quality slider
                Slider(
                  value: imageQuality,
                  min: 5,
                  max: 100,
                  label: "${imageQuality.toInt()}",
                  divisions: 19,
                  onChanged: (quality) {
                    setState(() {
                      imageQuality = quality;
                    });
                  },
                ),

                //Muted text
                Text(
                  "PDF size will be reduced to above percentage.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),

                // Spacing
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                // Continue to PDFImagesScreen
                ElevatedButton(
                  child: Text("Continue"),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PDFImagesScreen(
                            filename: _fileNameController.text,
                            imageQuality: imageQuality.toInt(),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
