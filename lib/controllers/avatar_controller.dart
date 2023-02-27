import 'package:get/get.dart';

class AvatarController extends GetxController {
  final avatarAnimationFinished = false.obs;
  finish() => avatarAnimationFinished(true);
  reset() => avatarAnimationFinished(false);
}
