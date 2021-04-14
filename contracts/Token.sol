// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./MyDateLibrary.sol";


/* @title - ERC20 Token Challenge
/// @author -  Cole Roberts
/// @notice -  Creates ERC20 token that can only be traded inside a given _startTime and _endTime observed from UTC timezone
/// @dev - 
/// @param -  rings The number of rings from dendrochronological sample
/// @return -  age in years, rounded up for partial years
*/
contract Token is ERC20{
    uint128 public startTime;
    uint128 public endTime;

    
    // @author -  Cole Roberts
    // @notice -  modifier used to restric trading outside of startTime and endTime window
    modifier TimeRestricted() {
        require(MyDateLibrary.getCurrentTimeInDay() >= uint256(startTime), "This function is restricted before 7AM");
        require(MyDateLibrary.getCurrentTimeInDay() <= uint256(endTime), "This function is restricted after 5PM");
        _;
    }


    event TokenTransferred(uint value);

    
    // @author -  Cole Roberts
    // @notice -  creates ERC20 token called "test"/"TST" and mints 1000000 TST to msg.sender
    // @dev - 
    // @param - _startTime - required range of 0-24 in units of "hours". converted to seconds before stored in startTime
    // @param - _endTime - required range of 0-24 in units of "hours". converted to seconds before stored in endTime
    constructor(uint256 _startTime, uint256 _endTime) ERC20("test", "TST"){
        require(_startTime <= 24, "Start time must be in range 0-24 hours");
        require(_endTime <= 24, "End time must be in range 0-24");
        uint256 toSeconds = 3600;
        startTime = uint128(_startTime * toSeconds); //start time at 7AM
        endTime = uint128(_endTime * toSeconds); //end time at 5 PM
        _mint(msg.sender, 1000000*(10**18));
    }
 


    // @notice -  overrides @openzeppelin ERC20 transfer function to add "TimeRestricted" modifier
    function transfer(address _recipient, uint256 _amount) public virtual override TimeRestricted returns (bool) {
        _transfer(_msgSender(), _recipient, _amount);
        emit TokenTransferred(_amount);
        return true;
    }

}