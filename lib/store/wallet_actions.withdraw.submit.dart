part of wallet_api_flutter;

class WithdrawSubmitParams {
  WithdrawSubmitParams({
    @required this.amount,
    @required this.toAddress,
    @required this.chainPrecision,
    this.type,
    this.txData,
    this.txDataUUID,
    this.txTemplateData,
    this.dataType,
    this.broadcastType,
  });

  final double amount;
  final String toAddress;
  final int chainPrecision;

  /// BBC transaction type
  /// 0 for token
  /// 2 for invitation
  final int type;

  /// BBC Tx Data
  final String txData;
  final String txDataUUID;
  final String txTemplateData;
  final BbcDataType dataType;

  final String broadcastType;
}

extension WalletActionsWithdrawSubmit on WalletActionsCubit {
  Future<String> withdrawSubmit({
    WithdrawSubmitParams params,
    WalletWithdrawData withdrawData,
    WalletPrivateData walletData,
    Future<bool> Function() onConfirmSubmit,
  }) async {
    String rawTx;
    switch (withdrawData.chain) {
      case 'BTC':
        rawTx = await _getWithdrawRawTxBTC(params, withdrawData);
        break;
      case 'ETH':
        rawTx = await _getWithdrawRawTxETH(params, withdrawData);
        break;
      case 'BBC':
        rawTx = await _getWithdrawRawTxBBC(params, withdrawData);
        break;
      case 'TRX':
        rawTx = await _getWithdrawRawTxTRX(params, withdrawData);
        break;
      default:
        throw 'Not Implemented';
    }

    final txId = await signAndSubmitRawTx(
      rawTx: rawTx,
      chain: withdrawData.chain,
      symbol: withdrawData.symbol,
      fromAddress: withdrawData.fromAddress,
      broadcastType: params.broadcastType,
      onConfirmSubmit: onConfirmSubmit,
      walletData: walletData,
      amount: withdrawData.isFeeOnSymbol
          ? NumberUtil.plus<double>(
              params.amount,
              withdrawData.fee.feeValue,
            )
          : params.amount,
    );
    if (txId?.isNotEmpty == true) {
      addTransaction(Transaction.fromWithdraw(
        params: params,
        withdrawData: withdrawData,
        txId: txId,
      ));
    }
    return txId;
  }

  Future<String> signAndSubmitRawTx({
    @required String chain,
    @required String symbol,
    @required String rawTx,
    @required String fromAddress,
    @required WalletPrivateData walletData,
    @required double amount,
    String broadcastType,
    Future<bool> Function() onConfirmSubmit,
  }) async {
    try {
      final signedTx = await WalletRepository().signTx(
        chain: chain,
        rawTx: rawTx,
        mnemonic: walletData.mnemonic,
        options: WalletCoreOptions(
          useBip44: walletData.useBip44,
          beta: WalletConfigNetwork.getTestNetByChain(chain),
        ),
      );

      if (onConfirmSubmit != null) {
        final canContinue = await onConfirmSubmit();
        if (canContinue != true) {
          return null;
        }
      }

      final txId = await WalletRepository().submitTransaction(
        type: broadcastType,
        chain: chain,
        symbol: symbol,
        signedTx: signedTx,
        walletId: walletData.walletId,
      );

      if (kChainsNeedUnspent.contains(chain)) {
        await WalletRepository().clearUnspentCache(
          symbol: symbol,
          address: fromAddress,
        );
      }

      // Update balance after submit
      getCoinBalance(
        wallet: state.activeWallet,
        chain: chain,
        symbol: symbol,
        address: fromAddress,
        ignoreBalanceLock: true,
        subtractFromBalance: amount,
      );

      return txId;
    } catch (error) {
      // If the error is about broadcasting (TX Rejected), maybe unspent have problem,
      // so we need to clear the unspent cache
      final responseError = Request().getResponseError(error);
      if (responseError.message.contains('Tx rejected')) {
        WalletRepository().clearUnspentCache(
          symbol: symbol,
          address: fromAddress,
        );
        // Force update balance if we have an error
        getCoinBalance(
          wallet: state.activeWallet,
          chain: chain,
          symbol: symbol,
          address: fromAddress,
          ignoreBalanceLock: true,
        );
        throw WalletTransTxRejected(responseError.message);
      }
      rethrow;
    }
  }

// //  ▼▼▼▼▼▼ Chains Implementations ▼▼▼▼▼▼  //

  Future<String> _getWithdrawRawTxBTC(
    WithdrawSubmitParams params,
    WalletWithdrawData data,
  ) async {
    final utxos = data.utxos.map((item) {
      return {
        'txId': item['tx_hash'].toString(),
        'vOut': NumberUtil.getInt(item['tx_output_n']),
        'vAmount': NumberUtil.getIntAmountAsDouble(item['value'], 8),
      };
    }).toList();

    final rawTx = await WalletRepository().createBTCTransaction(
      utxos: utxos,
      toAddress: data.toAddress,
      toAmount: params.amount,
      fromAddress: data.fromAddress,
      feeRate: data.fee.feeRateToInt,
      beta: WalletConfigNetwork.btc,
      isGetFee: false,
    );

    return rawTx;
  }

  Future<String> _getWithdrawRawTxETH(
    WithdrawSubmitParams params,
    WalletWithdrawData data,
  ) async {
    final chainAmount = NumberUtil.getAmountAsInt(
      params.amount,
      params.chainPrecision,
    );

    final rawTx = await WalletRepository().createETHTransaction(
      nonce: data.fee.nonce,
      gasPrice: data.fee.gasPrice,
      gasLimit: data.fee.gasLimit,
      address: data.toAddress,
      amount: chainAmount,
      contract: data.contract,
    );

    return rawTx;
  }

  Future<String> _getWithdrawRawTxBBC(
    WithdrawSubmitParams params,
    WalletWithdrawData data,
  ) async {
    final utxos = data.utxos
        .map((item) => {
              'txId': item['txid'],
              'vOut': NumberUtil.getInt(item['out']),
            })
        .toList();

    final rawTx = await WalletRepository().createBBCTransaction(
      utxos: utxos,
      address: data.toAddress,
      timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      anchor: data.contract,
      amount: params.amount,
      fee: data.fee.feeRateToDouble,
      version: 1,
      lockUntil: 0,
      type: params.type ?? 0,
      data: params.txData,
      dataUUID: params.txDataUUID,
      templateData: params.txTemplateData,
      dataType: params.dataType,
    );

    return rawTx;
  }

  Future<String> _getWithdrawRawTxTRX(
    WithdrawSubmitParams params,
    WalletWithdrawData data,
  ) async {
    final rawTx = await WalletRepository().createTRXTransaction(
      symbol: data.symbol,
      address: data.toAddress,
      from: data.fromAddress,
      amount: NumberUtil.getAmountAsInt(params.amount, params.chainPrecision),
      fee: data.fee.feeRateToInt,
    );

    return rawTx;
  }
}
