import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImageUploader extends StatefulWidget {
  final File? file;
  final String? bucket;

  const ImageUploader({Key? key, this.file, this.bucket}) : super(key: key);
  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  UploadTask? _uploadTask;
  double progressPercent = 0.0;
  var imgURL;
  void startUpload() async {
    String filePath = "${DateTime.now()}.png";
    var reference = _storage.ref().child(filePath);

    setState(() {
      _uploadTask = reference.putFile(widget.file!);
    });

    await _uploadTask!.then((snapshot) {
      setState(() {
        imgURL = snapshot.ref.getDownloadURL();
      });
      print("Image URL $imgURL");
    });
  }

  @override
  Widget build(BuildContext context) {
    print(Get.arguments);
    return Scaffold(
        body: Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 5.0),
              child: Center(
                child: Image(
                  image: AssetImage('assets/icons/logo.png'),
                  height: 80.0,
                  width: 300.0,
                ),
              ),
            ),
            const Text(
              "Upload Image",
              style: TextStyle(
                  fontSize: 28.0,
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            const Divider(),
            Image.file(
              widget.file!,
              filterQuality: FilterQuality.high,
              cacheHeight: 300,
              cacheWidth: 300,
            ),
            const SizedBox(height: 20.0),
            _uploadTask != null
                ? StreamBuilder(
                    stream: _uploadTask!.snapshotEvents,
                    builder: (context, snapshot) {
                      _uploadTask!.snapshotEvents
                          .listen((TaskSnapshot snapshot) {
                        setState(() {
                          progressPercent =
                              snapshot.bytesTransferred.toDouble() /
                                  snapshot.totalBytes.toDouble();
                        });
                      });

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10.0, left: 45.0, right: 45.0),
                            child: LinearProgressIndicator(
                                semanticsLabel:
                                    "${(progressPercent * 100).toString()} % uploaded...",
                                minHeight: 10.0,
                                value: progressPercent * 100),
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Text(
                            "${(progressPercent * 100).toString()} % uploaded...",
                            style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      );
                    })
                : ElevatedButton.icon(
                    onPressed: () {
                      startUpload();
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Upload Image")),
          ],
        ),
      ),
    ));
  }
}
