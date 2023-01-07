import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infren/common/view/root_tab.dart';
import 'package:infren/restaurant/view/restaurant_detail__screen.dart';
import 'package:infren/user/model/user_model.dart';
import 'package:infren/user/provider/user_me_provider.dart';
import 'package:infren/user/view/login_screen.dart';
import 'package:infren/user/view/splash_screen.dart';

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider(ref: ref);
});

class AuthProvider extends ChangeNotifier {
  final Ref ref;

  AuthProvider({
    required this.ref,
  }) {
    ref.listen<UserModelBase?>(userMeProvider, (previous, next) {
      if (previous != next) {
        notifyListeners();
      }
    });
  }

  List<GoRoute> get routes => [
        GoRoute(
          // path == 서버 구조와 같음
          path: '/',
          name: RootTab.routeName,
          builder: (_, __) => RootTab(),
          routes: [
            GoRoute(
              //server path와 동일하게
              path: 'restaurant/:rid',
              name: RestaurantDetailScreen.routeName,
              builder: (_, state) => RestaurantDetailScreen(
                id: state.params['rid']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/splash',
          name: SplashScreen.routeName,
          builder: (_, __) => SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: LoginScreen.routeName,
          builder: (_, __) => LoginScreen(),
        ),
      ];
  void logout() {
    ref.read(authProvider.notifier).logout();
  }

  // SplashScreen
  // 앱을 처음 시작했을 때
  // 로그인 스크린으로 보내줄지
  // 홈 스크린으로 보내줄지 확인하는 과정이 필요!
  String? redirectLogic(GoRouterState state) {
    final UserModelBase? user = ref.read(userMeProvider);
    final loginIn = state.location == '/login';

    // 유저 정보가 없는데
    // 로그인중이면 그대로 로그인 페이지에 두고
    // 만약 로그인중이 아니라면 로그인 페이지로 이동
    if (user == null) {
      return loginIn ? null : '/login';
    }
    // user가 null이 아님

    // UserModel 인 상태: 로딩이 된 상태
    // 사용자 정보가 있는 상태면
    // 로그인 중이거나현재 위치가 SplashScreen이면
    // 홈으로 이동
    if (user is UserModel) {
      return loginIn || state.location == '/splash' ? '/' : null;
    }

    //UserModelError 일때
    if (user is UserModelError) {
      return !loginIn ? '/login' : null;
    }
    return null;
  }
}
