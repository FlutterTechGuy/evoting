import 'package:e_voting_app/controllers/user_controller.dart';
import 'package:e_voting_app/models/user.dart';
import 'package:e_voting_app/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void createUser(imgURL, name, phoneNumber, email, password) async {
    _isLoading = true;
    notifyListeners();
    try {
      var authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      //Create a user in firestore
      UserModel user = UserModel(
          id: authResult.user!.uid,
          avatar: imgURL,
          name: name,
          phoneNumber: phoneNumber,
          email: email);
      if (await DataBase().createNewUser(user)) {
        Get.find<UserController>().user = user;
        Get.back();
      }
    } catch (err) {
      Get.snackbar('Processing Error', err.toString());
    }
    _isLoading = false;
    notifyListeners();
  }

  void readUser() async {
    Get.find<UserController>().user =
        await DataBase().getUser(FirebaseAuth.instance.currentUser!.uid);
  }

  Future<String> loginUser(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    var result = 'OK';
    try {
      var authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      Get.find<UserController>().user =
          await DataBase().getUser(authResult.user!.uid);
    } catch (err) {
      Get.snackbar('Processing Error', err.obs.string);
      result = err.obs.toString();
    }
    _isLoading = false;

    notifyListeners();
    return result;
  }

  Future<String> forgotPassword(
    String email,
  ) async {
    _isLoading = true;
    notifyListeners();
    var result = 'OK';
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
          'Message', 'We sent the password reset instruction to $email');
    } catch (err) {
      Get.snackbar('Processing Error', err.obs.string);
      result = err.obs.toString();
    }
    _isLoading = false;

    notifyListeners();
    return result;
  }

  void signOut() {
    try {
      _auth.signOut();
      Get.find<UserController>().clear();
    } catch (err) {
      Get.snackbar('Processing Error', err.obs.string);
    }
  }
}
