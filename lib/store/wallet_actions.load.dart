part of wallet_api_flutter;

extension WalletActionsLoad on WalletActionsCubit {
  Future<void> loadAll(String activeWalletId) async {
    final allWallets = await WalletRepository().getAllWallets();

    final activeWallet = await WalletRepository().getWalletById(activeWalletId);

    _updateState(state.copyWith(
      wallets: allWallets,
      activeWallet: activeWallet,
    ));
  }

  Future<void> setActive(Wallet activeWallet) async {
    _updateState(state.copyWith(
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
}
