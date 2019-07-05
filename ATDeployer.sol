pragma solidity ^0.5.1;

import "./IERC20Seed.sol";
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
    function setFactoryAddress(address _fAddress) public onlyOwner {
        require(_fAddress != address(0), "Address not allowed");
        fAddress = _fAddress;
    }

    /**
     * @dev Get the factory address for deployment.
     */
    function getFactoryAddress() public view returns(address) {
        return fAddress;
    }

    /**
     * @dev deployment of a new AdminTools contract
     * @return address of the deployed AdminTools contract
     */
    function newAdminTools(uint256 _whitelistThresholdBalance) public onlyFactory returns(address) {
        AdminTools c = new AdminTools(_whitelistThresholdBalance);
        c.transferOwnership(msg.sender);
        emit ATDeployed (block.number);
        return address(c);
    }

}