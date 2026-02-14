
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.090.0/testing/asserts.ts';

Clarinet.test({
    name: "Ensure that user can register an inscription",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const wallet1 = accounts.get('wallet_1')!;
        const inscriptionId = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef";
        const metadata = "My First Ordinal";

        let block = chain.mineBlock([
            Tx.contractCall('ordindex', 'register-inscription', [
                types.buff(inscriptionId),
                types.utf8(metadata)
            ], wallet1.address)
        ]);

        block.receipts[0].result.expectOk().expectBool(true);
    },
});

Clarinet.test({
    name: "Ensure that duplicates cannot be registered",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const wallet1 = accounts.get('wallet_1')!;
        const wallet2 = accounts.get('wallet_2')!;
        const inscriptionId = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef";

        // 1. Register first time
        chain.mineBlock([
            Tx.contractCall('ordindex', 'register-inscription', [
                types.buff(inscriptionId),
                types.utf8("Original")
            ], wallet1.address)
        ]);

        // 2. Try to register again
        let block = chain.mineBlock([
            Tx.contractCall('ordindex', 'register-inscription', [
                types.buff(inscriptionId),
                types.utf8("Copy")
            ], wallet2.address)
        ]);

        // Expect error u100 (err-inscription-already-registered)
        block.receipts[0].result.expectErr().expectUint(100);
    },
});
