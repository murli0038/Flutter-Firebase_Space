import 'dart:convert';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:toast/toast.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideo extends StatefulWidget {

  final String newurl;
  FullScreenVideo({this.newurl});


  @override
  _FullScreenVideoState createState() => _FullScreenVideoState();
}

class _FullScreenVideoState extends State<FullScreenVideo> {

  VideoPlayerController _controller;
  final fb = FirebaseDatabase.instance.reference().child("LikeVideo");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = VideoPlayerController.network(widget.newurl);

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String Createrandom([int length = 32]){
    final Random _random = Random.secure();
    var values = List<int>.generate(length, (index) => _random.nextInt(256));
    return base64Url.encode(values);

  }

  Future<bool> onLikeButtonTapped(bool isLiked) async{
    /// send your request here
    // final bool success= await sendRequest();

    dynamic key = Createrandom(32);

    fb.child(key).set({
      "id": key,
      "link" : widget.newurl
    }).then((value){
      print("Video Liked !!");
      showToast("Your Video is saved in LikedVideo", gravity: Toast.BOTTOM);
    });
    /// if failed, you can do nothing
    // return success? !isLiked:isLiked;
    return !isLiked;
  }
  void showToast(String msg, {int duration, int gravity})
  {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(bottom: 60),
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(_controller),
                  // _ControlsOverlay(controller: _controller),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                ],
              ),
            ),
          ),
          Container(
            child: LikeButton(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              size: 60,
              circleColor:
              CircleColor(start: Color(0xff00ddff), end: Color(0xff0099cc)),
              onTap: onLikeButtonTapped,
              bubblesColor: BubblesColor(
                // dotPrimaryColor: Color(0xff33b5e5),
                  dotPrimaryColor: Colors.red,
                  // dotSecondaryColor: Color(0xff0099cc),
                  dotSecondaryColor: Colors.blue
              ),
              likeBuilder: (bool isLiked) {
                return Icon(
                  Icons.favorite,
                  color: isLiked ? Colors.red : Colors.grey,
                  size: 40,
                );
              },
              // likeCount: 665,
              // countBuilder: (int count, bool isLiked, String text) {
              //   var color = isLiked ? Colors.deepPurpleAccent : Colors.grey;
              //   Widget result;
              // if (count == 0) {
              //   result = Text(
              //     "love",
              //     style: TextStyle(color: color),
              //   );
              // } else
              //   result = Text(
              //     text,
              //     style: TextStyle(color: color),
              //   );
              // return result;
              // },
            ),
          ),
        ],
      ),
    );
    // return Scaffold(
    //   backgroundColor: Colors.white,
    //   body: SingleChildScrollView(
    //       child: Column(
    //         children: <Widget>[
    //           // Container(
    //           //   padding: const EdgeInsets.only(top: 20.0),
    //           // ),
    //           Container(
    //             padding: const EdgeInsets.all(5),
    //             child: AspectRatio(
    //               aspectRatio: _controller.value.aspectRatio,
    //               child: Stack(
    //                 alignment: Alignment.bottomCenter,
    //                 children: <Widget>[
    //                   VideoPlayer(_controller),
    //                   // _ControlsOverlay(controller: _controller),
    //                   VideoProgressIndicator(_controller, allowScrubbing: true),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //    )
    // );
  }
}
