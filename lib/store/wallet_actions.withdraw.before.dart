part of wallet_api_flutter;

class WithdrawBeforeParams {
  WithdrawBeforeParams({
    @required this.chain,
    @required this.symbol,
    @required this.fromAddress,
    @required this.chainPrecision,
    this.contractOrForkId,
    this.toAddress,
    this.amount,
    this.txData,
  });

  final String chain;
  final String symbol;
  final String fromAddress;

  final int chainPrecision;

  /// [ETH or BCC Only]:  token contract/fork
  final String contractOrForkId;

  /// [ETH and BTC Only]: need toAddress to check for GAS fee
  final String toAddress;

  /// [BTC Only]: need to check for fee
  final double amount;

  /// [BBC Only]: transaction data, need for calculate the fee
  final String txData;
}

/// WithdrawData Before submit
///
class WithdrawBeforeData {
  WithdrawBeforeData({
    @required this.chain,
    @required this.symbol,
    @required this.fromAddress,
    @required this.contract,
    @required this.utxos,
    @required this.fee,
    @required this.feeData,
    @required this.feeUnit,
    @required this.feeSymbol,
    @required this.feeError,
    this.toAddress,
    this.feeRate,
  });

  final String chain;
  final String symbol;
  final String fromAddress;

  /// Fork ID or ETH Token Contract
  final String contract;

  /// fromAddress unspent utxos
  final List<Map<String, dynamic>> utxos;

  /// Fee in current chain symbol
  double fee;

  /// All Data returned from the Fee API
  final dynamic feeData;

  /// Mainly use for Bitcoin (satoshi/byte)
  final String feeUnit;

  /// Fee in coin symbol
  final String feeSymbol;

  /// Error code from getFee API
  /// null is not error
  final String feeError;

  /// Used for bitcoin, the fee in satoshi/byte
  double feeRate;

  /// Used for ETH since we need the toAddress to get the fee
  String toAddress;

  bool get isDoubleTransaction => false;
  // bool get isDoubleTransaction =>
  //     feeError != null &&
  //     feeError == 'INTERACT_WITH_THE_SAME_WALLET_FREQUENTLY';

  String get displayFee => fee != null && fee > 0
      ? NumberUtil.truncateDecimal<String>(fee, 10)
      : '-';

  String get displayFeeRate => feeRate != null && feeRate > 0
      ? NumberUtil.truncateDecimal<String>(feeRate, 10)
      : '-';
}

// class WalletActionWithdrawBefore extends _BaseAction {
//   WalletActionWithdrawBefore({
//     this.params,
//     this.completer,
//     this.previousData,
//     this.ignoreAddressCheck = false,
//   });

//   final WithdrawBeforeParams params;
//   final WithdrawBeforeData previousData;
//   final Completer<WithdrawBeforeData> completer;
//   final bool ignoreAddressCheck;

//   @override
//   Future<WalletState> reduce() async {
//     final toAddress = params.toAddress;
//     final chain = params.chain;

//     // Validate toAddress
//     if (ignoreAddressCheck != true &&
//         toAddress != null &&
//         toAddress.isNotEmpty) {
//       await WalletRepository().validateAddress(
//         chain: chain,
//         address: toAddress,
//       );
//     }

//     _BaseAction action;
//     switch (chain) {
//       case 'BTC':
//         action = WalletActionBTCTxBefore(params, completer, previousData);
//         break;
//       case 'ETH':
//         action = WalletActionETHTxBefore(params, completer);
//         break;
//       case 'BBC':
//         action = WalletActionBBCTxBefore(params, completer);
//         break;
//       case 'TRX':
//         action = WalletActionTRXTxBefore(params, completer);
//         break;
//       default:
//         completer.complete();
//     }
//     if (action != null) {
//       await store.dispatchFuture(action, notify: false);
//     }
//     return null;
//   }

//   @override
//   Object wrapError(dynamic error) {
//     // Customize errors
//     if (error is PlatformException && error.code == 'AddressError') {
//       completer.completeError(WalletAddressError());
//       return error;
//     }
//     completer.completeError(error);
//     return error;
//   }
// }

// //  ▼▼▼▼▼▼ Chains Implementations ▼▼▼▼▼▼  //

// class WalletActionBTCTxBefore extends _BaseAction {
//   WalletActionBTCTxBefore(
//     this.params,
//     this.completer, [
//     this.perviousData,
//   ]);
//   static const chain = 'BTC';

//   final WithdrawBeforeParams params;
//   final WithdrawBeforeData perviousData;
//   final Completer<WithdrawBeforeData> completer;

//   @override
//   Future<WalletState> reduce() async {
//     final toAddress = params.fromAddress;
//     final fromAddress = params.fromAddress;
//     final amount = params.amount;
//     final symbol = params.symbol;

//     var data = perviousData;
//     if (perviousData == null || perviousData?.utxos == null) {
//       final utxosRequest = Completer<List<Map<String, dynamic>>>();
//       final balance = state.activeWallet.getCoinBalance(
//         chain: params.chain,
//         symbol: symbol,
//       );
//       dispatch(WalletActionGetUnspent(
//         chain: chain,
//         symbol: symbol,
//         address: fromAddress,
//         completer: utxosRequest,
//         balance: balance,
//       ));
//       final unspent = await utxosRequest.future;

//       final feeData = await WalletRepository().getFee(
//         chain: chain,
//         symbol: symbol,
//         toAddress: toAddress,
//         fromAddress: fromAddress,
//       );

//       data = WithdrawBeforeData(
//         chain: chain,
//         symbol: 'BTC',
//         toAddress: toAddress,
//         fromAddress: fromAddress,
//         feeRate: NumberUtil.getDouble(feeData['fee']),
//         fee: 0, // Is calculated below
//         feeData: feeData,
//         feeUnit: feeData['unit'].toString(),
//         feeSymbol: 'BTC',
//         feeError: feeData['risk']?.toString(),
//         utxos: unspent,
//         contract: params.contractOrForkId,
//       );
//     }

//     // Calculate real Fee if I have utxos
//     if (data.utxos != null && data.utxos.isNotEmpty) {
//       final utxos = data.utxos
//           .map((item) => {
//                 'txId': item['tx_hash'],
//                 'vOut': NumberUtil.getInt(item['tx_output_n']),
//                 'vAmount': Decimal.parse('${item['value']}').toInt(),
//               })
//           .toList();

//       final feeRate = NumberUtil.getDecimal(data.feeRate).toInt();
//       final feeInBtc = await WalletRepository().createBTCTransaction(
//         utxos: utxos,
//         toAddress: toAddress,
//         fromAddress: fromAddress,
//         toAmount: amount,
//         feeRate: feeRate,
//         beta: WalletConfigNetwork.btc,
//         isGetFee: true,
//       );
//       // Update fee with BTC value
//       data.fee = NumberUtil.truncateDecimal<double>(
//         feeInBtc,
//         params.chainPrecision,
//       );
//     }

//     completer.complete(data);
//     return null;
//   }
// }

// class WalletActionETHTxBefore extends _BaseAction {
//   WalletActionETHTxBefore(
//     this.params,
//     this.completer,
//   );

//   static const chain = 'ETH';

//   final WithdrawBeforeParams params;
//   final Completer<WithdrawBeforeData> completer;

//   @override
//   Future<WalletState> reduce() async {
//     final symbol = params.symbol;
//     final toAddress = params.toAddress;
//     final fromAddress = params.fromAddress;

//     final feeData = await WalletRepository().getFee(
//       chain: chain,
//       symbol: symbol,
//       toAddress: toAddress,
//       fromAddress: fromAddress,
//     );
//     final gasPrice = NumberUtil.getDecimal(feeData['gas_price']);
//     final gasLimit = NumberUtil.getDecimal(feeData['gas_limit']);
//     var fee = NumberUtil.getIntAmountAsDouble(
//       gasPrice * gasLimit,
//     );

//     fee = NumberUtil.truncateDecimal<double>(fee, params.chainPrecision);

//     final info = WithdrawBeforeData(
//       chain: chain,
//       symbol: symbol,
//       toAddress: toAddress,
//       fromAddress: fromAddress,
//       fee: fee,
//       feeData: feeData,
//       feeUnit: 'ETH',
//       feeSymbol: 'ETH',
//       feeError: feeData['risk']?.toString(),
//       utxos: [], // ETH don't have unspent
//       contract: params.contractOrForkId,
//     );

//     completer.complete(info);
//     return null;
//   }
// }

// class WalletActionBBCTxBefore extends _BaseAction {
//   WalletActionBBCTxBefore(
//     this.params,
//     this.completer,
//   );
//   static const chain = 'BBC';

//   final WithdrawBeforeParams params;
//   final Completer<WithdrawBeforeData> completer;

//   @override
//   Future<WalletState> reduce() async {
//     final symbol = params.symbol;
//     final toAddress = params.toAddress;
//     final fromAddress = params.fromAddress;

//     final utxosRequest = Completer<List<Map<String, dynamic>>>();
//     final balance = state.activeWallet.getCoinBalance(
//       chain: params.chain,
//       symbol: symbol,
//     );

//     dispatch(WalletActionGetUnspent(
//       chain: chain,
//       symbol: symbol,
//       address: fromAddress,
//       completer: utxosRequest,
//       balance: balance,
//     ));
//     final unspent = await utxosRequest.future;

//     final feeData = await WalletRepository().getFee(
//       chain: chain,
//       symbol: symbol,
//       data: params.txData,
//       toAddress: toAddress,
//       fromAddress: fromAddress,
//     );

//     final info = WithdrawBeforeData(
//       chain: chain,
//       symbol: symbol,
//       toAddress: toAddress,
//       fromAddress: fromAddress,
//       fee: NumberUtil.getDouble(feeData['fee']),
//       feeData: feeData,
//       feeUnit: feeData['unit'].toString(),
//       feeSymbol: feeData['unit'].toString(),
//       feeError: feeData['risk']?.toString(),
//       utxos: unspent,
//       contract: params.contractOrForkId,
//     );

//     completer.complete(info);
//     return null;
//   }
// }

// class WalletActionTRXTxBefore extends _BaseAction {
//   WalletActionTRXTxBefore(
//     this.params,
//     this.completer,
//   );
//   static const chain = 'TRX';

//   final WithdrawBeforeParams params;
//   final Completer<WithdrawBeforeData> completer;

//   @override
//   Future<WalletState> reduce() async {
//     final symbol = params.symbol;
//     final toAddress = params.toAddress;
//     final fromAddress = params.fromAddress;

//     final feeData = await WalletRepository().getFee(
//       chain: chain,
//       symbol: symbol,
//       data: params.txData,
//       toAddress: toAddress,
//       fromAddress: fromAddress,
//     );

//     final info = WithdrawBeforeData(
//       chain: chain,
//       symbol: symbol,
//       toAddress: toAddress,
//       fromAddress: fromAddress,
//       fee: NumberUtil.getIntAmountAsDouble(feeData['fee'], 6),
//       feeData: feeData,
//       feeUnit: feeData['unit'].toString(),
//       feeSymbol: 'TRX',
//       feeRate: NumberUtil.getDouble(feeData['fee']),
//       feeError: feeData['risk']?.toString(),
//       utxos: [],
//       contract: params.contractOrForkId,
//     );

//     completer.complete(info);
//     return null;
//   }
// }
