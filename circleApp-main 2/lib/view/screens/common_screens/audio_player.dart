import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:circleapp/controller/getx_controllers/messenger_controller.dart';
import 'package:circleapp/view/custom_widget/common_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

Widget audioPlayerItem(
    {required BuildContext context,
    required MessengerController controller,
      required AudioPlayer player,
    required bool isCurrentUser,
    required Callback buttonpress,
    required Function(double) onChange}) {
  return Obx(
    () => !controller.isAudioInitialized.value
        ? commonShimmer(height: 8.h, width: 100.w)
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  buttonpress();
                },
                child: Icon(
                  controller.isPlaying.value ? Icons.pause_circle_rounded : Icons.play_circle_fill_rounded,
                  color: isCurrentUser ? const Color(0xff383838) : Colors.white,
                  size: 35.px,
                ),
              ),
              Expanded(
                child: StreamBuilder<Duration?>(
                  stream: player.onPositionChanged,
                  builder: (context, snapshot) {
                    return Container(
                      margin: EdgeInsets.only(right: 5.px, left: 5.px),
                      child: ProgressBar(
                        thumbRadius: 7.px,
                        progressBarColor: isCurrentUser ? const Color(0xff383838) : Colors.white,
                        baseBarColor: const Color.fromARGB(255, 208, 204, 204),
                        thumbColor: isCurrentUser ? const Color(0xff383838) : Colors.white,
                        barCapShape: BarCapShape.round,
                        timeLabelLocation: TimeLabelLocation.none,
                        timeLabelType: TimeLabelType.totalTime,
                        progress: snapshot.data ?? Duration.zero,
                        buffered: Duration(seconds: controller.progress.value.toInt()),
                        total: Duration(milliseconds: controller.duration.value.inMilliseconds.toInt()),
                        onSeek: (duration) {
                          player.seek(duration);
                        },
                      ),
                    );
                  },
                ),
              ),
              Text(
                _formatDuration(controller.position.value),
                style: TextStyle(
                  color: isCurrentUser ? const Color(0xff383838) : Colors.white,
                ),
              ),
            ],
          ),
  );
}

String _formatDuration(Duration duration) {
  return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
}
