import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:circleapp/controller/getx_controllers/messenger_controller.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../models/message_models/get_message_model.dart';
import '../screens/common_screens/audio_player.dart';
import '../screens/common_screens/full_screen_image.dart';
import '../screens/common_screens/video_player_screen.dart';
import 'common_shimmer.dart';
final Map<String, Uint8List> _thumbnailCache = {};


Widget mediaWidget(List<Media> media,
    {required BuildContext context, required var messengerController, required bool isCurrentUser}) {
  List<Media> imageAndVideo = [];
  List<Media> audios = [];
  for (var mediaItem in media) {
    switch (mediaItem.type) {
      case "image":
      case "video":
        imageAndVideo.add(mediaItem);
        break;
      case "audio":
        audios.add(mediaItem);
        break;
    }
  }

  if (imageAndVideo.isNotEmpty) {
    return GestureDetector(
      onTap: () {
        if (imageAndVideo.first.type == "image") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenImage(imageUrl: imageAndVideo.first.url),
            ),
          );
        }
      },
      child: imageAndVideo.first.type == "image"
          ? CachedNetworkImage(
              imageUrl: imageAndVideo.first.url,
              placeholder: (context, url) => commonShimmer(height: 100.px, width: 100.w),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            )
          : FutureBuilder(
              future: _getThumbnail(imageAndVideo.first.url),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: commonShimmer(height: 100.px, width: 100.w));
                } else if (snapshot.hasError) {
                  print("Video Thumbnail ${snapshot.error.toString()}");
                  return const Center(child: Icon(Icons.error));
                } else if (snapshot.hasData) {
                  return FittedBox(
                    fit: BoxFit.fill,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.px),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoPlayerScreen(videoUrl: imageAndVideo.first.url),
                            ),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.memory(
                              snapshot.data!,
                            ),
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(25.px),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), shape: BoxShape.circle),
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.black.withOpacity(0.4),
                                size: 60.px,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  print("Video Thumbnail ${imageAndVideo.first.url} ${snapshot.error.toString()}");
                  return const Center(child: Icon(Icons.error));
                }
              },
            ),
    );
  } else if (audios.isNotEmpty) {
    messengerController.setUpPlayer(audios.first.url);
    return audioPlayerItem(
      context: context,
      controller: messengerController,
      isCurrentUser: isCurrentUser,
      buttonpress: () {
        messengerController.playPause();
      },
      onChange: (value) {
        messengerController.player.seek(Duration(milliseconds: value.toInt()));
      }, player: messengerController.player,
    );
  } else {
    return const SizedBox();
  }
}

Future<Uint8List?> _getThumbnail(String videoUrl) async {
  if (_thumbnailCache.containsKey(videoUrl)) {
    return _thumbnailCache[videoUrl];
  }

  try {
    final thumbnailData = await VideoThumbnail.thumbnailData(
      video: videoUrl,
      imageFormat: ImageFormat.JPEG,
      quality: 75,
    );

    if (thumbnailData != null) {
      _thumbnailCache[videoUrl] = thumbnailData;
    }

    return thumbnailData;
  } catch (e) {
    return null;
  }
}