import 'package:flutter/material.dart';
import 'package:flutter_delivery/app/common/components/custom_text_form_field.dart';
import 'package:flutter_delivery/app/common/view/splash_screen.dart';
import 'package:flutter_delivery/app/modules/user/login_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'NotoSans',
      ),
      home: SplashScreen(),
    );
  }
}
