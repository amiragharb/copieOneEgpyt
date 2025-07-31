import 'package:flutter/material.dart';
import 'package:better_player_enhanced/better_player.dart';

class MP4CoverVideo extends StatefulWidget {
  final String videoUrl;

  const MP4CoverVideo(this.videoUrl, {Key? key}) : super(key: key);

  @override
  _MP4CoverVideoState createState() => _MP4CoverVideoState();
}

class _MP4CoverVideoState extends State<MP4CoverVideo> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();

    final betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoUrl,
    );

    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: true,
        looping: false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enablePlaybackSpeed: false,
        ),
      ),
      betterPlayerDataSource: betterPlayerDataSource,
    );
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: BetterPlayer(controller: _betterPlayerController),
        ),
      ),
    );
  }
}
