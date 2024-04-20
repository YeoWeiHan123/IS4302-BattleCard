pragma solidity ^0.5.0;
import "./BattleCard.sol";

contract BattleGround {
    BattleCard battleCardContract;
    mapping(address => address) battle_pair;

    constructor(BattleCard battleCardAddress) public {
        battleCardContract = battleCardAddress;
    }
    event add_enemy(address enemy);
    event battlewin(uint256 id1, uint256 id2);
    event battleDraw(uint256 id1, uint256 id2);

    function setBattlePair(address enemy) public {
        battle_pair[msg.sender] = enemy;
        emit add_enemy(enemy);
    }

    function battle(uint256 myDice, uint256 enemyDice) public {
        // Require that battle_pairs align, ie each player has accepted a battle with the other
        address mine = battleCardContract.getPrevOwner(myDice);
        address enemy = battleCardContract.getPrevOwner(enemyDice);

        require(battle_pair[mine] == enemy, "Not valid pair!");
        require(battle_pair[enemy] == mine, "Not valid pair!");

        // Do the battle
    }

}