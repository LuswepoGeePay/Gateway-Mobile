import 'package:get/get.dart';
import 'package:gateway_mobile/features/authentication/controllers/sign_in/sign_in_controller.dart';
import 'package:gateway_mobile/utils/helpers/network_manager.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkManager());
    Get.lazyPut(() => SigninController(), fenix: true);
  }
}
