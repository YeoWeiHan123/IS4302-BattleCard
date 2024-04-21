const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions"); // npm truffle-assertions
const BigNumber = require("bignumber.js"); // npm install bignumber.js
const Web3 = require("web3"); // npm install web3
var assert = require("assert");

var BattleToken = artifacts.require("../contracts/BattleToken.sol");
var RNG = artifacts.require("../contracts/RNG.sol");
var BattleCard = artifacts.require("../contracts/BattleCard.sol");
var BattleGround = artifacts.require("../contracts/BattleGround.sol");
var BattleMarket = artifacts.require("../contracts/BattleMarket.sol");
var BattleLedger = artifacts.require("../contracts/BattleLedger.sol");

const oneEth = new BigNumber(1000000000000000000); // 1 eth

contract("BattleLedger", function (accounts) {
  before(async () => {
    battleTokenInstance = await BattleToken.deployed();
    rngInstance = await RNG.deployed();
    battleCardInstance = await BattleCard.deployed();
    battleGroundInstance = await BattleGround.deployed();
    battleMarketInstance = await BattleMarket.deployed();
    battleLedgerInstance = await BattleLedger.deployed();
  });

  console.log("Testing BattleLedger contract");

  it("Get BattleToken", async () => {
    await battleLedgerInstance.getBT({
      from: accounts[1],
      value: oneEth.dividedBy(2),
    }); // .5 eth gets 50 BT

    await battleLedgerInstance.getBT({
      from: accounts[2],
      value: oneEth,
    }); // 1 eth gets 100 BT

    const amt1 = new BigNumber(
      await battleLedgerInstance.checkBT({ from: accounts[1] })
    );
    const amt2 = new BigNumber(
      await battleLedgerInstance.checkBT({ from: accounts[2] })
    );

    correctAmt1 = new BigNumber(50);
    correctAmt2 = new BigNumber(100);

    await assert(amt1.isEqualTo(correctAmt1), "Incorrect BT given");
    await assert(amt2.isEqualTo(correctAmt2), "Incorrect BT given");
  });

  it("Return BattleToken", async () => {
    await battleLedgerInstance.getBT({
      from: accounts[3],
      value: oneEth.multipliedBy(10),
    });
    // Store the initial Account balances for account 3 and BattleLedger Contract
    let intialAccountBal = new BigNumber(
      await web3.eth.getBalance(accounts[3])
    );
    let intialBattleBal = new BigNumber(
      await web3.eth.getBalance(battleLedgerInstance.address)
    );
    let intialBattleBTBal = new BigNumber(
      await battleTokenInstance.checkCredit(battleLedgerInstance.address)
    );

    // 1000 BT and (9 out of 10) Eth should be returned to the account 3
    await battleLedgerInstance.returnBT({ from: accounts[3] });
    let newAccountBal = new BigNumber(await web3.eth.getBalance(accounts[3]));

    // Check that 1000 BT is returned
    let newBattleBTBal = new BigNumber(
      await battleTokenInstance.checkCredit(battleLedgerInstance.address)
    );
    await assert(
      newBattleBTBal.isEqualTo(intialBattleBTBal.plus(1000)),
      "BT was not returned to Contract"
    );
    // Check that the new account has greater ETH
    await assert(
      newAccountBal.isGreaterThan(intialAccountBal),
      "Incorrect Return Amt"
    );

    // BattleLedger Contract should have 1 eth left out of the 10 eth, losing 9 eth in the process
    let newBattleBal = new BigNumber(
      await web3.eth.getBalance(battleLedgerInstance.address)
    );
    let battleBalIncr = intialBattleBal.minus(newBattleBal);
    await assert(
      battleBalIncr.isEqualTo(oneEth.multipliedBy(9)),
      "BattleLedger was not given the correct amount of ETH"
    );
  });

  it("Get BattleCard", async () => {
    // Store intial BT of account 1
    const account1BT = new BigNumber(
      await battleLedgerInstance.checkBT({ from: accounts[1] })
    );

    // Create cards by spending 10 BT
    await rngInstance.setRandomNumber(1000);
    await battleCardInstance.createCard({ from: accounts[1] });

    await rngInstance.setRandomNumber(100);
    await battleCardInstance.createCard({ from: accounts[2] });

    // Store the new BT balance
    const newAccount1BT = new BigNumber(
      await battleLedgerInstance.checkBT({ from: accounts[1] })
    );
    // Check if the new balance is 10 BT lower than original
    await assert(
      newAccount1BT.isEqualTo(account1BT.minus(10)),
      "BT not subtracted for card creation"
    );
  });

  it("Transfer ownership of BattleCard and set battle pair", async () => {
    let t1 = await battleCardInstance.transferOwnership(
      0,
      battleGroundInstance.address,
      { from: accounts[1] }
    );
    let t2 = await battleCardInstance.transferOwnership(
      1,
      battleGroundInstance.address,
      { from: accounts[2] }
    );

    truffleAssert.eventEmitted(t1, "OwnershipTransferred");
    truffleAssert.eventEmitted(t2, "OwnershipTransferred");

    let enemy_adj1 = await battleGroundInstance.setBattlePair(accounts[2], 0, {
      from: accounts[1],
    });
    let enemy_adj2 = await battleGroundInstance.setBattlePair(accounts[1], 1, {
      from: accounts[2],
    });

    truffleAssert.eventEmitted(enemy_adj1, "add_enemy");
    truffleAssert.eventEmitted(enemy_adj2, "add_enemy");
  });

  it("Do battle", async () => {
    // Store the initial BT balance
    const account1BT = new BigNumber(
      await battleLedgerInstance.checkBT({ from: accounts[1] })
    );
    const account2BT = new BigNumber(
      await battleLedgerInstance.checkBT({ from: accounts[2] })
    );

    // Do battle
    let doBattle = await battleGroundInstance.battle({ from: accounts[2] });

    // Store the new BT balance
    const newAccount1BT = new BigNumber(
      await battleLedgerInstance.checkBT({ from: accounts[1] })
    );
    const newAccount2BT = new BigNumber(
      await battleLedgerInstance.checkBT({ from: accounts[2] })
    );

    // Check if the new balance is 5 BT more than original
    await assert(
      newAccount1BT.isEqualTo(account1BT.plus(5)),
      "BT not added for winning battle"
    );
  });

  it("List Card on Marketplace", async () => {
    // give account 5 some BT
    await battleLedgerInstance.getBT({
      from: accounts[5],
      value: oneEth,
    });

    // create card from account 5
    await battleCardInstance.createCard({
      from: accounts[5],
    });

    // list card from account 5
    let cardListed = await battleMarketInstance.listCard(2, 5, {
      from: accounts[5],
    });

    // transfer ownership to BMinstance which will facilitate the transaction
    // let transferOwnership = await battleCardInstance.transferOwnership(
    //   2,
    //   battleMarketInstance.address,
    //   { from: accounts[5] }
    // );

    truffleAssert.eventEmitted(cardListed, "CardListed");
    // truffleAssert.eventEmitted(transferOwnership, "OwnershipTransferred");
  });

  it("Withdraw Card From Marketplace", async () => {
    // give account 6 some BT
    await battleLedgerInstance.getBT({
      from: accounts[6],
      value: oneEth,
    });

    // transfer ownership back to account 5
    // let transferOwnership = await battleCardInstance.transferOwnership(
    //   2,
    //   accounts[5],
    //   { from: address(this) }
    // );

    // delist card from account 5
    await battleMarketInstance.withdrawCard(2, { from: accounts[5] });

    try {
      // buy delisted card from account 6
      await battleMarketInstance.purchaseCard(2, { from: accounts[6] });
      assert.fail("Card was bought even though it was delisted");
    } catch (error) {
      console.log("Card cannot be bought after it gets delisted");
    }

    // verify owner of card remains as account 5
    assert.strictEqual(
      await battleCardInstance.getOwner(2),
      accounts[5],
      "Ownership changed somehow"
    );
  });

  it("Purchase Card", async () => {
    // list card again
    let cardListed = await battleMarketInstance.listCard(2, 5, {
      from: accounts[5],
    });

    await battleMarketInstance.purchaseCard(2, { from: accounts[6] });

    // transfer ownership to account 6
    let transferOwnership = await battleCardInstance.transferOwnership(
      2,
      accounts[6],
      { from: accounts[5] }
    );

    // verify new owner of card is account[6]
    assert.strictEqual(
      await battleCardInstance.getOwner(2),
      accounts[6],
      "Ownership not correctly transferred"
    );
  });

  it("creates a new card and deducts 10 BT from player", async () => {
    // Get the initial BT balance of account[1]
    const initialBalance = await battleTokenInstance.checkCredit(accounts[1]);

    // Buy a new card from the BattleCard contract
    await battleCardInstance.createCard({ from: accounts[1] });

    // Get the new BT balance of account[1]
    const newBalance = await battleTokenInstance.checkCredit(accounts[1]);

    // Check if the BT balance was reduced by 10
    assert.strictEqual(
      newBalance.toString(),
      initialBalance.sub(web3.utils.toBN(10)).toString(),
      "BT balance was not reduced by 10"
    );
  });
});
