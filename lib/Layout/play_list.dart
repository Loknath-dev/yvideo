import 'package:flutter/material.dart';
import 'package:list_all_videos/list_all_videos.dart';
import 'package:list_all_videos/model/video_model.dart';
import 'package:list_all_videos/thumbnail/ThumbnailTile.dart';
import 'package:permission_handler/permission_handler.dart';

class PlayList extends StatefulWidget {
  const PlayList({super.key, required this.play});
  final ValueChanged<String> play;

  @override
  // ignore: library_private_types_in_public_api
  _PlayListState createState() => _PlayListState();
}

class _PlayListState extends State<PlayList> {
  Future<List<VideoDetails>>? _videoFuture;
  @override
  void initState() {
    super.initState();
    // Request permissions and then initialize _videoFuture
    _initialize();
  }

  Future<void> _initialize() async {
    // Request permissions
    final status = await Permission.storage.request();
    if (status.isGranted) {
      // Initialize the Future after permission is granted
      _videoFuture = ListAllVideos().getAllVideosPath();
      setState(() {}); // Trigger rebuild to use the Future
    } else {
      // Handle the case when the user denies the permission
      debugPrint('Storage permission is not granted');
      // You could show an error message or handle this situation appropriately
      _videoFuture =
          Future.value([]); // Provide an empty list if permission is denied
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VideoDetails>>(
      future: _videoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return const Center(child: Text('No videos found.'));
        } else {
          final videoList = snapshot.data!;
          return AnimatedList(
              initialItemCount: videoList.length,
              itemBuilder: (context, index, animation) {
                final currentVideo = videoList[index];
                return ListTile(
                  hoverColor: Colors.black54,
                  focusColor: Colors.blueGrey,
                  splashColor: Colors.lightBlue,
                  onTap: () => {widget.play(currentVideo.videoPath)},
                  title: Text(
                    currentVideo.videoName,
                    maxLines: 1,
                    style: const TextStyle(
                        fontSize: 18, overflow: TextOverflow.ellipsis),
                  ),
                  leading: Stack(alignment: Alignment.center, children: [
                    ThumbnailTile(
                      thumbnailController: currentVideo.thumbnailController,
                    ),
                    const CircleAvatar(
                      backgroundColor: Colors.black38,
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                      ),
                    )
                  ]),
                  subtitle: Text(
                    "size: ${currentVideo.videoSize}",
                  ),
                );
              });
        }
      },
    );
  }
}
