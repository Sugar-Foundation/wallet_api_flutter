# wallet_api_flutter

Wallet API for Sugar Foundation projects

## Introduction

Wallet API provide all the functions to create or import a cryptocurrecny wallet, check coins balances, get network fee, create transactions and submit transaction.

This module depends on the following Sugar ecosystem libraries:

- [Wallet SDK](https://github.com/Sugar-Foundation/wallet_sdk_flutter): Native cryptocurrecy wallet
- [Utils](https://github.com/Sugar-Foundation/utils_flutter): Utils for handle numbers, bytes, etc
- [Network](https://github.com/Sugar-Foundation/network_flutter): Handle Sugar nodes compatible HTTP request 

## Getting Started

Add the dependency in your project's 'pubspec.yaml' file.

```yaml

  wallet_sdk_flutter:
    git: https://github.com/Sugar-Foundation/wallet_api_flutter

```

## Setup module

In your app entry point, you need to initialize the Hive entities

```dart

moduleWalletInitHive();

```
