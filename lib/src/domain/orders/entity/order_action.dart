/// Buyer/seller actions the API exposes via `availableActions`.
enum OrderAction {
  ship,
  confirmReceipt,
  reportProblem,
  cancel,
  review;

  /// Maps the opaque `availableActions` strings to actions (normalises casing
  /// and `-`/`_`).
  static Set<OrderAction> fromApi(List<dynamic>? raw) {
    final result = <OrderAction>{};
    for (final entry in raw ?? const <dynamic>[]) {
      if (entry is! String) continue;
      final token = entry.toLowerCase().replaceAll(RegExp('[_-]'), '');
      if (token.contains('ship')) result.add(OrderAction.ship);
      if (token.contains('confirm')) result.add(OrderAction.confirmReceipt);
      if (token.contains('report')) result.add(OrderAction.reportProblem);
      if (token.contains('cancel')) result.add(OrderAction.cancel);
      if (token.contains('review')) result.add(OrderAction.review);
    }
    return result;
  }
}

enum OrderRole { buyer, seller }

enum OrderListState { inProgress, completed }
