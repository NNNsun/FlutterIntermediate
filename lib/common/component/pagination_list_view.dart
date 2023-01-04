import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infren/common/model/cursor_pagination_model.dart';
import 'package:infren/common/model/model_with_id.dart';
import 'package:infren/common/provider/pagination_provider.dart';
import 'package:infren/common/utils/pagination_utils.dart';

typedef PaginationWidGetBuilder<T extends IModelWithId> = Widget Function(
  BuildContext buildContext,
  int index,
  T model,
);

class PaginationListView<T extends IModelWithId>
    extends ConsumerStatefulWidget {
  final StateNotifierProvider<PaginationProvider, CursorPaginationBase>
      provider;
  final PaginationWidGetBuilder<T> itemBuilder;

  const PaginationListView({
    required this.provider,
    required this.itemBuilder,
    super.key,
  });

  @override
  ConsumerState<PaginationListView> createState() =>
      _PaginationListViewState<T>();
}

class _PaginationListViewState<T extends IModelWithId>
    extends ConsumerState<PaginationListView> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  void listener() {
    PaginationUtils.paginate(
      controller: controller,
      provider: ref.read(
        widget.provider.notifier,
      ),
    );
  }

  @override
  void dispose() {
    controller.removeListener(listener);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.provider);
    // 완전 처음 로딩일 때
    if (state is CursorPaginationLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    // 에러
    if (state is CursorPaginationError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            state.message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 16.0,
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(widget.provider.notifier).paginate(
                    forceRefetch: true,
                  );
            },
            child: Text('다시시도'),
          ),
        ],
      );
    }

    // CursorPagination
    // CursorPaginationLoadingFetchingMore
    // CursorPaginationLoadingRefetching

    final cp = state as CursorPagination<T>;

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
                  child: cp is CursorPaginationFetchingMore
                      ? CircularProgressIndicator()
                      : Text('마지막 데이터 입니다ㅠㅠ'),
                ),
              );
            }
            final pItem = cp.data[index];
            // parsed:변환되었음
            return widget.itemBuilder(
              context,
              index,
              pItem,
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
