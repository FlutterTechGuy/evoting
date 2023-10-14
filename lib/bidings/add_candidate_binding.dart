import 'package:e_voting_app/controllers/user_controller.dart';
import 'package:e_voting_app/services/database.dart';
import 'package:get/get.dart';

class AddCandidateBinding extends Bindings {
  @override
  void dependencies() {
    getData() async {
      var data;
      await DataBase()
          .candidatesStream(Get.find<UserController>().user.id!,
              Get.arguments[0].id.toString())
          .then((election) {
        final r = election.data() as Map<String, dynamic>;
        data = r['options'];
        
      });
    }
  }
}
