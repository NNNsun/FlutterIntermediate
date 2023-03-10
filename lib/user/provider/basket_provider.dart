import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infren/product/model/product_model.dart';
import 'package:infren/user/model/basket_item_model.dart';
import 'package:collection/collection.dart';
import 'package:infren/user/model/patch_basket_body.dart';
import 'package:infren/user/repository/user_me_repository.dart';

final basketProvider =
    StateNotifierProvider<BasketProvider, List<BasketItemModel>>((ref) {
  final repository = ref.watch(userMeRepositoryProvider);
  return BasketProvider(
    repository: repository,
  );
});

class BasketProvider extends StateNotifier<List<BasketItemModel>> {
  final UserMeRepository repository;

  BasketProvider({
    required this.repository,
  }) : super([]);
  Future<void> patchBasket() async {
    await repository.patchBasket(
      body: PatchBasketBody(
          basket: state
              .map((e) => PatchBasketBodyBasket(
                  productId: e.product.id, count: e.count))
              .toList()),
    );
  }

  Future<void> addToBasket({
    required ProductModel product,

    // true면 count와 관계없이 아예 삭제함
  }) async {
    // 요청을 먼저 보내고
    // 응답이 오면
    // 캐시를 업데이트 했었음 ->요청이 올때까지 기다림 -> 느린 것처럼 보임
    // 에러가 나도 큰 문제가 생기진않음
    // => Optimistic Response(긍정적 응답)
    //  응답이 성공할 것이라고 가정하고 상태를 먼저 업데이트 한다

    // 1) 아직 장바구니에 해당되는 상품이 없다면
    //    장바구니에 상품을 추가한다
    // 2) 만약에 이미 들어있다면
    //    장바구니에 있는 값에 +1을 한다
    // 장바구니에 존재
    final exists =
        state.firstWhereOrNull((e) => e.product.id == product.id) != null;
    if (exists) {
      state = state
          .map(
            (e) => e.product.id == product.id
                ? e.copyWith(
                    count: e.count + 1,
                  )
                : e,
          )
          .toList();
    } else {
      state = [
        ...state,
        BasketItemModel(
          product: product,
          count: 1,
        ),
      ];
    }
    await patchBasket();
  }

  Future<void> removeFromBasket({
    required ProductModel product,
    bool isDelete = false,
  }) async {
    // 1) 장바구니에 상품이 존재할때는
    //      a) 상품의 카운트가 1보다 크면 -1한다
    //      b) 상품의 카운트가 1이면 삭제한다
    // 2) 상품이 존재하지 않을때
    //      즉시 함수를 반환하고 아무것도 하지 않는다
    final exists =
        state.firstWhereOrNull((e) => e.product.id == product.id) != null;
    if (!exists) {
      return;
    }
    final existingProduct = state.firstWhere((e) => e.product.id == product.id);

    if (existingProduct.count == 1 || isDelete == true) {
      state = state
          .where(
            (e) => e.product.id != product.id,
          )
          .toList();
    } else {
      state = state
          .map(
            (e) => e.product.id == product.id
                ? e.copyWith(
                    count: e.count - 1,
                  )
                : e,
          )
          .toList();
    }

    await patchBasket();
  }
}
