import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infren/common/model/cursor_pagination_model.dart';
import 'package:infren/common/model/model_with_id.dart';
import 'package:infren/common/model/pagination_params.dart';
import 'package:infren/common/repository/base_pagination_repository.dart';

// dart는 제네릭타입에 implement를 기입할 수 없다 => extends를 사용해도 무방
class PaginationProvider<T extends IModelWithId,
        U extends IBasePaginationRepository<T>>
    extends StateNotifier<CursorPaginationBase> {
  final U repository;

  PaginationProvider({
    required this.repository,
  }) : super(CursorPaginationLoading()) {
    paginate();
  }

  Future<void> paginate({
    int fetchCount = 20,
    // 추가로 데이터 더 가져오기
    // true - 추가로 데이터 더 가져옴
    // false - 새로고침(현재 상태를 덮어 씌움)
    bool fetchMore = false,
    // 강제로 다시 로딩하기
    // true - CursorPaginationLoading()
    bool forceRefetch = false,
  }) async {
    try {
      // SateBase의 5가지 가능성 -> cursorPaseBase를 extends하고 있는 class의 갯수
      // [상태가]
      // 1) CursorPagination - 정상적으로 데이터가 있는 상태
      // 2) CursorPaginationLoading - 데이터가 로딩중인 상태 (현재 캐시 없음)
      // 5) CursorPaginationError - 에러가 있는 상태
      // 4) CursorPaginationRefetching - 첫번째 페이지부터 다시 데이터를 가져올때
      // 5) CursorPaginationFetchMore - 추가 데이터를 paginate 해오라는 요청을 받았을 때

      // 바로 반환하는 상황
      // 1) hasMore == false (기존 상태에서 이미 다음 데이터가 없다는 값을 들고있다면)
      if (state is CursorPagination && !forceRefetch) {
        final pState = state as CursorPagination; // 무조건 CursorPagination이라고 공표!

        if (!pState.meta.hasMore) {
          //paginate()를 더이상 실행하지 않는다
          return;
        }
      }
      // 2) 로딩중 - fetchMore == true =>즉시반환
      //    fetchMore가 아닐때 - 새로 고침의 의도가 있을 수 있다
      final isLoading = state is CursorPaginationLoading; // 처음 로딩
      final isRefetching =
          state is CursorPaginationRefetching; // 데이터를 받아온 적은 있으나 유저가 새로고침을 할 때
      final isFetchingMore = state is CursorPaginationFetchingMore;

      if (fetchMore && (isLoading || isRefetching || isFetchingMore)) {
        return;
      }

      // PaginationParams 생성
      PaginationParams paginationParams = PaginationParams(
        count: fetchCount,
      );
      //fetchMore (화면에 데이터가 보여지고 있는 상황)
      //데이터를 추가로 더 가져오는 상황
      if (fetchMore) {
        final pState = state as CursorPagination<T>;

        state = CursorPaginationFetchingMore(
          meta: pState.meta,
          data: pState.data,
        );
        paginationParams = paginationParams.copyWith(
          after: pState.data.last.id,
        );
      }
      // 데이터를 처음부터 가져오는 상황
      else {
        // 만약에 데이터가 있는 상황이라면
        // 기존 데이터를 보존한 채로 Fetch (API 요청)를 진행
        if (state is CursorPagination && !forceRefetch) {
          final pState = state as CursorPagination<T>;
          state = CursorPaginationRefetching<T>(
            meta: pState.meta,
            data: pState.data,
          );
        }
        // 나머지 상황
        else {
          state = CursorPaginationLoading();
        }
      }
      final resp = await repository.paginate(
        paginationParams: paginationParams,
      );
      if (state is CursorPaginationFetchingMore) {
        // is : class 인스턴스인지 테스트
        final pState =
            state as CursorPaginationFetchingMore<T>; // as : class 인스턴스라고 지정
        //기존 데이터에 새로운 데이터를 추가
        state = resp.copyWith(data: [
          ...pState.data,
          ...resp.data,
        ]);
      } else {
        state = resp;
      }
    } catch (e, stack) {
      print('[PROV_ERR] $e');
      print(stack);
      state = CursorPaginationError(message: '데이터를 가져오지 못했습니다');
    }
  }
}
