import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:my_stories/controllers/avatar_controller.dart';
import 'package:my_stories/controllers/story_controller.dart';
import 'package:my_stories/widgets/animated_avatar.dart';
import 'package:my_stories/widgets/story_viewer.dart';

class StoryPage extends StatefulWidget {
  final Rect? avatarBounds;
  final Widget? avatar;
  final int selectedIndex;

  const StoryPage({
    super.key,
    required this.avatarBounds,
    required this.avatar,
    required this.selectedIndex,
  });

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> with SingleTickerProviderStateMixin {
  final CarouselSliderController carouselController = CarouselSliderController();
  final AvatarController avatarController = Get.put(AvatarController());
  final StoryController storyController = Get.find();
  late AnimationController animationController;

  int carouselIndex = 0;

  @override
  void initState() {
    super.initState();

    avatarController.reset();
    carouselIndex = widget.selectedIndex;

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    carouselController.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() => CarouselSlider(
              key: const ValueKey('carousel'),
              initialPage: widget.selectedIndex,
              controller: carouselController,
              slideTransform: const CubeTransform(),
              onSlideChanged: (value) {
                carouselIndex = value;
              },
              children: storyController.storyGroups
                  .mapIndexed((index, element) => StoryViewer(
                        key: ValueKey(index),
                        storyGroupIndex: index,
                        toNextPage: () {
                          if (carouselIndex == storyController.storyGroups.length - 1) {
                            Navigator.of(context).pop();
                          }
                          carouselController.nextPage(const Duration(milliseconds: 300));
                        },
                        toPreviousPage: () {
                          carouselController.previousPage(const Duration(milliseconds: 300));
                        },
                        storyGroup: element,
                        lateAvatar: index == widget.selectedIndex,
                      ))
                  .toList(),
            )),
        AnimatedAvatar(avatarBounds: widget.avatarBounds, avatar: widget.avatar),
      ],
    );
  }
}
