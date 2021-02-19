part of wallet_api_flutter;

class WithdrawSubmitParams {
  WithdrawSubmitParams({
    @required this.amount,
    @required this.toAddress,
    @required this.chainPrecision,
    @required this.withdrawData,
    this.txData,
    this.txDataUUID,
    this.txTemplateData,
    this.dataType,
    this.type,
    this.broadcastType,
  });

  final double amount;
  final String toAddress;
  final int chainPrecision;
  final WithdrawBeforeData withdrawData;

// BBC chain props
  final String txData;
  final String txDataUUID;
  final String txTemplateData;
  final BbcDataType dataType;

  /// bbc type 0-token 2-invitation
  final int type;

  final String broadcastType;
}

// class WalletActionWithdrawSubmit extends _BaseAction {
//   WalletActionWithdrawSubmit({
//     @required this.params,
//     @required this.walletData,
//     @required this.completer,
//     this.onConfirmSubmit,
//   });

//   final WithdrawSubmitParams params;
//   final WalletPrivateData walletData;
//   final Completer<String> completer;
//   final Future<bool> Function() onConfirmSubmit;

//   @override
//   Future<WalletState> reduce() async {
//     _BaseAction action;
//     final chain = params.withdrawData.chain;
//     switch (chain) {
//       case 'BTC':
//         action = WalletActionBTCTxSubmit(
//           params,
//           walletData,
//           completer,
//           onConfirmSubmit,
//         );
//         break;
//       case 'ETH':
//         action = WalletActionETHTxSubmit(
//           params,
//           walletData,
//           completer,
//           onConfirmSubmit,
//         );
//         break;
//       case 'BBC':
//         action = WalletActionBBCTxSubmit(
//           params,
//           walletData,
//           completer,
//           onConfirmSubmit,
//         );
//         break;
//       case 'TRX':
//         action = WalletActionTRXTxSubmit(
//           params,
//           walletData,
//           completer,
//           onConfirmSubmit,
//         );
//         break;
//     }
//     if (action != null) {
//       await dispatchFuture(action, notify: false);
//     }

//     return null;
//   }

//   @override
//   Object wrapError(dynamic error) {
//     completer.completeError(error);
//     return false;
//   }
// }

// //  ▼▼▼▼▼▼ Chains Implementations ▼▼▼▼▼▼  //

// class WalletActionBTCTxSubmit extends _BaseAction {
//   WalletActionBTCTxSubmit(
//     this.params,
//     this.walletData,
//     this.completer,
//     this.onConfirmSubmit,
//   );

//   static const chain = 'BTC';

//   final WithdrawSubmitParams params;
//   final WalletPrivateData walletData;
//   final Completer<String> completer;
//   final Future<bool> Function() onConfirmSubmit;

//   @override
//   Future<WalletState> reduce() async {
//     final data = params.withdrawData;
//     final toAddress = params.toAddress;
//     final amount = params.amount;
//     final fromAddress = data.fromAddress;
//     final feeRate = NumberUtil.getDecimal(data.feeRate).toInt();

//     final utxos = data.utxos.map((item) {
//       final vAmount =
//           Decimal.parse(item['value'].toString()) / Decimal.parse('1e8');
//       return {
//         'txId': item['tx_hash'].toString(),
//         'vOut': NumberUtil.getInt(item['tx_output_n']),
//         'vAmount': vAmount.toDouble(),
//       };
//     }).toList();

//     final rawTx = await WalletRepository().createBTCTransaction(
//       utxos: utxos,
//       toAddress: toAddress,
//       toAmount: amount,
//       fromAddress: fromAddress,
//       feeRate: feeRate,
//       beta: WalletConfigNetwork.btc,
//       isGetFee: false,
//     );

//     final requestSubmit = Completer<String>();
//     dispatch(WalletActionSignAndSubmitRawTx(
//       chain: chain,
//       symbol: data.symbol,
//       rawTx: rawTx,
//       walletData: walletData,
//       fromAddress: fromAddress,
//       broadcastType: params.broadcastType,
//       onConfirmSubmit: onConfirmSubmit,
//       completer: requestSubmit,
//       amount: params.withdrawData.feeSymbol == params.withdrawData.symbol
//           ? NumberUtil.plus<double>(params.amount, params.withdrawData.fee)
//           : params.amount,
//     ));
//     final txId = await requestSubmit.future;

//     // TODO: Handle Asset Call
//     // dispatch(AssetActionAddTransaction(Transaction.fromSubmit(
//     //   params: params,
//     //   txId: txId,
//     // )));

//     completer.complete(txId);
//     return null;
//   }
// }

// class WalletActionETHTxSubmit extends _BaseAction {
//   WalletActionETHTxSubmit(
//     this.params,
//     this.walletData,
//     this.completer,
//     this.onConfirmSubmit,
//   );

//   static const chain = 'ETH';

//   final WithdrawSubmitParams params;
//   final WalletPrivateData walletData;
//   final Completer<String> completer;
//   final Future<bool> Function() onConfirmSubmit;

//   @override
//   Future<WalletState> reduce() async {
//     final data = params.withdrawData;
//     final amount = params.amount;
//     final toAddress = params.toAddress;
//     final fromAddress = data.fromAddress;
//     final gasPrice = NumberUtil.getInt(data.feeData['gas_price']);
//     final gasLimit = NumberUtil.getInt(data.feeData['gas_limit']);
//     final nonce = NumberUtil.getInt(data.feeData['nonce']);
//     final chainAmount = NumberUtil.getAmountAsInt(
//       amount,
//       params.chainPrecision,
//     );

//     final rawTx = await WalletRepository().createETHTransaction(
//       nonce: nonce,
//       gasLimit: gasLimit,
//       address: toAddress,
//       amount: chainAmount,
//       gasPrice: gasPrice,
//       contract: data.contract,
//     );

//     final requestSubmit = Completer<String>();
//     dispatch(WalletActionSignAndSubmitRawTx(
//       chain: chain,
//       symbol: data.symbol,
//       rawTx: rawTx,
//       walletData: walletData,
//       fromAddress: fromAddress,
//       broadcastType: params.broadcastType,
//       onConfirmSubmit: onConfirmSubmit,
//       completer: requestSubmit,
//       amount: params.withdrawData.feeSymbol == params.withdrawData.symbol
//           ? NumberUtil.plus<double>(params.amount, params.withdrawData.fee)
//           : params.amount,
//     ));
//     final txId = await requestSubmit.future;

//     // TODO: Handle Asset Call
//     // dispatch(AssetActionAddTransaction(Transaction.fromSubmit(
//     //   params: params,
//     //   txId: txId,
//     // )));

//     completer.complete(txId);
//     return null;
//   }
// }

// class WalletActionBBCTxSubmit extends _BaseAction {
//   WalletActionBBCTxSubmit(
//     this.params,
//     this.walletData,
//     this.completer,
//     this.onConfirmSubmit,
//   );

//   static const chain = 'BBC';

//   final WithdrawSubmitParams params;
//   final WalletPrivateData walletData;
//   final Completer<String> completer;
//   final Future<bool> Function() onConfirmSubmit;

//   @override
//   Future<WalletState> reduce() async {
//     final data = params.withdrawData;
//     final toAddress = params.toAddress;
//     final fromAddress = data.fromAddress;
//     final amount = params.amount;
//     final anchor = data.contract;
//     const timestamp = 0; // TODO: SystemDate.getTime();
//     final utxos = data.utxos
//         .map((item) => {
//               'txId': item['txid'],
//               'vOut': NumberUtil.getInt(item['out']),
//             })
//         .toList();

//     final rawTx = await WalletRepository().createBBCTransaction(
//       utxos: utxos,
//       address: toAddress,
//       timestamp: timestamp,
//       anchor: anchor,
//       amount: amount,
//       fee: data.fee,
//       version: 1, // version
//       lockUntil: 0, // lockUntil 王杰新说用 0
//       type: params.type ?? 0, // type 0-token 2-invitation
//       data: params.txData,
//       dataUUID: params.txDataUUID,
//       templateData: params.txTemplateData,
//       dataType: params.dataType,
//     );

//     final requestSubmit = Completer<String>();
//     dispatch(WalletActionSignAndSubmitRawTx(
//       chain: chain,
//       symbol: data.symbol,
//       rawTx: rawTx,
//       walletData: walletData,
//       fromAddress: fromAddress,
//       broadcastType: params.broadcastType,
//       onConfirmSubmit: onConfirmSubmit,
//       completer: requestSubmit,
//       amount: params.withdrawData.feeSymbol == params.withdrawData.symbol
//           ? NumberUtil.plus<double>(params.amount, params.withdrawData.fee)
//           : params.amount,
//     ));
//     final txId = await requestSubmit.future;

//     // TODO: Handle Asset Call
//     // dispatch(AssetActionAddTransaction(Transaction.fromSubmit(
//     //   params: params,
//     //   txId: txId,
//     // )));

//     completer.complete(txId);
//     return null;
//   }
// }

// class WalletActionTRXTxSubmit extends _BaseAction {
//   WalletActionTRXTxSubmit(
//     this.params,
//     this.walletData,
//     this.completer,
//     this.onConfirmSubmit,
//   );

//   static const chain = 'TRX';

//   final WithdrawSubmitParams params;
//   final WalletPrivateData walletData;
//   final Completer<String> completer;
//   final Future<bool> Function() onConfirmSubmit;

//   @override
//   Future<WalletState> reduce() async {
//     final data = params.withdrawData;
//     final toAddress = params.toAddress;
//     final fromAddress = data.fromAddress;
//     final amount = params.amount;

//     final rawTx = await WalletRepository().createTRXTransaction(
//       symbol: data.symbol,
//       address: toAddress,
//       from: fromAddress,
//       amount: NumberUtil.getAmountAsInt(amount, params.chainPrecision),
//       fee: data.feeRate.toInt(),
//     );

//     final requestSubmit = Completer<String>();
//     dispatch(WalletActionSignAndSubmitRawTx(
//       chain: chain,
//       symbol: data.symbol,
//       rawTx: rawTx,
//       walletData: walletData,
//       fromAddress: fromAddress,
//       broadcastType: params.broadcastType,
//       onConfirmSubmit: onConfirmSubmit,
//       completer: requestSubmit,
//       amount: params.withdrawData.feeSymbol == params.withdrawData.symbol
//           ? NumberUtil.plus<double>(params.amount, params.withdrawData.fee)
//           : params.amount,
//     ));
//     final txId = await requestSubmit.future;
//     // TODO: Handle Asset Call
//     // dispatch(AssetActionAddTransaction(Transaction.fromSubmit(
//     //   params: params,
//     //   txId: txId,
//     // )));

//     completer.complete(txId);
//     return null;
//   }
// }

// class WalletActionSignAndSubmitRawTx extends _BaseAction {
//   WalletActionSignAndSubmitRawTx({
//     @required this.chain,
//     @required this.symbol,
//     @required this.rawTx,
//     @required this.fromAddress,
//     @required this.walletData,
//     @required this.amount,
//     @required this.completer,
//     this.broadcastType,
//     this.onConfirmSubmit,
//   });

//   final String chain;
//   final String symbol;
//   final String rawTx;
//   final String fromAddress;
//   final double amount;
//   final String broadcastType;
//   final WalletPrivateData walletData;
//   final Completer<String> completer;
//   final Future<bool> Function() onConfirmSubmit;

//   @override
//   Future<WalletState> reduce() async {
//     String signedTx;

//     if (walletData.walletType == WalletType.device) {
//       // TODO: use HDKeyCore.signTx
//     } else {
//       signedTx = await WalletRepository().signTx(
//         mnemonic: walletData.mnemonic,
//         chain: chain,
//         rawTx: rawTx,
//         options: WalletCoreOptions(
//           useBip44: walletData.useBip44,
//           beta: WalletConfigNetwork.getTestNetByChain(chain),
//         ),
//       );
//     }

//     if (onConfirmSubmit != null) {
//       final canContinue = await onConfirmSubmit();
//       if (canContinue != true) {
//         return null;
//       }
//     }

//     final txId = await WalletRepository().submitTransaction(
//       type: broadcastType,
//       chain: chain,
//       symbol: symbol,
//       signedTx: signedTx,
//       walletId: walletData.walletId,
//     );
//     // } catch (error) {
//     //   if (chain == 'TRX' &&
//     //       error is DioError &&
//     //       error.response?.statusCode == 400 &&
//     //       error.message != null &&
//     //       error.message.contains('timed out')) {
//     //     // For TRX, continue with empty txId
//     //   } else {
//     //     rethrow;
//     //   }
//     // }

//     if (kChainsNeedUnspent.contains(chain)) {
//       await WalletRepository().clearUnspentCache(
//         symbol: symbol,
//         address: fromAddress,
//       );
//     }

//     // Update balance after submit
//     // TODO: Handle Asset Call
//     // dispatch(
//     //   AssetActionGetCoinBalance(
//     //     wallet: store.state.activeWallet,
//     //     chain: chain,
//     //     symbol: symbol,
//     //     address: fromAddress,
//     //     subtractFromBalance: amount,
//     //     ignoreBalanceLock: true,
//     //   ),
//     // );

//     completer.complete(txId);

//     return null;
//   }

//   @override
//   Object wrapError(dynamic error) {
//     // If the error is about broadcasting, maybe unspent have problem,
//     // so we need to clear it
//     // "Tx rejected" is the error message from BBC wallet
//     final responseError = Request().getResponseError(error);
//     if (responseError.message.contains('Tx rejected')) {
//       WalletRepository().clearUnspentCache(
//         symbol: symbol,
//         address: fromAddress,
//       );
//       // Update balance if have error
//       // TODO: Handle Asset Call
//       // dispatch(AssetActionGetCoinBalance(
//       //   wallet: store.state.activeWallet,
//       //   chain: chain,
//       //   symbol: symbol,
//       //   address: fromAddress,
//       //   subtractFromBalance: amount,
//       //   ignoreBalanceLock: true,
//       // ));
//       completer.completeError(WalletTransTxRejected(responseError.message));
//     } else {
//       completer.completeError(error);
//     }
//     return error;
//   }
// }
