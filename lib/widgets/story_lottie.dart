import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../utils.dart';
import '../controller/story_controller.dart';

class LottieLoader {
  String url;
  LoadState state = LoadState.loading;
  Key? key;
  late LottieBuilder lottieBuilder;

  LottieLoader(this.url, this.key);

  void loadLottie(VoidCallback onComplete) {
    loadFutureLottie(onComplete);
  }

  Future<void> loadFutureLottie(VoidCallback onComplete) async {
    lottieBuilder = Lottie.network(url, key: this.key);
    this.state = LoadState.success;
    onComplete();
  }
}

class StoryLottie extends StatefulWidget {
  final StoryController? storyController;
  final LottieLoader lottieLoader;

  StoryLottie(this.lottieLoader, {this.storyController, Key? key})
      : super(key: key ?? UniqueKey());

  static StoryLottie url(String url,
      {StoryController? controller,
      Map<String, dynamic>? requestHeaders,
      Key? key}) {
    return StoryLottie(
      LottieLoader(url, key),
      storyController: controller,
      key: key,
    );
  }

  @override
  State<StatefulWidget> createState() {
    return StoryLottieState();
  }
}

class StoryLottieState extends State<StoryLottie>
    with TickerProviderStateMixin {
  late AnimationController playerController;

  StreamSubscription? _streamSubscription;

  @override
  void initState() {
    super.initState();
    playerController = AnimationController(vsync: this);

    widget.storyController!.pause();

    widget.lottieLoader.loadLottie(() {
      if (widget.lottieLoader.state == LoadState.success) {
        widget.storyController!.play();

        // if (widget.storyController != null) {
        //   _streamSubscription =
        //       widget.storyController!.playbackNotifier.listen((playbackState) {
        //     if (playbackState == PlaybackState.pause) {
        //       playerController.stop();
        //     } else {
        //       playerController.forward();
        //     }
        //   });
        // }
      } else {
        setState(() {});
      }
    });
  }

  Widget getContentView() {
    if (widget.lottieLoader.state == LoadState.success) {
      return Container(
        child: widget.lottieLoader.lottieBuilder,
      );
    }

    return widget.lottieLoader.state == LoadState.loading
        ? Center(
            child: Container(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          )
        : Center(
            child: Text(
            "Media failed to load.",
            style: TextStyle(
              color: Colors.white,
            ),
          ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: double.infinity,
      width: double.infinity,
      child: getContentView(),
    );
  }

  @override
  void dispose() {
    playerController.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }
}
