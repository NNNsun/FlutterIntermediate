import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infren/common/const/data.dart';
import 'package:infren/common/dio/dio.dart';
import 'package:infren/common/model/cursor_pagination_model.dart';
import 'package:infren/common/model/pagination_params.dart';
import 'package:infren/restaurant/model/restaurant_detail_model.dart';
import 'package:infren/restaurant/model/restaurant_model.dart';
import 'package:retrofit/retrofit.dart';

part 'restaurant_repository.g.dart';

final restaurantRepositoryProvider = Provider<RestaurantRepository>(
  (ref) {
    final dio = ref.watch(dioProvider);
    final repository =
        RestaurantRepository(dio, baseUrl: 'http://$ip/restaurant');
    return repository;
  },
);

@RestApi()
abstract class RestaurantRepository {
  // http://$ip/restaurant
  factory RestaurantRepository(Dio dio, {String baseUrl}) =
      _RestaurantRepository;

  // http://$ip/restaurant/
  @GET('/')
  @Headers({
    'accessToken': 'true',
  })
  //after와 count가 없어도 첫번째 page를 가져오도록 api가 설계되어있음
  Future<CursorPagination<RestaurantModel>> paginate({
    @Queries() PaginationParams? paginationParams = const PaginationParams(),
  });

  // http://$ip/restaurant/:id/
  @GET('/{id}')
  @Headers({
    'accessToken': 'true',
  })
  Future<RestaurantDetailModel> getRestaurantDetail({
    @Path() required String id,
  });
}
