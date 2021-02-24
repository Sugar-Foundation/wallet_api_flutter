part of wallet_api_flutter;

class WalletApi {
  WalletApi(this._request);
  final Request _request;

//  ▼▼▼▼▼▼ Network Fee ▼▼▼▼▼▼  //

  Future<Map<String, dynamic>> getFee({
    @required String chain,
    @required String symbol,
    String toAddress,
    String fromAddress,
    String data,
  }) =>
      _request.post<Map<String, dynamic>>(
        '/v1/hd/wallet/$chain/$symbol/transaction/fee',
        {
          'from_address': fromAddress,
          'to_address': toAddress,
          'data': data,
        },
      );

//  ▼▼▼▼▼▼ Balances ▼▼▼▼▼▼  //

  Future<String> getCoinBalance({
    @required String chain,
    @required String symbol,
    @required String address,
  }) =>
      Request().getValue<String>(
        '/v1/hd/wallet/$chain/$symbol/$address/balance',
      );

  Future<Map<String, dynamic>> getCoinBalanceWithUnconfirmed({
    @required String chain,
    @required String symbol,
    @required String address,
  }) =>
      Request().getObject(
        '/v2/hd/wallet/$chain/$symbol/$address/balance',
      );

  Future<String> getBtcBalance(
    String address,
  ) =>
      Request().getExternalObject<String>(
        '/address/$address',
        baseUrl: 'https://chain.api.btc.com/v3',
        onResponse: (response) {
          if (response?.data == null ||
              response.data is String ||
              response.data['data'] == null) {
            return null;
          }
          return NumberUtil.getIntAmountAsDouble(
            response.data['data']['balance'],
            8,
          ).toString();
        },
      );

//  ▼▼▼▼▼▼ Unspent ▼▼▼▼▼▼  //

  Future<List<Map<String, dynamic>>> getUnspent({
    @required String chain,
    @required String symbol,
    @required String address,
    @required String type,
  }) =>
      _request.getListOfObjects(
        '/v1/hd/wallet/$chain/$symbol/$address/unspent',
        params: {
          'type': type,
        },
      );

//  ▼▼▼▼▼▼ Transactions ▼▼▼▼▼▼  //

  Future<Map<String, dynamic>> getTransactionInfo({
    @required String chain,
    @required String symbol,
    @required String txId,
  }) =>
      Request().getObject(
        '/v1/hd/wallet/$chain/$symbol/$txId/transaction_info',
      );

  Future<List<Map<String, dynamic>>> getTransactions({
    @required String chain,
    @required String symbol,
    @required String address,
    @required String page,
    int take = 10,
  }) =>
      Request().getListOfObjects(
        '/v1/hd/wallet/$chain/$symbol/$address/transaction?page=$page&take=$take',
      );

  Future<String> submitTransaction({
    @required String chain,
    @required String symbol,
    @required String tx,
    @required String type,
  }) =>
      _request.post<String>(
        '/v1/hd/wallet/$chain/$symbol/transaction/broadcasting',
        {
          'tx': tx,
          'type': type,
        },
      );

  Future<String> createTRXTransaction({
    @required String chain,
    @required String symbol,
    @required String address,
    @required int amount,
    @required int fee,
    @required String from,
  }) async =>
      _request.post<String>(
        '/v1/hd/wallet/$chain/$symbol/transaction',
        {
          'from_public_key': '',
          'to_address': address,
          'from_address': from,
          'amount': amount,
          'fee': fee,
        },
      );
}
