import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infren/common/model/cursor_pagination_model.dart';
import 'package:infren/common/provider/pagination_provider.dart';
import 'package:infren/restaurant/model/restaurant_model.dart';
import 'package:infren/restaurant/repository/restaurant_repository.dart';
import 'package:collection/collection.dart';

// cache
final restaurantDetailProvider =
    Provider.family<RestaurantModel?, String>((ref, id) {
  final state = ref.watch(restaurantProvider);

  if (state is! CursorPagination) {
    return null;
  }
  // firstWhereOrNull: 데이터가 존재하지 않으면 null을 던진다
  return state.data.firstWhereOrNull((element) => element.id == id);
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

    // [RestaurantModel(1),RestaurantModel(2),RestaurantModel(3)]
    // 요청 id :10
    // list.where((e)=>e.id==10) 데이터X
    // 데이터가 없을때는 그냥 캐시의 끝에다가 데이터를 추가해버린다.
    // [RestaurantModel(1),RestaurantModel(2),RestaurantModel(3)
    // RestaurantDetailModel(10)]
    if (pState.data.where((e) => e.id == id).isEmpty) {
      state = pState.copyWith(
        data: <RestaurantModel>[
          ...pState.data,
          resp,
        ],
      );
    } else {
      // [RestaurantModel(1),RestaurantModel(2),RestaurantModel(3)]
      // id: 2인 친구를 Detail모델을 가져와라
      // getDetail(id:2)
      // [RestaurantModel(1),RestaurantDetailModel(2),RestaurantModel(3)]

      state = pState.copyWith(
        data: pState.data
            .map<RestaurantModel>(
              (e) => e.id == id ? resp : e,
            )
            .toList(),
      );
    }
  }
}
