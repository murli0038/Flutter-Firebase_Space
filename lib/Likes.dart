import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Likes extends StatefulWidget {
  @override
  _LikesState createState() => _LikesState();
}

class _LikesState extends State<Likes> with SingleTickerProviderStateMixin {
  // TabController to control and switch tabs
  TabController _tabController;

  // Current Index of tab
  int _currentIndex = 0;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final fb = FirebaseDatabase.instance.reference().child("LikeImage");
  List<String> lists = List();
  PageController _pageController;

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    fb.once().then((DataSnapshot snapshot) {
      print(snapshot);
      var data = snapshot.value;
      lists.clear();
      data.forEach((key, value) {
        lists.add(value["link"]);
      });
      setState(() {
        print("value is ${lists.length}");
      });
    });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    fb.once().then((DataSnapshot snapshot) {
      print(snapshot);
      var data = snapshot.value;
      lists.clear();
      data.forEach((key, value) {
        lists.add(value["link"]);
        print(lists);
      });
      setState(() {
        print("value is ${lists.length}");
      });
    });
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    _tabController =
        new TabController(vsync: this, length: 2, initialIndex: _currentIndex);
    _pageController = PageController();

      fb.once().then((DataSnapshot snapshot) {
        print(snapshot);
        var data = snapshot.value;
        lists.clear();
        data.forEach((key, value) {
          lists.add(value["link"]);
        });
        setState(() {
          print("value is ${lists.length}");
        });
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        gradient: LinearGradient(colors: [Colors.red, Colors.grey]),
        centerTitle: true,
        title: Text("Likes"),
      ),
      // body: Center(child: Text("Likes")),
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
            child: new Container(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Sign In Button
                  new FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.red[100])),
                    color: _currentIndex == 0 ? Colors.red[100] : Colors.white,
                    onPressed: () {
                      _tabController.animateTo(0);
                      setState(() {
                        _currentIndex = 0;
                      });
                    },
                    child: new Text("LikedImage"),
                  ),
                  // Sign Up Button
                  new FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.red[100])),
                    color: _currentIndex == 1 ? Colors.red[100] : Colors.white,
                    onPressed: () {
                      _tabController.animateTo(1);
                      setState(() {
                        _currentIndex = 1;
                      });
                    },
                    child: new Text("LikedVideo"),
                  )
                ],
              ),
            ),
          ),
          new Expanded(
            child: new TabBarView(
                controller: _tabController,
                // Restrict scroll by user
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Sign In View
                  Center(
                    child: SafeArea(
                      child: SmartRefresher(
                        enablePullDown: true,
                        enablePullUp: true,
                        header: WaterDropHeader(),
                        footer: CustomFooter(
                          builder: (BuildContext context, LoadStatus mode) {
                            Widget body;
                            if (mode == LoadStatus.idle) {
                              body = Text("pull up load");
                            } else if (mode == LoadStatus.loading) {
                              body = CupertinoActivityIndicator();
                            } else if (mode == LoadStatus.failed) {
                              body = Text("Load Failed!Click retry!");
                            } else if (mode == LoadStatus.canLoading) {
                              body = Text("release to load more");
                            } else {
                              body = Text("No more Data");
                            }
                            return Container(
                              height: 55.0,
                              child: Center(child: body),
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
                                    borderRadius: BorderRadius.circular(10)),
                                child: GestureDetector(
                                  onTap: () {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) => ImageView(
                                    //       imgUrl: lists[index],
                                    //     ),
                                    //   ),
                                    // );
                                  },
                                  child: Image(
                                    image: NetworkImage(lists[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ));
                          }),
                        ),
                      ),
                    ),
                  ),
                  // Sign Up View
                  Center(
                    child: new Text("SignUp"),
                  )
                ]),
          )
        ],
      ),
    );
  }
}
