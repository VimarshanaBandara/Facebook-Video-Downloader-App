import 'package:flutter/material.dart';

double screenHeightSize(double size, BuildContext context) {
  return size * MediaQuery.of(context).size.height / 650.0;
}

double screenWidthSize(double size, BuildContext context) {
  return size * MediaQuery.of(context).size.width / 400.0;
}

Widget screenAppBar(String screenName) {
  return AppBar(
    title: Text(
      screenName,
      style: new TextStyle(
        fontSize: 34,
      ),
    ),
    backgroundColor: ThemeData.dark().scaffoldBackgroundColor,
    elevation: 0,
  );
}

Widget mySnackBar(BuildContext context, String msg) {
  return SnackBar(
    content: Text(msg),
    backgroundColor: Theme.of(context).accentColor,
    duration: Duration(seconds: 1),
  );
}

