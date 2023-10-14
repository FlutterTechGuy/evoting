import 'package:e_voting_app/controllers/election_controller.dart';
import 'package:get/get.dart';

class VoteDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ElectionController>(() => ElectionController());
  }
}
