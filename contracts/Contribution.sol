// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";



/* @title - Contribution Challenge
/// @author -  Cole Roberts
/// @notice -  Creates donation pool where ETH donors are given a 1:1 equivalent (wei) in pool tokens
*/
contract Contribution is ERC20{

    uint256 public tokenValue;
    address[] public donors;
    mapping (address => uint256) public balances;

    event DonationReceived(uint256 value);
    event EtherWithdrawn(uint256 value);

    //@notice - creates ERC20 token contract when Contribution is initialized
    constructor() ERC20('contribution', 'CONT'){
    }
    
    /*
    /// @author -  Cole Roberts
    /// @notice -  determines if donor is already a donor, mints the CONT tokens (based on amount of eth sent) to msg.sender, and updates user balance
    /// @param -  msg.value - the amount of CONT tokens is determined by msg.value, so ETH must be sent with function call
    */
    function donate() external payable{
        uint8 find = 0;
        for(uint i; i < donors.length; i++){
            if(donors[i] == msg.sender){
                find=1;
                break;
            }
        }

        if(find == 1){
            donors.push(msg.sender);
        }
        mint(msg.value);
        balances[msg.sender] += msg.value;
        emit DonationReceived(msg.value);

    }


    /*
    /// @author -  Cole Roberts
    /// @notice -  Withdraws the value in eth to the given address and updates the balance of the given address to 0
    /// @dev - I wasn't sure if the ETH should be withdrawn from msg.sender or the requested address so i went with the latter
    /// @dev - to change to msg.sender's funds, dev should change each _requestedAddress variable instance to msg.sender unless line comment specifies otherwise
    /// @param -  _requestedAddress - address given to withdraw from and send ETH to
    /// @return -  
    */
    function withdraw(address _requestedAddress) external {
            require(balances[_requestedAddress] > 0, "Address does not have a balance");
            uint256 value = balances[_requestedAddress]; 
            burn(_requestedAddress, value);
            require(balanceOf(_requestedAddress) == 0, "ERC20 burn failed");
            payable(_requestedAddress).transfer(value); //(see @dev) remain "_requestedAddress"
            balances[_requestedAddress] = 0;   
            emit EtherWithdrawn(value); 
    }


    
    // @notice -  executes @openzeppelin's ERC20 _mint function with msg.sender inputted as "recipient"
    // @param - _amount - amount to be minted
    function mint(uint256 _amount) internal{
        _mint(msg.sender, _amount);
    }

    // @notice -  executes @openzeppelin's ERC20 _burn function with given parameters
    // @param - _requestedAddress - address from which tokens will be burned
    // @param - _amount - amount of tokens to be burned
    function burn(address _requestedAddress, uint256 _amount) internal{
        _burn(_requestedAddress, _amount);
    }


}