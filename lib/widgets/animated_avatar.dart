import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_stories/controllers/avatar_controller.dart';

class AnimatedAvatar extends StatefulWidget {
  final Rect? avatarBounds;
  final Widget? avatar;
  const AnimatedAvatar({
    Key? key,
    required this.avatarBounds,
    required this.avatar,
  }) : super(key: key);

  @override
  State<AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<AnimatedAvatar> {
  late double _avatarTop;
  late double _avatarLeft;
  double _avatarScale = 1.0;
  bool _avatarAnimationFinished = false;

  final AvatarController _avatarController = Get.find();

  @override
  void initState() {
    super.initState();

    _avatarTop = widget.avatarBounds == null ? 0.0 : widget.avatarBounds!.top;
    _avatarLeft = widget.avatarBounds == null ? 0.0 : widget.avatarBounds!.left;

    Future.delayed(const Duration(milliseconds: 450), () {
      setState(() {
        _avatarAnimationFinished = true;
        _avatarController.finish();
      });
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() {
        _avatarTop = 72.0;
        _avatarLeft = 8.0;
        _avatarScale = 0.7;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _avatarAnimationFinished
        ? Container()
        : AnimatedPositioned(
            top: _avatarTop,
            left: _avatarLeft,
            duration: const Duration(milliseconds: 300),
            child: widget.avatar != null
                ? AnimatedScale(
                    duration: const Duration(milliseconds: 300),
                    scale: _avatarScale,
                    child: widget.avatar,
                  )
                : Container(),
          );
  }
}
