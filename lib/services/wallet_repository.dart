part of wallet_api_flutter;

class WalletRepository {
// Singleton instance

  factory WalletRepository([
    WalletApi _api,
  ]) {
    _instance._api = _api ?? WalletApi(Request());
    return _instance;
  }
  WalletRepository._internal();

  static final _instance = WalletRepository._internal();

  WalletApi _api;
  LazyBox<Wallet> _wallets;
  LazyBox<List<dynamic>> _broadcasts;
  LazyBox<List<dynamic>> _unspents;

  static const _walletCacheKey = 'wallets_v1';
  static const _unspentsCacheKey = 'unspents_v1';
  static const _broadcastsCacheKey = 'broadcasts_v1';

  /// m/44'/%d'/0'/0/0 兼容imToken
  static const walletPathImToken = "m/44'/%d'/0'/0/0";

  /// PockMine path
  static const walletPathPockMine = "m/44'/%d'";

  /// 为空 兼容imToken
  static const walletPasswordImToken = '';

  /// 为空 兼容PockMine
  static const walletPasswordPockMine = 'bbc_keys';

// Methods

  Future<void> initializeCache() async {
    _wallets = await Hive.openLazyBox<Wallet>(
      _walletCacheKey,
    );
    _broadcasts = await Hive.openLazyBox<List<dynamic>>(
      _broadcastsCacheKey,
    );
    _unspents = await Hive.openLazyBox<List<dynamic>>(
      _unspentsCacheKey,
    );
  }

  Future<Map<String, dynamic>> getFee({
    @required String chain,
    @required String symbol,
    String toAddress,
    String fromAddress,
    String data = '',
  }) {
    return _api.getFee(
      chain: chain,
      symbol: symbol,
      toAddress: toAddress,
      fromAddress: fromAddress,
      data: data,
    );
  }

//  ▼▼▼▼▼▼ Unspent ▼▼▼▼▼▼  //

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

  /// null-api error ,[]-balance zero ,[unspent]-nice
  Future<List<Map<String, dynamic>>> getUnspentFromCache({
    @required String symbol,
    @required String address,
  }) async {
    final list = await _unspents.get('$symbol:$address');
    if (list != null && list.isNotEmpty) {
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

//  ▼▼▼▼▼▼ Manage Wallet ▼▼▼▼▼▼  //

  Future<List<Wallet>> getAllWallets() async {
    final wallets = <Wallet>[];
    final walletsKeys = _wallets.keys;
    for (final walletKey in walletsKeys) {
      wallets.add(await _wallets.get(walletKey));
    }
    wallets.sort(
      (a, b) =>
          (a.createdAt?.millisecondsSinceEpoch ?? 0) -
          (b.createdAt?.millisecondsSinceEpoch ?? 0),
    );
    return wallets;
  }

  Future<Wallet> getWalletById(String walletId) async {
    if (walletId != null) {
      return _wallets.get(walletId);
    }
    return null;
  }

  Future<List<Wallet>> saveWallet(String walletId, Wallet wallet) async {
    wallet.updatedAt = DateTime.now();
    await _wallets.put(walletId, wallet);
    return getAllWallets();
  }

  /// Create new mnemonic
  Future<String> generateMnemonic() {
    return WalletCore.generateMnemonic();
  }

  /// Validate mnemonic
  Future<bool> validateMnemonic(String mnemonic) {
    return WalletCore.validateMnemonic(mnemonic);
  }

  /// Validate Address
  Future<bool> validateAddress({
    @required String chain,
    @required String address,
  }) {
    return WalletCore.validateAddress(
      chain: chain,
      address: address,
      isBeta: WalletConfigNetwork.getTestNetByChain(chain), // 只有btc 要 beta
    );
  }

  /// Import existing mnemonic
  /// mnemonic 助记词
  /// path xxx
  /// password 钱包标识，一个应用一个password
  Future<Map<String, WalletAddressInfo>> importMnemonic({
    String mnemonic,
    WalletCoreOptions options = const WalletCoreOptions(),
    List<String> symbols,
  }) async {
    final keys = await WalletCore.importMnemonic(
      mnemonic: mnemonic,
      path: options.useBip44 ? walletPathImToken : walletPathPockMine,
      password:
          options.useBip44 ? walletPasswordImToken : walletPasswordPockMine,
      symbols: symbols ??
          [
            WalletSdkChains.btc,
            WalletSdkChains.bbc,
            WalletSdkChains.eth,
            WalletSdkChains.trx,
          ],
      options: options,
    );
    return keys;
  }

  Future<String> exportPrivateKey({
    @required String mnemonic,
    @required String chain,
    @required String forkId,
    WalletCoreOptions options = const WalletCoreOptions(),
  }) {
    return WalletCore.exportPrivateKey(
      symbol: chain,
      mnemonic: mnemonic,
      path: options.useBip44 ? walletPathImToken : walletPathPockMine,
      password:
          options.useBip44 ? walletPasswordImToken : walletPasswordPockMine,
      options: options,
    );
  }

  Future<BbcAddressInfo> createBBCPairKey({
    WalletCoreOptions options = const WalletCoreOptions(),
  }) {
    return WalletBBC.createBBCKeyPair(
      bip44Path: options.useBip44 ? walletPathImToken : walletPathPockMine,
      bip44Key:
          options.useBip44 ? walletPasswordImToken : walletPasswordPockMine,
    );
  }

  //  ▼▼▼▼▼▼ Save Broadcast TxId ▼▼▼▼▼▼  //

  Future<List<BroadcastTxInfo>> getBroadcastsFromCache(
    String walletId,
  ) async {
    try {
      final list = await _broadcasts.get(
        walletId,
        defaultValue: [],
      );
      return List.from(list);
    } catch (_) {
      return List.from([]);
    }
  }

  Future<void> saveBroadcastsToCache(
    String walletId,
    List<BroadcastTxInfo> broadcasts,
  ) async {
    await _broadcasts.put(
      walletId,
      broadcasts,
    );
  }

  Future<void> clearBroadcastsCache(
    String walletId,
  ) async {
    await _broadcasts.put(
      walletId,
      [],
    );
  }

//  ▼▼▼▼▼▼ Create Withdraw Transaction ▼▼▼▼▼▼  //

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
    return _api.postTRXCreateTransaction(
      chain: 'TRX',
      symbol: symbol,
      from: from,
      amount: amount,
      address: address,
      fee: fee,
    );
  }

//  ▼▼▼▼▼▼ Create DEX Transaction ▼▼▼▼▼▼  //

  Future<double> getDexApproveBalance({
    @required String chain,
    @required String symbol,
    @required String sellAddress,
    @required String sellContract,
    @required int chainPrecision,
  }) async {
    final balance = await _api.getDexApproveBalance(
      chain: chain,
      symbol: symbol,
      sellAddress: sellAddress,
      sellContract: sellContract,
    );
    return balance != null
        ? NumberUtil.getIntAmountAsDouble(
            balance['balance']?.toString() ?? 0,
            chainPrecision,
          )
        : 0.0;
  }

  Future<double> getDexOrderBalance({
    @required String chain,
    @required String symbol,
    @required String sellAddress,
    @required String primaryKey,
    @required int chainPrecision,
  }) async {
    final balance = await _api.getDexOrderBalance(
      chain: chain,
      symbol: symbol,
      primaryKey: primaryKey,
      sellAddress: sellAddress,
    );
    return balance != null
        ? NumberUtil.getIntAmountAsDouble(
            balance ?? 0,
            chainPrecision,
          )
        : 0.0;
  }

  Future<Map<String, dynamic>> dexCreateApproveTransaction({
    @required String chain,
    @required String symbol,
    @required int sellAmount,
    @required String sellContract,
    @required String sellAddress,
  }) {
    return _api.getDexOrderApproveRawTx(
      chain: chain,
      symbol: symbol,
      sellAmount: sellAmount,
      sellContract: sellContract,
      sellAddress: sellAddress,
    );
  }

  Future<BbcTemplateData> dexCreateBBCOrderTransaction({
    @required String tradePairId,
    @required double price,
    @required int fee,
    @required int timestamp,
    @required int validHeight,
    @required String recvAddress,
    @required String sellerAddress,
    @required String matchAddress,
    @required String dealAddress,
  }) {
    return WalletBBC.createBBCDexOrderTemplateData(
      tradePair: tradePairId,
      price: NumberUtil.getAmountAsInt(price, 10),
      fee: fee,
      timestamp: timestamp,
      validHeight: validHeight,
      recvAddress: recvAddress,
      sellerAddress: sellerAddress,
      matchAddress: matchAddress,
      dealAddress: dealAddress,
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
      path: options.useBip44 ? walletPathImToken : walletPathPockMine,
      password:
          options.useBip44 ? walletPasswordImToken : walletPasswordPockMine,
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
      path: options.useBip44 ? walletPathImToken : walletPathPockMine,
      password:
          options.useBip44 ? walletPasswordImToken : walletPasswordPockMine,
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
