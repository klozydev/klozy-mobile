class PaginatedListResponse<T> {
  final Map<String, dynamic>? metadata;
  final List<T> data;

  const PaginatedListResponse({this.metadata, required this.data});

  factory PaginatedListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final rawData = json['data'] as List<dynamic>? ?? const [];
    return PaginatedListResponse(
      metadata: json['metadata'] as Map<String, dynamic>?,
      data: rawData.map(fromJsonT).toList(),
    );
  }
}
