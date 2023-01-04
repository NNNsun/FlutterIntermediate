import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infren/common/model/cursor_pagination_model.dart';
import 'package:infren/common/provider/pagination_provider.dart';
import 'package:infren/restaurant/model/restaurant_model.dart';
import 'package:infren/restaurant/repository/restaurant_repository.dart';

// cache
final restaurantDetailProvider =
    Provider.family<RestaurantModel?, String>((ref, id) {
  final state = ref.watch(restaurantProvider);

  if (state is! CursorPagination) {
    return null;
  }
  return state.data.firstWhere((element) => element.id == id);
}); // family: 값 두개

final restaurantProvider =
    StateNotifierProvider<RestaurantStateNotifier, CursorPaginationBase>(
  (ref) {
    final repository = ref.watch(restaurantRepositoryProvider);
    final notifier = RestaurantStateNotifier(repository: repository);
    return notifier;
  },
);

class RestaurantStateNotifier
    extends PaginationProvider<RestaurantModel, RestaurantRepository> {
  RestaurantStateNotifier({
    required super.repository,
  });

  void getDetail({
    required String id,
  }) async {
    // 만약에 아직 데이터가 하나도 없는 상태라면 (CursorPagination이 아니라면)
    // 데이터를 가져오는 시도를 한다.
    if (state is! CursorPagination) {
      await this.paginate();
    }

    // state가 CursorPagination이 아닐때 그냥 return, server Error
    if (state is! CursorPagination) {
      return;
    }
    // Client Logic
    final pState = state as CursorPagination;
    final resp = await repository.getRestaurantDetail(id: id);

    // [RestaurntMode(1),RestaurntMode(2),RestaurntMode(3)]
    // getDetail(id:2)
    // [RestaurntMode(1),RestaurntDetailMode(2),RestaurntMode(3)]

    state = pState.copyWith(
      data: pState.data
          .map<RestaurantModel>(
            (e) => e.id == id ? resp : e,
          )
          .toList(),
    );
  }
}
