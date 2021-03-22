import 'dart:io';
import 'dart:ui';
import 'package:connectivity/connectivity.dart';
import 'package:facebook_video_downloader/const.dart';
import 'package:facebook_video_downloader/screens/fb.dart';
import 'package:facebook_video_downloader/screens/homeScreens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

Directory thumbDir = Directory('/storage/emulated/0/FbVideo');
Directory dir = Directory('/storage/emulated/0/FbVideo');

class FacebookDownload extends StatefulWidget {
  @override
  _FacebookDownloadState createState() => _FacebookDownloadState();
}

class _FacebookDownloadState extends State<FacebookDownload> {
  var _fbScaffoldKey = GlobalKey<ScaffoldState>();
  FacebookProfile _fbProfile;
  TextEditingController _urlController = TextEditingController();
  bool _isDisabled = true, _showData = false, _hasAudio = true, _notfirst = false;
  String _postThumbnail = '';
  var thumb;

  Future<String> _loadthumb(String videoUrl) async {
    thumb = await VideoThumbnail.thumbnailFile(
      video: videoUrl,
      thumbnailPath: thumbDir.path,
      imageFormat: ImageFormat.PNG,
    );
    var rep = thumb.toString().substring(thumb.toString().indexOf('ThumbFiles/') + 'ThumbFiles/'.length, thumb.toString().indexOf('.mp4'));
    File thumbname = File(thumb.toString());
    thumbname.rename(thumbDir.path + '$rep.png');

    print(thumbDir.path + '$rep.png');
    return (thumbDir.path + '$rep.png');
  }

  bool validateURL(List<String> urls) {

    Pattern pattern = r'^http(s)?://(www\.)?facebook.([a-z]+)/(?!(?:video\.php\?v=\d+|usernameFB/videos/\d+)).*$';
    RegExp regex = new RegExp(pattern);

    for (var url in urls) {
      if (!regex.hasMatch(url)) {
        return false;
      }
    }
    return true;
  }

  void getButton(String url) {
    if (validateURL([url])) {
      setState(() {
        _isDisabled = false;
      });
    } else {
      setState(() {
        _isDisabled = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    if (!thumbDir.existsSync()) {
      thumbDir.createSync(recursive: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.5,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('FB',style: TextStyle(color: Colors.black),),
            SizedBox(width: 5.0,),
            Text('Video',style: TextStyle(color: Colors.blue),),
            SizedBox(width: 5.0,),
            Text('Downloader',style: TextStyle(color: Colors.black),)
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.grey,),
          onPressed: (){
            Navigator.push(context,MaterialPageRoute(builder: (context)=>MyHomePage()));
          },
        ),
        actions: [

          Icon(Icons.video_collection_sharp,color: Colors.grey,),
          SizedBox(width: 10.0,),
        ],
      ),
      key: _fbScaffoldKey,
      // appBar: screenAppBar("Facebook Downloader"),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: <Widget>[
            Container(

              width: MediaQuery.of(context).size.width,
              height: 140.0,
              decoration: BoxDecoration(

                  image: DecorationImage(
                      image: AssetImage('assets/images/img4.png',),

                      fit: BoxFit.cover
                  )
              ),
            ),
            SizedBox(height:20.0 ,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child:TextField(
                keyboardType: TextInputType.text,
                controller: _urlController,
                maxLines: 1,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
                    prefixIcon:Icon(Icons.paste),
                    hintText: 'Paste Facebook Video link Here'),
                onChanged: (value) {
                  getButton(value);
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0))),
                  color:Colors.blue,
                  child: Text('Paste'),
                  onPressed: () async {
                    Map<String, dynamic> result = await SystemChannels.platform.invokeMethod('Clipboard.getData');
                    WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _urlController.text = result['text'].toString(),
                    );
                    setState(() {
                      getButton(result['text'].toString());
                    });
                  },
                ),
                SizedBox(width: 15.0,),
                _isDisabled
                    ? RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0))),
                  color:Colors.blue,
                  child: Text('Download'),

                  onPressed: (){},
                )
                    : RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0))),
                  color: Colors.red,
                  child: Text('Download'),
                  onPressed: () async {
                    var connectivityResult = await Connectivity().checkConnectivity();
                    if (connectivityResult == ConnectivityResult.none) {
                      _fbScaffoldKey.currentState.showSnackBar(mySnackBar(context, 'No Internet'));
                      return;
                    }
                    setState(() {
                      _notfirst = true;
                      _showData = false;
                    });
                    _fbProfile = await FacebookData.postFromUrl('${_urlController.text}');
                    if (_fbProfile.postData.videoMp3Url == '') {
                      setState(() {
                        _hasAudio = false;
                      });
                    } else {
                      setState(() {
                        _hasAudio = true;
                      });
                    }
                    _postThumbnail = await _loadthumb(_fbProfile.postData.videoHdUrl.toString());

                    setState(() {
                      _showData = true;
                    });
                  },
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            _notfirst
                ? _showData
                ? Container(
              padding: EdgeInsets.only(bottom: 30.0),
              margin: EdgeInsets.all(8.0),
              child: SizedBox(
                height: screenHeightSize(350, context),
                child: GridView.builder(
                  itemCount: 1,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Column(
                      children: <Widget>[

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(width: 25.0,),
                            RaisedButton.icon(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
                              label: Text('Download Video',
                                style: TextStyle(color: Colors.white),),
                              icon: Icon(Icons.download_outlined, color:Colors.white,),
                              textColor: Colors.white,
                              splashColor: Colors.red,
                              color: Colors.green,
                              onPressed: _hasAudio
                                  ? () async {
                             //   _fbScaffoldKey.currentState.showSnackBar(mySnackBar(context, 'Added to Download'));
                                String downloadUrl = _fbProfile.postData.videoSdUrl;
                                String name = 'Video-${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}${DateTime.now().millisecond}.mp4';

                                await FlutterDownloader.enqueue(
                                  url: downloadUrl,
                                  savedDir: dir.path,
                                  fileName: name,
                                  showNotification: true,
                                  openFileFromNotification: true,
                                );
                              }
                                  : null,
                            ),

                          ],
                        ),
                      ],
                    );
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 5.0,
                    crossAxisSpacing: 10.0,
                    childAspectRatio: 1,
                  ),
                ),
              ),
            )
                : Container(
              height: 100,
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10.0,),
                    Text('Please Wait',style: TextStyle(fontSize: 20.0 , color: Colors.grey),),
                  ],
                ),
              ),
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}
