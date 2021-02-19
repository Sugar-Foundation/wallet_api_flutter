part of wallet_api_flutter;

class WalletApi {
  WalletApi(this._request);
  final Request _request;

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

  /// 广播交易
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

//  ▼▼▼▼▼▼ Dex Methods ▼▼▼▼▼▼  //

  Future<Map<String, dynamic>> getDexApproveBalance({
    @required String chain,
    @required String symbol,
    @required String sellAddress,
    @required String sellContract,
  }) =>
      _request.getObject(
        '/v1/hd/wallet/$chain/$symbol/approve_balance',
        params: {
          'sell_token': sellContract,
          'sell_address': sellAddress,
        },
      );

  Future<String> getDexOrderBalance({
    @required String chain,
    @required String symbol,
    @required String primaryKey,
    @required String sellAddress,
  }) =>
      _request.getValue<String>(
        '/v1/hd/wallet/$chain/$symbol/dex_order_balance',
        params: {
          'primary_key': primaryKey,
          'sell_address': sellAddress,
        },
      );

  Future<Map<String, dynamic>> getDexOrderApproveRawTx({
    @required String chain,
    @required String symbol,
    @required int sellAmount,
    @required String sellAddress,
    @required String sellContract,
  }) =>
      _request.getObject(
        '/v1/hd/wallet/$chain/$symbol/approve',
        params: {
          'sell_token': sellContract,
          'sell_amount': sellAmount,
          'sell_address': sellAddress,
        },
      );

  Future<String> postTRXCreateTransaction({
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
          'fee': fee,
          'amount': amount,
        },
      );
}
