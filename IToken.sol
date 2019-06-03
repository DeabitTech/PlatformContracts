pragma solidity ^0.5.2;

interface IToken {
    function checkTransferAllowed (address, address, uint256) external view returns (byte);
    function checkTransferFromAllowed (address, address, uint256) external view returns (byte);
    function checkMintAllowed (address, uint256) external pure returns (byte);
    function checkBurnAllowed (address, uint256) external pure returns (byte);
}
