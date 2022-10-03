import 'package:flutter/material.dart';
import 'package:flutter_delivery/app/common/components/custom_text_form_field.dart';
import 'package:flutter_delivery/app/common/provider/go_router.dart';
import 'package:flutter_delivery/app/common/view/splash_screen.dart';
import 'package:flutter_delivery/app/modules/user/provider/auth_provider.dart';
import 'package:flutter_delivery/app/modules/user/view/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch - 값이 변경될때마다 다시 빌드
    // read - 한번만 읽고 값이 변경돼도 다시 빌드하지 않음
    final router = ref.read(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'NotoSans',
      ),
      routerConfig: router,
    );
  }
}
