// import 'dart:html';

import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:space_app/FullScreenVideo.dart';
import 'package:video_player/video_player.dart';


class Videos extends StatefulWidget {
  @override
  _VideosState createState() => _VideosState();
}

class _VideosState extends State<Videos> {


  final fb = FirebaseDatabase.instance.reference().child("VideosLink");
  List<String> lists = List();
  // FirebaseAuth mAuth = FirebaseAuth.instance;
  File _imageFile;
  String _uploadUrl;
  final picker = ImagePicker();

  String Createrandom([int length = 32]){
    final Random _random = Random.secure();
    var values = List<int>.generate(length, (index) => _random.nextInt(256));
    return base64Url.encode(values);

  }

  Future pickVideo() async {

    final pickedFile = await picker.getVideo(source: ImageSource.gallery);

    setState(() async {
      _imageFile = File(pickedFile.path);
      String fileName = basename(_imageFile.path);
      StorageReference firebaseStorageRef =
      FirebaseStorage.instance.ref().child('Videos/$fileName');
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(_imageFile, StorageMetadata(contentType: 'video/mp4'));
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      taskSnapshot.ref.getDownloadURL().then(
            (value) => print("Done: $value"),
      );

      firebaseStorageRef.getDownloadURL().then((value) {
        _uploadUrl = value;

        if(_uploadUrl != null)
        {
          dynamic key = Createrandom(32);
          fb.child(key).set({
            "id": key,
            "link" : _uploadUrl
          }).then((value){
            print("upload video is done");
          });


        }
        else{
          print("url is null !!");
        }
      });
    });
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    // _pageController = PageController();
    fb.once().then((DataSnapshot snapshot){
      print(snapshot);
      var data = snapshot.value;
      lists.clear();
      data.forEach((key, value){
        lists.add(value["link"]);
        print(lists);
      });
      setState(() {
        print("value is ${lists.length}");
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        gradient: LinearGradient(colors: [Colors.green, Colors.red]),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  print("videos vadu page");
                  pickVideo();
                },
                child: Icon(
                  Icons.add,
                  size: 26.0,
                ),
              )
          ),
        ],
        centerTitle: true,
        title: Text("Videos"),
      ),
      body: GridView.count(
        crossAxisCount: 3 ,
        children: List.generate(lists.length,(index){
          return Center(
            child: SelectCard(
              url: lists[index],
            ),
          );
        }),
      ),
    );
  }
}


class SelectCard extends StatefulWidget {


  final String url;
  SelectCard({Key key, this.url}) : super(key: key);

  @override
  _SelectCardState createState() => _SelectCardState();
}

class _SelectCardState extends State<SelectCard> {

  // VideoPlayerController _controller = VideoPlayerController.network("$url");
  VideoPlayerController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // print(widget.url);
    _controller =
        VideoPlayerController.network("$url");

    _controller.addListener(() {
      setState(() {

      });
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


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        print(widget.url);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenVideo(
              newurl: widget.url,
            ),
          ),
        );
      },
      child: Card(
          color: Colors.orange,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
                VideoPlayer(_controller),
                // ClosedCaption(text: _controller.value.caption.text),
                // _ControlsOverlay(controller: _controller),
                VideoProgressIndicator(_controller, allowScrubbing: true),
              ],
          )
      ),
    );
  }
}
