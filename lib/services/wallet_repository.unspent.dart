part of wallet_api_flutter;

extension WalletRepositoryUnspent on WalletRepository {
  Future<List<Map<String, dynamic>>> getUnspentFromApi({
    @required String chain,
    @required String symbol,
    @required String address,
    @required String type,
  }) {
    return _api.getUnspent(
      chain: chain,
      symbol: symbol,
      address: address,
      type: type,
    );
  }

  Future<List<Map<String, dynamic>>> getUnspentFromCache({
    @required String symbol,
    @required String address,
  }) async {
    final list = await _unspents.get(
      '$symbol:$address',
    );
    if (list?.isNotEmpty == true) {
      return List<Map<String, dynamic>>.from(
        list.map(
          (e) => (e as Map).cast<String, dynamic>(),
        ),
      );
    }
    if (list == null) {
      return null;
    }
    return List.from(list);
  }

  Future<void> saveUnspentToCache({
    @required String symbol,
    @required String address,
    @required List<Map<String, dynamic>> unspent,
  }) async {
    await _unspents.put(
      '$symbol:$address',
      unspent,
    );
  }

  Future<void> clearUnspentCache({
    @required String symbol,
    @required String address,
  }) async {
    await _unspents.put(
      '$symbol:$address',
      null,
    );
  }
}
