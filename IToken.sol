pragma solidity ^0.5.2;

interface IToken {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function paused() external view returns (bool);
    function pause() external;
    function unpause() external;
    function isImportedContract(address) external view returns (bool);
    function getImportedContractRate(address) external view returns (uint256);
    function setImportedContract(address, uint256) external;
    function checkTransferAllowed (address, address, uint256) external view returns (byte);
    function checkTransferFromAllowed (address, address, uint256) external view returns (byte);
    function checkMintAllowed (address, uint256) external pure returns (byte);
    function checkBurnAllowed (address, uint256) external pure returns (byte);
}
