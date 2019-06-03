pragma solidity ^0.5.2;

interface IAdminTools {
    function isFundingOperator(address) external view returns (bool);
    function isFundsUnlockerOperator(address) external view returns (bool);
    function setFFPAddresses(address, address) external;
    function setMinterAddress(address) external returns(address);
    function getMinterAddress() external view returns(address);
    function getWalletOnTopAddress() external view returns (address);
    function isWhitelisted(address) external view returns(bool);
    function getWLThresholdBalance() external view returns (uint256);
    function getMaxWLAmount(address) external view returns(uint256);
}