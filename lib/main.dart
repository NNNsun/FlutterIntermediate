import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infren/common/provider/go_router.dart';

import 'log/provider_logger.dart';

void main() {
  runApp(ProviderScope(
    observers: [
      ProviderLogger(),
    ],
    child: const _App(),
  ));
}

class _App extends ConsumerWidget {
  const _App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      // 기본 폰트 모두 'NotoSans'로 변경
      theme: ThemeData(
        fontFamily: 'NotoSans',
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
