part of wallet_api_flutter;

@HiveType(typeId: kHiveTypeCoinAddress)
class CoinAddress extends HiveObject {
  CoinAddress({
    @required this.chain,
    @required this.symbol,
    @required this.address,
    @required this.publicKey,
    this.type,
    this.memoOrTag,
    this.description,
  }) {
    createdAt = DateTime.now();
    type = type ?? 'general';
    description = description ?? '';
  }

  @HiveField(0)
  String chain;
  @HiveField(1)
  String symbol;
  @HiveField(2)
  String address;

  @HiveField(3)
  String publicKey;

  /// Type of add address
  /// Default to general, means chain default address
  /// - For BTC can be General or SegWit
  /// - For other coins can be ETH and Mainnet
  @HiveField(4)
  String type;

  /// Memo or Tag, for example for EOS or XRP
  @HiveField(5)
  String memoOrTag;

  /// Description for this address, like a user note
  @HiveField(6)
  String description;

  @HiveField(20)
  DateTime createdAt;
  @HiveField(21)
  DateTime updatedAt;
}
