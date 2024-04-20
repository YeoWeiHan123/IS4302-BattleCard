pragma solidity ^0.5.0;

import "./BattleToken.sol";
import "./RNG.sol";

contract BattleCard {
    struct Card {
        uint256 id;
        uint256 damage;
        uint256 hp;
        uint256 luckMultiplier;
        uint256 totalWins;
        uint256 totalLosses;
        uint256 totalUsage;
        address[] previousOwners;
    }

    uint256 private nextCardId = 1;
    mapping(uint256 => Card) public cards;

    BattleToken battleTokenContract;
    RNG rngContract;

    constructor(BattleToken battleTokenAddress, RNG rngAddress) public {
        battleTokenContract = battleTokenAddress;
        rngContract = rngAddress;
    }

    event CardCreated(
        uint256 id,
        uint256 damage,
        uint256 hp,
        uint256 luckMultiplier,
        address owner
    );
    event OwnershipTransferred(uint256 cardId, address from, address to);
    event CardStatsUpdated(
        uint256 cardId,
        uint256 totalWins,
        uint256 totalLosses,
        uint256 totalUsage
    );

    // create a card with random stats, costs 10 BT
    function createCard() public returns (uint256) {
        require(
            battleTokenContract.checkCredit(msg.sender) >= 10,
            "Not enough BT"
        );

        uint256 randomSeed = rngContract.generateRandonNumber();
        uint256 damage = (randomSeed % 10) + 1;
        uint256 hp = ((randomSeed / 10) % 20) + 10;
        uint256 luckMultiplier = ((randomSeed / 100) % 5) + 1;

        Card storage newCard = cards[nextCardId];
        newCard.id = nextCardId;
        newCard.damage = damage;
        newCard.hp = hp;
        newCard.luckMultiplier = luckMultiplier;
        newCard.previousOwners.push(msg.sender);

        emit CardCreated(nextCardId, damage, hp, luckMultiplier, msg.sender);

        nextCardId++;

        battleTokenContract.transferCredit(address(this), 10); // deduct 10 BT from the player
        return newCard.id;
    }

    function transferOwnership(uint256 cardId, address newOwner) public {
        require(
            isOwner(msg.sender, cardId),
            "Caller must be owner of the card"
        );

        Card storage card = cards[cardId];
        card.previousOwners.push(newOwner);

        emit OwnershipTransferred(cardId, msg.sender, newOwner);
    }

    function getOwner(uint256 cardId) public view returns (address) {
        return
            cards[cardId].previousOwners[
                cards[cardId].previousOwners.length - 1
            ];
    }

    function getPrevOwner(uint256 cardId) public view returns (address) {
        require(cards[cardId].previousOwners.length > 1, "No previous owner.");
        return
            cards[cardId].previousOwners[
                cards[cardId].previousOwners.length - 2
            ];
    }

    function getAllPrevOwners(
        uint256 cardId
    ) public view returns (address[] memory) {
        return cards[cardId].previousOwners;
    }

    function isOwner(address owner, uint256 cardId) public view returns (bool) {
        return getOwner(cardId) == owner;
    }

    function incrementWins(uint256 cardId) public {
        cards[cardId].totalWins++;
        emit CardStatsUpdated(
            cardId,
            cards[cardId].totalWins,
            cards[cardId].totalLosses,
            cards[cardId].totalUsage
        );
    }

    function incrementLosses(uint256 cardId) public {
        cards[cardId].totalLosses++;
        emit CardStatsUpdated(
            cardId,
            cards[cardId].totalWins,
            cards[cardId].totalLosses,
            cards[cardId].totalUsage
        );
    }

    function incrementUsage(uint256 cardId) public {
        cards[cardId].totalUsage++;
        emit CardStatsUpdated(
            cardId,
            cards[cardId].totalWins,
            cards[cardId].totalLosses,
            cards[cardId].totalUsage
        );
    }
}
