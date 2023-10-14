import 'package:e_voting_app/models/user.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserController extends GetxController {
  Rx<UserModel> _userModel = UserModel().obs;

  UserModel get user => _userModel.value;
  set user(UserModel value) => this._userModel.value = value;
  void clear() {
    _userModel.value = UserModel();
  }

  UserModel fromDocumentSnapshot(DocumentSnapshot doc) {
    UserModel _user = UserModel();
    _user.id = doc.id; 
    final data = doc.data() as Map<String,dynamic>; 
    _user.email = data['email'];
    _user.name = data['name'];
    _user.phoneNumber = data['phonenumber'];
    _user.ownedElections = data['owned_elections'];
    _user.avatar = data['avatar'];
    return _user;
  }
}
