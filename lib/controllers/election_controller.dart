import 'dart:math';

import 'package:e_voting_app/controllers/user_controller.dart';
import 'package:e_voting_app/models/election_model.dart';
import 'package:e_voting_app/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//Function to generate the vote access code as a mix of number and sting

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _random = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_random.nextInt(_chars.length))));

class ElectionController with ChangeNotifier {
  final Rx<ElectionModel> _electionModel = ElectionModel().obs;
  ElectionModel currentElection = ElectionModel();

  ElectionModel get election => _electionModel.value;

  set election(ElectionModel value) => _electionModel.value = value;



  ElectionModel fromDocumentSnapshot(DocumentSnapshot doc) {
    ElectionModel election = ElectionModel();

    election.id = doc.id;
    final data = doc.data() as Map<String, dynamic>;
    election.accessCode = data['accessCode'];
    election.description = data['description'];
    election.endDate = data['endDate'];
    election.name = data['name'];
    election.options = data['options'];
    election.startDate = doc['startDate'];
    election.voted = data['voted'];
    election.owner = data['owner'];
    return election;
  }

  createElection(name, description, startDate, endDate) {
    ElectionModel election = ElectionModel(
        accessCode: getRandomString(6),
        name: name,
        voted: [],
        owner: FirebaseAuth.instance.currentUser!.uid,
        description: description,
        startDate: startDate,
        endDate: endDate);
    DataBase().createElection(election);
  }

  candidatesStream(String uid, String electionId) {
    DataBase().candidatesStream(uid, electionId);
  }

  copyAccessCode(String code) {
    //how to copy to the clipboard using dart
    Clipboard.setData(ClipboardData(text: code));
    Get.snackbar(
      'COPYING ACCESS CODE',
      'Access code copied successfully',
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.TOP,
      barBlur: 0.0,
      overlayBlur: 0.0,
      margin: const EdgeInsets.only(top: 200.0),
      icon: const Icon(
        Icons.check_circle,
        color: Colors.green,
      ),
      backgroundGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green[300]!, Colors.blue]),
    );
  }

  getElection(String uid, String electionID) {
    DataBase()
        .getElection(uid, electionID)
        .then((election) => Get.find<ElectionController>().election = election);
  }
}
