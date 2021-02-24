part of wallet_api_flutter;

extension WalletRepositoryWithdraw on WalletRepository {
  Future<String> createETHTransaction({
    @required int nonce,
    @required int gasLimit,
    @required String address,
    @required int amount,
    @required int gasPrice,
    String contract,
  }) {
    return WalletETH.createETHTransaction(
      nonce: nonce,
      gasLimit: gasLimit,
      address: address,
      amount: amount,
      gasPrice: gasPrice,
      contract: contract,
    );
  }

  Future<String> createBTCTransaction({
    @required List<Map<String, dynamic>> utxos,
    @required String toAddress,
    @required double toAmount,
    @required String fromAddress,
    @required int feeRate,
    @required bool beta,
    @required bool isGetFee,
  }) {
    return WalletBTC.createBTCTransaction(
      utxos: utxos,
      toAddress: toAddress,
      toAmount: toAmount,
      fromAddress: fromAddress,
      feeRate: feeRate,
      beta: beta,
      isGetFee: isGetFee,
    );
  }

  Future<String> createBBCTransaction({
    @required List<Map<String, dynamic>> utxos,
    @required String address,
    @required int timestamp,
    @required String anchor,
    @required double amount,
    @required double fee,
    @required int version,
    @required int lockUntil,
    @required int type,
    String data,
    String dataUUID,
    String templateData,
    BbcDataType dataType,
  }) {
    return WalletBBC.createBBCTransaction(
      utxos: utxos,
      address: address,
      timestamp: timestamp,
      anchor: anchor,
      amount: amount,
      fee: fee,
      version: version,
      lockUntil: lockUntil,
      type: type,
      data: data,
      dataUUID: dataUUID,
      templateData: templateData,
      dataType: dataType,
    );
  }

  Future<String> createTRXTransaction({
    @required String symbol,
    @required String from,
    @required String address,
    @required int amount,
    @required int fee,
  }) {
    return _api.createTRXTransaction(
      chain: 'TRX',
      symbol: symbol,
      from: from,
      amount: amount,
      address: address,
      fee: fee,
    );
  }

//  ▼▼▼▼▼▼ Sign and Submit Transaction ▼▼▼▼▼▼  //

  Future<String> signTx({
    @required String mnemonic,
    @required String chain,
    @required String rawTx,
    WalletCoreOptions options = const WalletCoreOptions(),
  }) {
    return WalletCore.signTx(
      mnemonic: mnemonic,
      path: options.useBip44
          ? WalletRepository._walletPathImToken
          : WalletRepository._walletPathPockMine,
      password: options.useBip44
          ? WalletRepository._walletPasswordImToken
          : WalletRepository._walletPasswordPockMine,
      chain: chain,
      rawTx: rawTx,
      options: options,
    );
  }

  Future<String> signMsg({
    @required String mnemonic,
    @required String chain,
    @required String msg,
    WalletCoreOptions options = const WalletCoreOptions(),
  }) {
    return WalletCore.signMsg(
      mnemonic: mnemonic,
      path: options.useBip44
          ? WalletRepository._walletPathImToken
          : WalletRepository._walletPathPockMine,
      password: options.useBip44
          ? WalletRepository._walletPasswordImToken
          : WalletRepository._walletPasswordPockMine,
      chain: chain,
      msg: msg,
      options: options,
    );
  }

  Future<String> signMsgWithPKAndBlake({
    @required String privateKey,
    @required String msg,
  }) {
    return WalletCore.signMsgWithPKAndBlake(
      privateKey: privateKey,
      msg: msg,
    );
  }

  Future<String> submitTransaction({
    @required String chain,
    @required String symbol,
    @required String signedTx,
    @required String walletId,
    @required String type,
  }) {
    return _api.submitTransaction(
      chain: chain,
      symbol: symbol,
      tx: signedTx,
      type: type,
    );
  }
}
