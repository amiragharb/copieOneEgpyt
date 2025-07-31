import 'package:flutter/material.dart';
import 'package:better_player_enhanced/better_player.dart';

class MP4Video extends StatefulWidget {
  final String videoURL;

  MP4Video(this.videoURL, {Key? key}) : super(key: key);

  @override
  _MP4VideoState createState() => _MP4VideoState();
}

class _MP4VideoState extends State<MP4Video> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();
    BetterPlayerDataSource betterPlayerDataSource =
        BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          widget.videoURL,
        );

    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableFullscreen: true,
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
