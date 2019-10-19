# PlatformContracts
Contracts for Seed Platform 

Here you can find solidity contracts for Seed Project to be deployed on ethereum blockchain

<img src="https://github.com/seedventure/PlatformContracts/blob/master/SeedPlatform.png">

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
