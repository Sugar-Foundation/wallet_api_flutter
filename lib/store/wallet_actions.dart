part of wallet_api_flutter;

class WalletActionsCubit extends Cubit<WalletState> {
  WalletActionsCubit() : super(WalletState());

  void _updateState(WalletState newState) {
    emit(newState);
  }

  Future<void> getUnspent({
    @required String chain,
    @required String symbol,
    @required String address,
    @required Completer<List<Map<String, dynamic>>> completer,
    @required double balance,
    String unspentType,
    bool forceUpdate = false,
  }) async {
    if (!kChainsNeedUnspent.contains(chain)) {
      completer.complete(null);
      return;
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
        // TODO: Reset coin balance
      }

      completer.complete(unspent);
    } catch (error) {
      WalletRepository().saveUnspentToCache(
        symbol: symbol,
        address: address,
        unspent: null,
      );

      completer.completeError(error);
    }
  }
}
