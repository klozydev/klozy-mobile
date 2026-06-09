import 'package:klozy/src/core/pagination/paginated_list.dart';
import 'package:klozy/src/core/pagination/paginated_list_response.dart';

extension PaginatedListMapper<T> on PaginatedListResponse<T> {
  PaginatedList<R> toPaginatedList<R>(R Function(T) mapper) {
    return PaginatedList(data: data.map(mapper).toList(), metadata: metadata);
  }
}
