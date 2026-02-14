
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.090.0/testing/asserts.ts';

Clarinet.test({
    name: "Ensure that user can create a stream",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const recipient = accounts.get('wallet_1')!;
        const amount = 1000;
        const duration = 10;

        let block = chain.mineBlock([
            Tx.contractCall('paystream', 'create-stream', [
                types.principal(recipient.address),
                types.uint(amount),
                types.uint(duration)
            ], deployer.address)
        ]);

        block.receipts[0].result.expectOk().expectUint(1); // Stream ID 1
    },
});

Clarinet.test({
    name: "Ensure that recipient can withdraw funds over time",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const recipient = accounts.get('wallet_1')!;
        const amount = 1000;
        const duration = 10;

        // 1. Create Stream
        chain.mineBlock([
            Tx.contractCall('paystream', 'create-stream', [
                types.principal(recipient.address),
                types.uint(amount),
                types.uint(duration)
            ], deployer.address)
        ]);

        // 2. Advance chain by 5 blocks (half duration)
        chain.mineEmptyBlockUntil(105); // Assuming start block is near 100 or 0+mined blocks. 
        // Actually, let's just mine 5 blocks explicitly.
        chain.mineEmptyBlock(5);

        // 3. Withdraw
        let block = chain.mineBlock([
            Tx.contractCall('paystream', 'withdraw', [
                types.uint(1)
            ], recipient.address)
        ]);

        // Expect success. The amount should be roughly half.
        // Rate = 1000 / 10 = 100 per block.
        // 5 blocks * 100 = 500.
        block.receipts[0].result.expectOk();
    },
});
