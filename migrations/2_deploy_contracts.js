const ERC20 = artifacts.require("ERC20");
const RNG = artifacts.require("RNG");
const BattleToken = artifacts.require("BattleToken");
const BattleCard = artifacts.require("BattleCard");
const Battle = artifacts.require("Battle");
const Marketplace = artifacts.require("Marketplace");
const Player = artifacts.require("Player");

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
            return deployer.deploy(Player, BattleCard.address);
        })
        .then(function () {
            return deployer.deploy(Battle, BattleCard.address, BattleToken.address);
        })
        .then(function () {
            return deployer.deploy(Marketplace, BattleCard.address, BattleToken.address, Player.address);
        });
};