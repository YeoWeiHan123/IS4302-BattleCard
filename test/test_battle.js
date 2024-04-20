const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions"); // npm truffle-assertions
const BigNumber = require("bignumber.js"); // npm install bignumber.js
const Web3 = require('web3'); // npm install web3
var assert = require("assert");

var BattleToken = artifacts.require("../contracts/BattleToken.sol");
var RNG = artifacts.require("../contracts/RNG.sol");
var BattleCard = artifacts.require("../contracts/BattleCard.sol");
var BattleLedger = artifacts.require("../contracts/BattleLedger.sol");

const oneEth = new BigNumber(1000000000000000000); // 1 eth

contract("BattleLedger", function (accounts) {
    before(async () => {
        battleTokenInstance = await BattleToken.deployed();
        rngInstance = await RNG.deployed();
        battleCardInstance = await BattleCard.deployed();
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

        const amt1 = new BigNumber(await battleLedgerInstance.checkBT({ from: accounts[1] }));
        const amt2 = new BigNumber(await battleLedgerInstance.checkBT({ from: accounts[2] }));

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
        let intialAccountBal = new BigNumber(await web3.eth.getBalance(accounts[3]));
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
        await assert(newAccountBal.isGreaterThan(intialAccountBal), "Incorrect Return Amt");

        // BattleLedger Contract should have 1 eth left out of the 10 eth, losing 9 eth in the process
        let newBattleBal = new BigNumber(await web3.eth.getBalance(battleLedgerInstance.address));
        let battleBalIncr = intialBattleBal.minus(newBattleBal);
        await assert(
            battleBalIncr.isEqualTo(oneEth.multipliedBy(9)),
            "BattleLedger was not given the correct amount of ETH"
        );
    });

    it ("Get BattleCard", async () => {
        // Store intial BT of account 1
        const account1BT = new BigNumber(await battleLedgerInstance.checkBT({ from: accounts[1] }));

        // Create card by spending 1 BT
        await battleCardInstance.createCard({ from: accounts[1] });

        // Store the new BT balance
        const newAccount1BT = new BigNumber(
            await battleLedgerInstance.checkBT({ from: accounts[1] })
        );
        // Check if the new balance is 1BT lower than original
        await assert(newAccount1BT.isEqualTo(account1BT.minus(10)), "BT not subtracted");
    });
});