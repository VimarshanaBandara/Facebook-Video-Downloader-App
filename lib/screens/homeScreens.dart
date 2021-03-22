import 'dart:io';
import 'package:facebook_video_downloader/const.dart';
import 'package:facebook_video_downloader/openScreen.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(

      keywords: <String>['WhatsApp', 'Status','WhatsApp Status','Status Downloader','Social Media','facebook','video downloader']
  );

  BannerAd _bannerAd;
  BannerAd createBannerAd(){
    return BannerAd(
        adUnitId: 'ca-app-pub-7778261196555839/5859129861',
        size: AdSize.banner,
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event){
          print("BannerAd $event");
        }
    );
  }


  PermissionStatus status;
  int denyCnt = 0;
  List<HomeList> homeList = HomeList.homeList;

  void _getPermission() async {
    status = await Permission.storage.request();

    if (status == PermissionStatus.permanentlyDenied) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('Storage Permission required'),
            content: Text('Enable Storage Permission from App Setting'),
            actions: <Widget>[
              FlatButton(
                child: Text('Open Setting'),
                onPressed: () async {
                  openAppSettings();
                  exit(0);
                },
              )
            ],
          );
        },
      );
    } else {
      while (!status.isGranted) {
        if (denyCnt > 20) {
          exit(0);
        }
        status = await Permission.storage.request();
        denyCnt++;
      }
    }
  }

  @override
  void initState() {
    FirebaseAdMob.instance.initialize(
      appId: 'ca-app-pub-7778261196555839~9798374871',
    );
    _bannerAd = createBannerAd()..load()..show();
    super.initState();
    _getPermission();
  }

  Future<bool> getData() async {
    await Future.delayed(const Duration(milliseconds: 0));
    return true;
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(

        ),

        child: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SizedBox();
            } else {
              return Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // appBar(),
                    SizedBox(
                      height: 55.0,
                    ),
                    Expanded(
                      child: FutureBuilder(
                        future: getData(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox();
                          } else {
                            return GridView(
                              padding: EdgeInsets.only(top: 0, left: 12, right: 12),
                              physics: BouncingScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              children: List.generate(
                                homeList.length,
                                    (index) {
                                  return HomeListView(
                                    listData: homeList[index],
                                    callBack: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => homeList[index].navigateScreen,
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                mainAxisSpacing: 5.0,
                                crossAxisSpacing: 5.0,
                                childAspectRatio: 1.0,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      )
    );
  }


}

class HomeListView extends StatelessWidget {
  final HomeList listData;
  final VoidCallback callBack;
  final AnimationController animationController;
  final Animation animation;

  const HomeListView({Key key, this.listData, this.callBack, this.animationController, this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Container(
          height: 80.0,
          child: RaisedButton(
            onPressed:callBack,

            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(150.0)),
            padding: EdgeInsets.all(0.0),
            child: Ink(
              decoration: BoxDecoration(

                  gradient: LinearGradient(colors: [Colors.blueAccent,  Colors.blueAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(150.0)
              ),
              child: Container(
                constraints: BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
                alignment: Alignment.center,
                child: Text("Facebook Video Downloader",textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 4.0,
                        color: Colors.black87,
                      ),
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 9.0,
                        color: Colors.black87,
                      ),
                    ],
                  ),),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


