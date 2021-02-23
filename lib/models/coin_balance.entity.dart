part of wallet_api_flutter;

@HiveType(typeId: kHiveTypeCoinBalance)
class CoinBalance extends HiveObject {
  CoinBalance({
    @required this.chain,
    @required this.symbol,
    this.balance = 0,
    this.unconfirmed = 0,
  }) {
    createdAt = DateTime.now();
    isFailed = false;
    _balanceChanges = StreamController();
  }

  @protected
  StreamController<CoinBalance> _balanceChanges;

  @HiveField(0)
  String chain;
  @HiveField(1)
  String symbol;
  @HiveField(2)
  double balance;
  @HiveField(3)
  double unconfirmed;

  /// Time use to avoid frequent balances updates
  @HiveField(6)
  DateTime lockUntil;

  /// If true indicate that update balance has failed
  @HiveField(7)
  bool isFailed;

  @HiveField(20)
  DateTime createdAt;
  @HiveField(21)
  DateTime updatedAt;

  /// Stream of balances updates
  Stream<CoinBalance> get balanceChanges => _balanceChanges.stream;

  /// Display balance without extra zeros
  String get displayBalance => NumberUtil.truncateDecimal<String>(balance);

  void dispose() {
    _balanceChanges.close();
  }
}
