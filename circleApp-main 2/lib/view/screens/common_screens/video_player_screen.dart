import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobx/mobx.dart' hide BoolExtension, DoubleExtension;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with ChangeNotifier {
  late VideoPlayerController _controller;
  late ReactionDisposer _positionListener;
  Rx<bool> isPlaying = false.obs;
  Rx<bool> isBuffering = false.obs;
  Rx<bool> isCompleted = false.obs;
  Rx<double> progress = (0.0).obs;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        _controller.addListener(() {
          progress.value = _controller.value.position.inMilliseconds.toDouble();
          isBuffering.value = _controller.value.isBuffering;
          isCompleted.value = _controller.value.isCompleted;
          isPlaying.value = _controller.value.isPlaying;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _positionListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.7),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 8,
            child: Container(
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  Obx(() => isBuffering.value && !isCompleted.value
                      ? LoadingAnimationWidget.progressiveDots(
                          color: Colors.white,
                          size: 50,
                        )
                      : !isPlaying.value
                          ? GestureDetector(
                              onTap: () {
                                play();
                              },
                              child: Container(
                                width: 80.px,
                                height: 80.px,
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(25.px),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), shape: BoxShape.circle),
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.black.withOpacity(0.4),
                                    size: 60.px,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox()),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.black,
            child: Obx(
              () => Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.black.withOpacity(0.5),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isPlaying.value ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        isPlaying.value ? pause() : play();
                      },
                    ),
                    Text(
                      _formatDuration(_controller.value.position),
                      style: const TextStyle(color: Colors.white),
                    ),
                    Expanded(
                      child: Slider(
                        value: progress.value,
                        min: 0,
                        max: _controller.value.duration.inMilliseconds.toDouble(),
                        onChanged: (value) {
                          _controller.seekTo(Duration(milliseconds: value.toInt()));
                          _controller.notifyListeners();
                        },
                      ),
                    ),
                    Text(
                      _formatDuration(_controller.value.duration),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void play() {
    isPlaying.value = true;
    _controller.play();
  }

  void pause() {
    isPlaying.value = false;
    _controller.pause();
  }

  String _formatDuration(Duration duration) {
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }
}
