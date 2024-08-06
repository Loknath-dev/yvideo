import 'package:flutter/material.dart';
import 'package:yvideo/Layout/helper.dart';

class GetVideo extends StatefulWidget {
  const GetVideo({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GetVideoState createState() => _GetVideoState();
}

class _GetVideoState extends State<GetVideo> {
  late List link;

  @override
  void initState() {
    super.initState();
    getLink();
  }

  Future<void> getLink() async {
    link = await fetchVideoDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Y video',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.amber,
        ),
        backgroundColor: Colors.white,
        body: ElevatedButton(
            onPressed: () async {
              debugPrint("$link");
            },
            child: const Text('data')));
  }
}
