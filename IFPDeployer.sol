pragma solidity ^0.5.2;

interface IFPDeployer {
    function newFundingPanel(address, string calldata, bytes32, uint256, uint256,
                            address, uint256, address, address, uint) external returns(address);
    function setFactoryAddress(address) external;
    function getFactoryAddress() external view returns(address);
}