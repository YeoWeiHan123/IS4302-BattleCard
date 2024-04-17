const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions"); // npm truffle-assertions
const BigNumber = require("bignumber.js"); // npm install bignumber.js
var assert = require("assert");

var BattleToken = artifacts.require("../contracts/BattleToken.sol");
var RNG = artifacts.require("../contracts/RNG.sol");
var BattleCard = artifacts.require("../contracts/BattleCard.sol");
var Battle = artifacts.require("../contracts/Battle.sol");

const oneEth = new BigNumber(1000000000000000000); // 1 eth

contract("Battle", function (accounts) {
    before(async () => {
        battleTokenInstance = await BattleToken.deployed();
        rngInstance = await RNG.deployed();
        battleCardInstance = await BattleCard.deployed();
        battleInstance = await Battle.deployed();
    });

    console.log("Testing Battle contract");

    it("Get BattleToken", async () => {
        await battleInstance.getBT({
            from: accounts[1],
            value: oneEth.dividedBy(2),
        }); // .5 eth gets 50 BT

        await battleInstance.getBT({
            from: accounts[2],
            value: oneEth,
        }); // 1 eth gets 100 BT

        const amt1 = new BigNumber(await battleInstance.checkBT({ from: accounts[1] }));
        const amt2 = new BigNumber(await battleInstance.checkBT({ from: accounts[2] }));

        correctAmt1 = new BigNumber(50);
        correctAmt2 = new BigNumber(100);

        await assert(amt1.isEqualTo(correctAmt1), "Incorrect BT given");
        await assert(amt2.isEqualTo(correctAmt2), "Incorrect BT given");
    });

    it ("Get BattleCard", async () => {
        // Store intial BT of account 1
        const account1BT = new BigNumber(await battleInstance.checkBT({ from: accounts[1] }));

        // Create card by spending 1 BT
        await battleCardInstance.createCard({ from: accounts[1] });

        // Store the new BT balance
        const newAccount1BT = new BigNumber(
            await battleInstance.checkBT({ from: accounts[1] })
        );
        // Check if the new balance is 1BT lower than original
        await assert(newAccount1BT.isEqualTo(account1BT.minus(1)), "BT not subtracted");
    });
});