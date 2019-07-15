pragma solidity ^0.5.1;

import "./Token.sol";
import "./ITDeployer.sol";

contract TDeployer is Ownable, ITDeployer {
    address private fAddress;
    event TokenDeployed(uint deployedBlock);

    //constructor() public {}

    modifier onlyFactory() {
        require(msg.sender == fAddress, "Address not allowed to create T Contract!");
        _;
    }

    function setFactoryAddress(address _fAddress) public onlyOwner {
        require(block.number < 6023000, "Time expired!");  //ropsten (Jul 20)
        //require(block.number < 9500000, "Time expired!");  //mainnet
        //https://codepen.io/adi0v/full/gxEjeP/  Fri Feb 07 2020 11:45:55 GMT+0100 (Ora standard dell’Europa centrale)
        require(_fAddress != address(0), "Address not allowed");
        fAddress = _fAddress;
    }

    function getFactoryAddress() public view returns(address) {
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
    function newToken(address _caller, string memory _name, string memory _symbol, address _ATAddress) public onlyFactory returns(address) {
        Token c = new Token(_name, _symbol, _ATAddress);
        c.transferOwnership(_caller);
        emit TokenDeployed(block.number);
        return address(c);
    }

}