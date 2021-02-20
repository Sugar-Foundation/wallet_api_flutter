// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of wallet_api_flutter;

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
class _$WalletStateTearOff {
  const _$WalletStateTearOff();

// ignore: unused_element
  _WalletState call(
      {List<Wallet> wallets = const [],
      Wallet activeWallet = null,
      WalletStatus activeWalletStatus = WalletStatus.unknown}) {
    return _WalletState(
      wallets: wallets,
      activeWallet: activeWallet,
      activeWalletStatus: activeWalletStatus,
    );
  }
}

/// @nodoc
// ignore: unused_element
const $WalletState = _$WalletStateTearOff();

/// @nodoc
mixin _$WalletState {
  List<Wallet> get wallets;
  Wallet get activeWallet;
  WalletStatus get activeWalletStatus;

  @JsonKey(ignore: true)
  $WalletStateCopyWith<WalletState> get copyWith;
}

/// @nodoc
abstract class $WalletStateCopyWith<$Res> {
  factory $WalletStateCopyWith(
          WalletState value, $Res Function(WalletState) then) =
      _$WalletStateCopyWithImpl<$Res>;
  $Res call(
      {List<Wallet> wallets,
      Wallet activeWallet,
      WalletStatus activeWalletStatus});
}

/// @nodoc
class _$WalletStateCopyWithImpl<$Res> implements $WalletStateCopyWith<$Res> {
  _$WalletStateCopyWithImpl(this._value, this._then);

  final WalletState _value;
  // ignore: unused_field
  final $Res Function(WalletState) _then;

  @override
  $Res call({
    Object wallets = freezed,
    Object activeWallet = freezed,
    Object activeWalletStatus = freezed,
  }) {
    return _then(_value.copyWith(
      wallets: wallets == freezed ? _value.wallets : wallets as List<Wallet>,
      activeWallet: activeWallet == freezed
          ? _value.activeWallet
          : activeWallet as Wallet,
      activeWalletStatus: activeWalletStatus == freezed
          ? _value.activeWalletStatus
          : activeWalletStatus as WalletStatus,
    ));
  }
}

/// @nodoc
abstract class _$WalletStateCopyWith<$Res>
    implements $WalletStateCopyWith<$Res> {
  factory _$WalletStateCopyWith(
          _WalletState value, $Res Function(_WalletState) then) =
      __$WalletStateCopyWithImpl<$Res>;
  @override
  $Res call(
      {List<Wallet> wallets,
      Wallet activeWallet,
      WalletStatus activeWalletStatus});
}

/// @nodoc
class __$WalletStateCopyWithImpl<$Res> extends _$WalletStateCopyWithImpl<$Res>
    implements _$WalletStateCopyWith<$Res> {
  __$WalletStateCopyWithImpl(
      _WalletState _value, $Res Function(_WalletState) _then)
      : super(_value, (v) => _then(v as _WalletState));

  @override
  _WalletState get _value => super._value as _WalletState;

  @override
  $Res call({
    Object wallets = freezed,
    Object activeWallet = freezed,
    Object activeWalletStatus = freezed,
  }) {
    return _then(_WalletState(
      wallets: wallets == freezed ? _value.wallets : wallets as List<Wallet>,
      activeWallet: activeWallet == freezed
          ? _value.activeWallet
          : activeWallet as Wallet,
      activeWalletStatus: activeWalletStatus == freezed
          ? _value.activeWalletStatus
          : activeWalletStatus as WalletStatus,
    ));
  }
}

/// @nodoc
class _$_WalletState with DiagnosticableTreeMixin implements _WalletState {
  _$_WalletState(
      {this.wallets = const [],
      this.activeWallet = null,
      this.activeWalletStatus = WalletStatus.unknown})
      : assert(wallets != null),
        assert(activeWallet != null),
        assert(activeWalletStatus != null);

  @JsonKey(defaultValue: const [])
  @override
  final List<Wallet> wallets;
  @JsonKey(defaultValue: null)
  @override
  final Wallet activeWallet;
  @JsonKey(defaultValue: WalletStatus.unknown)
  @override
  final WalletStatus activeWalletStatus;

  bool _didhasWallet = false;
  bool _hasWallet;

  @override
  bool get hasWallet {
    if (_didhasWallet == false) {
      _didhasWallet = true;
      _hasWallet = activeWallet != null && activeWallet.id != null;
    }
    return _hasWallet;
  }

  bool _didactiveWalletId = false;
  String _activeWalletId;

  @override
  String get activeWalletId {
    if (_didactiveWalletId == false) {
      _didactiveWalletId = true;
      _activeWalletId = activeWallet?.id;
    }
    return _activeWalletId;
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'WalletState(wallets: $wallets, activeWallet: $activeWallet, activeWalletStatus: $activeWalletStatus, hasWallet: $hasWallet, activeWalletId: $activeWalletId)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'WalletState'))
      ..add(DiagnosticsProperty('wallets', wallets))
      ..add(DiagnosticsProperty('activeWallet', activeWallet))
      ..add(DiagnosticsProperty('activeWalletStatus', activeWalletStatus))
      ..add(DiagnosticsProperty('hasWallet', hasWallet))
      ..add(DiagnosticsProperty('activeWalletId', activeWalletId));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _WalletState &&
            (identical(other.wallets, wallets) ||
                const DeepCollectionEquality()
                    .equals(other.wallets, wallets)) &&
            (identical(other.activeWallet, activeWallet) ||
                const DeepCollectionEquality()
                    .equals(other.activeWallet, activeWallet)) &&
            (identical(other.activeWalletStatus, activeWalletStatus) ||
                const DeepCollectionEquality()
                    .equals(other.activeWalletStatus, activeWalletStatus)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(wallets) ^
      const DeepCollectionEquality().hash(activeWallet) ^
      const DeepCollectionEquality().hash(activeWalletStatus);

  @JsonKey(ignore: true)
  @override
  _$WalletStateCopyWith<_WalletState> get copyWith =>
      __$WalletStateCopyWithImpl<_WalletState>(this, _$identity);
}

abstract class _WalletState implements WalletState {
  factory _WalletState(
      {List<Wallet> wallets,
      Wallet activeWallet,
      WalletStatus activeWalletStatus}) = _$_WalletState;

  @override
  List<Wallet> get wallets;
  @override
  Wallet get activeWallet;
  @override
  WalletStatus get activeWalletStatus;
  @override
  @JsonKey(ignore: true)
  _$WalletStateCopyWith<_WalletState> get copyWith;
}
