part of wallet_api_flutter;

final kTransactionChainConfirmations = {
  'ETH': 12,
  'BTC': 3,
  'BBC': 1,
  'TRX': 1,
};

/// Type of this wallet (used to generate address)
@HiveType(typeId: kHiveTypeTransactionType)
enum TransactionType {
  @HiveField(0)
  deposit,

  @HiveField(1)
  withdraw,

  @HiveField(2)
  contractCall,

  @HiveField(3)
  approveCall,
}

@HiveType(typeId: kHiveTypeTransaction)
class Transaction extends HiveObject {
  Transaction();

  factory Transaction.fromBTCTx(
    String symbol,
    String fromAddress,
    Map<String, dynamic> data,
  ) {
    final balanceDiff =
        NumberUtil.getIntAmountAsDouble(data['balance_diff'], 8);

    final isWithdraw = balanceDiff < 0;

    final inList =
        (data['inputs'] as List).map((e) => e['prev_addresses'][0]).toList();

    var outList = (data['outputs'] as List)
        .where((e) => !inList.contains('${e['addresses'][0]}'))
        .map((e) => e['addresses'][0])
        .toList();

    outList = outList == null || outList.isEmpty ? inList : outList;

    final inFirst = '${inList[0] ?? ''}';
    final outFirst = '${outList[0] ?? ''}';

    return Transaction()
      ..txId = data['hash']?.toString()
      ..chain = 'BTC'
      ..symbol = symbol
      ..fromAddress = isWithdraw ? fromAddress : inFirst
      ..toAddress = isWithdraw ? outFirst : fromAddress
      ..timestamp = NumberUtil.getInt(data['block_time'])
      ..confirmations = NumberUtil.getInt(data['confirmations'])
      ..feeValue = NumberUtil.getIntAmountAsDouble(data['fee'], 8)
      ..feeSymbol = symbol
      ..type = isWithdraw ? TransactionType.withdraw : TransactionType.deposit
      ..amount = balanceDiff.abs();
  }

  factory Transaction.fromETHTx(
    String symbol,
    String fromAddress,
    int precision,
    Map<String, dynamic> data,
  ) {
    final gas = NumberUtil.multiply<double>(data['gasPrice'], data['gasUsed']);
    final feeUsed = NumberUtil.getIntAmountAsDouble(gas ?? 0);
    final amount = data['amount'] != null
        ? NumberUtil.getDouble(data['amount'])
        : NumberUtil.getIntAmountAsDouble(data['value'] ?? 0, precision);

    return Transaction()
      ..txId = data['hash'].toString()
      ..chain = 'ETH'
      ..symbol = symbol
      ..fromAddress = data['from'].toString()
      ..toAddress = data['to'].toString()
      ..timestamp = NumberUtil.getInt(data['timeStamp'])
      ..blockHeight = NumberUtil.getInt(data['blockNumber'])
      ..confirmations =
          NumberUtil.getInt(data['confirmations'] ?? data['confirmed'])
      ..feeValue = feeUsed
      ..feeSymbol = 'ETH'
      ..type =
          fromAddress.toLowerCase() == data['from'].toString().toLowerCase()
              ? TransactionType.withdraw
              : TransactionType.deposit
      ..failed = data['isError']?.toString() == '1' ||
          data['status']?.toString() == '0x0'
      ..amount = amount;
  }

  factory Transaction.fromTRXTx(
    String symbol,
    String fromAddress,
    Map<String, dynamic> data,
  ) {
    final amount =
        data['type'] == 'Approval' ? 0.0 : NumberUtil.getDouble(data['value']);

    final fee = data['receipt'] != null
        ? NumberUtil.getIntAmountAsDouble(data['receipt']['fee'], 6)
        : 0.0;

    return Transaction()
      ..txId = data['transaction_id']?.toString() ?? data['txID']?.toString()
      ..chain = 'TRX'
      ..symbol = symbol
      ..fromAddress = data['from'].toString()
      ..toAddress = data['to'].toString()
      ..timestamp = data['block_timestamp'] != null
          ? NumberUtil.getInt(data['block_timestamp']) ~/ 1000
          : NumberUtil.getInt(data['timestamp'])
      ..blockHeight = NumberUtil.getInt(data['block_number'] ?? data['block'])
      ..confirmations = NumberUtil.getInt(data['confirmed'], 1)
      ..failed = data['status'] == 'failed'
      ..feeValue = fee
      ..feeSymbol = 'TRX'
      ..type = data['type'] == 'Approval'
          ? TransactionType.approveCall
          : fromAddress.toLowerCase() == data['from'].toString().toLowerCase()
              ? TransactionType.withdraw
              : TransactionType.deposit
      ..amount = amount;
  }

  factory Transaction.fromBBCTx(
    String symbol,
    String fromAddress,
    Map<String, dynamic> data,
  ) =>
      Transaction()
        ..txId = data['hash'].toString()
        ..chain = 'BBC'
        ..symbol = symbol
        ..fromAddress = data['fromAddress'].toString()
        ..toAddress = data['toAddress'].toString()
        ..timestamp = NumberUtil.getInt(data['timestamp'])
        ..confirmations = NumberUtil.getInt(data['confirmed'])
        ..feeValue = NumberUtil.getDouble(data['txFee'])
        ..feeSymbol = symbol
        ..type = fromAddress.toLowerCase() ==
                data['fromAddress'].toString().toLowerCase()
            ? TransactionType.withdraw
            : TransactionType.deposit
        ..amount = NumberUtil.getDouble(data['amount']);

  factory Transaction.fromJson({
    @required String chain,
    @required String symbol,
    @required String fromAddress,
    @required int chainPrecision,
    @required Map<String, dynamic> json,
  }) {
    switch (chain) {
      case 'BBC':
        return Transaction.fromBBCTx(symbol, fromAddress, json);
      case 'ETH':
        return Transaction.fromETHTx(symbol, fromAddress, chainPrecision, json);
      case 'TRX':
        return Transaction.fromTRXTx(symbol, fromAddress, json);
      default:
        return null;
    }
  }

  factory Transaction.fromWithdraw({
    @required WalletWithdrawData withdrawData,
    @required WithdrawSubmitParams params,
    @required String txId,
  }) =>
      Transaction()
        ..txId = txId
        ..chain = withdrawData.chain
        ..symbol = withdrawData.symbol
        ..fromAddress = withdrawData.fromAddress
        ..toAddress = params.toAddress
        ..timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000
        ..confirmations = 0
        ..feeValue = withdrawData.fee.feeValue
        ..feeSymbol = withdrawData.fee.feeSymbol
        ..type = TransactionType.withdraw
        ..amount = params.amount;

  factory Transaction.fromRaw({
    @required String txId,
    @required String chain,
    @required String symbol,
    @required String toAddress,
    @required String fromAddress,
    @required double feeValue,
    @required String feeSymbol,
    @required double amount,
    @required TransactionType type,
  }) =>
      Transaction()
        ..txId = txId
        ..chain = chain
        ..symbol = symbol
        ..fromAddress = fromAddress
        ..toAddress = toAddress
        ..timestamp = DateTime.now().millisecondsSinceEpoch
        ..confirmations = 0
        ..feeValue = feeValue
        ..feeSymbol = feeSymbol
        ..type = type
        ..amount = amount;

  @HiveField(0)
  String txId;
  @HiveField(1)
  String chain;
  @HiveField(2)
  String symbol;
  @HiveField(3)
  int confirmations;
  @HiveField(4)
  int timestamp;
  @HiveField(5)
  int blockHeight;
  @HiveField(6)
  bool failed;

  @HiveField(7)
  String toAddress;
  @HiveField(8)
  String fromAddress;

  @HiveField(9)
  double amount;
  @HiveField(10)
  double feeValue;
  @HiveField(11)
  String feeSymbol;

  @HiveField(13)
  TransactionType type;

  String get displayAmount => NumberUtil.truncateDecimal<String>(amount);

  String get displayAmountWithSign => amount == 0
      ? displayAmount
      : isOutput
          ? '-$displayAmount'
          : '+$displayAmount';

  /// If true, ETH tx failed
  bool get isFailed => failed == true;

  int get timestampSafe => timestamp ?? 0;

  bool get isOutput =>
      type == TransactionType.withdraw ||
      type == TransactionType.contractCall ||
      type == TransactionType.approveCall;

  bool get isExpired =>
      isConfirmed == false &&
      !isFailed &&
      (DateTime.now().millisecondsSinceEpoch - timestamp) > 24 * 60 * 60;

  bool get isTakingLongTime =>
      isConfirmed == false &&
      !isFailed &&
      (DateTime.now().millisecondsSinceEpoch - timestamp) > 5 * 60;

  /// If true, TX is confirmermed, reached the minimum Confirmation
  bool get isConfirmed =>
      confirmations >= (kTransactionChainConfirmations[chain] ?? 0);

  bool get isConfirming =>
      confirmations <= (kTransactionChainConfirmations[chain] ?? 0);
}
