pragma solidity ^0.5.2;

interface IFactory {
    function changeATFactoryAddress(address) external;
    function changeTDeployerAddress(address) external;
    function changeFPDeployerAddress(address) external;
    function changeDeployFees (uint256) external;
    function changeFeesCollector (address) external;
    function deployPanelContracts(string calldata, string calldata, string calldata, bytes32, uint8, uint8, uint8, uint256) external;
    function getTotalDeployFees() external view returns (uint256);
    function isFactoryDeployer(address) external view returns(bool);
    function isFactoryATGenerated(address) external view returns(bool);
    function isFactoryTGenerated(address) external view returns(bool);
    function isFactoryFPGenerated(address) external view returns(bool);
    function getTotalDeployer() external view returns(uint256);
    function getTotalATContracts() external view returns(uint256);
    function getTotalTContracts() external view returns(uint256);
    function getTotalFPContracts() external view returns(uint256);
    function getContractsByIndex(uint256) external view returns (address, address, address, address);
    function getDeployerAddressByIndex(uint256) external view returns (address);
    function getATAddressByIndex(uint256) external view returns (address);
    function getTAddressByIndex(uint256) external view returns (address);
    function getFPAddressByIndex(uint256) external view returns (address);
    function withdraw(address) external;
}