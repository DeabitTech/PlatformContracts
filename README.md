# PlatformContracts
Contracts for Seed Platform 

Here you can find solidity contracts for Seed Project to be deployed on ethereum blockchain

<img src="https://github.com/seedventure/PlatformContracts/blob/master/SeedPlatform.png" width='600px'>

+	ATDeployer: AdminTools contracts deployer. No parameter.
+	TDeployer: Token contracts deployer. No parameter.
+	FPDeployer: Funding Panel contracts deployer. No parameter.
+ Factory: contract facility to deploy all other platform contracts. It requires 4 parameters:
  - SEED token address.
  - ATDeployer address.
  - TDeployer address.
  - FPDeployer address.
+ Internal DEX: DEX for deployed tokens deployed by Factory. It requires 2 parameters:
  - SEED token address.
  - Factory address.
  
A new set of contracts (AdminTools, Token and Funding Panel) could be deployed invoking the deployPanelContracts function included in Factory contract. It requires the following parameters:
- name of the token to be deployed
- symbol of the token to be deployed
- URL of the document describing the Panel
- hash of the document describing the Panel
- exchange rate between SEED tokens received and tokens given to the SEED sender
- exchange rate between SEED token received and tokens minted on top
- max supply of SEED tokens accepted by this set of contracts
- max anonym threshold

Whenever a new set of contracts will be deployed, these parameters will be set automatically:
- owner address of contracts (deployer)
- token contract minter address (deployer)
- DEX whitelisted for the specified total quantity of tokens
- Wallet on top address set to deployer address and whitelisted for the specified total quantity of tokens

Once a new set has been deployed, owner (deployer) could add address to have different managers and operators for whitelisting and funds unlocker operators. 
Whitelist managers and operators could whitelist addresses to send SEED tokens to the Funding Panel.
Funds unlocker managers and operators could add startup to Funding Panel and could unlock funds to inserted startups.

Whitelisted addresses could send SEED tokens to Funding Panel contract address, receiving set tokens back.
Set tokens owners could use the internal DEX to trade their tokens.

A desktop and mobile client should have been provided to make all the described process easier for anyone.
