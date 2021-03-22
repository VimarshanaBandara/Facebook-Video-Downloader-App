import 'package:facebook_video_downloader/screens/homeScreens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await FlutterDownloader.initialize(debug: true
  );
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Facebook Video Downloader',
      theme: ThemeData.light().copyWith(
        accentColor: Colors.blue,
        textSelectionColor: Colors.blue,
        textSelectionHandleColor: Colors.blue,
        platform: TargetPlatform.iOS,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

