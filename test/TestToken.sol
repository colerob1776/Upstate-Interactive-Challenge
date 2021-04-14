// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "truffle/Assert.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../contracts/Token.sol";



/* @title - A unit test for Token Contract
/// @author - Cole Roberts
/// @notice - This contract tests the transfer windows restricted by the specified _startTime and _endTime
*/
contract TestToken {

    uint public constant ONE = 10**18; //coefficient for wei conversion

    /* @author - Cole Roberts
    /// @notice - deploy Token Contract with specified _startTime/_endTime, and test initialization
    /// @dev - _startTime,"7", and _endTime,"17", are the parameters entered in Token()
    /// @dev - times are tested in units of "hours"
    */
    function testDeploy() public{
        Token _token = new Token(7,17);

        Assert.equal(_token.name(), 'test', 'Token name does not match');
        Assert.equal(_token.symbol(), 'TST', 'Token symbol does not match');
        Assert.equal(_token.totalSupply()/ONE, 1000000,'Token supply does not match');
        Assert.equal(_token.startTime()/3600, 7, 'Start time does not equal 7AM');
        Assert.equal(_token.endTime()/3600, 17, 'Start time does not equal 5PM');
    }


    /* @author - Cole Roberts
    /// @notice - used to test trading outside of specified time window. Time window initialized as 0 hours
    /// @dev - _startTime,"5", and _endTime,"5", are the parameters entered in Token()
    /// @dev - assertions ensure the balances of included parties remain the same before and after the attempted transfer
    */
    function testTimeRestriction() public returns (string memory _message, bool){
        //create token contract with time window between 5AM and 5AM (0 time window)
        Token _tokenRestr = new Token(5,5);

        Assert.equal(_tokenRestr.balanceOf(address(this)), 1000000*ONE, "ERC20token did not mint to this address");
        Assert.equal(_tokenRestr.balanceOf(address(_tokenRestr)), 0, "ERC20token did not mint to this address");

        try _tokenRestr.transfer(payable(address(_tokenRestr)), 50*ONE) returns (bool _success){
            _message = "no error transfering outside of time window";
            return (_message, _success);

        } catch Error(string memory){
            _message = "Successful revert (no transfering outside of time window";
            Assert.equal(_tokenRestr.balanceOf(address(this)), 1000000*ONE, "Transfer succeeded outside of time window");
            Assert.equal(_tokenRestr.balanceOf(address(_tokenRestr)), 0, "Transfer succeeded outside of time window");

            return(_message, false);
        }

        
    
    }


    /* @author - Cole Roberts
        @notice - used to test trading outside of specified time window. Time window initialized as 24 hours (no Restriction)
        @dev - _startTime,"0", and _endTime,"24", are the parameters entered in Token()
        @dev - assertions ensure the balances of included parties change by the transfered amount before and after the transfer call
    */
    function testUnrestrictedTime() public returns(string memory _message, bool){
        //create token contract with time window between 12AM and 12AM the next day (24 hour time window)
        Token _tokenUnrestr = new Token(0,24);

        Assert.equal(_tokenUnrestr.balanceOf(address(this)), 1000000*ONE, "ERC20token did not mint to this address");
        Assert.equal(_tokenUnrestr.balanceOf(address(_tokenUnrestr)), 0, "ERC20token did not mint to this address");

        try _tokenUnrestr.transfer(payable(address(_tokenUnrestr)), 50*ONE) returns (bool _success){
            _message = "transfer succeeded inside of time window";
            Assert.equal(_tokenUnrestr.balanceOf(address(this)), 999950*ONE, "Transfer succeeded");
            Assert.equal(_tokenUnrestr.balanceOf(address(_tokenUnrestr)), 50*ONE, "Transfer succeeded");
            return (_message, _success);

        } catch Error(string memory){
            _message="Error transferrring token";
            return(_message, false);
        }

        
    
    }
}