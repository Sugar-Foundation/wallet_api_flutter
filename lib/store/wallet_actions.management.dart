part of wallet_api_flutter;

extension WalletActionsManagment on  WalletActionsCubit  {

  Future<void> changeWalletName(
    String name,
  ) async {
  

    final activeWallet = state.activeWallet;

    if (activeWallet == null) {
      return null;
    }

    activeWallet.name = name;

    final allWallets = await WalletRepository().saveWallet(
      activeWallet.id,
      activeWallet,
    );

    //  emit(state.rebuild(
    //   (b) => b
    //     ..activeWallet = activeWallet
    //     ..wallets = allWallets ?? [],
    // ));
  }
}

// /// Delete current active wallet and select a previous one
// class WalletActionDeleteWallet extends _BaseAction {
//   WalletActionDeleteWallet();

//   @override
//   Future<WalletState> reduce() async {
//     final activeWallet = state.activeWallet;

//     if (activeWallet == null) {
//       return null;
//     }

//     await activeWallet.delete();

//     final allWallets = await WalletRepository().getAllWallets();

//     final nextWallet = allWallets.isEmpty ? null : allWallets[0];

//     // TODO: Handle Asset Call
//     // dispatch(AppActionLoadWallet(nextWallet));

//     return state.rebuild(
//       (b) => b
//         ..activeWalletId = nextWallet?.id
//         ..activeWallet = nextWallet
//         ..wallets = allWallets ?? [],
//     );
//   }
// }
