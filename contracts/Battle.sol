pragma solidity ^0.5.0;

import "./BattleCard.sol";
import "./BattleToken.sol";

contract Battle {
    BattleCard battleCardContract;
    BattleToken battleTokenContract;

    constructor(BattleCard battleCardAddress, BattleToken battleTokenAddress) public {
        battleCardContract = battleCardAddress;
        battleTokenContract = battleTokenAddress;
    }

    event buyCredit(uint256 btAmt); //event of minting of BT to the msg.sender
    event returnCredits(uint256 btAmt); //event of returning of BT of the msg.sender
    event battleWin(address winner, address loser); //event of the roll resulting in winners
    event battleDraw(address ad1, address ad2); //event of the roll resulting in a draw

    /**
   * @dev Takes in Eth from the msg.sender and gives him BattleToken in return
   */
    function getBT() public payable {
        // Hint 1: default currency for msg.value is in wei
        battleTokenContract.getCredit(msg.sender, msg.value);
        uint256 btAmt = msg.value / (1000000000000000000/100);
        emit buyCredit(btAmt);
    }

    /**
    * @dev Function to check the amount of DT the msg.sender has
    * @return A uint256 representing the amount of DT owned by the msg.sender.
    */
    function checkBT() public view returns (uint256) {
        return battleTokenContract.checkCredit(msg.sender);
    }
}