const ERC20 = artifacts.require("ERC20");
const RNG = artifacts.require("RNG");
const BattleToken = artifacts.require("BattleToken");
const BattleCard = artifacts.require("BattleCard");
const Battle = artifacts.require("Battle");

module.exports = (deployer, network, accounts) => {
    deployer
        .deploy(BattleToken)
        .then(function () {
            return deployer.deploy(RNG);
        })
        .then(function () {
            return deployer.deploy(BattleCard, BattleToken.address, RNG.address);
        })
        .then(function(){
            return deployer.deploy(Battle, BattleCard.address, BattleToken.address);
        });
};
