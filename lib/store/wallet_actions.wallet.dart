part of wallet_api_flutter;

extension WalletActionsCreate on WalletActionsCubit {
  Future<String> create({
    @required String name,
    @required String walletId,
    @required String password,
    @required WalletType type,

    /// App supported coins for this wallet
    @required List<CoinInfo> coins,

    /// If a mnemonic is provided, is considered as import wallet
    String mnemonic,
  }) async {
    assert(name != null, password != null);

    final isImport = mnemonic?.isNotEmpty == true;

    // Create new Wallet
    if (!isImport) {
      mnemonic = await WalletRepository().generateMnemonic();
    }

    // Check mnemonic, if still empty, wallet creation failed
    if (mnemonic == null || mnemonic.isEmpty) {
      throw WalletMnemonicError();
    }

    // Import new wallet Or use created
    final coinList = await WalletRepository().importMnemonic(
      mnemonic: mnemonic,
      options: WalletCoreOptions(
        useBip44: type == WalletType.mnemonicBip44,
      ),
    );

    final addresses = coinList.entries
        .map(
          (item) => CoinAddress(
            chain: item.key,
            symbol: item.key,
            address: item.value.address,
            publicKey: item.value.publicKey,
          ),
        )
        .toList();

    final existingWallet = await WalletRepository().getWalletById(walletId);

    // Only add wallet if is new, otherwise use existing one
    final newWallet = existingWallet ??
        Wallet(
          id: walletId,
          type: type,
          name: name,
          coins: coins,
          addresses: addresses,
          // If isImport, I guess user already did backup
          hasBackup: isImport,
        );

    newWallet.name = name;
    newWallet.addresses = addresses;

    final allWallets = await WalletRepository().saveWallet(
      walletId,
      newWallet,
    );

    _updateState(state.copyWith(
      wallets: allWallets,
      activeWallet: newWallet,
    ));

    return mnemonic;
  }

  Future<void> loadAll(String activeWalletId) async {
    final allWallets = await WalletRepository().getAllWallets();

    final activeWallet = await WalletRepository().getWalletById(activeWalletId);

    _updateState(state.copyWith(
      wallets: allWallets,
      activeWallet: activeWallet,
    ));
  }

  Future<WalletPrivateData> unlock(String mnemonic) async {
    final activeWallet = state.activeWallet;

    if (activeWallet == null) {
      return null;
    }

    final data = WalletPrivateData(
      walletId: activeWallet.id,
      walletType: activeWallet.type,
      mnemonic: mnemonic,
    );
    return data;
  }


  Future<void> setActive(Wallet activeWallet) async {
    _updateState(state.copyWith(
      activeWallet: activeWallet,
    ));
  }


  Future<bool> validateAddress({
    @required String chain,
    @required String address,
  }) async {
    try {
      await WalletRepository().validateAddress(
        chain: chain,
        address: address,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> validateMnemonic({
    @required String mnemonic,
  }) async {
    try {
      await WalletRepository().validateMnemonic(mnemonic);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> updateAddress({
    @required String mnemonic,
    @required String chain,
  }) async {
    final wallet = state.activeWallet;
    final walletId = state.activeWalletId;

    if (!WalletSdkChains.all.contains(chain)) {
      throw AssertionError('$chain not supported in this wallet');
    }

    final coinList = await WalletRepository().importMnemonic(
      mnemonic: mnemonic,
      options: WalletCoreOptions(
        useBip44: wallet.type == WalletType.mnemonicBip44,
      ),
      symbols: [chain],
    );

    final addresses = coinList.entries
        .map(
          (item) => CoinAddress(
            chain: item.key,
            symbol: item.key,
            address: item.value.address,
            publicKey: item.value.publicKey,
          ),
        )
        .toList();

    final item = addresses.firstWhere((e) => e.chain == chain);
    wallet.updateCoinAddress(
      chain: chain,
      address: item.address,
      publicKey: item.publicKey,
    );

    final allWallets = await WalletRepository().saveWallet(
      walletId,
      wallet,
    );

    _updateState(state.copyWith(
      wallets: allWallets,
      activeWallet: wallet,
    ));
  }
}
