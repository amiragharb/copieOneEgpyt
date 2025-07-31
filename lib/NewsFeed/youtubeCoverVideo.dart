import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeCoverVideo extends StatefulWidget {
  final String videoURL;

  YoutubeCoverVideo(this.videoURL);

  @override
  _YoutubeCoverVideoState createState() => _YoutubeCoverVideoState();
}

class _YoutubeCoverVideoState extends State<YoutubeCoverVideo> {
  late YoutubePlayerController _youtubePlayerController;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoURL) ?? '';
    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        isLive: false,
      ),
    );
  }

  @override
  void dispose() {
    _youtubePlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _youtubePlayerController,
    );
  }
}
