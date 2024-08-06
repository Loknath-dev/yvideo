import 'package:flutter/material.dart';
import 'package:list_all_videos/list_all_videos.dart';
import 'package:list_all_videos/model/video_model.dart';

Future<List<VideoDetails>> fetchVideoDetails() async {
  // Simulate a delay for fetching data

  // Fetch the video details
  List<VideoDetails> videoDetails = await ListAllVideos().getAllVideosPath();
  debugPrint("Fetched video details: $videoDetails");

  return videoDetails;
}
