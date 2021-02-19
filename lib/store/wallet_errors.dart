part of wallet_api_flutter;

class WalletMnemonicError extends Error {}

class WalletPasswordError extends Error {}

class WalletAddressError extends Error {}

class WalletTransTxRejected extends Error {
  WalletTransTxRejected(this.message);
  String message;
}

class WalletBBCFromPrivateKeyError extends Error {}

class WalletAddressBBCToPublicKeyError extends Error {}

class WalletExportPrivateKeyError extends Error {}

class WalletSignMsgError extends Error {}
