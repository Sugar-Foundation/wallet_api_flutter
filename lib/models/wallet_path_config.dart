part of wallet_api_flutter;

class WalletPathConfig {
  WalletPathConfig({
    @required this.name,
    @required this.img,
    this.path = WalletType.mnemonicBip44,
  });

  final String name;
  final WalletType path;
  final String img;
}
