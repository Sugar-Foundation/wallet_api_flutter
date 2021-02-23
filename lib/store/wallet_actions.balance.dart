part of wallet_api_flutter;

extension WalletActionsBalance on WalletActionsCubit {
  Future<double> getCoinBalance({
    @required Wallet wallet,
    @required String chain,
    @required String symbol,
    @required String address,
    double subtractFromBalance,

    /// If True, will not fetch the unspents/utxos from the network
    bool ignoreUnspent = false,

    /// If True, will ignore the balance lock and always fetch the balance from the network
    bool ignoreBalanceLock = false,
  }) async {
    final coinInfo = wallet.getCoinInfo(
      chain: chain,
      symbol: symbol,
    );

    final coinBalance = wallet.getCoinBalance(
      chain: chain,
      symbol: symbol,
      address: address,
    );

    // By default always use cached balance
    final cachedBalance = coinBalance?.balance ?? 0.0;
    var newBalance = coinBalance?.balance ?? 0.0;
    var newUnconfirmed = coinBalance?.unconfirmed ?? 0.0;

    if (address == null || address.isEmpty) {
      return newBalance;
    }

    bool isFailed = false;
    try {
      // Avoid refresh balance too frequently
      if (ignoreBalanceLock == true ||
          !wallet.isCoinBalanceLocked(
            chain: chain,
            symbol: symbol,
            address: address,
          )) {
        final apiBalance = await WalletRepository().getCoinBalance(
          chain: chain,
          symbol: symbol,
          address: address,
          contract: coinInfo.contract,
        );

        // For ETH token, since we use etherscan the balance
        // is a Int using the chainPrecision
        if (chain == 'ETH' && symbol != 'ETH') {
          newBalance = NumberUtil.getIntAmountAsDouble(
            apiBalance['balance'],
            coinInfo.chainPrecision,
          );
        } else {
          newBalance = NumberUtil.getDouble(apiBalance['balance']);
          newUnconfirmed = NumberUtil.getDouble(apiBalance['unconfirmed']);
        }
      }
    } catch (_) {
      isFailed = true;
    }

    // After a withdraw, we refresh the balance but
    // - if the balance is not -1 (equal to zero)
    // - if the balance didn't change
    // We need to subtractFromBalance
    if (subtractFromBalance != null &&
        (newBalance == -1 || cachedBalance == newBalance)) {
      newBalance = NumberUtil.minus(cachedBalance, subtractFromBalance);
    }

    // If api return a negative balance,
    // use the provided balance or the cached one
    if (newBalance < 0) {
      newBalance = cachedBalance ?? 0.0;
    }

    // If balance still negative, use zero
    if (newBalance < 0) {
      newBalance = 0.0;
    }

    if (ignoreUnspent != true) {
      var unspent = <Map<String, dynamic>>[];
      try {
        unspent = await getUnspent(
          chain: chain,
          symbol: symbol,
          address: address,
          forceUpdate: newBalance != cachedBalance,
          balance: newBalance,
        );
      } catch (_) {
        isFailed = true;
        unspent = null;
      }

      // If we have unspent and is a empty list, means we don't have any balance
      if (unspent != null && unspent.isEmpty) {
        newBalance = 0.0;
      }
    }

    wallet.updateCoinBalance(
      chain: chain,
      symbol: symbol,
      address: address,
      balance: newBalance,
      unconfirmed: newUnconfirmed,
      isFailed: isFailed,
    );

    if (isFailed == false) {
      wallet.lookCoinBalance(
        chain: chain,
        symbol: symbol,
        address: address,
        lookUntil: DateTime.now().add(Duration(seconds: 30)),
      );
    }

    return newBalance;
  }

  double resetCoinBalance({
    @required Wallet wallet,
    @required String chain,
    @required String symbol,
    @required String address,
  }) {
    const newBalance = 0.0;
    wallet.updateCoinBalance(
      chain: chain,
      symbol: symbol,
      address: address,
      balance: newBalance,
      unconfirmed: newBalance,
      isFailed: false,
    );
    return newBalance;
  }

  Future<void> updateAllCoinBalances({
    @required Wallet wallet,
  }) async {
    for (final coin in wallet.coins) {
      await getCoinBalance(
        wallet: wallet,
        chain: coin.chain,
        symbol: coin.symbol,
        address: wallet.getCoinAddress(coin.chain),
      );
    }
  }
}
