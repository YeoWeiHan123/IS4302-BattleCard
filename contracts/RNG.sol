pragma solidity ^0.5.0;

 /*contract RNG{
    uint256 fakeRandomNumber;

    function generateRandonNumber() public view returns (uint256){
        return fakeRandomNumber; // lol isnt it always returning forced number????
    }

    function setRandomNumber(uint256 forcedNumber) public{ 
         fakeRandomNumber = forcedNumber; // lol isnt it always returning forced number????
    }
}*/ 

//use the keccak256 hash function with a combination of block properties 
//(like block.timestamp, block.difficulty, etc.) and other sources of 
//randomness (like the msg.sender address) to generate a pseudo-random number.
contract RNG {
    function generateRandomNumber() public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));
    }
}
