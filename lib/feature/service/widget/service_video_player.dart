import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:demandium/utils/core_export.dart';

class ServiceVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? thumbUrl;
  const ServiceVideoPlayer({super.key, required this.videoUrl, this.thumbUrl});

  @override
  State<ServiceVideoPlayer> createState() => _ServiceVideoPlayerState();
}

class _ServiceVideoPlayerState extends State<ServiceVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  String? errorMessage;

  Future<void> initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _videoPlayerController.initialize();
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          aspectRatio: _videoPlayerController.value.aspectRatio,
          autoPlay: false,
          looping: false,
          placeholder: widget.thumbUrl != null && widget.thumbUrl!.isNotEmpty
              ? CustomImage(image: widget.thumbUrl!, fit: BoxFit.cover, height: double.infinity, width: double.infinity,)
              : null,
          autoInitialize: true,
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(errorMessage, style: const TextStyle(color: Colors.white)),
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
    if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized) {
      return Chewie(controller: _chewieController!);
    } else {
       return widget.thumbUrl != null && widget.thumbUrl!.isNotEmpty 
           ? CustomImage(image: widget.thumbUrl!, fit: BoxFit.cover, height: double.infinity, width: double.infinity,) 
           : Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 const CircularProgressIndicator(),
                 const SizedBox(height: 10),
                 Text("Loading Video...", style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
               ],
             ),
           );
    }
  }
}
