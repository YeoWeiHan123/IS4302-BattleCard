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
    * @dev Function to return the BT to the casino and get ether back at the conversion rate of 0.009 Eth per BT
    */
    function returnBT() public  {
        // Hint 1: in recipient.transfer(amt), the amt is in wei,
        //         which you can convert from eth at: 1eth = 1000000000000000000 wei
        // Hint 2: Contracts address can be accessed with address(this)
        // Hint 3: You can just transfer the BT back to this contracts address, there is no need to burn the BT
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