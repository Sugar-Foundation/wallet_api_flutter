part of wallet_api_flutter;

extension WalletRepositoryWallet on WalletRepository {
  Future<List<Wallet>> getAllWallets() async {
    final wallets = <Wallet>[];
    final walletsKeys = _wallets.keys;
    for (final walletKey in walletsKeys) {
      wallets.add(await _wallets.get(walletKey));
    }
    wallets.sort(
      (a, b) =>
          (a.createdAt?.millisecondsSinceEpoch ?? 0) -
          (b.createdAt?.millisecondsSinceEpoch ?? 0),
    );
    return wallets;
  }

  Future<Wallet> getWalletById(String walletId) async {
    if (walletId != null) {
      return _wallets.get(walletId);
    }
    return null;
  }

  Future<List<Wallet>> saveWallet(String walletId, Wallet wallet) async {
    wallet.updatedAt = DateTime.now();
    await _wallets.put(walletId, wallet);
    return getAllWallets();
  }

  /// Create new mnemonic
  Future<String> generateMnemonic() {
    return WalletCore.generateMnemonic();
  }

  /// Validate mnemonic
  Future<bool> validateMnemonic(String mnemonic) {
    return WalletCore.validateMnemonic(mnemonic);
  }

  /// Validate Address
  Future<bool> validateAddress({
    @required String chain,
    @required String address,
  }) {
    return WalletCore.validateAddress(
      chain: chain,
      address: address,
      isBeta: WalletConfigNetwork.getTestNetByChain(chain), // 只有btc 要 beta
    );
  }

  /// Import existing mnemonic
  Future<Map<String, WalletAddressInfo>> importMnemonic({
    @required String mnemonic,
    WalletCoreOptions options = const WalletCoreOptions(),
    List<String> symbols,
  }) async {
    final keys = await WalletCore.importMnemonic(
      mnemonic: mnemonic,
      path: options.useBip44
          ? WalletRepository._walletPathImToken
          : WalletRepository._walletPathPockMine,
      password: options.useBip44
          ? WalletRepository._walletPasswordImToken
          : WalletRepository._walletPasswordPockMine,
      symbols: symbols ??
          [
            WalletSdkChains.btc,
            WalletSdkChains.bbc,
            WalletSdkChains.eth,
            WalletSdkChains.trx,
          ],
      options: options,
    );
    return keys;
  }

  Future<String> exportPrivateKey({
    @required String mnemonic,
    @required String chain,
    @required String forkId,
    WalletCoreOptions options = const WalletCoreOptions(),
  }) {
    return WalletCore.exportPrivateKey(
      symbol: chain,
      mnemonic: mnemonic,
      path: options.useBip44
          ? WalletRepository._walletPathImToken
          : WalletRepository._walletPathPockMine,
      password: options.useBip44
          ? WalletRepository._walletPasswordImToken
          : WalletRepository._walletPasswordPockMine,
      options: options,
    );
  }

  Future<BbcAddressInfo> createBBCPairKey({
    WalletCoreOptions options = const WalletCoreOptions(),
  }) {
    return WalletBBC.createBBCKeyPair(
      bip44Path: options.useBip44
          ? WalletRepository._walletPathImToken
          : WalletRepository._walletPathPockMine,
      bip44Key: options.useBip44
          ? WalletRepository._walletPasswordImToken
          : WalletRepository._walletPasswordPockMine,
    );
  }
}
