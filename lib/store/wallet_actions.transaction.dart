part of wallet_api_flutter;

extension WalletActionsTransaction on WalletActionsCubit {
  Future<List<Transaction>> getTransactions({
    @required String chain,
    @required String symbol,
    @required String address,
    @required int chainPrecision,
    String page,
    int skip,
  }) async {
    /// Start with transaction from cache, so we show pending transactions
    final transactions = await WalletRepository().getTransactionsFromCache(
      symbol: symbol,
      address: address,
    );

    /// Get confirmed transaction on the network
    final rawData = await WalletRepository().getTransactionsFromApi(
      chain: chain,
      symbol: symbol,
      address: address,
      page: page,
      skip: skip,
    );

    var newTransactions = <Transaction>[];
    switch (chain) {
      case 'ETH':
        newTransactions = rawData.map((item) => Transaction.fromETHTx(
              symbol,
              address,
              chainPrecision,
              item,
            ));
        break;
      case 'BTC':
        newTransactions = rawData.map((item) => Transaction.fromBTCTx(
              symbol,
              address,
              item,
            ));
        break;
      case 'BBC':
        newTransactions = rawData.map((item) => Transaction.fromBBCTx(
              symbol,
              address,
              item,
            ));
        break;
      case 'TRX':
        newTransactions = rawData.map((item) => Transaction.fromTRXTx(
              symbol,
              address,
              item,
            ));
        break;
      default:
    }

    final newTxIds = newTransactions.map((e) => e.txId).toSet();
    transactions.retainWhere((x) => !newTxIds.contains(x.txId ?? ''));
    transactions.addAll(newTransactions);

    transactions.sort((a, b) => b.timestamp == a.timestamp
        ? b.txId.compareTo(b.txId)
        : (b.timestamp ?? 0).compareTo(a.timestamp ?? 0));

    await WalletRepository().saveTransactionsToCache(
      symbol: symbol,
      address: address,
      transactions: transactions,
    );

    return transactions;
  }
}