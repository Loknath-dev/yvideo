import 'package:flutter/material.dart';

class VideoPreview extends StatefulWidget {
  const VideoPreview(
      {super.key,
      required this.thambnail,
      required this.name,
      required this.size,
      required this.url});
  // ignore: prefer_typing_uninitialized_variables
  final thambnail, name, size, url;

  @override
  // ignore: library_private_types_in_public_api
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () async {
       
      },
      child: Container(
        margin: const EdgeInsets.all(5),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: size.width,
                  height: size.height * 0.25,
                  color: Colors.black45,
                  child: widget.thambnail,
                ),
                Container(
                  alignment: Alignment.center,
                  child: const CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: Icon(
                      Icons.play_arrow,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              color: const Color.fromARGB(255, 0, 0, 0),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              margin: const EdgeInsets.symmetric(vertical: 2),
              width: size.width,
              height: size.height * 0.07,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: size.width * 0.7,
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    alignment: Alignment.topLeft,
                    child: Text(
                      '${widget.name}',
                      textAlign: TextAlign.start,
                      textDirection: TextDirection.ltr,
                      maxLines: 2,
                      style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  Text(
                    'size: ${widget.size}',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
