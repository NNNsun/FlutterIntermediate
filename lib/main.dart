import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infren/common/component/custom_text_form_field.dart';
import 'package:infren/user/view/login_screen.dart';
import 'package:infren/user/view/splash_screen.dart';

void main() {
  runApp(ProviderScope(
    child: _App(),
  ));
}

class _App extends StatelessWidget {
  const _App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 기본 폰트 모두 'NotoSans'로 변경
      theme: ThemeData(
        fontFamily: 'NotoSans',
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
