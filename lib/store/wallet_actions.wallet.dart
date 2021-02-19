part of wallet_api_flutter;

//** HD Wallet Load/Unlock **//

// class WalletActionWalletLoadAll extends _BaseAction {
//   @override
//   Future<WalletState> reduce() async {
//     // TODO: Handle Asset Call
//     // final settings = CommonRepository().getSettings();
//     final allWallets = await WalletRepository().getAllWallets();

//     const activeWalletId = 'settings?.activeWalletId';
//     final activeWallet = await WalletRepository().getWalletById(
//       activeWalletId,
//     );

//     return state.rebuild(
//       (b) => b
//         ..wallets = allWallets ?? []
//         ..activeWallet = activeWallet
//         ..activeWalletId = activeWalletId,
//     );
//   }

//   @override
//   Object wrapError(dynamic error) {
//     return error;
//   }
// }

// class WalletActionWalletSetActive extends _BaseAction {
//   WalletActionWalletSetActive(this.wallet);
//   final Wallet wallet;

//   @override
//   Future<WalletState> reduce() async {
//     // final settings = CommonRepository().getSettings();
//     // if (wallet == null || settings?.activeWalletId == wallet.id) {
//     //   return null;
//     // }
//     // settings.activeWalletId = wallet.id;
//     // await settings.save();

//     return state.rebuild(
//       (a) => a
//         ..activeWallet = wallet
//         ..activeWalletId = wallet.id,
//     );
//   }
// }

// class WalletActionWalletRemoveAll extends _BaseAction {
//   @override
//   Future<WalletState> reduce() async {
//     final wallets = state.wallets;
//     if (wallets != null && wallets.isNotEmpty) {
//       for (final _ in wallets) {
//         await store.dispatchFuture(WalletActionDeleteWallet());
//         await Future.delayed(Duration(milliseconds: 200));
//       }
//     }
//     return state.rebuild(
//       (b) => b
//         ..activeWalletId = null
//         ..activeWallet = null
//         ..wallets = [],
//     );
//   }
// }

// class WalletActionWalletUnlock extends _BaseAction {
//   WalletActionWalletUnlock(
//     this.password,
//     this.completer,
//   );
//   final String password;
//   final Completer<WalletPrivateData> completer;

//   @override
//   Future<WalletState> reduce() async {
//     // final activeWallet = state.activeWallet;

//     WalletPrivateData data;
//     // TODO: Handle Asset Call
//     // if (activeWallet.isDevice) {
//     //   data = await getWalletDevicePrivateData(
//     //     walletId: activeWallet.id,
//     //   );
//     // } else {
//     //   data = await getWalletPrivateData(
//     //     walletId: activeWallet.id,
//     //     walletType: activeWallet.type,
//     //     password: password,
//     //   );
//     // }

//     assert(data != null);
//     completer.complete(data);
//     return null;
//   }

//   @override
//   Object wrapError(dynamic error) {
//     completer.completeError(error);
//     return error;
//   }
// }
