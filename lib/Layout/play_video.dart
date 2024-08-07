import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:list_all_videos/thumbnail/ThumbnailTile.dart';

class PlayVideo extends StatefulWidget {
  const PlayVideo(
      {super.key,
      required this.urlLink,
      required this.index,
      required this.playList});
  final String urlLink;
  final List playList;
  final int index;
  @override
  // ignore: library_private_types_in_public_api
  _PlayVideoState createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  late VlcPlayerController _videoPlayerController;
  late Duration _videoDuration = Duration.zero;
  late Duration _videoPosition = Duration.zero;
  bool isPlaying = false;
  bool isLoading = true;
  bool _isFullScreen = false;
  double _opacity = 0.0;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _videoPlayerController = VlcPlayerController.file(
      File("/${widget.urlLink}"),
      autoPlay: true,
      options: VlcPlayerOptions(),
    )
      ..addListener(() {
        setState(() {
          _videoPosition = _videoPlayerController.value.position;
          _videoDuration = _videoPlayerController.value.duration;
          isPlaying = _videoPlayerController.value.isPlaying;
          isLoading = _videoPlayerController.value.isBuffering;

          if (_videoPlayerController.value.isEnded) {
            _videoPlayerController.stop();
          }
        });
      })
      ..addOnInitListener(() {
        setState(() {
          isPlaying = true;
        });
      });

    // Handle orientation change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isFullScreen) {
        _setFullScreen();
      }
    });
  }

  @override
  void dispose() async {
    super.dispose();
    await _videoPlayerController.stop();
    await _videoPlayerController.stopRendererScanning();
    await _videoPlayerController.dispose();
  }

  @override
  void deactivate() async {
    await _videoPlayerController.stop();
    super.deactivate();
  }

  void _setFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      // Hide system UI and lock orientation to landscape
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    } else {
      // Show system UI and allow portrait orientation
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    // Trigger a rebuild to adjust size and orientation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _changeUrl(String url) async {
    await _videoPlayerController.setMediaFromFile(File("/$url"));
    await _videoPlayerController.play();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double aspectRatio = _isFullScreen ? size.aspectRatio : 16 / 9;
    return Scaffold(
      appBar: !_isFullScreen
          ? AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Y Video'),
              backgroundColor: Colors.amber,
            )
          : null,
      body: Container(
        margin: _isFullScreen
            ? const EdgeInsets.all(0)
            : const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    margin: _isFullScreen
                        ? const EdgeInsets.all(0)
                        : const EdgeInsets.only(bottom: 80),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() {
                            _opacity = 1.0;
                            Future.delayed(const Duration(seconds: 3))
                                .then((value) => _opacity = 0);
                          }),
                          child: Container(
                            width: size.width,
                            height: _isFullScreen
                                ? size.height
                                : size.height * 0.35,
                            color: Colors.black87,
                            child: VlcPlayer(
                              controller: _videoPlayerController,
                              aspectRatio: aspectRatio,
                              virtualDisplay: true,
                              placeholder: const Center(
                                  child: CircularProgressIndicator()),
                            ),
                          ),
                        ),
                        if (isLoading)
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: _isFullScreen ? _opacity : 1.0,
                    duration: const Duration(seconds: 1),
                    child: Positioned(
                      bottom: _isFullScreen ? 10 : 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        width: size.width,
                        color: const Color.fromARGB(146, 0, 0, 0),
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.zero,
                              child: SliderTheme(
                                data: const SliderThemeData(
                                  thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 2,
                                  ),
                                  overlayShape:
                                      RoundSliderOverlayShape(overlayRadius: 6),
                                  overlayColor:
                                      Color.fromARGB(255, 252, 60, 46),
                                  activeTrackColor: Colors.red,
                                ),
                                child: Slider(
                                  value: _videoPosition.inSeconds.toDouble(),
                                  min: 0,
                                  max: _videoDuration.inSeconds.toDouble(),
                                  onChanged: (duration) {
                                    _videoPlayerController.seekTo(
                                      _videoDuration = Duration(
                                        seconds: duration.toInt(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "${formatDuration(_videoPosition)}/${formatDuration(_videoDuration)}",
                                textAlign: TextAlign.left,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.volume_up),
                                  color: Colors.white,
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.skip_previous),
                                      color: Colors.white,
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        isPlaying
                                            ? _videoPlayerController.pause()
                                            : _videoPlayerController.play();
                                      },
                                      icon: isPlaying
                                          ? const Icon(Icons.pause)
                                          : const Icon(Icons.play_arrow),
                                      color: Colors.white,
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.skip_next),
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: _setFullScreen,
                                  icon: _isFullScreen
                                      ? const Icon(Icons.fullscreen_exit)
                                      : const Icon(Icons.fullscreen),
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (!_isFullScreen)
                Container(
                  color: Colors.black38,
                  margin: const EdgeInsets.only(top: 2),
                  width: size.width,
                  height: size.height * 0.1,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    widget.playList[_currentIndex].videoName,
                    maxLines: 2,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
              Container(
                color: Colors.black26,
                margin: const EdgeInsets.symmetric(vertical: 3),
                width: size.width,
                height: size.height * 0.3,
                padding: const EdgeInsets.all(5),
                child: AnimatedList(
                    key: _listKey,
                    physics: const BouncingScrollPhysics(),
                    initialItemCount: widget.playList.length,
                    itemBuilder: (context, index, animation) {
                      final currentVideo = widget.playList[index];
                      return ListTile(
                        hoverColor: Colors.black54,
                        focusColor: Colors.blueGrey,
                        splashColor: Colors.lightBlue,
                        tileColor: _currentIndex == index
                            ? Colors.black26
                            : Colors.white,
                        onTap: () => {
                          if (_currentIndex != index)
                            {
                              setState(() {
                                _currentIndex = index;
                              }),
                              _changeUrl(currentVideo.videoPath)
                            }
                        },
                        title: Text(
                          currentVideo.videoName,
                          maxLines: 1,
                          style: const TextStyle(
                              fontSize: 18, overflow: TextOverflow.ellipsis),
                        ),
                        leading:
                            Stack(alignment: Alignment.bottomRight, children: [
                          ThumbnailTile(
                            thumbnailController:
                                currentVideo.thumbnailController,
                          ),
                          if (index == _currentIndex)
                            Container(
                              color: Colors.black54,
                              padding: const EdgeInsets.only(left: 5),
                              child: const Text(
                                "Now Playing...",
                                style: TextStyle(color: Colors.green),
                              ),
                            )
                        ]),
                        subtitle: Text(
                          "size: ${currentVideo.videoSize}",
                        ),
                      );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
