pragma solidity ^0.5.2;

import "./AdminTools.sol";
import "./IATDeployer.sol";

contract ATDeployer is Ownable, IATDeployer {

    address private fAddress;
    event ATDeployed(uint deployedBlock);

    //constructor() public {}

    modifier onlyFactory() {
        require(msg.sender == fAddress, "Address not allowed to create AT Contract!");
        _;
    }

    /**
     * @dev Set the factory address for deployment.
     * @param _fAddress The factory address.
     */
    function setFactoryAddress(address _fAddress) external onlyOwner {
        require(block.number < 8850000, "Time expired!");
        require(_fAddress != address(0), "Address not allowed");
        fAddress = _fAddress;
    }

    /**
     * @dev Get the factory address for deployment.
     */
    function getFactoryAddress() external view returns(address) {
        return fAddress;
    }

    /**
     * @dev deployment of a new AdminTools contract
     * @return address of the deployed AdminTools contract
     */
    function newAdminTools(uint256 _whitelistThresholdBalance) external onlyFactory returns(address) {
        AdminTools c = new AdminTools(_whitelistThresholdBalance);
        c.transferOwnership(msg.sender);
        emit ATDeployed (block.number);
        return address(c);
    }

}