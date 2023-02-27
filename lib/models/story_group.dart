import 'package:my_stories/models/story.dart';

class StoryGroup {
  final String userInitials;
  final String userImageUrl;
  final List<Story> stories;
  int lastSeenIndex = 0;

  StoryGroup({
    required this.stories,
    required this.userInitials,
    required this.userImageUrl,
  });
}
