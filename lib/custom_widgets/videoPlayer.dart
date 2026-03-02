//
//
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
//
// class _VideoPlayerWidget extends StatefulWidget {
//   final String videoUrl;
//
//   const _VideoPlayerWidget({required this.videoUrl});
//
//   @override
//   State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
// }
//
// class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
//   late VideoPlayerController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.network(widget.videoUrl)
//       ..initialize().then((_) {
//         setState(() {});
//       });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Center(
//           child: _controller.value.isInitialized
//               ? AspectRatio(
//             aspectRatio: _controller.value.aspectRatio,
//             child: VideoPlayer(_controller),
//           )
//               : const CircularProgressIndicator(),
//         ),
//         Positioned(
//           bottom: 20,
//           left: 20,
//           child: IconButton(
//             icon: Icon(
//               _controller.value.isPlaying
//                   ? Icons.pause
//                   : Icons.play_arrow,
//               color: Colors.white,
//               size: 30,
//             ),
//             onPressed: () {
//               setState(() {
//                 _controller.value.isPlaying
//                     ? _controller.pause()
//                     : _controller.play();
//               });
//             },
//           ),
//         ),
//         Positioned(
//           top: 10,
//           right: 10,
//           child: IconButton(
//             icon: const Icon(Icons.close, color: Colors.white),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ),
//       ],
//     );
//   }
// }
