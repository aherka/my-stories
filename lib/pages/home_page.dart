import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_stories/controllers/story_controller.dart';
import 'package:my_stories/pages/story_page.dart';
import 'package:my_stories/widgets/circle_button.dart';

extension GlobalPaintBounds on BuildContext {
  Rect? get globalPaintBounds {
    final renderObject = findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      final offset = Offset(translation.x + 10, translation.y + 10);
      return renderObject!.paintBounds.shift(offset);
    } else {
      return null;
    }
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final StoryController storyController = Get.put(StoryController());

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.lightBlueAccent[50],
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 140,
                child: Obx(
                  () => ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: storyController.storyGroups.length,
                    itemBuilder: (context, index) {
                      Widget avatar = CircleAvatar(
                        key: Key(index.toString()),
                        foregroundImage:
                            NetworkImage(storyController.storyGroups[index].userImageUrl),
                        backgroundColor: Colors.blueGrey,
                        radius: 36,
                        child: Text(storyController.storyGroups[index].userInitials),
                      );
                      return UnconstrainedBox(
                        child: LayoutBuilder(
                          builder: (buildContext, constraints) {
                            return Obx(
                              () => CircleButton(
                                finished: storyController.finished[index],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StoryPage(
                                        avatarBounds: buildContext.globalPaintBounds,
                                        avatar: avatar,
                                        selectedIndex: index,
                                      ),
                                    ),
                                  );
                                },
                                child: avatar,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Material(
                    borderRadius: BorderRadius.circular(200),
                    elevation: 1,
                    color: Colors.pinkAccent,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        storyController.fetchStories();
                      },
                      child: const SizedBox(
                        width: 120,
                        height: 120,
                        child: Center(
                          child: Icon(
                            Icons.restart_alt_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
