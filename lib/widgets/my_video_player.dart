import 'package:flutter/material.dart';
import 'package:my_stories/models/story.dart';
import 'package:video_player/video_player.dart';

class MyVideoPlayer extends StatefulWidget {
  final Story story;
  final void Function(VideoPlayerController?) callback;

  const MyVideoPlayer({
    Key? key,
    required this.story,
    required this.callback,
  }) : super(key: key);

  @override
  State<MyVideoPlayer> createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  late VideoPlayerController videoController;

  @override
  void initState() {
    super.initState();
    videoController = VideoPlayerController.network(widget.story.url)
      ..initialize().then((_) {
        widget.callback(videoController);
        setState(() {});
        videoController.play();
        videoController.setLooping(true);
      });
  }

  @override
  void dispose() {
    widget.callback(null);
    videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return videoController.value.isInitialized
        ? AspectRatio(
            aspectRatio: videoController.value.aspectRatio,
            child: VideoPlayer(videoController),
          )
        : Container();
  }
}
