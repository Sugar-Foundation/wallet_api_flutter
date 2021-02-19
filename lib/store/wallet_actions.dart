part of wallet_api_flutter;

class WalletActionsCubit extends Cubit<WalletState> {
  WalletActionsCubit() : super(WalletState());

  Future<void> getUnspent({
    @required String chain,
    @required String symbol,
    @required String address,
    @required Completer<List<Map<String, dynamic>>> completer,
    @required double balance,
    String unspentType,
    bool forceUpdate = false,
  }) async {
    if (!kChainsNeedUnspent.contains(chain)) {
      completer.complete(null);
      return null;
    }

    final cacheUnspent = await WalletRepository().getUnspentFromCache(
      symbol: symbol,
      address: address,
    );
    var unspent = <Map<String, dynamic>>[];
    if (forceUpdate ||
        cacheUnspent == null ||
        (cacheUnspent.isEmpty && balance > 0)) {
      unspent = await WalletRepository().getUnspentFromApi(
        chain: chain,
        symbol: symbol,
        address: address,
        type: unspentType,
      );
      await WalletRepository().saveUnspentToCache(
        symbol: symbol,
        address: address,
        unspent: unspent,
      );
    } else {
      unspent = cacheUnspent;
    }

    if (unspent == null || unspent.isEmpty) {
      // TODO: Handle Asset Call
      // dispatch(AssetActionResetCoinBalance(
      //   wallet: store.state.activeWallet, // TODO: check
      //   chain: chain,
      //   symbol: symbol,
      //   address: address,
      // ));
    }

    completer.complete(unspent);

    return null;
  }
}

// abstract class _BaseAction extends ReduxAction<WalletState> {
//   //
// }

// class WalletActionGetUnspent extends _BaseAction {
//   WalletActionGetUnspent({
//     @required this.chain,
//     @required this.symbol,
//     @required this.address,
//     @required this.completer,
//     @required this.balance,
//     this.unspentType,
//     this.forceUpdate = false,
//   });

//   final String chain;
//   final String symbol;
//   final String address;
//   final bool forceUpdate;
//   final double balance;
//   final String unspentType;
//   final Completer<List<Map<String, dynamic>>> completer;

//   @override
//   Future<WalletState> reduce() async {
//     if (!kChainsNeedUnspent.contains(chain)) {
//       completer.complete(null);
//       return null;
//     }

//     final cacheUnspent = await WalletRepository().getUnspentFromCache(
//       symbol: symbol,
//       address: address,
//     );
//     var unspent = <Map<String, dynamic>>[];
//     if (forceUpdate ||
//         cacheUnspent == null ||
//         (cacheUnspent.isEmpty && balance > 0)) {
//       unspent = await WalletRepository().getUnspentFromApi(
//         chain: chain,
//         symbol: symbol,
//         address: address,
//         type: unspentType,
//       );
//       await WalletRepository().saveUnspentToCache(
//         symbol: symbol,
//         address: address,
//         unspent: unspent,
//       );
//     } else {
//       unspent = cacheUnspent;
//     }

//     if (unspent == null || unspent.isEmpty) {
//       // TODO: Handle Asset Call
//       // dispatch(AssetActionResetCoinBalance(
//       //   wallet: store.state.activeWallet, // TODO: check
//       //   chain: chain,
//       //   symbol: symbol,
//       //   address: address,
//       // ));
//     }

//     completer.complete(unspent);

//     return null;
//   }

//   @override
//   Object wrapError(dynamic error) {
//     WalletRepository().saveUnspentToCache(
//       symbol: symbol,
//       address: address,
//       unspent: null,
//     );

//     completer.completeError(error);
//     return error;
//   }
// }

// class WalletActionValidateMnemonic extends _BaseAction {
//   WalletActionValidateMnemonic(this.mnemonic);
//   final String mnemonic;

//   @override
//   Future<WalletState> reduce() async {
//     await WalletRepository().validateMnemonic(mnemonic);
//     return null;
//   }

//   @override
//   Object wrapError(dynamic error) {
//     return error;
//   }
// }

// class WalletActionValidateAddress extends _BaseAction {
//   WalletActionValidateAddress({this.chain, this.address, this.completer});
//   final String chain;
//   final String address;
//   final Completer<bool> completer;

//   @override
//   Future<WalletState> reduce() async {
//     await WalletRepository().validateAddress(
//       chain: chain,
//       address: address,
//     );
//     completer.complete(true);
//     return null;
//   }

//   @override
//   Object wrapError(dynamic error) {
//     completer.complete(false);
//     return error;
//   }
// }
