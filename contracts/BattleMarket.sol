pragma solidity ^0.5.0;

import "./BattleCard.sol";
import "./BattleToken.sol";

contract BattleMarket {
    BattleCard battleCardContract;
    BattleToken battleTokenContract;

    struct CardListing {
        uint256 cardId;
        uint256 price;
        address seller;
    }

    mapping(uint256 => CardListing) public listings;
    uint256 public listingCount;

    event CardListed(uint256 cardId, uint256 price, address seller);
    event CardPurchased(
        uint256 cardId,
        address buyer,
        address seller,
        uint256 price
    );
    event CardWithdrawn(uint256 cardId, address owner);

    constructor(
        BattleCard _battleCardContract,
        BattleToken _battleTokenContract
    ) public {
        battleCardContract = _battleCardContract;
        battleTokenContract = _battleTokenContract;
    }

    // Player calls this function to list a card for sale
    function listCard(uint256 cardId, uint256 price) public {
        require(
            battleCardContract.getOwner(cardId) == msg.sender,
            "You must own the card to list it"
        );
        require(listings[cardId].cardId == 0, "Card is already listed");

        battleCardContract.transferOwnership(cardId, address(this));

        listings[cardId] = CardListing(cardId, price, msg.sender);
        listingCount++;

        emit CardListed(cardId, price, msg.sender);
    }

    // Player calls this function to purchase a listed card
    function purchaseCard(uint256 cardId) public {
        require(listings[cardId].cardId > 0, "Card is not listed for sale");

        uint256 price = listings[cardId].price;
        address seller = listings[cardId].seller;

        battleTokenContract.transferCredit(seller, price);

        battleCardContract.transferOwnership(cardId, msg.sender);
        delete listings[cardId];
        listingCount--;

        emit CardPurchased(cardId, msg.sender, seller, price);
    }

    // Player calls this function to withdraw a listed card
    function withdrawCard(uint256 cardId) public {
        require(
            listings[cardId].seller == msg.sender,
            "You must be the seller to withdraw the card"
        );

        battleCardContract.transferOwnership(cardId, msg.sender);
        delete listings[cardId];
        listingCount--;

        emit CardWithdrawn(cardId, msg.sender);
    }
}
