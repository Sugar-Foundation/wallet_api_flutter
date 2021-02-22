part of wallet_api_flutter;

@freezed
abstract class WalletState with _$WalletState {
  factory WalletState({
    @Default([]) List<Wallet> wallets,
    @nullable @Default(null) Wallet activeWallet,
    @nullable @Default(WalletStatus.unknown) WalletStatus activeWalletStatus,
  }) = _WalletState;

  @late
  bool get hasWallet => activeWallet != null && activeWallet.id != null;

  @late
  String get activeWalletId => activeWallet?.id;
}
