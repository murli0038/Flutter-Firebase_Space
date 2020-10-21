import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:space_app/Likes.dart';
import 'package:space_app/LogIn.dart';
import 'package:space_app/Photos.dart';
import 'package:space_app/Settings.dart';
import 'package:space_app/Videos.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WallpaperHub',
      theme: ThemeData(
        //  primarySwatch: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      home: LogIn(),
    );
  }
}

class Bottombar extends StatefulWidget {
  @override
  _BottombarState createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> {

  int _selectedindex = 0;
  int _counter = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SizedBox.expand(
          child: Container(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _selectedindex = index);
              },
              children: <Widget>[
                Container(child: Photos(),),
                Container(child: Videos(),),
                Container(child: Likes(),),
                Container(child: Settings(),)
              ],
            ),
          ),),
      ),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _selectedindex,
        showElevation: true,
        itemCornerRadius: 8,
        curve: Curves.easeInCirc,
        onItemSelected: (int index) { setState(() => _selectedindex = index);
        _pageController.jumpToPage(index); },
        items: [
          BottomNavyBarItem(

              icon: Icon(Icons.photo),
              title: Text('Photos'),
              activeColor: Colors.blue,
              inactiveColor: Color(0xffFCA5F1)
          ),
          BottomNavyBarItem(icon: Icon(Icons.videocam),
              title: Text('Videos'),
              activeColor: Colors.green,
              inactiveColor: Color(0xffFCA5F1)
          ),
          BottomNavyBarItem(

              icon: Icon(Icons.favorite),
              title: Text('Like'),
              activeColor: Colors.red,
              inactiveColor: Color(0xffFCA5F1)
          ),
          BottomNavyBarItem(

              icon: Icon(Icons.settings),
              title: Text('Setting'),
              activeColor: Colors.grey,
              inactiveColor: Color(0xffFCA5F1)
          ),
        ],

      ),
    );
  }
}

