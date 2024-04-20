pragma solidity ^0.5.0;

import "./BattleCard.sol";
import "./BattleToken.sol";

contract BattleGround {
    BattleCard battleCardContract;
    BattleToken battleTokenContract;

    mapping(address => address) battle_pair;
    mapping(address => uint256) battle_card_id_used;

    constructor(BattleCard battleCardAddress, BattleToken battleTokenAddress) public {
        battleCardContract = battleCardAddress;
        battleTokenContract = battleTokenAddress;
    }
    event add_enemy(address enemy, uint256 myCardId);
    event battlewin(uint256 id1, uint256 id2);
    event battleDraw(uint256 id1, uint256 id2);

    function setBattlePair(address enemy, uint myCardId) public {
        require(battleCardContract.getPrevOwner(myCardId) == tx.origin, "Not owner of this card!");
        require(battleCardContract.getPrevOwner(myCardId) != enemy, "Cannot battle yourself!");
        battle_pair[tx.origin] = enemy;
        battle_card_id_used[tx.origin] = myCardId;

        battleTokenContract.transferCredit(address(this), 5);

        emit add_enemy(enemy, myCardId);
    }

    function battle() public {
        // Require that battle_pairs align, ie each player has accepted a battle with the other
        address mine = tx.origin;
        address enemy = battle_pair[mine];
        
        require(battle_pair[mine] == enemy, "Not valid pair!");
        require(battle_pair[enemy] == mine, "Not valid pair!");

        uint256 myCardId = battle_card_id_used[mine];
        uint256 enemyCardId = battle_card_id_used[enemy];

        // Do the battle
        uint256 myCardDamage = battleCardContract.getDamage(myCardId);
        uint256 enemyCardDamage = battleCardContract.getDamage(enemyCardId);

        uint256 myCardHealth = battleCardContract.getHp(myCardId);
        uint256 enemyCardHealth = battleCardContract.getHp(enemyCardId);
        while (myCardHealth > 0 && enemyCardHealth > 0) {
            myCardHealth -= enemyCardDamage;
            enemyCardHealth -= myCardDamage;
        }

        battleCardContract.incrementUsage(myCardId);
        battleCardContract.incrementUsage(enemyCardId);

        if (myCardHealth > 0) {
            battleCardContract.incrementWins(myCardId);
            battleCardContract.incrementLosses(enemyCardId);
            battleTokenContract.transferCredit(battleCardContract.getPrevOwner(myCardId), 10);

            emit battlewin(myCardId, enemyCardId);
        } else if (enemyCardHealth > 0) {
            battleCardContract.incrementWins(enemyCardId);
            battleCardContract.incrementLosses(myCardId);
            battleTokenContract.transferCredit(battleCardContract.getPrevOwner(enemyCardId), 10);

            emit battlewin(enemyCardId, myCardId);
        } else {
            battleTokenContract.transferCredit(battleCardContract.getPrevOwner(myCardId), 5);
            battleTokenContract.transferCredit(battleCardContract.getPrevOwner(enemyCardId), 5);
            
            emit battleDraw(myCardId, enemyCardId);
        }

        // Reset the battle pair
        battle_pair[mine] = address(0);
        battle_pair[enemy] = address(0);
    }
}
