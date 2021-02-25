part of wallet_api_flutter;

/// WithdrawData
class WalletWithdrawData {
  WalletWithdrawData({
    @required this.chain,
    @required this.symbol,
    @required this.fromAddress,
    @required this.contract,
    @required this.utxos,
    @required this.fee,
    @required this.feeDefault,
    this.toAddress,
  });

  final String chain;
  final String symbol;
  final String fromAddress;

  /// Fork ID or Token Contract
  final String contract;

  /// Unspent utxos
  final List<Map<String, dynamic>> utxos;

  /// Default Network Fee data
  final WalletWithdrawFeeData feeDefault;

  /// Current Network Fee data
  WalletWithdrawFeeData fee;

  /// Used for ETH since we need the toAddress to get the fee
  String toAddress;

  bool get isDoubleTransaction => false;

  /// Return true if the withdraw fee symbol is same as withdraw symbol
  /// Example:
  /// for ETH is true, since the fee is paid in ETH
  /// for USDT is false, since the fee is paid in ETH
  bool get isFeeOnSymbol => fee?.feeSymbol == symbol;

  String get displayFee => fee?.feeValue != null && fee.feeValue > 0
      ? NumberUtil.truncateDecimal<String>(fee.feeValue, 10)
      : '-';
}

class WalletWithdrawFeeData {
  WalletWithdrawFeeData({
    @required this.feeRate,
    @required this.feeValue,
    @required this.feeUnit,
    @required this.feeSymbol,
    this.feeError,
    this.gasPrice,
    this.gasLimit,
    this.nonce,
    this.feeLevel = 'default',
  });

  factory WalletWithdrawFeeData.fromJson({
    @required String feeSymbol,
    @required Map<String, dynamic> json,
    String feeUnit,
  }) {
    return WalletWithdrawFeeData(
      feeRate: json['fee']?.toString(),
      feeValue: 0,
      feeUnit: feeUnit ?? json['unit']?.toString(),
      feeSymbol: feeSymbol,
      feeError: json['risk']?.toString(),
    );
  }

  /// Level of the fee
  /// Can be high, low, standard
  final String feeLevel;

  /// Fee in unit on the network
  /// Example for Bitcoin is satoshi/byte
  /// Example for Ethereum is Gwei
  final String feeUnit;

  /// Fee rate in fee unit
  /// Example for Ethereum it will be Gwei
  final String feeRate;

  /// Fee in coin symbol
  final String feeSymbol;

  /// Error code from getFee API
  /// - null is not there is no error
  final String feeError;

  /// Fee value in chain symbol
  /// Example 0.005 ETH for Ethereum
  double feeValue;

  int gasPrice;
  int gasLimit;
  int nonce;

  int get feeRateToInt => NumberUtil.getInt(feeRate);
  double get feeRateToDouble => NumberUtil.getDouble(feeRate);

  WalletWithdrawFeeData copyWith({
    String feeRate,
    String feeLevel,
    String feeUnit,
    String feeSymbol,
    String feeError,
    double feeValue,
    int gasPrice,
    int gasLimit,
    int nonce,
  }) {
    return WalletWithdrawFeeData(
      feeRate: feeRate ?? this.feeRate,
      feeLevel: feeLevel ?? this.feeLevel,
      feeUnit: feeUnit ?? this.feeUnit,
      feeSymbol: feeSymbol ?? this.feeSymbol,
      feeError: feeError ?? this.feeError,
      feeValue: feeValue ?? this.feeValue,
      gasPrice: gasPrice ?? this.gasPrice,
      gasLimit: gasLimit ?? this.gasLimit,
      nonce: nonce ?? this.nonce,
    );
  }
}
