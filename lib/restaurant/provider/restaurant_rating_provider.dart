import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infren/common/model/cursor_pagination_model.dart';
import 'package:infren/common/provider/pagination_provider.dart';
import 'package:infren/rating/model/rating_model.dart';
import 'package:infren/restaurant/repository/restaurant_rating_repository.dart';

final restaurantRatingProvider = StateNotifierProvider.family<
    RestaurantRatingStateNotifier, CursorPaginationBase, String>((ref, id) {
  final repo = ref.watch(restaurantRatingRepositoryProvider(id));

  return RestaurantRatingStateNotifier(repository: repo);
});

class RestaurantRatingStateNotifier
    extends PaginationProvider<RatingModel, RestaurantRatingRepository> {
  RestaurantRatingStateNotifier({
    required super.repository,
  });
}
