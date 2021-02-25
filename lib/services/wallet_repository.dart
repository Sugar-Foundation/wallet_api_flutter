part of wallet_api_flutter;

class WalletRepository {
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
  LazyBox<List<dynamic>> _unspents;
  LazyBox<List<dynamic>> _transactions;

  static const _walletsCacheKey = 'wallets_v1';
  static const _unspentsCacheKey = 'unspents_v1';
  static const _transactionsCacheKey = 'transactions_v1';

  /// imToken Path
  static const _walletPathImToken = "m/44'/%d'/0'/0/0";

  /// PockMine path
  static const _walletPathPockMine = "m/44'/%d'";

  /// imToken Password
  static const _walletPasswordImToken = '';

  /// PockMine Password
  static const _walletPasswordPockMine = 'bbc_keys';

// Methods

  Future<void> initializeCache() async {
    _wallets = await Hive.openLazyBox<Wallet>(
      _walletsCacheKey,
    );
    _unspents = await Hive.openLazyBox<List<dynamic>>(
      _unspentsCacheKey,
    );
    _transactions = await Hive.openLazyBox<List<dynamic>>(
      _transactionsCacheKey,
    );
  }

//  ▼▼▼▼▼▼ Network Fee ▼▼▼▼▼▼  //

  Future<Map<String, dynamic>> getFee({
    @required String chain,
    @required String symbol,
    String toAddress,
    String fromAddress,
    String txData = '',
  }) {
    return _api.getTransactionFee(
      chain: chain,
      symbol: symbol,
      toAddress: toAddress,
      fromAddress: fromAddress,
      txData: txData,
    );
  }
}
