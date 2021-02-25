part of wallet_api_flutter;

extension WalletActionsTransaction on WalletActionsCubit {
  Future<WalletTransactionData> getTransactions({
    @required String chain,
    @required String symbol,
    @required String address,
    @required int chainPrecision,
    int skip = 0,
    int page = 0,

    /// If provided, will use fingerprint instead of the page to load more data
    String fingerprint,

    /// If True will not call API to fetch transaction, will only return cached data
    bool onlyCache = false,
  }) async {
    /// Start with transaction from cache, so we show pending transactions
    final allTransactions = await WalletRepository().getTransactionsFromCache(
      symbol: symbol,
      address: address,
    );

    var apiError;
    var newFingerprint;
    var newTransactions = <Transaction>[];
    try {
      if (onlyCache != true) {
        /// Get confirmed transaction on the network
        final rawData = await WalletRepository().getTransactionsFromApi(
          chain: chain,
          symbol: symbol,
          address: address,
          skip: skip,
          page: fingerprint ?? '$page',
        );
        switch (chain) {
          case 'ETH':
            newTransactions = rawData.value
                .map((item) => Transaction.fromETHTx(
                      symbol,
                      address,
                      chainPrecision,
                      item,
                    ))
                .toList();
            break;
          case 'BTC':
            newTransactions = rawData.value
                .map((item) => Transaction.fromBTCTx(
                      symbol,
                      address,
                      item,
                    ))
                .toList();
            break;
          case 'BBC':
            newTransactions = rawData.value
                .map((item) => Transaction.fromBBCTx(
                      symbol,
                      address,
                      item,
                    ))
                .toList();
            break;
          case 'TRX':
            newFingerprint = rawData.key;
            newTransactions = rawData.value
                .map((item) => Transaction.fromTRXTx(
                      symbol,
                      address,
                      item,
                    ))
                .toList();
            break;
          default:
        }
      }
    } catch (error) {
      apiError = error;
    }

    if (newTransactions.isNotEmpty) {
      final newTxIds = newTransactions.map((e) => e.txId).toSet();
      allTransactions.retainWhere((x) => !newTxIds.contains(x.txId ?? ''));
      allTransactions.addAll(newTransactions);
    }

    allTransactions.sort(
      (a, b) => b.timestamp == a.timestamp
          ? b.txId.compareTo(b.txId)
          : b.timestampSafe.compareTo(a.timestampSafe),
    );

    await WalletRepository().saveTransactionsToCache(
      symbol: symbol,
      address: address,
      transactions: allTransactions,
    );

    return WalletTransactionData(
      skip: skip,
      page: page,
      apiError: apiError,
      fingerprint: newFingerprint,
      transactions: allTransactions,
      newCount: newTransactions.length,
      totalCount: allTransactions.length,
    );
  }

  Future<Transaction> addTransaction(Transaction transaction) async {
    final allTransactions = await WalletRepository().getTransactionsFromCache(
      symbol: transaction.symbol,
      address: transaction.fromAddress,
    );

    allTransactions.insert(0, transaction);

    await WalletRepository().saveTransactionsToCache(
      symbol: transaction.symbol,
      address: transaction.fromAddress,
      transactions: allTransactions.toList(),
    );

    return transaction;
  }
}
