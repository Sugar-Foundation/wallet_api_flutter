part of wallet_api_flutter;

class WithdrawPrepareParams {
  WithdrawPrepareParams({
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

extension WalletActionsWithdrawPrepare on WalletActionsCubit {
  Future<WalletWithdrawData> withdrawPrepare({
    WithdrawPrepareParams params,
    WalletWithdrawData previousData,
    bool ignoreAddressCheck = false,
  }) async {
    try {
      final toAddress = params.toAddress;
      final chain = params.chain;

      // Validate toAddress
      if (ignoreAddressCheck != true &&
          toAddress != null &&
          toAddress.isNotEmpty) {
        await WalletRepository().validateAddress(
          chain: chain,
          address: toAddress,
        );
      }

      switch (chain) {
        case 'BTC':
          return await _withdrawBeforeBTC(params, previousData);
        case 'ETH':
          return await _withdrawBeforeETH(params, previousData);
        case 'BBC':
          return await _withdrawBeforeBBC(params, previousData);
        case 'TRX':
          return await _withdrawBeforeTRX(params, previousData);
        default:
          throw 'Not Implemented';
      }
    } catch (error) {
      // Customize errors
      if (error is PlatformException && error.code == 'AddressError') {
        throw WalletAddressError();
      }

      rethrow;
    }
  }

  ///  ▼▼▼▼▼▼ Chains Implementations ▼▼▼▼▼▼  //

  Future<WalletWithdrawData> _withdrawBeforeBTC(
    WithdrawPrepareParams params,
    WalletWithdrawData perviousData,
  ) async {
    const chain = 'BTC';

    final symbol = params.symbol;
    final toAddress = params.fromAddress;
    final fromAddress = params.fromAddress;

    var data = perviousData;
    if (perviousData == null || perviousData?.utxos == null) {
      final balance = state.activeWallet.getCoinBalance(
        chain: chain,
        symbol: symbol,
        address: fromAddress,
      );

      final unspent = await getUnspent(
        chain: chain,
        symbol: symbol,
        address: fromAddress,
        balance: balance.balance,
      );

      final feeJson = await WalletRepository().getFee(
        chain: chain,
        symbol: symbol,
        toAddress: toAddress,
        fromAddress: fromAddress,
      );

      final fee = WalletWithdrawFeeData.fromJson(
        json: feeJson,
        feeSymbol: symbol,
      );

      data = WalletWithdrawData(
        chain: chain,
        symbol: symbol,
        toAddress: toAddress,
        fromAddress: fromAddress,
        fee: fee,
        feeDefault: fee,
        utxos: unspent,
        contract: params.contractOrForkId,
      );
    }

    // Update fee with BTC value
    data.fee.feeValue = await WalletFeeUtils.getBTCFeeValue(
      satoshi: data.fee.feeRateToInt,
      fromAddress: fromAddress,
    );

    return data;
  }

  Future<WalletWithdrawData> _withdrawBeforeETH(
    WithdrawPrepareParams params,
    WalletWithdrawData perviousData,
  ) async {
    const chain = 'ETH';

    final symbol = params.symbol;
    final toAddress = params.toAddress;
    final fromAddress = params.fromAddress;

    final feeJson = await WalletRepository().getFee(
      chain: chain,
      symbol: symbol,
      toAddress: toAddress,
      fromAddress: fromAddress,
    );

    final nonce = NumberUtil.getInt(feeJson['nonce']);
    final gasPrice = NumberUtil.getInt(feeJson['gas_price']);
    final gasLimit = NumberUtil.getInt(feeJson['gas_limit']);
    // Since API do not return the rate, we need to add it
    feeJson['fee'] = WalletFeeUtils.getETHFeeRate(gasPrice);

    final fee = WalletWithdrawFeeData.fromJson(
      json: feeJson,
      feeSymbol: chain,
      feeUnit: 'Gwei',
    )
      ..nonce = nonce
      ..gasLimit = gasLimit
      ..gasPrice = gasPrice
      ..feeValue = WalletFeeUtils.getETHFeeValue(
        gasPrice: gasPrice,
        gasLimit: gasLimit,
        chainPrecision: params.chainPrecision,
      );

    final data = WalletWithdrawData(
      chain: chain,
      symbol: symbol,
      toAddress: toAddress,
      fromAddress: fromAddress,
      fee: fee,
      feeDefault: fee,
      utxos: [], // ETH don't have unspent
      contract: params.contractOrForkId,
    );

    return data;
  }

  Future<WalletWithdrawData> _withdrawBeforeBBC(
    WithdrawPrepareParams params,
    WalletWithdrawData perviousData,
  ) async {
    const chain = 'BBC';

    final symbol = params.symbol;
    final toAddress = params.toAddress;
    final fromAddress = params.fromAddress;

    final balance = state.activeWallet.getCoinBalance(
      chain: params.chain,
      symbol: symbol,
      address: fromAddress,
    );

    final unspent = await getUnspent(
      chain: chain,
      symbol: symbol,
      address: fromAddress,
      balance: balance.balance,
    );

    final feeJson = await WalletRepository().getFee(
      chain: chain,
      symbol: symbol,
      data: params.txData,
      toAddress: toAddress,
      fromAddress: fromAddress,
    );

    final fee = WalletWithdrawFeeData.fromJson(
      json: feeJson,
      feeSymbol: feeJson['unit']?.toString() ?? symbol,
    );
    fee.feeValue = WalletFeeUtils.getBBCFeeValue(
      bbc: fee.feeRateToDouble,
      chainPrecision: params.chainPrecision,
    );

    final data = WalletWithdrawData(
      chain: chain,
      symbol: symbol,
      toAddress: toAddress,
      fromAddress: fromAddress,
      fee: fee,
      feeDefault: fee,
      utxos: unspent,
      contract: params.contractOrForkId,
    );

    return data;
  }

  Future<WalletWithdrawData> _withdrawBeforeTRX(
    WithdrawPrepareParams params,
    WalletWithdrawData perviousData,
  ) async {
    const chain = 'TRX';
    final symbol = params.symbol;
    final toAddress = params.toAddress;
    final fromAddress = params.fromAddress;

    final feeJson = await WalletRepository().getFee(
      chain: chain,
      symbol: symbol,
      data: params.txData,
      toAddress: toAddress,
      fromAddress: fromAddress,
    );

    final fee = WalletWithdrawFeeData.fromJson(
      json: feeJson,
      feeSymbol: chain,
    );
    fee.feeValue = WalletFeeUtils.getTRXFeeValue(
      sun: fee.feeRateToInt,
      chainPrecision: params.chainPrecision,
    );

    final data = WalletWithdrawData(
      chain: chain,
      symbol: symbol,
      toAddress: toAddress,
      fromAddress: fromAddress,
      fee: fee,
      feeDefault: fee,
      utxos: [],
      contract: params.contractOrForkId,
    );

    return data;
  }
}
