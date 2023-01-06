import 'dart:convert';

import 'package:infren/common/const/data.dart';

class DataUtils {
  static String pathToUrl(String value) {
    return 'http://$ip$value';
  }

  static List<String> listPathsToUrls(List paths) {
    //dynamic 타입으로 가정
    return paths.map((e) => pathToUrl(e)).toList();
  }

  static plainToBase64(String plain) {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    //인코딩 정의
    String encoded = stringToBase64.encode(plain);

    return encoded;
  }
}
