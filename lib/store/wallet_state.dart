part of wallet_api_flutter;

class WalletState {
  List<dynamic> toCache() {
    return [];
  }

// Fields
  List<Wallet> wallets;

  Wallet activeWallet;
  String activeWalletId;
  WalletStatus activeWalletStatus;

  bool get hasWallet => activeWallet != null && activeWalletId != null;
}
