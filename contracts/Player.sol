pragma solidity ^0.5.0;
import "./BattleCard.sol";
// import "./Battle.sol";

contract Player {
    enum playerState {
        offline,
        online
    }

    playerState state;
    address name = msg.sender;
    uint256 wallet;
    mapping(uint256 => BattleCard) cardsInventory;

    constructor(uint256 id, BattleCard starterCard) public {
        cardsInventory[id] = starterCard;
        state = playerState.offline;
        wallet = 0;
    }

    event MoneyDeposited(address depositor, uint256 amount);
    event MoneyWithdrawn(address withdrawer, uint256 amount);
    event StartedLookingToBattle(address name, uint256 betAmount);
    event StoppedLookingToBattle(address name);

    // check if player is at the required state
    // eg. player is online before battling
    // eg. player is offline before withdrawing his deposits
    modifier checkState(playerState _state) {
        require(state == _state, "Player is not available right now");
        _;
    }

    function toggleOnline() internal {
        state = playerState.online;
    }

    function toggleOffline() internal {
        state = playerState.offline;
    }

    function deposit(uint256 amount) public {
        wallet += amount;
        emit MoneyDeposited(msg.sender, amount);
    }

    function withdraw(uint256 amount) public returns (uint256) {
        require(wallet >= amount, "Insufficient balance to withdraw");
        wallet -= amount;
        return amount; // might change depending on currency
    }

    // Battle contract calls Player contract when battling
    // eg. battle(Player player1, Player player 2) { }
    // before that, player must look for players
    // all players looking to battle will be stored in Battle contract

    function lookingToBattle(uint256 betAmount) public {
        require(wallet >= betAmount, "Insufficient balance to bet");
        toggleOnline();
        emit StartedLookingToBattle(name, betAmount);
    }

    function cancelBattling() public {
        require(state == playerState.online);
        toggleOffline();
        emit StoppedLookingToBattle(name);
    }

    function addCard(uint256 id, BattleCard newCard) public {
        require(cardsInventory[id] == BattleCard(0), "Already owned card");
        cardsInventory[id] = newCard;
    }

    function removeCard(uint256 id) public {
        require(cardsInventory[id] != BattleCard(0), "Does not own this card");
        cardsInventory[id] = BattleCard(0);
    }
}
