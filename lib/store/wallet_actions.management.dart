part of wallet_api_flutter;

extension WalletActionsManagement on WalletActionsCubit {
  Future<void> changeName(String name) async {
    final activeWallet = state.activeWallet;

    if (activeWallet == null) {
      return null;
    }

    activeWallet.name = name;

    final allWallets = await WalletRepository().saveWallet(
      activeWallet.id,
      activeWallet,
    );

    _updateState(state.copyWith(
      wallets: allWallets,
      activeWallet: activeWallet,
    ));
  }

  /// Delete current active wallet and select a previous one
  Future<void> delete() async {
    final activeWallet = state.activeWallet;

    if (activeWallet == null) {
      return null;
    }

    await activeWallet.delete();

    final allWallets = await WalletRepository().getAllWallets();

    final nextWallet = allWallets.isEmpty ? null : allWallets.first;

    _updateState(state.copyWith(
      wallets: allWallets,
      activeWallet: nextWallet,
    ));
  }
}
