pragma solidity ^0.5.2;

interface IFundingPanel {
    function getFactoryDeployIndex() external view returns(uint);
    function isMemberInserted(address) external view returns(bool);
    function addMemberToSet(address, uint8, string calldata, bytes32) external returns (bool);
    function enableMember(address) external;
    function disableMemberByStaffRetire(address) external;
    function disableMemberByStaffForExit(address) external;
    function disableMemberByMember(address) external;
    function changeMemberData(address, string calldata, bytes32) external;
    function changeTokenExchangeRate(uint256) external;
    function changeTokenExchangeOnTopRate(uint256) external;
    function getOwnerData() external view returns (string memory, bytes32);
    function setOwnerData(string calldata, bytes32) external;
    function getMembersNumber() external view returns (uint);
    function getMemberAddressByIndex(uint8) external view returns (address);
    function getMemberDataByAddress(address _memberWallet) external view returns (bool, uint8, string memory, bytes32, uint256, uint, uint256);
    function setNewSeedMaxSupply(uint256) external returns (uint256);
    function holderSendSeeds(uint256) external;
    function unlockFunds(address, uint256) external;
    function burnTokensForMember(address, uint256) external;
    function importOtherTokens(address, uint256) external;
}