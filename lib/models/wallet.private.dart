part of wallet_api_flutter;

class WalletPrivateData {
  WalletPrivateData({
    this.walletId,
    this.walletType,
    this.mnemonic,
    this.privateKey,
  });

  String walletId;
  WalletType walletType;
  String mnemonic;
  String privateKey;

  bool get useBip44 => walletType == WalletType.mnemonicBip44;
  bool get hasMnemonic => mnemonic.isNotEmpty;
  bool get hasPrivateKey => privateKey.isNotEmpty;
}
