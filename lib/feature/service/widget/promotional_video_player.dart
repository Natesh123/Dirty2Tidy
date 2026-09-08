import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:demandium/utils/dimensions.dart';
import 'package:demandium/utils/styles.dart';

import 'package:demandium/helper/responsive_helper.dart';

class PromotionalVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? description;
  const PromotionalVideoPlayer({Key? key, required this.videoUrl, this.description}) : super(key: key);

  @override
  State<PromotionalVideoPlayer> createState() => _PromotionalVideoPlayerState();
}

class _PromotionalVideoPlayerState extends State<PromotionalVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _videoPlayerController.initialize();
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: false,
          looping: false,
          aspectRatio: _videoPlayerController.value.aspectRatio,
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        );
      });
    } catch (e) {
      debugPrint("Video Player Error: $e");
      setState(() {
        errorMessage = "Video Unavailable";
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       ResponsiveHelper.isDesktop(context) ?
       AspectRatio(
         aspectRatio: 16/9,
         child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Colors.black,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(controller: _chewieController!)
                : errorMessage != null
                    ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center))
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 10),
                            Text("Loading Video...", style: robotoRegular.copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
          ),
        ),
       ) :
        Container(
          height: 200,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Colors.black,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(controller: _chewieController!)
                : errorMessage != null
                    ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center))
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 10),
                            Text("Loading Video...", style: robotoRegular.copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
          ),
        ),
        if (widget.description != null && widget.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Text(
              widget.description!,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
          ),
      ],
    );
  }
}
