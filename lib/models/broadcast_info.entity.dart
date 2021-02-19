part of wallet_api_flutter;

@HiveType(typeId: kHiveTypeBroadcastTxType)
enum BroadcastTxType {
  @HiveField(0)
  swap,

  @HiveField(1)
  pool,

  @HiveField(2)
  project,

  @HiveField(3)
  tradeFailOrder,
}

@HiveType(typeId: kHiveTypeBroadcastTxInfo)
class BroadcastTxInfo extends HiveObject {
  BroadcastTxInfo({
    @required this.chain,
    @required this.symbol,
    @required this.type,
    @required this.txId,
    @required this.apiParams,
  }) {
    createdAt = DateTime.now();
    isSubmitted = false;
  }

  @HiveField(0)
  String chain;
  @HiveField(1)
  String symbol;

  @HiveField(2)
  BroadcastTxType type;
  @HiveField(3)
  String txId;

  @HiveField(4)
  bool isSubmitted;

  @HiveField(5)
  String apiParams;

  @HiveField(6)
  DateTime createdAt;
  @HiveField(7)
  DateTime updatedAt;
}
