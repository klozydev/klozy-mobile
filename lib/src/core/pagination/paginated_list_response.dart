class PaginatedListResponse<T> {
  final Map<String, dynamic>? metadata;
  final List<T> data;

  const PaginatedListResponse({this.metadata, required this.data});

  factory PaginatedListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    // The API wraps paginated lists as {items, page, limit, total};
    // `data` is kept as a fallback envelope key.
    final rawData =
        (json['items'] ?? json['data']) as List<dynamic>? ?? const [];
    final metadata =
        json['metadata'] as Map<String, dynamic>? ??
        <String, dynamic>{
          for (final key in const <String>['page', 'limit', 'total'])
            if (json[key] is num) key: json[key],
        };
    return PaginatedListResponse(
      metadata: metadata.isEmpty ? null : metadata,
      data: rawData.map(fromJsonT).toList(),
    );
  }
}
