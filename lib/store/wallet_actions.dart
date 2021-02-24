part of wallet_api_flutter;

class WalletActionsCubit extends Cubit<WalletState> {
  WalletActionsCubit() : super(WalletState());

  void _updateState(WalletState newState) {
    emit(newState);
  }
}
