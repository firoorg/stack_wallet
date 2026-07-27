import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:stackwallet/wallets/wallet/impl/ethereum_wallet.dart';
import 'package:web3dart/web3dart.dart' as web3;

void main() {
  group("encodeSignedWeb3Tx", () {
    final signedRlp = Uint8List.fromList([0x01, 0x02, 0x03, 0x04]);

    test("EIP-1559 raw hex carries the 0x02 type envelope", () {
      final encoded = EthereumWallet.encodeSignedWeb3Tx(
        signedRlp,
        isEIP1559: true,
      );

      expect(encoded.raw, "0x0201020304");
      expect(
        encoded.txid,
        web3.bytesToHex(
          web3.keccak256(web3.prependTransactionType(0x02, signedRlp)),
          include0x: true,
        ),
      );
      // regression: txid must NOT be the hash of the bare RLP
      expect(
        encoded.txid,
        isNot(web3.bytesToHex(web3.keccak256(signedRlp), include0x: true)),
      );
    });

    test("legacy tx passes through without a type byte", () {
      final encoded = EthereumWallet.encodeSignedWeb3Tx(
        signedRlp,
        isEIP1559: false,
      );

      expect(encoded.raw, "0x01020304");
      expect(
        encoded.txid,
        web3.bytesToHex(web3.keccak256(signedRlp), include0x: true),
      );
    });
  });
}
