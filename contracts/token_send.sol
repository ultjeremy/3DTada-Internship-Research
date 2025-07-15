// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract tokenSend {

    event CurrencySent(address sender, address receiver, uint amount);

    // Sender does not have enough currency to send amount
    error NotEnoughCurrency(uint amount);
    
    // Function that transferes payment from the caller to a receiver
    function sendToken(address payable receiver) external payable {

        // Ensure that the sender sends more than nothing
        require(msg.value > 0, "You have to send something.");

        // Make sure the transfer successfully went through
        (bool success, ) = receiver.call{value: msg.value}("");
        require(success, "Transfer failed.");

        // Log the transfer
        emit CurrencySent(msg.sender, receiver, msg.value);

        }
}