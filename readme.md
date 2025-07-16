# Blockchain Use Case Research

In this GitHub project, I am exploring various well-known and real-world tokens and their use cases. This project focuses on their technical integration and includes some code snippet examples throughout.

## Binance (BNB):

Binance utilizes smart contracts with their BNB Smart Chain to facilitate the building of dApps to allow developers to create projects taking advantage of the benefits that the BNB token provides. The BNB Smart Chain utilizes the BEP-20 token standard, which is very similar to the ERC-20 standard. The standard acts like a guide and blueprint for how to utilize the BEP-20 standard.

BNB transactions largely operate with on-chain logic, where transactions are recorded on the BNB chain and executed by smart contracts directly on the chain. This follows from the fact that BNB is the native currency on the Binance Exchange, powering transactions and paying for fees.

### Token Sending:

BNB can be interacted with through smart contracts that allow many transactions to occur, providing many benefits to users. I coded a small example of a smart contract through Solidity of transfering tokens, which can be used for transfering BNB, Ether, and other currencies across accounts. 

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract tokenSend {

    // Create event that listens for the transferring of currency
    event CurrencySent(address sender, address receiver, uint amount);

    // Sender does not have enough currency to send amount
    error NotEnoughCurrency(uint amount);
    
    // Function that transfers payment from the caller to a receiver
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
```

In this example, you can call the `sendToken` function, inputting a recipient's address, to send a specified `msg.value` amount of currency to a chosen recipient. I implemented this in Remix as a smart contract, using Solidity.

### BNB Burning:

Another large token interaction example with the BNB token is the auto-burning feature. In order to ensure that a finite amount of BNB is in circulation and to avoid BNB inflation, BNB is periodically burned. This happens in two main ways:

1. Burning a portion of gas fees spent with BNB on the BNB Chain
2. Quarterly BNB burning events

A short example of BNB burning from Etherscan can be found [here](https://etherscan.io/token/0xB8c77482e45F1F44dE1745F52C74426C631bDD52#code), I have pulled an excerpt showing the specific burning process:

```
function burn(uint256 _value) returns (bool success) {
	if (balanceOf[msg.sender] < _value) throw;            // Check if the sender has enough
		if (_value <= 0) throw; 
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                      // Subtract from the sender
        totalSupply = SafeMath.safeSub(totalSupply,_value);                                // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }
```

In this example, a `burn` function can be called that removes an inputted amount of BNB from the caller's account, updating the total supply and returning whether the operation was successful or not. This is again implemented with Solidity as a smart contract.

### Binance API:

A large part of the Binance Exchange is also the Binance API. Through its utilization, users can easily fetch information on various crypto currencies, and even create automated trading programs to have bots make trades on behalf of the trader.

One good method for working with the Binance API is through the python library `python-binance`. A simple example checking the latest price of Bitcoin is shown:

```
btc_price = client.get_symbol_ticker(symbol="BTCUSDT")
print(btc_price)
```

This block of code queries the Binance API to find and retrieve the latest price of Bitcoin. An example output:

```
{'symbol': 'BTCUSDT', 'price': '117,623.40'}
```

This output is formatted as an easily accessible python dictionary. The API can also access past Bitcoin values and many other crypto currencies, allowing the automation of stock trading to be easily implemented using the Binance API.
