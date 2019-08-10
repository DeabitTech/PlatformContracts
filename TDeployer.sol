pragma solidity ^0.5.2;

import "./Token.sol";
import "./ITDeployer.sol";

contract TDeployer is Ownable, ITDeployer {
    address private fAddress;
    event TokenDeployed(uint deployedBlock);


    modifier onlyFactory() {
        require(msg.sender == fAddress, "Address not allowed to create T Contract!");
        _;
    }

    function setFactoryAddress(address _fAddress) external onlyOwner {
        require(block.number < 8850000, "Time expired!");
        require(_fAddress != address(0), "Address not allowed");
        fAddress = _fAddress;
    }

    function getFactoryAddress() external view returns(address) {
        return fAddress;
    }

    /**
     * @dev deploy a new Token contract and transfer ownership to _caller address
     * @param _caller address that will take the ownership of the contract
     * @param _name name of the token to be deployed
     * @param _symbol symbol of the token to be deployed
     * @param _ATAddress address of the corresponding AT contract
     * @return address of the deployed Token contract
     */
    function newToken(address _caller, string calldata _name, string calldata _symbol, address _ATAddress) external onlyFactory returns(address) {
        Token c = new Token(_name, _symbol, _ATAddress);
        c.transferOwnership(_caller);
        emit TokenDeployed(block.number);
        return address(c);
    }

}