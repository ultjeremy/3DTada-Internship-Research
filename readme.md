# Blockchain Use Case Research

In this GitHub project, I am exploring various well-known and real-world tokens and their use cases. This project focuses on their technical integration and includes some code snippet examples throughout.

---
## Binance (BNB):

Binance utilizes smart contracts with their BNB Smart Chain to facilitate the building of dApps, allowing developers to create projects that take advantage of the benefits of the BNB token. The BNB Smart Chain utilizes the BEP-20 token standard, which is very similar to the ERC-20 standard. The standard acts like a guide and blueprint for how to create tokens for users of the Binance Exchange.

BNB transactions largely operate with on-chain logic, where transactions are recorded on the BNB chain and executed by smart contracts directly on the chain. This follows from the fact that BNB is the native currency on the Binance Exchange, powering transactions and paying for fees.

### Token Sending:

BNB can be interacted with through smart contracts that allow many transactions to occur, providing many benefits to users. I coded a small example of a smart contract through Solidity for transfering tokens, which can be used for transfering BNB, Ether, and other currencies across accounts. 

```solidity
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
[[Link to code]](https://github.com/ultjeremy/3DTada-Internship-Research/blob/af169c5949e71b2dddf7ae1776c6614731280076/contracts/token_send.sol)

In this example, you can call the `sendToken` function, inputting a recipient's address, to send a specified `msg.value` amount of currency to a chosen recipient. I implemented this in Solidity as a smart contract, using the Remix IDE.

### BNB Burning:

Another large token interaction example with the BNB token is the auto-burning feature. In order to ensure that a finite amount of BNB is in circulation and to avoid BNB inflation, BNB is periodically burned. This happens in two main ways:

1. Burning a portion of gas fees spent with BNB on the BNB Chain
2. Quarterly BNB burning events

A short example of BNB burning from Etherscan can be found [[here]](https://etherscan.io/token/0xB8c77482e45F1F44dE1745F52C74426C631bDD52#code), I have pulled an excerpt showing the specific burning process:

```solidity
function burn(uint256 _value) returns (bool success) {
	if (balanceOf[msg.sender] < _value) throw;            // Check if the sender has enough
		if (_value <= 0) throw; 
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                      // Subtract from the sender
        totalSupply = SafeMath.safeSub(totalSupply,_value);                                // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }
```
[[Repo Link to code]](https://github.com/ultjeremy/3DTada-Internship-Research/blob/a68c4ee7d554a00e53dd89a71a5a8003ec8a45ca/contracts/BNB.sol#L110-L117)

In this example, a `burn` function can be called that removes an inputted amount of BNB from the caller's account, updating the total supply and returning whether the operation was successful or not. This is again implemented with Solidity as a smart contract.

### Binance API:

A large part of the Binance Exchange is also the Binance API. Through its utilization, users can easily fetch information on various crypto currencies, and even create automated trading programs to have bots make trades on behalf of the trader.

One good method for working with the Binance API is through the python library `python-binance`. A simple example checking the latest price of Bitcoin is shown, taken from AlgoTrading101's guide on the Binance Python API [[here]](https://algotrading101.com/learn/binance-python-api-guide/):

```python
btc_price = client.get_symbol_ticker(symbol="BTCUSDT")
print(btc_price)
```

This block of code queries the Binance API to find and retrieve the latest price of Bitcoin. An example output:

```
{'symbol': 'BTCUSDT', 'price': '117,623.40'}
```

This output is formatted as an easily accessible python dictionary. The API can also access past Bitcoin values and many other crypto currencies, allowing the automation of stock trading to be easily implemented using the Binance API.

---
## Helium (HNT):

HNT was initially natively built on the Helium blockchain. In 2023, Helium migrated to Solana and adopted the SPL token standard. Like Binance's token standard. SPL is very similar in structure to ERC-20. Now, HNT utilizes Rust for its core software activities on the blockchain, through Rust programs (essentially smart contracts). 

The core functionality of HNT (token transfers, Proof-of-Coverage rewards, Data Credits), is handled on-chain, which some computationally intensive and data-driven tasks are handled off-chain. Some examples of this include the validation of Proof-of-Coverage, and the storage and processing of data.

### Proof-of-Coverage (PoC):

Proof-of-Coverage is Helium's main consensus algorithm that is used to verify the legitimacy of Hotspots and distribute HNT rewards based on the wireless coverage generated. From the Helium Documentation: "Proof-of-Coverage incentivizes Hotspot Operators to deploy Hotspots in underserved areas and report their deployments accurately so that users of the Helium Network can see where coverage is likely to be available." [[Link]](https://docs.helium.com/iot/proof-of-coverage/)

Powerful machines, called Oracles, are deployed across the Helium Network to test and verify results of Hotspots, and report back to the Helium Network to issue rewards. These Oracles operate off-chain, allowing for processing to be completed much quicker and without restrictions of smart contracts. Essentially, since smart contracts operate on-chain, which ensures transperency and thoroughness, it is not the best for Oracles which are complex algorithms that would be slow and expensive to run on the block-chain. So, the bulk of the work is done off-chain, where the final results are posted on the blockchain for the smart contracts to utilize.

The PoC scheme is structured in a way to give higher rewards to Hotspots in less dense and concentrated areas. PoC has a system that judges an area's density and calculates the effectiveness of each Hotspot, scaling rewards accordingly.

<img width="317" height="397" alt="image" src="https://github.com/user-attachments/assets/12737c58-201c-4761-a4a8-8e17cfdf3e78" />

[[Model Link]](https://docs.helium.com/iot/proof-of-coverage-roadmap)

### Reward Fanout:

```rust
pub fn handler(ctx: Context<InitializeFanoutV0>, args: InitializeFanoutArgsV0) -> Result<()> {
  let signer_seeds: &[&[&[u8]]] = &[&[b"fanout", args.name.as_bytes(), &[ctx.bumps.fanout]]];

  token::mint_to(
    CpiContext::new_with_signer(
      ctx.accounts.token_program.to_account_info(),
      MintTo {
        mint: ctx.accounts.collection.to_account_info(),
        to: ctx.accounts.collection_account.to_account_info(),
        authority: ctx.accounts.fanout.to_account_info(),
      },
      signer_seeds,
    ),
    1,
  )?;

  create_metadata_accounts_v3(
    CpiContext::new_with_signer(
      ctx
        .accounts
        .token_metadata_program
        .to_account_info()
        .clone(),
      CreateMetadataAccountsV3 {
        metadata: ctx.accounts.metadata.to_account_info().clone(),
        mint: ctx.accounts.collection.to_account_info().clone(),
        mint_authority: ctx.accounts.fanout.to_account_info().clone(),
        payer: ctx.accounts.payer.to_account_info().clone(),
        update_authority: ctx.accounts.fanout.to_account_info().clone(),
        system_program: ctx.accounts.system_program.to_account_info().clone(),
        rent: ctx.accounts.rent.to_account_info().clone(),
      },
      signer_seeds,
    ),
    DataV2 {
      name: args.name.clone(),
      symbol: String::from("FANOUT"),
      uri:
        "https://shdw-drive.genesysgo.net/6tcnBSybPG7piEDShBcrVtYJDPSvGrDbVvXmXKpzBvWP/fanout.json"
          .to_string(),
      seller_fee_basis_points: 0,
      creators: None,
      collection: None,
      uses: None,
    },
    true,
    true,
    Some(CollectionDetails::V2 { padding: [0; 8] }),
  )?;

  create_master_edition_v3(
    CpiContext::new_with_signer(
      ctx
        .accounts
        .token_metadata_program
        .to_account_info()
        .clone(),
      CreateMasterEditionV3 {
        edition: ctx.accounts.master_edition.to_account_info().clone(),
        mint: ctx.accounts.collection.to_account_info().clone(),
        update_authority: ctx.accounts.fanout.to_account_info().clone(),
        mint_authority: ctx.accounts.fanout.to_account_info().clone(),
        metadata: ctx.accounts.metadata.to_account_info().clone(),
        payer: ctx.accounts.payer.to_account_info().clone(),
        token_program: ctx.accounts.token_program.to_account_info().clone(),
        system_program: ctx.accounts.system_program.to_account_info().clone(),
        rent: ctx.accounts.rent.to_account_info().clone(),
      },
      signer_seeds,
    ),
    Some(0),
  )?;

  ctx.accounts.fanout.set_inner(FanoutV0 {
    authority: ctx.accounts.authority.key(),
    token_account: ctx.accounts.token_account.key(),
    membership_mint: ctx.accounts.membership_mint.key(),
    fanout_mint: ctx.accounts.fanout_mint.key(),
    membership_collection: ctx.accounts.collection.key(),
    name: args.name,
    total_shares: ctx.accounts.membership_mint.supply,
    total_staked_shares: 0,
    last_snapshot_amount: ctx.accounts.token_account.amount,
    total_inflow: ctx.accounts.token_account.amount,
    bump_seed: ctx.bumps.fanout,
  });

  Ok(())
}
```



