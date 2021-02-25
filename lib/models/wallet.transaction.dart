part of wallet_api_flutter;

class WalletTransactionData {
  WalletTransactionData({
    @required this.transactions,
    @required this.apiError,
    @required this.page,
    @required this.skip,
    @required this.newCount,
    @required this.totalCount,
    @required this.fingerprint,
  });

  final List<Transaction> transactions;
  final dynamic apiError;
  final int page;
  final int skip;
  final int newCount;
  final int totalCount;
  final String fingerprint;

  bool get hasError => apiError != null;
}
