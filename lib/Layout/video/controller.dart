import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class AudioTracksExample extends StatefulWidget {
  const AudioTracksExample({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AudioTracksExampleState createState() => _AudioTracksExampleState();
}

class _AudioTracksExampleState extends State<AudioTracksExample> {
  late VlcPlayerController _vlcPlayerController;
  late Duration _videoDuration = Duration.zero;
  late Duration _videoPosition = Duration.zero;
  bool _isFullScreen = false;
  Map<int, String> _audioTracks = {};

  @override
  void initState() {
    super.initState();
    _vlcPlayerController = VlcPlayerController.network(
      'https://media.w3.org/2010/05/sintel/trailer.mp4',
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );

    _vlcPlayerController.addListener(() {
      if (_vlcPlayerController.value.isInitialized) {
        setState(() {
          _videoPosition = _vlcPlayerController.value.position;
          _videoDuration = _vlcPlayerController.value.duration;
        });
        _loadAudioTracks();
      }
    });
  }

  Future<void> _loadAudioTracks() async {
    try {
      final tracks = await _vlcPlayerController.getAudioTracks();
      setState(() {
        _audioTracks = tracks;
      });
      // ignore: empty_catches
    } catch (e) {}
  }

  void _setVolume(int volume) {
    _vlcPlayerController.setVolume(volume);
  }

  void _setAudioTrack(int trackIndex) {
    _vlcPlayerController.setAudioTrack(trackIndex);
  }

  void _toggleFullScreen() {
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

  void _skipTo(int seconds) {
    _vlcPlayerController.seekTo(Duration(seconds: seconds));
  }

  @override
  void dispose() {
    _vlcPlayerController.dispose();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double aspectRatio = _isFullScreen ? screenSize.aspectRatio : 16 / 9;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Tracks Example'),
      ),
      body: Column(
        children: [
          Container(
            color: const Color.fromARGB(255, 255, 243, 208),
            width: screenSize.width * 0.8,
            height: screenSize.height * 0.2,
            child: Center(
              child: ListView.builder(
                itemCount: _audioTracks.length,
                itemBuilder: (context, index) {
                  final track = _audioTracks.entries.elementAt(index);
                  return ListTile(
                    title: Text('track:${track.value}'),
                    onTap: () {
                      _setAudioTrack(track.key);
                    },
                  );
                },
              ),
            ),
          ),
          Center(
            child: VlcPlayer(
              controller: _vlcPlayerController,
              aspectRatio: aspectRatio,
              virtualDisplay: true,
              placeholder: const Center(child: CircularProgressIndicator()),
            ),
          ),
          Slider(
            value: _videoPosition.inSeconds.toDouble(),
            min: 0.0,
            max: _videoDuration.inSeconds.toDouble(),
            onChanged: (value) {
              _vlcPlayerController.seekTo(Duration(seconds: value.toInt()));
            },
          ),
          Text(formatDuration(_videoPosition)),
          ElevatedButton(
            child: Text('skeep 10'),
            onPressed: () {
              _skipTo((_videoPosition.inSeconds + 10)
                  .clamp(0, _videoDuration.inSeconds));
            },
          ),
          ElevatedButton(
            onPressed: () =>
                {_setVolume(10), print('$_audioTracks')}, // Set volume to 100%
            child: const Text('Set Volume to 10'),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: Icon(
                _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                color: const Color.fromARGB(255, 253, 28, 28),
              ),
              onPressed: _toggleFullScreen,
            ),
          ),
        ],
      ),
    );
  }
}
