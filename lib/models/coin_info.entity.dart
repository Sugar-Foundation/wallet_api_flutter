part of wallet_api_flutter;

@HiveType(typeId: kHiveTypeCoinInfo)
class CoinInfo extends HiveObject {
  CoinInfo({
    @required this.chain,
    @required this.symbol,
    @required this.name,
    @required this.fullName,
    @required this.chainPrecision,
    @required this.displayPrecision,
    this.contract = '',
    this.iconOnline,
    this.iconLocal,
    this.isEnabled,
    this.isFixed,
  }){
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  @HiveField(0)
  String chain;
  @HiveField(1)
  String symbol;

  /// Token contract or fork
  /// - ETH: Token contract
  /// - BBC: Fork ID
  @HiveField(2)
  String contract;

  @HiveField(3)
  String name;
  @HiveField(4)
  String fullName;

  @HiveField(5)
  String iconOnline;
  @HiveField(6)
  String iconLocal;

  @HiveField(7)
  int chainPrecision;
  @HiveField(8)
  int displayPrecision;

  @HiveField(10)
  bool isFixed;
  @HiveField(11)
  bool isEnabled;

  @HiveField(20)
  DateTime createdAt;
  @HiveField(21)
  DateTime updatedAt;

  String get id => '$chain:$symbol';

  String get displayName => name ?? symbol;
}
