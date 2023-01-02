import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infren/common/const/data.dart';
import 'package:infren/common/dio/dio.dart';
import 'package:infren/common/model/cursor_pagination_model.dart';
import 'package:infren/restaurant/component/restaurant_card.dart';
import 'package:infren/restaurant/model/restaurant_model.dart';
import 'package:infren/restaurant/provider/restaurant_provider.dart';
import 'package:infren/restaurant/repository/restaurant_repository.dart';
import 'package:infren/restaurant/view/restaurant_detail__screen.dart';

class RestaurantScreen extends ConsumerStatefulWidget {
  const RestaurantScreen({super.key});

  @override
  ConsumerState<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends ConsumerState<RestaurantScreen> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(scrollListener);
  }

  void scrollListener() {
    // 현재위치가 최대 길이보다 조금 덜 되는 위치까지 왔다면
    // 새로운 데이터를 추가 요청
    // 현재 스크롤이 내려갈 수 있는 최대 길이 - 300픽셀
    if (controller.offset > controller.position.maxScrollExtent - 300) {
      ref.read(restaurantProvider.notifier).paginate(
            fetchMore: true,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    //data를 반환하는 함수
    final data = ref.watch(restaurantProvider);
    // 완전 처음 로딩일 때
    if (data is CursorPaginationLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    // 에러
    if (data is CursorPaginationError) {
      return Center(
        child: Text(data.message),
      );
    }

    // CursorPagination
    // CursorPaginationLoadingFetchingMore
    // CursorPaginationLoadingRefetching

    final cp = data as CursorPagination;

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.separated(
          controller: controller,
          itemCount: cp.data.length + 1,
          itemBuilder: (_, index) {
            if (index == cp.data.length) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Center(
                  child: data is CursorPaginationFetchingMore
                      ? CircularProgressIndicator()
                      : Text('마지막 데이터 입니다ㅠㅠ'),
                ),
              );
            }
            final pItem = cp.data[index];
            //parsed:변환되었음
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => RestaurantDetailScreen(
                            id: pItem.id,
                          )),
                );
              },
              child: RestaurantCard.fromModel(
                model: pItem,
              ),
            );
          },
          // 각 아이템 사이에 들어가는 것들을 빌드해준다
          separatorBuilder: (_, index) {
            return SizedBox(
              height: 16.0,
            );
          },
        ));
  }
}
