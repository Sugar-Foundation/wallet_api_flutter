// GENERATED CODE - DO NOT MODIFY BY HAND

part of wallet_api_flutter;

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BroadcastTxTypeAdapter extends TypeAdapter<BroadcastTxType> {
  @override
  final int typeId = 50;

  @override
  BroadcastTxType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BroadcastTxType.swap;
      case 1:
        return BroadcastTxType.pool;
      case 2:
        return BroadcastTxType.project;
      case 3:
        return BroadcastTxType.tradeFailOrder;
      default:
        return null;
    }
  }

  @override
  void write(BinaryWriter writer, BroadcastTxType obj) {
    switch (obj) {
      case BroadcastTxType.swap:
        writer.writeByte(0);
        break;
      case BroadcastTxType.pool:
        writer.writeByte(1);
        break;
      case BroadcastTxType.project:
        writer.writeByte(2);
        break;
      case BroadcastTxType.tradeFailOrder:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BroadcastTxTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BroadcastTxInfoAdapter extends TypeAdapter<BroadcastTxInfo> {
  @override
  final int typeId = 51;

  @override
  BroadcastTxInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BroadcastTxInfo(
      chain: fields[0] as String,
      symbol: fields[1] as String,
      type: fields[2] as BroadcastTxType,
      txId: fields[3] as String,
      apiParams: fields[5] as String,
    )
      ..isSubmitted = fields[4] as bool
      ..createdAt = fields[6] as DateTime
      ..updatedAt = fields[7] as DateTime;
  }

  @override
  void write(BinaryWriter writer, BroadcastTxInfo obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.chain)
      ..writeByte(1)
      ..write(obj.symbol)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.txId)
      ..writeByte(4)
      ..write(obj.isSubmitted)
      ..writeByte(5)
      ..write(obj.apiParams)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BroadcastTxInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CoinAddressAdapter extends TypeAdapter<CoinAddress> {
  @override
  final int typeId = 13;

  @override
  CoinAddress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoinAddress(
      chain: fields[0] as String,
      symbol: fields[8] as String,
      address: fields[1] as String,
      publicKey: fields[4] as String,
      addressType: fields[2] as String,
      addressMemoOrTag: fields[3] as String,
      description: fields[5] as String,
    )
      ..createdAt = fields[6] as DateTime
      ..updatedAt = fields[7] as DateTime;
  }

  @override
  void write(BinaryWriter writer, CoinAddress obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.chain)
      ..writeByte(8)
      ..write(obj.symbol)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.addressMemoOrTag)
      ..writeByte(2)
      ..write(obj.addressType)
      ..writeByte(4)
      ..write(obj.publicKey)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoinAddressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CoinBalanceAdapter extends TypeAdapter<CoinBalance> {
  @override
  final int typeId = 14;

  @override
  CoinBalance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoinBalance(
      chain: fields[0] as String,
      symbol: fields[1] as String,
      balance: fields[2] as double,
      unconfirmed: fields[3] as double,
    )
      ..createdAt = fields[4] as DateTime
      ..updatedAt = fields[5] as DateTime
      ..lockUntil = fields[6] as DateTime;
  }

  @override
  void write(BinaryWriter writer, CoinBalance obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.chain)
      ..writeByte(1)
      ..write(obj.symbol)
      ..writeByte(2)
      ..write(obj.balance)
      ..writeByte(3)
      ..write(obj.unconfirmed)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.lockUntil);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoinBalanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CoinInfoAdapter extends TypeAdapter<CoinInfo> {
  @override
  final int typeId = 12;

  @override
  CoinInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoinInfo(
      chain: fields[0] as String,
      symbol: fields[1] as String,
      name: fields[3] as String,
      fullName: fields[4] as String,
      chainPrecision: fields[7] as int,
      displayPrecision: fields[8] as int,
      contract: fields[2] as String,
      iconOnline: fields[5] as String,
      iconLocal: fields[6] as String,
      isEnabled: fields[11] as bool,
      isFixed: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CoinInfo obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.chain)
      ..writeByte(1)
      ..write(obj.symbol)
      ..writeByte(2)
      ..write(obj.contract)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.fullName)
      ..writeByte(5)
      ..write(obj.iconOnline)
      ..writeByte(6)
      ..write(obj.iconLocal)
      ..writeByte(7)
      ..write(obj.chainPrecision)
      ..writeByte(8)
      ..write(obj.displayPrecision)
      ..writeByte(10)
      ..write(obj.isFixed)
      ..writeByte(11)
      ..write(obj.isEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoinInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WalletStatusAdapter extends TypeAdapter<WalletStatus> {
  @override
  final int typeId = 15;

  @override
  WalletStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WalletStatus.synced;
      case 1:
        return WalletStatus.notSynced;
      case 2:
        return WalletStatus.unknown;
      case 3:
        return WalletStatus.loading;
      default:
        return null;
    }
  }

  @override
  void write(BinaryWriter writer, WalletStatus obj) {
    switch (obj) {
      case WalletStatus.synced:
        writer.writeByte(0);
        break;
      case WalletStatus.notSynced:
        writer.writeByte(1);
        break;
      case WalletStatus.unknown:
        writer.writeByte(2);
        break;
      case WalletStatus.loading:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WalletTypeAdapter extends TypeAdapter<WalletType> {
  @override
  final int typeId = 11;

  @override
  WalletType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WalletType.mnemonicBip44;
      case 1:
        return WalletType.mnemonicBip39;
      case 2:
        return WalletType.privateKey;
      case 3:
        return WalletType.device;
      default:
        return null;
    }
  }

  @override
  void write(BinaryWriter writer, WalletType obj) {
    switch (obj) {
      case WalletType.mnemonicBip44:
        writer.writeByte(0);
        break;
      case WalletType.mnemonicBip39:
        writer.writeByte(1);
        break;
      case WalletType.privateKey:
        writer.writeByte(2);
        break;
      case WalletType.device:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WalletAdapter extends TypeAdapter<Wallet> {
  @override
  final int typeId = 10;

  @override
  Wallet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Wallet(
      id: fields[0] as String,
      type: fields[2] as WalletType,
      name: fields[1] as String,
      addresses: (fields[9] as List)?.cast<CoinAddress>(),
      hasBackup: fields[4] as bool,
      coins: (fields[7] as List)?.cast<CoinInfo>(),
    )
      ..status = fields[3] as WalletStatus
      ..createdAt = fields[5] as DateTime
      ..updatedAt = fields[6] as DateTime
      ..balances = (fields[8] as List)?.cast<CoinBalance>();
  }

  @override
  void write(BinaryWriter writer, Wallet obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.hasBackup)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.coins)
      ..writeByte(8)
      ..write(obj.balances)
      ..writeByte(9)
      ..write(obj.addresses);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
