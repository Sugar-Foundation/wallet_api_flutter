part of wallet_api_flutter;

extension WalletActionsCreate on  WalletActionsCubit  {

  void createFromMnemonic(
     String name,
     String walletId,
     String password, [
    String importMnemonic,
    WalletType type,
    Completer<String> completer,
  ]) async  {

 assert(name != null, password != null);

 
    var mnemonic = importMnemonic ?? '';
    final isImport = mnemonic.isNotEmpty;

    // Create new Wallet
    if (!isImport) {
      mnemonic = await WalletRepository().generateMnemonic();
    }

    // Import new wallet Or use created
    final coinList = await WalletRepository().importMnemonic(
      mnemonic: mnemonic,
      options: WalletCoreOptions(
        useBip44: type == WalletType.mnemonicBip44,
      ),
    );

    // Check mnemonic, if still empty, wallet creation failed
    if (mnemonic == null || mnemonic.isEmpty) {
      throw WalletMnemonicError();
    }

    // 创建本地钱包信息
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
    final walletModel = existingWallet ??
        Wallet(
          id: walletId,
          type: type,
          name: name,
          coins: [],
          addresses: addresses,
          // If import Mnemonic, I guess user already did backup
          hasBackup: isImport,
        );

    walletModel.name = name;
    walletModel.addresses = addresses;

    final allWallets = await WalletRepository().saveWallet(
      walletId,
      walletModel,
    );

    // TODO: Handle Asset Call
    // dispatch(AppActionLoadWallet(walletModel));

    completer.complete(mnemonic);

    // return state.rebuild(
    //   (b) => b
    //     ..activeWalletId = walletId
    //     ..activeWallet = walletModel
    //     ..wallets = allWallets,
    // );
  }

  // @override
  // Object wrapError(dynamic error) {
  //   completer.completeError(error);
  //   return error;
  // }
}

// class WalletActionUpdateAddress extends _BaseAction {
//   WalletActionUpdateAddress({
//     @required this.mnemonic,
//     @required this.completer,
//     @required this.chain,
//   });

//   final String mnemonic;
//   final String chain;
//   final Completer<bool> completer;

//   @override
//   Future<WalletState> reduce() async {
//     final wallet = store.state.activeWallet;
//     final walletId = store.state.activeWalletId;

//     if (!WalletSdkChains.all.contains(chain)) {
//       throw AssertionError('$chain not supported in this wallet');
//     }

//     final coinList = await WalletRepository().importMnemonic(
//       mnemonic: mnemonic,
//       options: WalletCoreOptions(
//         useBip44: wallet.type == WalletType.mnemonicBip44,
//       ),
//       symbols: [chain],
//     );

//     // 创建本地钱包信息
//     final addresses = coinList.entries
//         .map(
//           (item) => CoinAddress(
//             chain: item.key,
//             symbol: item.key,
//             address: item.value.address,
//             publicKey: item.value.publicKey,
//           ),
//         )
//         .toList();

//     final item = addresses.firstWhere((e) => e.chain == chain);
//     wallet.updateCoinAddress(
//       chain: chain,
//       address: item.address,
//       publicKey: item.publicKey,
//     );

//     final allWallets = await WalletRepository().saveWallet(
//       walletId,
//       wallet,
//     );



//     completer.complete(true);

//     return state.rebuild(
//       (b) => b
//         ..activeWallet = wallet
//         ..wallets = allWallets,
//     );
//   }

//   @override
//   Object wrapError(dynamic error) {
//     completer.completeError(error);
//     return error;
//   }
// }
