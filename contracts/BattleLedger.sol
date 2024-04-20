pragma solidity ^0.5.0;

import "./BattleCard.sol";
import "./BattleToken.sol";

contract BattleLedger {
    BattleCard battleCardContract;
    BattleToken battleTokenContract;

    constructor(BattleCard battleCardAddress, BattleToken battleTokenAddress) public {
        battleCardContract = battleCardAddress;
        battleTokenContract = battleTokenAddress;
    }

    event buyCredit(uint256 btAmt); //event of minting of BT to the msg.sender
    event returnCredits(uint256 btAmt); //event of returning of BT of the msg.sender
    event battleWin(address winner, address loser); //event of the battle resulting in winners
    event battleDraw(address ad1, address ad2); //event of the battle resulting in a draw

    /**
   * @dev Takes in Eth from the msg.sender and gives him BattleToken in return
   */
    function getBT() public payable {
        battleTokenContract.getCredit(msg.sender, msg.value);
        uint256 btAmt = msg.value / (1000000000000000000/100);
        emit buyCredit(btAmt);
    }

    /**
    * @dev Function to check the amount of BT the msg.sender has
    * @return A uint256 representing the amount of BT owned by the msg.sender.
    */
    function checkBT() public view returns (uint256) {
        return battleTokenContract.checkCredit(msg.sender);
    }

    /**
    * @dev Function to return the BT to the BattleLedger and get ether back at the conversion rate of 0.009 Eth per BT
    */
    function returnBT() public  {
        uint256 btAmt = battleTokenContract.checkCredit(msg.sender);
        battleTokenContract.transferCredit(address(this), btAmt);

        uint256 weiAmt = btAmt * (1000000000000000000/100) * 9 / 10;
        address payable recipient = address(
            uint160(msg.sender)
        );
        recipient.transfer(weiAmt);
        emit returnCredits(btAmt);
    }
}