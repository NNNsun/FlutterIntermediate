import 'package:infren/common/const/data.dart';

class DataUtils {
  static String pathToUrl(String value) {
    return 'http://$ip$value';
  }

  static List<String> listPathsToUrls(List paths) {
    //dynamic 타입으로 가정
    return paths.map((e) => pathToUrl(e)).toList();
  }
}
