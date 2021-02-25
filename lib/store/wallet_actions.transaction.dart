part of wallet_api_flutter;

extension WalletActionsTransaction on WalletActionsCubit {
  Future<WalletTransactionData> getTransactions({
    @required String chain,
    @required String symbol,
    @required String address,
    @required int chainPrecision,
    int page = 0,
    int skip = 0,

    /// If provided, will use fingerprint instead of the page to load more data
    String fingerprint,

    /// If True will not call API to fetch transaction, will only return cached data
    bool skipRequest = false,
  }) async {
    /// Start with transaction from cache, so we show pending transactions
    final transactions = await WalletRepository().getTransactionsFromCache(
      symbol: symbol,
      address: address,
    );

    var apiError;
    var fingerprint = '';
    var newTransactions = <Transaction>[];
    try {
      if (skipRequest != true) {
        /// Get confirmed transaction on the network
        final rawData = await WalletRepository().getTransactionsFromApi(
          chain: chain,
          symbol: symbol,
          address: address,
          page: fingerprint ?? '$page',
          skip: skip,
        );

        switch (chain) {
          case 'ETH':
            newTransactions = rawData
                .map((item) => Transaction.fromETHTx(
                      symbol,
                      address,
                      chainPrecision,
                      item,
                    ))
                .toList();
            break;
          case 'BTC':
            newTransactions = rawData
                .map((item) => Transaction.fromBTCTx(
                      symbol,
                      address,
                      item,
                    ))
                .toList();
            break;
          case 'BBC':
            newTransactions = rawData
                .map((item) => Transaction.fromBBCTx(
                      symbol,
                      address,
                      item,
                    ))
                .toList();
            break;
          case 'TRX':
            newTransactions = rawData
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
      transactions.retainWhere((x) => !newTxIds.contains(x.txId ?? ''));
      transactions.addAll(newTransactions);
    }

    transactions.sort(
      (a, b) => b.timestamp == a.timestamp
          ? b.txId.compareTo(b.txId)
          : b.timestampSafe.compareTo(a.timestampSafe),
    );

    await WalletRepository().saveTransactionsToCache(
      symbol: symbol,
      address: address,
      transactions: transactions,
    );

    return WalletTransactionData(
      page: page,
      skip: skip,
      apiError: apiError,
      fingerprint: fingerprint,
      transactions: transactions,
      newCount: newTransactions.length,
      totalCount: transactions.length,
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
