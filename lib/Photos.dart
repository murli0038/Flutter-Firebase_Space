import 'dart:convert';
// import 'dart:html';
import 'dart:math';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:space_app/FullScreenImage.dart';
import 'package:toast/toast.dart';

class Photos extends StatefulWidget {
  @override
  _PhotosState createState() => _PhotosState();
}

class _PhotosState extends State<Photos> {

  File _imageFile;
  final _auth = FirebaseAuth.instance;
  String userId;
  final picker = ImagePicker();
  String _uploadUrl;
  final fb = FirebaseDatabase.instance.reference().child("MyImage");
  List<String> lists = List();
  PageController _pageController;


  getCurrentUser() async
  {
    final user = await _auth.currentUser;
    final uid = user.uid;
    // Similarly we can get email as well
    //final uemail = user.email;
    userId = uid;
    print('User ID:  '+userId);
    print(user.email);

  }


  String Createrandom([int length = 32]){
    final Random _random = Random.secure();
    var values = List<int>.generate(length, (index) => _random.nextInt(256));
    return base64Url.encode(values);

  }


  Future pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() async {
      _imageFile = File(pickedFile.path);
      String fileName = basename(_imageFile.path);
      StorageReference firebaseStorageRef =
      FirebaseStorage.instance.ref().child('Images/$fileName');
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      taskSnapshot.ref.getDownloadURL().then(
            (value) => print("Done: $value"),
      );

      firebaseStorageRef.getDownloadURL().then((value) {
        _uploadUrl = value;

        if(_uploadUrl != null)
          {
            dynamic key = Createrandom(32);
            fb.child(userId).set({
              // "id": key,
              "link" : _uploadUrl
            }).then((value){
              print("upload image is done");
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
    getCurrentUser();
    _pageController = PageController();
    fb.orderByChild(userId).once().then((DataSnapshot snapshot)
    {
      if (snapshot.value != null)
        {
          print(snapshot);
          var data = snapshot.value;
          lists.clear();
          data.forEach((key, value){
            lists.add(value["link"]);
          });
          setState(() {
            print("value is ${lists.length}");
          });
        }
      else{
        print("this ID hs no Data !!");
      }

    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _pageController.dispose();
  }

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  void _onRefresh() async
  {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));

    fb.once().then((DataSnapshot snapshot){
      print(snapshot);
      var data = snapshot.value;
      lists.clear();
      data.forEach((key, value){
        lists.add(value["link"]);
      });

      setState(() {
        print("value is ${lists.length}");
      });

    });

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    fb.once().then((DataSnapshot snapshot){
      print(snapshot);
      var data = snapshot.value;
      lists.clear();
      data.forEach((key, value){
        lists.add(value["link"]);
      });
      setState(() {
        print("value is ${lists.length}");
      });
    });
    _refreshController.loadComplete();
  }



  @override
  Widget build(BuildContext context) {

    void showToast(String msg, {int duration, int gravity}) {
      Toast.show(msg, context, duration: duration, gravity: gravity);
    }

    double width = MediaQuery.of(context).size.width;
    // return Scaffold(
    //
    //   appBar: AppBar(
    //     actions: <Widget>[
    //       Padding(
    //           padding: EdgeInsets.only(right: 20.0),
    //           child: GestureDetector(
    //             onTap: () {
    //               print("photos vadu page");
    //               pickImage();
    //             },
    //             child: Icon(
    //               Icons.add,
    //               size: 26.0,
    //             ),
    //           )
    //       ),
    //     ],
    //     centerTitle: true,
    //     title: Text("Photos"),
    //   ),
    //   // body: Padding(
    //   //   padding: EdgeInsets.all(10),
    //   //   child: Container(
    //   //     height: 60,
    //   //     width: width,
    //   //     child: Expanded(
    //   //       child: lists.length == 0 ? Text("Loading") : ListView.builder(
    //   //         itemCount: lists.length,
    //   //           scrollDirection: Axis.horizontal,
    //   //           itemBuilder: (context, index){
    //   //           return Padding(
    //   //               padding: EdgeInsets.all(10),
    //   //             child: Container(
    //   //               height: 60,
    //   //               width: 60,
    //   //               decoration: BoxDecoration(
    //   //                 shape: BoxShape.circle,
    //   //                 border: Border.all(color: Colors.red),
    //   //                 image: DecorationImage(
    //   //                   fit: BoxFit.fill,
    //   //                   image: NetworkImage(
    //   //                     lists[index]
    //   //                   )
    //   //                 )
    //   //               ),
    //   //             ),
    //   //           );
    //   //           }
    //   //       ),
    //   //     ),
    //   //   ),
    //   // ),
    //   body:  GridView.count(
    //     crossAxisCount: 3,
    //     controller: _pageController,
    //     children: List.generate(lists.length, (index) {
    //       // return Center(
    //       //   // child: Text(
    //       //   //   'Item $index',
    //       //   //   style: Theme.of(context).textTheme.headline5,
    //       //   // ),
    //       //   child: Image(
    //       //     image: NetworkImage(lists[index]),
    //       //     fit: BoxFit.cover,
    //       //   )
    //       // );
    //       return Container(
    //         padding: EdgeInsets.all(2),
    //         decoration: BoxDecoration(
    //           borderRadius: BorderRadius.circular(10)
    //         ),
    //         child:  Image(
    //               image: NetworkImage(lists[index]),
    //               fit: BoxFit.cover,
    //          )
    //       );
    //     }),
    //   ),
    // );
    return Scaffold(
        appBar: GradientAppBar(
          gradient: LinearGradient(colors: [Colors.blue, Colors.green]),
            actions: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      print("photos vadu page");
                      pickImage();
                    },
                    child: Icon(
                      Icons.add,
                      size: 26.0,
                    ),
                  )
              ),
            ],
            centerTitle: true,
            title: Text("Photos"),
          ),
      body: SafeArea(
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: WaterDropHeader(),
          footer: CustomFooter(
            builder: (BuildContext context,LoadStatus mode){
              Widget body ;
              if(mode==LoadStatus.idle){
                body =  Text("pull up load");
              }
              else if(mode==LoadStatus.loading){
                body =  CupertinoActivityIndicator();
              }
              else if(mode == LoadStatus.failed){
                body = Text("Load Failed!Click retry!");
              }
              else if(mode == LoadStatus.canLoading){
                body = Text("release to load more");
              }
              else{
                body = Text("No more Data");
              }
              return Container(
                height: 55.0,
                child: Center(child:body),
              );
            },
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: GridView.count(
                crossAxisCount: 3,
                controller: _pageController,
                children: List.generate(lists.length, (index) {
                  // return Center(
                  //   // child: Text(
                  //   //   'Item $index',
                  //   //   style: Theme.of(context).textTheme.headline5,
                  //   // ),
                  //   child: Image(
                  //     image: NetworkImage(lists[index]),
                  //     fit: BoxFit.cover,
                  //   )
                  // );
                  return Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child:  GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageView(
                              imgUrl: lists[index],
                            ),
                          ),
                        );
                      },
                      child: Image(
                            image: NetworkImage(lists[index]),
                            fit: BoxFit.cover,
                       ),
                    )
                  );
                }),
              ),
          ),
        ),
    );
  }
}
