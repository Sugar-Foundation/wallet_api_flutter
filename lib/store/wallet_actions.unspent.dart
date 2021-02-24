part of wallet_api_flutter;

extension WalletActionsUnspent on WalletActionsCubit {
  Future<List<Map<String, dynamic>>> getUnspent({
    @required String chain,
    @required String symbol,
    @required String address,
    @required double balance,
    String unspentType,
    bool forceUpdate = false,
  }) async {
    if (!kChainsNeedUnspent.contains(chain)) {
      return null;
    }

    try {
      final cacheUnspent = await WalletRepository().getUnspentFromCache(
        symbol: symbol,
        address: address,
      );
      var unspent = <Map<String, dynamic>>[];
      if (forceUpdate ||
          cacheUnspent == null ||
          (cacheUnspent.isEmpty && balance > 0)) {
        unspent = await WalletRepository().getUnspentFromApi(
          chain: chain,
          symbol: symbol,
          address: address,
          type: unspentType,
        );
        await WalletRepository().saveUnspentToCache(
          symbol: symbol,
          address: address,
          unspent: unspent,
        );
      } else {
        unspent = cacheUnspent;
      }

      if (unspent == null || unspent.isEmpty) {
        resetCoinBalance(
          wallet: state.activeWallet,
          chain: chain,
          symbol: symbol,
          address: address,
        );
      }

      return unspent;
    } catch (error) {
      WalletRepository().saveUnspentToCache(
        symbol: symbol,
        address: address,
        unspent: null,
      );
      rethrow;
    }
  }
}
