import 'dart:convert';

import 'package:flutter_delivery/app/common/const/data.dart';

class DataUtils {
  static String pathToUrl(String value){
    return 'http://$ip$value';
  }

  static List<String> listPathsToUrl(List paths){

    return paths.map((e) => pathToUrl(e)).toList();
  }

  static String plainToBase64(String plain){
    Codec<String, String> stringToBase64 = utf8.fuse(base64);

    String token = stringToBase64.encode(plain);
    return token;
  }

  static DateTime stringToDateTime(String value){
    return DateTime.parse(value);
  }
}
