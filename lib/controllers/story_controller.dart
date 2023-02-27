import 'dart:math';

import 'package:get/get.dart';
import 'package:my_stories/models/story.dart';
import 'package:my_stories/models/story_group.dart';

class StoryController extends GetxController {
  final storyGroups = List<StoryGroup>.empty(growable: true).obs;
  final lastSeenIndex = List<int>.empty(growable: true).obs;
  final finished = List<bool>.empty(growable: true).obs;

  @override
  void onInit() {
    super.onInit();

    fetchStories();
  }

  setFinished(int index) => finished[index] = true;
  setLastFinished(int index, int last) => lastSeenIndex[index] = last;

  void fetchStories() async {
    List<Story> videoStories = [
      Story(storyType: StoryType.video, url: 'https://assets.mixkit.co/videos/preview/mixkit-little-girl-jumping-on-the-bed-43358-small.mp4', duration: 12),
      Story(storyType: StoryType.video, url: 'https://assets.mixkit.co/videos/preview/mixkit-violinist-playing-a-sheet-music-in-a-recording-studio-41714-small.mp4', duration: 9),
      Story(storyType: StoryType.video, url: 'https://assets.mixkit.co/videos/preview/mixkit-violinist-playing-a-sheet-music-in-a-recording-studio-41714-small.mp4', duration: 9),
      Story(storyType: StoryType.video, url: 'https://assets.mixkit.co/videos/preview/mixkit-man-traveling-fast-by-motorcycle-on-a-road-39931-small.mp4', duration: 10),
      Story(storyType: StoryType.video, url: 'https://assets.mixkit.co/videos/preview/mixkit-two-women-making-earthenware-vases-side-by-side-40025-small.mp4', duration: 8),
      Story(storyType: StoryType.video, url: 'https://assets.mixkit.co/videos/preview/mixkit-slowly-descending-a-rocky-mountain-34582-small.mp4', duration: 12),
      Story(storyType: StoryType.video, url: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', duration: 4),
    ];

    storyGroups.removeRange(0, storyGroups.length);
    lastSeenIndex.removeRange(0, lastSeenIndex.length);
    finished.removeRange(0, finished.length);

    final randomStoryGroupCount = Random().nextInt(5) + 5;

    for (var i = 0; i < randomStoryGroupCount; ++i) {
      final randomStoryCount = Random().nextInt(3) + 5;
      final List<Story> stories = [];

      for (var j = 0; j < randomStoryCount; ++j) {
        if (Random().nextBool()) {
          stories.add(videoStories[Random().nextInt(6)]);
        } else {
          stories.add(Story(
            storyType: StoryType.image,
            url: 'https://picsum.photos/id/${Random().nextInt(60) + 20}/600/1200.jpg',
          ));
        }
      }

      lastSeenIndex.add(0);
      finished.add(false);
      storyGroups.add(StoryGroup(
        userInitials: String.fromCharCodes(List.generate(2, (index) => Random().nextInt(25) + 65)),
        userImageUrl: 'https://i.pravatar.cc/256?img=${Random().nextInt(60)}',
        stories: stories,
      ));
    }
  }
}
