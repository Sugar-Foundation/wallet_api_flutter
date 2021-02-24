part of wallet_api_flutter;

extension WalletRepositoryTransaction on WalletRepository {
  Future<Map<String, dynamic>> getTransactionInfo({
    @required String chain,
    @required String symbol,
    @required String txId,
  }) {
    return _api.getTransactionInfo(
      chain: chain,
      symbol: symbol,
      txId: txId,
    );
  }

  Future<List<Map<String, dynamic>>> getTransactionsFromApi({
    @required String chain,
    @required String symbol,
    @required String address,
    @required String page,
    @required int skip,
  }) {
    return _api.getTransactions(
      chain: chain,
      symbol: symbol,
      address: address,
      page: page,
      take: skip,
    );
  }

  Future<List<Transaction>> getTransactionsFromCache({
    @required String symbol,
    @required String address,
  }) async {
    final list = await _transactions.get(
      '$symbol:$address',
      defaultValue: [],
    );
    return List.from(list);
  }

  Future<void> saveTransactionsToCache({
    @required String symbol,
    @required String address,
    @required List<Transaction> transactions,
  }) async {
    await _transactions.put(
      '$symbol:$address',
      transactions,
    );
  }

  Future<void> clearTransactionsCache({
    @required String symbol,
    @required String address,
  }) async {
    await _transactions.put(
      '$symbol:$address',
      [],
    );
  }
}
