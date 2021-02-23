part of wallet_api_flutter;

const kWalletNameMaxLength = 30;

/// Wallet status
@HiveType(typeId: kHiveTypeWalletStatus)
enum WalletStatus {
  @HiveField(0)
  synced,

  @HiveField(1)
  notSynced,

  @HiveField(2)
  unknown,

  @HiveField(3)
  loading,
}

/// Type of this wallet (used to generate address)
@HiveType(typeId: kHiveTypeWalletType)
enum WalletType {
  @HiveField(0)
  mnemonicBip44,

  @HiveField(1)
  mnemonicBip39,

  /// Only privateKey wallet
  @HiveField(2)
  privateKey,

  /// Device wallet
  @HiveField(3)
  device,
}

@HiveType(typeId: kHiveTypeWallet)
class Wallet extends HiveObject {
  Wallet({
    @required this.id,
    @required this.type,
    @required this.name,
    @required this.addresses,
    @required this.hasBackup,
    @required this.coins,
  }) {
    balances = [];
    createdAt = DateTime.now();
    status = WalletStatus.notSynced;
  }

  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  WalletType type;
  @HiveField(3)
  WalletStatus status;
  @HiveField(4)
  bool hasBackup;

  @HiveField(5)
  List<CoinInfo> coins;
  @HiveField(9)
  List<CoinBalance> balances;
  @HiveField(8)
  List<CoinAddress> addresses;

  @HiveField(20)
  DateTime createdAt;
  @HiveField(21)
  DateTime updatedAt;

  /// If true this is device wallet
  bool get isDevice => type == WalletType.device;

  List<String> get supportedChains => addresses.map((e) => e.chain).toList();

  @override
  String toString() => '$id-$name';

  String get bbcAddress {
    final coin = addresses?.firstWhere(
      (item) => item.chain == 'BBC',
      orElse: () => null,
    );
    return coin?.address ?? '';
  }

  CoinInfo getCoinInfo({
    @required String chain,
    @required String symbol,
  }) {
    assert(chain != null);
    assert(symbol != null);
    return coins.firstWhere(
      (e) => e.chain == chain && e.symbol == symbol,
      orElse: () => null,
    );
  }

  String getCoinAddress(String chain) {
    assert(chain != null);
    return addresses
            .firstWhere(
              (e) => e.chain == chain,
              orElse: () => null,
            )
            ?.address ??
        '';
  }

  bool isCoinBalanceLocked({
    @required String chain,
    @required String symbol,
    @required String address,
  }) {
    assert(chain != null, symbol != null);
    assert(address != null);
    if (!isThisWalletAddress(address)) {
      return false;
    }
    final data = balances?.firstWhere(
      (e) => e.symbol == symbol && e.chain == chain,
      orElse: () => null,
    );
    return data?.lockUntil?.isAfter(DateTime.now()) ?? false;
  }

  bool isThisWalletAddress(String address) {
    assert(address != null);
    return addresses.where((element) => element.address == address).isNotEmpty;
  }

  /// Get coin balance from this wallet cache
  CoinBalance getCoinBalance({
    @required String address,
    @required String chain,
    @required String symbol,
  }) {
    assert(chain != null, symbol != null);
    if (!isThisWalletAddress(address)) {
      return null;
    }
    final data = balances?.firstWhere(
      (e) => e.symbol == symbol && e.chain == chain,
      orElse: () => null,
    );
    return data;
  }

  /// Update coin balance in this wallet
  void updateCoinBalance({
    @required String chain,
    @required String symbol,
    @required String address,
    @required double balance,
    @required double unconfirmed,
    @required bool isFailed,
  }) {
    assert(chain != null, symbol != null);
    assert(address != null);
    // Check if this address is in this wallet
    if (!isThisWalletAddress(address)) {
      return;
    }

    final coinBalance = balances.firstWhere(
      (e) => e.symbol == symbol && e.chain == chain,
      orElse: () {
        final coinBalance = CoinBalance(chain: chain, symbol: symbol);
        balances.add(coinBalance);
        return coinBalance;
      },
    );
    if (coinBalance != null) {
      coinBalance.balance = balance;
      coinBalance.unconfirmed = unconfirmed;
      coinBalance.updatedAt = DateTime.now();
      coinBalance.isFailed = isFailed;
      coinBalance._balanceChanges.sink.add(coinBalance);
      save();
    }
  }

  /// Forbid Update balance until the given time
  void lookCoinBalance({
    @required String chain,
    @required String symbol,
    @required String address,
    @required DateTime lookUntil,
  }) {
    assert(chain != null, symbol != null);
    assert(address != null);
    if (!isThisWalletAddress(address)) {
      return;
    }
    final coinBalance = balances.firstWhere(
      (e) => e.symbol == symbol && e.chain == chain,
      orElse: () => null,
    );
    if (coinBalance != null) {
      coinBalance.lockUntil = lookUntil;
      save();
    }
  }

  /// Add or update a specific chain address in this wallet
  void updateCoinAddress({
    @required String chain,
    @required String address,
    @required String publicKey,
  }) {
    assert(chain != null, address != null);
    addresses.removeWhere((element) => element.chain == chain);
    addresses.add(CoinAddress(
      chain: chain,
      symbol: chain,
      address: address,
      publicKey: publicKey,
    ));
    updatedAt = DateTime.now();
    save();
  }

  /// Update coin enable to use state
  void updateCoinEnable({
    @required String chain,
    @required String symbol,
    @required bool isEnabled,
  }) {
    assert(chain != null, symbol != null);
    assert(isEnabled != null);
    final coinInfo = coins.firstWhere(
      (e) => e.symbol == symbol && e.chain == chain,
      orElse: () => null,
    );
    if (coinInfo != null) {
      coinInfo.isEnabled = isEnabled;
      save();
    }
  }

  void updateStatus({
    @required WalletStatus status,
  }) {
    this.status = status;
    updatedAt = DateTime.now();
    save();
  }
}
