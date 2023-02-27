enum StoryType { image, video }

class Story {
  final StoryType storyType;
  final String url;
  final int duration;

  Story({
    required this.storyType,
    required this.url,
    this.duration = 5,
  });
}
