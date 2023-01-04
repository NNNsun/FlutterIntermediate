import 'package:infren/common/model/cursor_pagination_model.dart';
import 'package:infren/common/model/model_with_id.dart';
import 'package:infren/common/model/pagination_params.dart';

// 인터페이스는 class로 만듦
abstract class IBasePaginationRepository<T extends IModelWithId> {
  Future<CursorPagination<T>> paginate({
    PaginationParams? paginationParams = const PaginationParams(),
  });
}
