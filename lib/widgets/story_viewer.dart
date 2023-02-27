import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_stories/controllers/avatar_controller.dart';
import 'package:my_stories/controllers/story_controller.dart';
import 'package:my_stories/models/story.dart';
import 'package:my_stories/models/story_group.dart';
import 'package:my_stories/widgets/my_video_player.dart';
import 'package:video_player/video_player.dart';

class StoryViewer extends StatefulWidget {
  final StoryGroup storyGroup;
  final int storyGroupIndex;
  final bool lateAvatar;
  final VoidCallback toNextPage;
  final VoidCallback toPreviousPage;

  const StoryViewer({
    Key? key,
    required this.toNextPage,
    required this.toPreviousPage,
    required this.storyGroup,
    required this.storyGroupIndex,
    this.lateAvatar = false,
  }) : super(key: key);

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> with SingleTickerProviderStateMixin {
  final StoryController storyController = Get.find();
  late final AnimationController _animationController;
  late final List<Story> _stories;
  late final List<double> _watchedPercentages;
  late Timer timer;
  final stopwatch = Stopwatch();

  VideoPlayerController? _videoController;

  int _storyIndex = 0;

  _nextStory() {
    if (_storyIndex == _stories.length - 1) {
      storyController.setFinished(widget.storyGroupIndex);
      storyController.lastSeenIndex[widget.storyGroupIndex] = 0;
      widget.toNextPage();
    } else {
      timer = Timer(const Duration(milliseconds: 150), () {
        _animationController.forward(from: 0.0);
      });
      setState(() {
        _animationController.stop();
        _animationController.reset();
        _watchedPercentages[_storyIndex] = 1.0;
        _storyIndex++;
        _animationController.duration = Duration(seconds: _stories[_storyIndex].duration);
      });

      storyController.lastSeenIndex[widget.storyGroupIndex] = _storyIndex;
    }
  }

  _previousStory() {
    if (_storyIndex == 0) {
      widget.toPreviousPage();
    } else {
      timer = Timer(const Duration(milliseconds: 150), () {
        _animationController.forward(from: 0.0);
      });
      setState(() {
        _watchedPercentages[_storyIndex--] = 0.0;
        _animationController.duration = Duration(seconds: _stories[_storyIndex].duration);
      });
      storyController.lastSeenIndex[widget.storyGroupIndex] = _storyIndex;
    }
  }

  _attachVideoController(VideoPlayerController? controller) {
    _videoController = controller;
  }

  late final List<Widget> children;

  @override
  void initState() {
    super.initState();

    _storyIndex = storyController.lastSeenIndex[widget.storyGroupIndex];

    _stories = widget.storyGroup.stories;
    _watchedPercentages = List.filled(_stories.length, 0.0);
    if (_storyIndex > 0) {
      for (var i = 0; i < _storyIndex; ++i) {
        _watchedPercentages[i] = 1.0;
      }
    }

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _stories[_storyIndex].duration),
    );

    _animationController.addListener(() {
      setState(() {
        _watchedPercentages[_storyIndex] = _animationController.value;
      });
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
        if (_storyIndex < _stories.length) {
          Future.delayed(const Duration(milliseconds: 100), () {
            _animationController.forward(from: 0.0);
          });
        }
      }
    });

    timer = Timer(const Duration(milliseconds: 300), () {
      _animationController.forward();
    });

    children = _stories.mapIndexed((index, element) {
      if (element.storyType == StoryType.image) {
        return Image.network(
          key: ValueKey('story_$index'),
          element.url,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Container(
              color: Colors.black,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            );
          },
        );
      } else {
        return MyVideoPlayer(
          key: ValueKey('story$index'),
          story: element,
          callback: _attachVideoController,
        );
      }
    }).toList();
  }

  @override
  void dispose() {
    timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  double _getDurationContainerRatio(double width) {
    final int total =
        _stories.fold<int>(0, (previousValue, element) => previousValue + element.duration);
    final count = _stories.length;
    return (width - 24 - (3 * (count - 1))) / total;
  }

  void _resume() {
    stopwatch.stop();
    stopwatch.reset();
    _animationController.forward();
    if (_videoController != null) {
      _videoController!.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final ratio = _getDurationContainerRatio(width);
    final AvatarController avatarController = Get.find();

    return SafeArea(
      child: GestureDetector(
        onTapDown: (details) {
          stopwatch.start();
          _animationController.stop(canceled: false);
          if (_videoController != null) {
            _videoController!.pause();
          }
        },
        onTapUp: (details) {
          stopwatch.stop();
          int sec = stopwatch.elapsedMilliseconds;
          stopwatch.reset();
          if (sec < 200) {
            if (details.globalPosition.dx < width / 2) {
              _previousStory();
            } else {
              _nextStory();
            }
          } else {
            _resume();
          }
        },
        onLongPressCancel: _resume,
        onPanEnd: (_) => _resume(),
        onLongPressUp: _resume,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black,
                alignment: Alignment.center,
                child: children[_storyIndex],
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              width: width - 24,
              height: 4,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _stories
                    .mapIndexed((index, e) => Container(
                          clipBehavior: Clip.antiAlias,
                          width: e.duration * ratio,
                          decoration: const BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x22000000),
                                spreadRadius: 0.8,
                                blurRadius: 0.8,
                                offset: Offset.zero,
                              )
                            ],
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            color: Color(0x99FFFFFF),
                          ),
                          alignment: Alignment.centerLeft,
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Container(
                                color: Colors.white,
                                width: e.duration * ratio * _watchedPercentages[index],
                              );
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
            !widget.lateAvatar
                ? Positioned(
                    top: 82.8 - MediaQuery.of(context).viewPadding.top,
                    left: 18.9,
                    child: CircleAvatar(
                      foregroundImage: NetworkImage(widget.storyGroup.userImageUrl),
                      backgroundColor: Colors.blueGrey,
                      radius: 36 * 0.7,
                      child: Text(widget.storyGroup.userInitials),
                    ),
                  )
                : Obx(
                    () => avatarController.avatarAnimationFinished.isTrue
                        ? Positioned(
                            top: 82.8 - MediaQuery.of(context).viewPadding.top,
                            left: 18.9,
                            child: CircleAvatar(
                              foregroundImage: NetworkImage(widget.storyGroup.userImageUrl),
                              backgroundColor: Colors.blueGrey,
                              radius: 36 * 0.7,
                              child: Text(widget.storyGroup.userInitials),
                            ),
                          )
                        : Container(),
                  ),
          ],
        ),
      ),
    );
  }
}
