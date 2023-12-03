import 'dart:async';

import 'package:flutter/material.dart';
import 'package:para_final/presentation/pages/login.dart';
import 'package:para_final/presentation/utils/text_utilities.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 2), () {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => Login()));
    });
    return Scaffold(
      body: Container(
          alignment: Alignment.center,
          color: Colors.blueAccent,
          child: Text(
            "PARA",
            style: bannerTextStyle,
          )),
    );
  }
}
