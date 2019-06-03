pragma solidity ^0.5.2;

interface IFundingPanel {
    function getFactoryDeployIndex() external view returns(uint);
    function isMemberInserted(address) external view returns(bool);
    function getMembersNumber() external view returns (uint);
    function getMemberAddressByIndex(uint8) external view returns (address);
}