import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_voting_app/controllers/election_controller.dart';
import 'package:e_voting_app/controllers/user_controller.dart';
import 'package:e_voting_app/models/election_model.dart';
import 'package:e_voting_app/models/user.dart';
import 'package:e_voting_app/screens/admin/add_candidate.dart';
import 'package:get/get.dart';

class DataBase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uid = Get.find<UserController>().user.id;
  List<UserModel> allUsers = [];
  List<ElectionModel> allElections = [];
  ElectionModel indexedElection = ElectionModel();
  ElectionController electionController = Get.put(ElectionController());
  DocumentReference? _electionRef;
  Future<bool> createNewUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set({
        "name": user.name,
        "phonenumber": user.phoneNumber,
        "email": user.email,
        "owned_elections": [],
        "avatar": user.avatar
      });
      return true;
    } catch (err) {
      print(err.obs.string);
      return false;
    }
  }

  Future<UserModel> getUser(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      return Get.find<UserController>().fromDocumentSnapshot(doc);
    } catch (err) {
      print(err.obs.string);
      rethrow;
    }
  }

  Future<DocumentReference?> createElection(ElectionModel election) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('elections')
          .add({
        'options': [],
        'name': election.name,
        'description': election.description,
        'startDate': election.startDate,
        'endDate': election.endDate,
        'accessCode': election.accessCode,
        'voted': [],
        'owner': election.owner
      }).then((reference) {
        _firestore.collection('users').doc(_uid).update({
          "owned_elections": FieldValue.arrayUnion([reference.id])
        });

        Get.to(const AddCandidate(), arguments: [reference, election]);
      });
      return _electionRef;
    } catch (err) {
      print(err.obs.toString());
    }
    return null;
  }

  Future<bool> addCandidate(
      electionId, candidateImgUrl, candidateName, candidateDescription) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('elections')
          .doc(electionId)
          .update({
        "options": FieldValue.arrayUnion([
          {
            'avatar': candidateImgUrl,
            'name': candidateName,
            'description': candidateDescription,
            'count': 1
          }
        ])
      });
      return true;
    } catch (err) {
      print(err.obs.string);
      Get.snackbar('ERROR',
          'Unexpected error occured while adding the candidate, Please try again');
      return false;
    }
  }

  Future<DocumentSnapshot> candidatesStream(
      String uid, String electionId) async {
    var data = await _firestore
        .collection('users')
        .doc(uid)
        .collection('elections')
        .doc(electionId)
        .get();
    return data;
  }

  Future<ElectionModel> getElection(String uid, String electionID) async {
    var data = await _firestore
        .collection('users')
        .doc(uid)
        .collection('elections')
        .doc(electionID)
        .get();
    return Get.find<ElectionController>().fromDocumentSnapshot(data);
  }

  // Future<ElectionModel> getElectionByAccessCode(String _electionID) async {
  //   return indexedElection;
  // }

  Stream<ElectionModel> getElections(userID) {
    var snaps;
    _firestore.collection("users").doc(userID).snapshots().map((user) {
      snaps = user.data()!['owned_elections'].map((electionOwned) {
        return _firestore
            .collection("users")
            .doc(userID)
            .collection("elections")
            .doc(electionOwned)
            .snapshots();
      });
      print(snaps);
    });
    print("Snaaaaaaaaaps oooooooh $snaps");
    return snaps;
  }
}
