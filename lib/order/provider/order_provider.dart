import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infren/order/repository/order_repository.dart';
import 'package:infren/user/provider/basket_provider.dart';
import 'package:uuid/uuid.dart';

import '../model/order_model.dart';
import '../model/post_order_body.dart';

final orderProvider =
    StateNotifierProvider<OrderStateNotifier, List<OrderModel>>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return OrderStateNotifier(
    ref: ref,
    repository: repo,
  );
});

class OrderStateNotifier extends StateNotifier<List<OrderModel>> {
  final Ref ref;
  final OrderRepository repository;
  OrderStateNotifier({
    required this.ref,
    required this.repository,
  }) : super([]);

  Future<bool> postOrder() async {
    try {
      final uuid = Uuid();
      final id = uuid.v4();
      final state = ref.read(basketProvider);
      final resp = await repository.postOrder(
        body: PostOrderBody(
          id: id,
          products: state
              .map((e) => PostOrderBodyProduct(
                    productId: e.product.id,
                    count: e.count,
                  ))
              .toList(),
          createdAt: DateTime.now().toString(),
          totalPrice:
              state.fold<int>(0, (p, n) => p + (n.count * n.product.price)),
        ),
      );
      return true;
    } catch (e) {
      print('[OrderERR] $e');
      return false;
    }
  }
}
