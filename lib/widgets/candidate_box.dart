import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CandidateBox extends StatelessWidget {
  final String? candidateImgURL;
  final String? candidateName;
  final String? candidateDesc;
  final Function? onTap;
  final double? height;

  const CandidateBox(
      {Key? key,
      this.candidateImgURL,
      this.candidateName,
      this.candidateDesc,
      this.onTap,
      this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(candidateImgURL);
    return ListTile(
      tileColor: Colors.green[200],
      title: Text(candidateName!),
    );
  }
}
