// Paystream SDK — TypeScript client for Paystream on Stacks

import { StacksMainnet, StacksTestnet } from '@stacks/network';
import {
    makeContractCall,
    broadcastTransaction,
    callReadOnlyFunction,
    uintCV,
    standardPrincipalCV,
    noneCV,
    someCV,
    stringUtf8CV,
    AnchorMode,
    PostConditionMode,
    cvToJSON
} from '@stacks/transactions';

export interface StreamConfig {
    contractAddress: string;
    contractName: string;
    network: 'mainnet' | 'testnet';
}

export interface CreateStreamParams {
    recipient: string;
    amountMicroSTX: number;
    durationBlocks: number;
    label?: string;
    senderKey: string;
}

export class PaystreamSDK {
    private config: StreamConfig;
    private network: StacksMainnet | StacksTestnet;

    constructor(config: StreamConfig) {
        this.config = config;
        this.network = config.network === 'mainnet' ? new StacksMainnet() : new StacksTestnet();
    }

    /** Create a new payment stream, streaming amountMicroSTX over durationBlocks. */
    async createStream(params: CreateStreamParams): Promise<string> {
        const tx = await makeContractCall({
            contractAddress: this.config.contractAddress,
            contractName: this.config.contractName,
            functionName: 'create-stream',
            functionArgs: [
                standardPrincipalCV(params.recipient),
                uintCV(params.amountMicroSTX),
                uintCV(params.durationBlocks),
                params.label ? someCV(stringUtf8CV(params.label)) : noneCV()
            ],
            senderKey: params.senderKey,
            network: this.network,
            anchorMode: AnchorMode.Any,
            postConditionMode: PostConditionMode.Allow,
        });
        const result = await broadcastTransaction(tx, this.network);
        return result.txid;
    }

    /** Withdraw claimable STX from a stream as recipient. */
    async withdraw(streamId: number, senderKey: string): Promise<string> {
        const tx = await makeContractCall({
            contractAddress: this.config.contractAddress,
            contractName: this.config.contractName,
            functionName: 'withdraw',
            functionArgs: [uintCV(streamId)],
            senderKey,
            network: this.network,
            anchorMode: AnchorMode.Any,
            postConditionMode: PostConditionMode.Allow,
        });
        const result = await broadcastTransaction(tx, this.network);
        return result.txid;
    }

    /** Pause a stream (sender only). Stops block accumulation. */
    async pauseStream(streamId: number, senderKey: string): Promise<string> {
        const tx = await makeContractCall({
            contractAddress: this.config.contractAddress,
            contractName: this.config.contractName,
            functionName: 'pause-stream',
            functionArgs: [uintCV(streamId)],
            senderKey,
            network: this.network,
            anchorMode: AnchorMode.Any,
            postConditionMode: PostConditionMode.Allow,
        });
        const result = await broadcastTransaction(tx, this.network);
        return result.txid;
    }

    /** Resume a paused stream (sender only). */
    async resumeStream(streamId: number, senderKey: string): Promise<string> {
        const tx = await makeContractCall({
            contractAddress: this.config.contractAddress,
            contractName: this.config.contractName,
            functionName: 'resume-stream',
            functionArgs: [uintCV(streamId)],
            senderKey,
            network: this.network,
            anchorMode: AnchorMode.Any,
            postConditionMode: PostConditionMode.Allow,
        });
        const result = await broadcastTransaction(tx, this.network);
        return result.txid;
    }

    /** Get claimable amount for a stream at the current block. */
    async getClaimableAmount(streamId: number): Promise<number> {
        const result = await callReadOnlyFunction({
            contractAddress: this.config.contractAddress,
            contractName: this.config.contractName,
            functionName: 'get-claimable-amount',
            functionArgs: [uintCV(streamId)],
            network: this.network,
            senderAddress: this.config.contractAddress,
        });
        const json = cvToJSON(result);
        return parseInt(json.value.value);
    }

    /** Get full stream state. */
    async getStream(streamId: number): Promise<any> {
        const result = await callReadOnlyFunction({
            contractAddress: this.config.contractAddress,
            contractName: this.config.contractName,
            functionName: 'get-stream',
            functionArgs: [uintCV(streamId)],
            network: this.network,
            senderAddress: this.config.contractAddress,
        });
        return cvToJSON(result);
    }
}
