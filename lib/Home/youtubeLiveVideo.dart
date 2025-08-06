import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:egpycopsversion4/l10n/app_localizations.dart';

class YoutubeLiveVideo extends StatefulWidget {
  final String url;
  final String isLive;
  final bool autoPlay;

  const YoutubeLiveVideo(this.url, this.isLive, this.autoPlay, {Key? key}) : super(key: key);

  @override
  _YoutubeLiveVideoState createState() => _YoutubeLiveVideoState();
}

class _YoutubeLiveVideoState extends State<YoutubeLiveVideo> {
  YoutubePlayerController? _youtubePlayerController;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    try {
      if (widget.url.isEmpty || !widget.url.contains('youtu')) return;
      _videoId = YoutubePlayer.convertUrlToId(widget.url);
      if (_videoId != null && _videoId!.isNotEmpty) {
        _youtubePlayerController = YoutubePlayerController(
          initialVideoId: _videoId!,
          flags: YoutubePlayerFlags(
            autoPlay: widget.autoPlay,
            isLive: false,
            mute: !widget.autoPlay,
            enableCaption: true,
            hideControls: false,
            controlsVisibleAtStart: true,
            forceHD: false,
            loop: false,
            disableDragSeek: false,
            useHybridComposition: true,
          ),
        );
      }
    } catch (_) {
      _youtubePlayerController = null;
      _videoId = null;
    }
  }

  @override
  void dispose() {
    try {
      _youtubePlayerController?.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (_youtubePlayerController == null || _videoId == null || _videoId!.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.grey[600], size: 48),
            const SizedBox(height: 8),
            Text(
              localizations?.videoNotAvailable ?? "Video not available",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: YoutubePlayer(
          controller: _youtubePlayerController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.redAccent,
          onReady: () {},
          onEnded: (metaData) {},
          bottomActions: [
            IconButton(
              icon: Icon(Icons.replay_10, color: Colors.white),
              onPressed: () {
                final position = _youtubePlayerController!.value.position;
                _youtubePlayerController!.seekTo(position - Duration(seconds: 10));
              },
            ),
            IconButton(
              icon: Icon(
                _youtubePlayerController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: () {
                final isPlaying = _youtubePlayerController!.value.isPlaying;
                isPlaying
                    ? _youtubePlayerController!.pause()
                    : _youtubePlayerController!.play();
              },
            ),
            IconButton(
              icon: Icon(Icons.forward_10, color: Colors.white),
              onPressed: () {
                final position = _youtubePlayerController!.value.position;
                _youtubePlayerController!.seekTo(position + Duration(seconds: 10));
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ProgressBar(
                isExpanded: true,
                colors: ProgressBarColors(
                  playedColor: Colors.red,
                  handleColor: Colors.redAccent,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FullScreenButton(),
          ],
          topActions: [
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _youtubePlayerController!.metadata.title,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white, size: 25),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
