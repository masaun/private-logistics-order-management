import { CounterContract } from "../artifacts/Counter.js";
import { describe, it, expect, beforeAll, beforeEach } from "vitest";
import { TestWallet } from "@aztec/test-wallet/server";
import { createAztecNodeClient } from "@aztec/aztec.js/node";
import { deployCounter } from "./utils.js";
import { AztecAddress } from "@aztec/stdlib/aztec-address";

import {
  INITIAL_TEST_SECRET_KEYS,
  INITIAL_TEST_ACCOUNT_SALTS,
  INITIAL_TEST_ENCRYPTION_KEYS,
} from "@aztec/accounts/testing";

describe("Logistics Order Management Contract", () => {
  let wallet: TestWallet;
  let alice: AztecAddress;
  let logisticsOrderManagement: LogisticsOrderManagementContract;

  beforeAll(async () => {
    const aztecNode = await createAztecNodeClient("http://localhost:8080", {});
    wallet = await TestWallet.create(
      aztecNode,
      {
        dataDirectory: "pxe-test",
        proverEnabled: false,
      },
      {},
    );

    // Register initial test accounts manually because of this:
    // https://github.com/AztecProtocol/aztec-packages/blame/next/yarn-project/accounts/src/schnorr/lazy.ts#L21-L25
    [alice] = await Promise.all(
      INITIAL_TEST_SECRET_KEYS.map(async (secret, i) => {
        const accountManager = await wallet.createSchnorrAccount(
          secret,
          INITIAL_TEST_ACCOUNT_SALTS[i],
          INITIAL_TEST_ENCRYPTION_KEYS[i],
        );
        return accountManager.address;
      }),
    );
  });

  beforeEach(async () => {
    logisticsOrderManagement = await deployLogisticsOrderManagement(wallet, alice);
  });

  it("e2e", async () => {
    const owner = await logisticsOrderManagement.methods.get_owner().simulate({
      from: alice,
    });
    expect(owner).toStrictEqual(alice);

    // default order_id should be 0
    expect(
      await logisticsOrderManagement.methods.get_order_id().simulate({
        from: alice,
      }),
    ).toBe(0n);

    // call to `create_new_order()` method
    const order_id = await logisticsOrderManagement.methods.get_order_id().simulate({ from: alice });
    const order_block_number = 1; // [TODO] - replace with actual block number
    await logisticsOrderManagement.methods
      .create_new_order(order_id, order_block_number)
      .send({
        from: alice,
      })
      .wait();
    
      // now the order_id should be incremented.
    expect(
      await logisticsOrderManagement.methods.get_order_id().simulate({
        from: alice,
      }),
    ).toBe(1n);
  });
});
