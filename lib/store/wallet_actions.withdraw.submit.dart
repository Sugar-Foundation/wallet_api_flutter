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

extension WalletActionsWithdrawSubmit on WalletActionsCubit {
  Future<String> withdrawSubmit({
    WithdrawSubmitParams params,
    WalletPrivateData walletData,
    Future<bool> Function() onConfirmSubmit,
  }) async {
    final chain = params.withdrawData.chain;
    switch (chain) {
      case 'BTC':
        return await _withdrawSubmitBTC(params, walletData, onConfirmSubmit);
      case 'ETH':
        return await _withdrawSubmitETH(params, walletData, onConfirmSubmit);
      case 'BBC':
        return await _withdrawSubmitBBC(params, walletData, onConfirmSubmit);
      case 'TRX':
        return await _withdrawSubmitTRX(params, walletData, onConfirmSubmit);
      default:
        throw 'Not Implemented';
    }
  }

// //  ▼▼▼▼▼▼ Chains Implementations ▼▼▼▼▼▼  //

  Future<String> _withdrawSubmitBTC(
    WithdrawSubmitParams params,
    WalletPrivateData walletData,
    Future<bool> Function() onConfirmSubmit,
  ) async {
    const chain = 'BTC';

    final data = params.withdrawData;
    final toAddress = params.toAddress;
    final amount = params.amount;
    final fromAddress = data.fromAddress;
    final feeRate = NumberUtil.getDecimal(data.feeRate).toInt();

    final utxos = data.utxos.map((item) {
      return {
        'txId': item['tx_hash'].toString(),
        'vOut': NumberUtil.getInt(item['tx_output_n']),
        'vAmount': NumberUtil.getIntAmountAsDouble(item['value'], 8),
      };
    }).toList();

    final rawTx = await WalletRepository().createBTCTransaction(
      utxos: utxos,
      toAddress: toAddress,
      toAmount: amount,
      fromAddress: fromAddress,
      feeRate: feeRate,
      beta: WalletConfigNetwork.btc,
      isGetFee: false,
    );

    final txId = await signAndSubmitRawTx(
      chain: chain,
      symbol: data.symbol,
      rawTx: rawTx,
      walletData: walletData,
      fromAddress: fromAddress,
      broadcastType: params.broadcastType,
      onConfirmSubmit: onConfirmSubmit,
      amount: params.withdrawData.feeSymbol == params.withdrawData.symbol
          ? NumberUtil.plus<double>(params.amount, params.withdrawData.fee)
          : params.amount,
    );

    return txId;
  }

  Future<String> _withdrawSubmitETH(
    WithdrawSubmitParams params,
    WalletPrivateData walletData,
    Future<bool> Function() onConfirmSubmit,
  ) async {
    const chain = 'ETH';

    final data = params.withdrawData;
    final amount = params.amount;
    final toAddress = params.toAddress;
    final fromAddress = data.fromAddress;
    final gasPrice = NumberUtil.getInt(data.feeData['gas_price']);
    final gasLimit = NumberUtil.getInt(data.feeData['gas_limit']);
    final nonce = NumberUtil.getInt(data.feeData['nonce']);
    final chainAmount = NumberUtil.getAmountAsInt(
      amount,
      params.chainPrecision,
    );

    final rawTx = await WalletRepository().createETHTransaction(
      nonce: nonce,
      gasLimit: gasLimit,
      address: toAddress,
      amount: chainAmount,
      gasPrice: gasPrice,
      contract: data.contract,
    );

    final txId = await signAndSubmitRawTx(
      chain: chain,
      symbol: data.symbol,
      rawTx: rawTx,
      walletData: walletData,
      fromAddress: fromAddress,
      broadcastType: params.broadcastType,
      onConfirmSubmit: onConfirmSubmit,
      amount: params.withdrawData.feeSymbol == params.withdrawData.symbol
          ? NumberUtil.plus<double>(params.amount, params.withdrawData.fee)
          : params.amount,
    );

    return txId;
  }

  Future<String> _withdrawSubmitBBC(
    WithdrawSubmitParams params,
    WalletPrivateData walletData,
    Future<bool> Function() onConfirmSubmit,
  ) async {
    const chain = 'BBC';

    final data = params.withdrawData;
    final toAddress = params.toAddress;
    final fromAddress = data.fromAddress;
    final amount = params.amount;
    final anchor = data.contract;
    const timestamp = 0; // TODO: SystemDate.getTime();
    final utxos = data.utxos
        .map((item) => {
              'txId': item['txid'],
              'vOut': NumberUtil.getInt(item['out']),
            })
        .toList();

    final rawTx = await WalletRepository().createBBCTransaction(
      utxos: utxos,
      address: toAddress,
      timestamp: timestamp,
      anchor: anchor,
      amount: amount,
      fee: data.fee,
      version: 1, // version
      lockUntil: 0, // lockUntil 王杰新说用 0
      type: params.type ?? 0, // type 0-token 2-invitation
      data: params.txData,
      dataUUID: params.txDataUUID,
      templateData: params.txTemplateData,
      dataType: params.dataType,
    );

    final txId = await signAndSubmitRawTx(
      chain: chain,
      symbol: data.symbol,
      rawTx: rawTx,
      walletData: walletData,
      fromAddress: fromAddress,
      broadcastType: params.broadcastType,
      onConfirmSubmit: onConfirmSubmit,
      amount: params.withdrawData.feeSymbol == params.withdrawData.symbol
          ? NumberUtil.plus<double>(params.amount, params.withdrawData.fee)
          : params.amount,
    );

    return txId;
  }

  Future<String> _withdrawSubmitTRX(
    WithdrawSubmitParams params,
    WalletPrivateData walletData,
    Future<bool> Function() onConfirmSubmit,
  ) async {
    const chain = 'TRX';

    final data = params.withdrawData;
    final toAddress = params.toAddress;
    final fromAddress = data.fromAddress;
    final amount = params.amount;

    final rawTx = await WalletRepository().createTRXTransaction(
      symbol: data.symbol,
      address: toAddress,
      from: fromAddress,
      amount: NumberUtil.getAmountAsInt(amount, params.chainPrecision),
      fee: data.feeRate.toInt(),
    );

    final txId = await signAndSubmitRawTx(
      chain: chain,
      symbol: data.symbol,
      rawTx: rawTx,
      walletData: walletData,
      fromAddress: fromAddress,
      broadcastType: params.broadcastType,
      onConfirmSubmit: onConfirmSubmit,
      amount: params.withdrawData.feeSymbol == params.withdrawData.symbol
          ? NumberUtil.plus<double>(params.amount, params.withdrawData.fee)
          : params.amount,
    );

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
      String signedTx;
      if (walletData.walletType == WalletType.device) {
        // TODO: use HDKeyCore.signTx
      } else {
        signedTx = await WalletRepository().signTx(
          mnemonic: walletData.mnemonic,
          chain: chain,
          rawTx: rawTx,
          options: WalletCoreOptions(
            useBip44: walletData.useBip44,
            beta: WalletConfigNetwork.getTestNetByChain(chain),
          ),
        );
      }

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
      // TODO: Update Balance

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
        // Update balance if have error
        // TODO: Update Balance
        throw (WalletTransTxRejected(responseError.message));
      }
    }
  }
}
