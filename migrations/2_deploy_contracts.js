const ERC20 = artifacts.require("ERC20");
const RNG = artifacts.require("RNG");
const BattleToken = artifacts.require("BattleToken");
const BattleCard = artifacts.require("BattleCard");
const BattleMarket = artifacts.require("BattleMarket");
const BattleLedger = artifacts.require("BattleLedger");

module.exports = (deployer, network, accounts) => {
    deployer
        .deploy(ERC20)
        .then(function () {
            return deployer.deploy(RNG);
        })
        .then(function () {
            return deployer.deploy(BattleToken);
        })
        .then(function () {
            return deployer.deploy(BattleCard, BattleToken.address, RNG.address);
        })
        .then(function () {
            return deployer.deploy(BattleMarket, BattleCard.address, BattleToken.address);
        })
        .then(function () {
            return deployer.deploy(BattleLedger, BattleCard.address, BattleToken.address);
        });
};