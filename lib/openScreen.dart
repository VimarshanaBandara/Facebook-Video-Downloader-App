import 'package:facebook_video_downloader/screens/downloadScreens.dart';
import 'package:flutter/widgets.dart';



class HomeList {
  String title;
  Widget navigateScreen;
  String imagePath;

  HomeList({
    this.title,
    this.navigateScreen,
    this.imagePath = '',
  });

  static List<HomeList> homeList = [
    HomeList(
      title: 'Facebook Video Downloader',

      navigateScreen: FacebookDownload(),
    ),

  ];
}

