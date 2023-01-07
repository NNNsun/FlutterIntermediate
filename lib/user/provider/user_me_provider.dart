import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:infren/common/component/secure_storage/secure_storage.dart';
import 'package:infren/common/const/data.dart';
import 'package:infren/user/model/user_model.dart';
import 'package:infren/user/repository/auth_repository.dart';
import 'package:infren/user/repository/user_me_repository.dart';

final userMeProvider =
    StateNotifierProvider<UserMeSateNotifier, UserModelBase?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final userMeRepository = ref.watch(userMeRepositoryProvider);
  final storage = ref.watch(secureStorageProvider);

  return UserMeSateNotifier(
    authRepository: authRepository,
    repository: userMeRepository,
    storage: storage,
  );
});

class UserMeSateNotifier extends StateNotifier<UserModelBase?> {
  final AuthRepository authRepository;
  final UserMeRepository repository;
  final FlutterSecureStorage storage;
  UserMeSateNotifier({
    required this.authRepository,
    required this.repository,
    required this.storage,
  }) : super(UserModelLoading()) {
    // 내 정보 가져오기
    getMe();
  }

  Future<void> getMe() async {
    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

    if (refreshToken == null || accessToken == null) {
      state == null; // 로그오프 상태를 알려줘야함
      return;
    }

    final resp = await repository.getMe();
    state = resp;
  }

  Future<UserModelBase> login({
    required String username,
    required String password,
  }) async {
    try {
      state = UserModelLoading();
      final resp = await authRepository.login(
        username: username,
        password: password,
      );

      await storage.write(key: REFRESH_TOKEN_KEY, value: resp.refreshToken);
      await storage.write(key: ACCESS_TOKEN_KEY, value: resp.accessToken);
      // 토큰에 해당하는 유저를 기억한다
      final userResp = await repository.getMe();

      state = userResp;

      return userResp;
    } catch (e) {
      // <심화>
      // 어떤 것이 잘못되었는지 (유저네임, 비밀번호)
      // authRepository에 반환되면
      // error 메시지를 좀더 자세하게 적어준다
      state = UserModelError(message: '로그인에 실패했습니다.');
      print('[User Login Error] $e');

      return Future.value(state);
    }
  }

  Future<void> logout() async {
    state = null;

    // await로 둘다 끝날때 결과값을 받음 -> 조금 빠름
    await Future.wait(
      [
        // 동시에 실행
        storage.delete(key: REFRESH_TOKEN_KEY),
        storage.delete(key: ACCESS_TOKEN_KEY),
      ],
    );
  }
}
