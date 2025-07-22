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

A beacon is essentially a means to prove a Hotspot exists and measure its performance for wireless coverage. The Verifier Oracle is a method to report and measure Proof-of-Coverage activity off-chain, ensuring only legitimate Hotspots get rewarded. Lastly, the Rewards Oracle is responsible for actually distributing HNT rewards based on verified network activity.

### Reward Fanout:

The following Rust function is taken from the Helium Program Library. It is a function designed for initializing the structure for distributing tokens, setting up the pool for ditrubution. [[Link to Code]](https://github.com/helium/helium-program-library/blob/6c4189fdca73cd6bc0e3ac4886d9fd42613ba8a4/programs/fanout/src/instructions/initialize_fanout_v0.rs)

```rust
pub fn handler(ctx: Context<InitializeFanoutV0>, args: InitializeFanoutArgsV0) -> Result<()> {
  let signer_seeds: &[&[&[u8]]] = &[&[b"fanout", args.name.as_bytes(), &[ctx.bumps.fanout]]];

/*
This mints 1 token to the fanout token account in the form of a NFT collection to represent shares.
*/
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

/*
This creates metadata for wallets to recognize the collection.
*/
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

/*
This allows for supply control of the NFT collection.
*/
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

/*
This part initializes all state variables to track tokens and authority.
*/
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

Essentially, this function serves to set up the process for a smart contract to distribute tokens amongst a group. It utilizes NFTs to represent the flow of tokens being distributed. This function overall initializes a fanout pool to later distribute token accordingly. This function enables the Rewards Oracle to actually split and distribute the HNT in a way that matches Solana’s on-chain design.

---
## Brave Browser (BAT - Basic Attention Token):

Brave Browser built BAT on the Etherium blockchain and uses the ERC-20 token standard. Main functions mostly consist of methods to manage token balances. All token transfers and activities occur on-chain, including the execution of smart contract logic. The management of user data is handled off-chain in order to preserve the user's privacy. While BAT does track user information to personalize ads, the personal information of the user does not ever leave the user's device.

### ERC-20 Token Standard:

In order to be considered to be an ERC-20 token, BAT implemented the following functions and events:

```solidity
function name() public view returns (string)
function symbol() public view returns (string)
function decimals() public view returns (uint8)
function totalSupply() public view returns (uint256)
function balanceOf(address _owner) public view returns (uint256 balance)
function transfer(address _to, uint256 _value) public returns (bool success)
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)
function approve(address _spender, uint256 _value) public returns (bool success)
function allowance(address _owner, address _spender) public view returns (uint256 remaining)
```
```solidity
event Transfer(address indexed _from, address indexed _to, uint256 _value)
event Approval(address indexed _owner, address indexed _spender, uint256 _value)
```

### Official BAT Transfer Method:

The following code is pulled from [Etherscan](https://etherscan.io/address/0x0D8775F648430679A709E98d2b0Cb6250d2887EF#code) and shows the official implementation of BAT's transfer method. 

```solidity
function transfer(address _to, uint256 _value) returns (bool success) {
	if (balances[msg.sender] >= _value && _value > 0) {
		balances[msg.sender] -= _value;
		balances[_to] += _value;
		Transfer(msg.sender, _to, _value);
		return true;
	} else {
        	return false;
      }
    }
```

This function makes sure to check that the balance of the caller and the user is both nonnegative and greater than the transfer value. Secondly, the function makes sure to use the Transfer event to log that a transfer has been successfully made. If any part of the function's conditions fail, the entire execution is dropped.

### Simple Smart Contract Example:

The following code is a very small example of a smart contract showing how it is possible to transfer BAT tokens to a different account's address.

```solidity
address userAddress = 0xA579BC48B953204118899BC98cbfBB372eCaD982;
uint256 amount = 1;
IERC20 batToken = IERC20(0x0D8775F648430679A709E98d2b0Cb6250d2887EF);
batToken.transfer(userAddress, amount);
```

The first and second line are just variable declarations for a user's address and a token amount. The third line creates a reference to the official BAT token created with the `ERC-20` token standard. The fourth line calls the `transfer` method from the BAT smart contract implementation and runs it on the given userAddress and amount. 

---
## Axie Infinity (AXS / SLP):

Both AXS and SLP are built using the ERC-20 token standard, through the use of smart contracts. Axie Infinity now operates on an Etherium side-chain called Ronin, developed by Axie Infinity's creator, Sky Mavis. AXS largely operates on chain through smart contracts to implement transfers, governance, and staking. SLP is slightly more complicated in that SLP rewards from gameplay are generated off-chain with game logic, but transferred to the user's Ronin wallet on-chain. Additionally, SLP burns from breeding are triggered off-chain through game logic but actually burned on-chain.

### Core Axie Logic:

The following is taken from the official Axie Infinity GitHub page, linked [[here]](https://github.com/axieinfinity/public-smart-contracts/blob/master/contracts/marketplace/AxieClockAuction.sol). This is a smart contract that represents the core logic for Axie NFTs.

```solidity
pragma solidity ^0.4.19;


import "./erc721/AxieERC721.sol";


// solium-disable-next-line no-empty-blocks
contract AxieCore is AxieERC721 {
  struct Axie {
    uint256 genes;
    uint256 bornAt;
  }

  Axie[] axies;

  event AxieSpawned(uint256 indexed _axieId, address indexed _owner, uint256 _genes);
  event AxieRebirthed(uint256 indexed _axieId, uint256 _genes);
  event AxieRetired(uint256 indexed _axieId);
  event AxieEvolved(uint256 indexed _axieId, uint256 _oldGenes, uint256 _newGenes);

  function AxieCore() public {
    axies.push(Axie(0, now)); // The void Axie
    _spawnAxie(0, msg.sender); // Will be Puff
    _spawnAxie(0, msg.sender); // Will be Kotaro
    _spawnAxie(0, msg.sender); // Will be Ginger
    _spawnAxie(0, msg.sender); // Will be Stella
  }

  function getAxie(
    uint256 _axieId
  )
    external
    view
    mustBeValidToken(_axieId)
    returns (uint256 /* _genes */, uint256 /* _bornAt */)
  {
    Axie storage _axie = axies[_axieId];
    return (_axie.genes, _axie.bornAt);
  }

  function spawnAxie(
    uint256 _genes,
    address _owner
  )
    external
    onlySpawner
    whenSpawningAllowed(_genes, _owner)
    returns (uint256)
  {
    return _spawnAxie(_genes, _owner);
  }

  function rebirthAxie(
    uint256 _axieId,
    uint256 _genes
  )
    external
    onlySpawner
    mustBeValidToken(_axieId)
    whenRebirthAllowed(_axieId, _genes)
  {
    Axie storage _axie = axies[_axieId];
    _axie.genes = _genes;
    _axie.bornAt = now;
    AxieRebirthed(_axieId, _genes);
  }

  function retireAxie(
    uint256 _axieId,
    bool _rip
  )
    external
    onlyByeSayer
    whenRetirementAllowed(_axieId, _rip)
  {
    _burn(_axieId);

    if (_rip) {
      delete axies[_axieId];
    }

    AxieRetired(_axieId);
  }

  function evolveAxie(
    uint256 _axieId,
    uint256 _newGenes
  )
    external
    onlyGeneScientist
    mustBeValidToken(_axieId)
    whenEvolvementAllowed(_axieId, _newGenes)
  {
    uint256 _oldGenes = axies[_axieId].genes;
    axies[_axieId].genes = _newGenes;
    AxieEvolved(_axieId, _oldGenes, _newGenes);
  }

  function _spawnAxie(uint256 _genes, address _owner) private returns (uint256 _axieId) {
    Axie memory _axie = Axie(_genes, now);
    _axieId = axies.push(_axie) - 1;
    _mint(_owner, _axieId);
    AxieSpawned(_axieId, _owner, _genes);
  }
}
```

Every Axie has different genes which determine its characteristics, and a creation time. An `axies` array stores Axies and indexes them by their Token ID. There are four events for Axies that log different parts of the lifecycles of Axies. When the contract is first deployed, a placeholder Axie is created at index zero, followed by four preset Axies. There are five main operations with Axies that can be executed, being getting, spawning, rebirthing, retiring, and evolving Axies.

---
## Chiliz (CHZ) / Socios.com:
