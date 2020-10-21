import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';

class ImageView extends StatefulWidget {
  final String imgUrl;
  ImageView({@required this.imgUrl});

  @override
  _ImageViewState createState() => _ImageViewState();
}

final fb = FirebaseDatabase.instance.reference().child("LikeImage");

String Createrandom([int length = 32]){
  final Random _random = Random.secure();
  var values = List<int>.generate(length, (index) => _random.nextInt(256));
  return base64Url.encode(values);

}



class _ImageViewState extends State<ImageView> {

  Future<bool> onLikeButtonTapped(bool isLiked) async{
    /// send your request here
    // final bool success= await sendRequest();

    if (isLiked == false)
      {
        print("like karo");
        dynamic key = Createrandom(32);

        fb.child(key).set({
          "id": key,
          "link" : widget.imgUrl
        }).then((value){
          print("Image Liked !!");
          showToast("Your Image is saved in LikedImage", gravity: Toast.BOTTOM);
        });
      }
    else if (isLiked == true)
      {
        print("like nai thay");
      }


    /// if failed, you can do nothing
    // return success? !isLiked:isLiked;
    return !isLiked;
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Hero(
            tag: widget.imgUrl,
            child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Image.network(widget.imgUrl,fit: BoxFit.cover,)),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,

              children: <Widget>[
                GestureDetector(
                  onTap: (){
                    _save();
                    Navigator.pop(context);
                  },
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0Xff1C1B1B).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(30),

                        ),
                        width: MediaQuery.of(context).size.width/2,


                      ),
                      Container(
                        width: MediaQuery.of(context).size.width/2,
                        height: 50,
                        padding: EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white54, width: 1),
                            gradient: LinearGradient(
                                colors: [
                                  Color(0X36FFFFFF),
                                  Color(0X0FFFFFFF)
                                ]
                            )
                        ),
                        child:Column(
                          children: <Widget>[
                            Text('Set Wallpaper',style: TextStyle(fontSize: 15,color: Colors.white70)),
                            Text('Image will be stored in gallery',style: TextStyle(fontSize: 10,color: Colors.white70),),
                          ],
                        ),
                      ),
                    ],
                  ),

                ),
                SizedBox(height: 16,),
                GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Text("Cancel",style: TextStyle(color: Colors.white),)),
                LikeButton(
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
                SizedBox(height: 70,)
              ],
            ),
          )
        ],
      ),
    );

  }
  _save() async {
    if(Platform.isAndroid) {
      // await _askPermission();
    }
    var response = await Dio().get(widget.imgUrl,
        options: Options(responseType: ResponseType.bytes));
    final result =
    await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
        quality: 100);
    print(result);
    Navigator.pop(context);
  }

  // _askPermission() async {
  //   if (Platform.isIOS) {
  //     /*Map<PermissionGroup, PermissionStatus> permissions =
  //         */await PermissionHandler()
  //         .requestPermissions([PermissionGroup.photos]);
  //   } else {
  //     /* PermissionStatus permission = */await PermissionHandler()
  //         .checkPermissionStatus(PermissionGroup.storage);
  //   }
  // }

}