import 'dart:io';

import 'package:e_voting_app/controllers/election_controller.dart';
import 'package:e_voting_app/services/database.dart';
import 'package:e_voting_app/widgets/input_field.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddVoteOptionWidget extends StatefulWidget {
  const AddVoteOptionWidget({super.key});

  @override
  _AddVoteOptionWidgetState createState() => _AddVoteOptionWidgetState();
}

class _AddVoteOptionWidgetState extends State<AddVoteOptionWidget> {
  var arguments = Get.arguments;
  File? _imagePicked;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  UploadTask? _uploadTask;
  double progressPercent = 0.0;
  var imgURL;
  var futureImgURL;
  @override
  void initState() {
    super.initState();
    arguments = arguments ?? Get.arguments;
  }

  void startUpload() async {
    String filePath = "election_pics/${DateTime.now()}.png";
    var reference = _storage.ref().child(filePath);

    setState(() {
      _uploadTask = reference.putFile(_imagePicked!);
      _uploadTask!.then((snapshot) {
        setState(() {
          snapshot.ref.getDownloadURL().then((imgURL) => imgURL = imgURL);
          futureImgURL = Future.value(snapshot.ref.getDownloadURL());
          Get.back(canPop: false);
        });
      });
    });
  }

  Future<void> pickImage(ImageSource source) async {
    XFile? selectedImage = await ImagePicker().pickImage(
        source: source, maxHeight: 300.0, maxWidth: 300.0, imageQuality: 100);
    setState(() {
      if (selectedImage != null) {
        _imagePicked = File(selectedImage.path);
        //Navigator.pop(context);
        Get.dialog(
            AlertDialog(
              // contentPadding: const EdgeInsets.only(top: 200.0, bottom: 200.0),
              title: const Text("Candidate Image Upload"),
              content: SizedBox(
                height: 320.0,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.file(
                        _imagePicked!,
                        filterQuality: FilterQuality.high,
                        height: 250,
                        width: 250,
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
              ),
            ),
            arguments: Get.arguments);
      } else {
        Get.snackbar("ERROR", "No Image selected");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var candidateNameController = TextEditingController();
    var candidateDescriptionController = TextEditingController();
    Get.put(ElectionController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Option Or Candidate",
          style: TextStyle(
              fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.green[100],
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 10.0,
            ),
            const Divider(),
            InkWell(
              onTap: () {
                Get.bottomSheet(
                    Container(
                      color: Colors.white,
                      height: 70.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                              onPressed: () {
                                ImageSource source = ImageSource.gallery;
                                pickImage(source);
                              },
                              icon: const Icon(
                                Icons.image_outlined,
                                color: Colors.red,
                              ),
                              label: const Text("Pick from Gallery")),
                          ElevatedButton.icon(
                              onPressed: () {
                                ImageSource source = ImageSource.camera;
                                pickImage(source);
                              },
                              icon: const Icon(
                                Icons.camera_enhance,
                                color: Colors.green,
                              ),
                              label: const Text("Take picture with Camera"))
                        ],
                      ),
                    ),
                    settings: RouteSettings(arguments: Get.arguments));
                setState(() {
                  _imagePicked = null;
                });
              },
              child: FutureBuilder(
                  future: Future.value(futureImgURL),
                  builder: (context, state) {
                    if (state.hasData) {
                      return CircleAvatar(
                        backgroundImage: NetworkImage(state.data as String),
                        radius: 80.0,
                      );
                    }
                    return const CircleAvatar(
                      radius: 80.0,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Icon(
                                Icons.account_circle,
                                size: 84.0,
                              ),
                            ),
                            Center(
                              child: Text("Add Image"),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
            ),
            const SizedBox(
              height: 40.0,
            ),
            InputField(
              prefixIcon: Icons.person,
              hintText: 'Candidate\'s names',
              controller: candidateNameController,
              obscure: false,
            ),
            InputField(
              prefixIcon: Icons.edit,
              hintText: 'Candidates\'s description',
              controller: candidateDescriptionController,
              obscure: false,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          print("Arrrrrrrrguments befor calling database: $arguments");
          print("Get befor calling database: ${arguments[0].id.toString()}");
          // imgURL = imgURL == null
          //     ? "gs://electchain-8ea68.appspot.com/avatar.jpg"
          //     : imgURL;
          imgURL = imgURL ??
              "electchain-8ea68.appspot.com/election_pics/2021-01-31 16:55:57.176426.png";
          print("URRRRRRRRRRRRL $imgURL");
          var result = await DataBase().addCandidate(
              arguments[0].id.toString(),
              imgURL,
              candidateNameController.text,
              candidateDescriptionController.text);

          if (result) {
            Get.back();
          }
        },
        child: const Icon(
          Icons.check_circle,
          color: Colors.white,
        ),
      ),
    );
  }
}
