// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Revenue Splitter version 1.0
 *
 * @notice Takes all money coming in and splits between two wallets
 *         defined on deployment  
 *
 * @author UnblockTechie
 */
contract RevenueSplitter {
    /// @dev Address of the first wallet 
    address public immutable walletOne;

    /// @dev Address of the second wallet
    address public immutable walletTwo;

    /**
	 * @dev Fired in received() when native currency is received
	 *
	 * @param from An address from which money is received
	 * @param amount An amomunt of native currency received
	 */
    event Received(address indexed from, uint256 amount);

    /**
	 * @dev Fired in splitTokens() when tokens splitted between two wallets
	 *
	 * @param by An address which executed the transaction
	 * @param token An address of token which is splitted
     * @param amount An amomunt of given token
	 */
    event Split(address indexed by, address indexed token, uint256 amount);

    /**
	 * @dev Creates / deploys Revenue Splitter version 1.0
	 *
     * @notice Defines wallet addresses that will recieve all the money
     *         recieved/ held by the contract 
     *
	 * @param walletOne_ An address of first wallet
     * @param walletTwo_ An address of second wallet
	 */
    constructor(address walletOne_, address walletTwo_) {
        require(walletOne_ != address(0), "Invalid address for first wallet");
        require(walletTwo_ != address(0), "Invalid address for second wallet");
        
        // Set first wallet address 
        walletOne = walletOne_;

        // Set second wallet address
        walletTwo = walletTwo_;
    }
    
    /**
     * @dev Receives native currency and splits between two defined wallets
     *
     * @notice The remainder amount will be transferred into second wallet 
     */
    receive() external payable {
        // Transfer half amount of the recieved amount to first wallet
        payable(walletOne).transfer(msg.value / 2);

        // Transfer half amount and remainder of the recieved amount to second wallet
        payable(walletTwo).transfer(msg.value - msg.value / 2);
        
        // Emits an event
        emit Received(msg.sender, msg.value);
    }

    /**
     * @dev Splits existing balance of given token between two defined wallets
     *
     * @notice The remainder amount will be transferred into second wallet
     *
     * @param token_ An address of token to be splitted
     */
    function splitTokens(address token_) external {
        // Fetch balance of given token
        uint256 _balance = IERC20(token_).balanceOf(address(this));

        // Transfer half amount of the existing balance to first wallet
        IERC20(token_).transfer(walletOne, _balance / 2);

        // Transfer half amount and remainder of the existing balance to second wallet
        IERC20(token_).transfer(walletTwo, _balance - _balance / 2);

        // Emits an event
        emit Split(msg.sender, token_, _balance);
    }
}