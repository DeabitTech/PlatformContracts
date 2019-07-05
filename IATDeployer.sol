pragma solidity ^0.5.2;

interface IATDeployer {
    function newAdminTools(uint256) external returns(address);
    function setFactoryAddress(address) external;
    function getFactoryAddress() external view returns(address);
}