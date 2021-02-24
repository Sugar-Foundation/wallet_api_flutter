part of wallet_api_flutter;

extension WalletRepositoryBalance on WalletRepository {
  Future<Map<String, String>> getCoinBalance({
    @required String chain,
    @required String symbol,
    @required String address,
    @required String contract,
  }) async {
    String balance = '0';
    String unconfirmed = '0';
    switch (chain) {
      case 'BTC':
        balance = await _api.getBtcBalance(address);
        break;
      case 'BBC':
        final res = await _api.getCoinBalanceWithUnconfirmed(
          chain: chain,
          symbol: symbol,
          address: address,
        );
        balance = res['balance']?.toString();
        unconfirmed = res['unconfirmed']?.toString();
        break;
      default:
        balance = await _api.getCoinBalance(
          chain: chain,
          symbol: symbol,
          address: address,
        );
        break;
    }
    return {
      'balance': balance,
      'unconfirmed': unconfirmed,
    };
  }
}
