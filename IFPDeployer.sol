pragma solidity ^0.5.2;

interface IFPDeployer {
    function newFundingPanel(address, string calldata, bytes32, uint8, uint8, uint8,
                            address, uint256, address, address, uint) external returns(address);
}