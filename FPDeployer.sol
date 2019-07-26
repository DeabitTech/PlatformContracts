pragma solidity ^0.5.2;

import "./FundingPanel.sol";
import "./IFPDeployer.sol";


contract FPDeployer is Ownable, IFPDeployer {
    address private fAddress;

    event FundingPanelDeployed(uint deployedBlock);

    //constructor() public {}

    modifier onlyFactory() {
        require(msg.sender == fAddress, "Address not allowed to create FP!");
        _;
    }

    /**
     * @dev Set the factory address for deployment.
     * @param _fAddress The factory address.
     */
    function setFactoryAddress(address _fAddress) external onlyOwner {
        require(block.number < 6150000, "Time expired!");  //ropsten (Aug 10)
        //require(block.number < 9500000, "Time expired!");  //mainnet
        //https://codepen.io/adi0v/full/gxEjeP/  Fri Feb 07 2020 11:45:55 GMT+0100 (Ora standard dell’Europa centrale)
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
     * @dev deployment of a new Funding Panel contract
     * @param _caller address that will take the ownership of the contract
     * @param _setDocURL URL of the document describing the Panel
     * @param _setDocHash hash of the document describing the Panel
     * @param _exchRateSeed exchange rate between SEED tokens received and tokens given to the SEED sender (multiply by 10^_exchRateDecim)
     * @param _exchRateOnTop exchange rate between SEED token received and tokens minted on top (multiply by 10^_exchRateDecim)
     * @param _seedTokenAddress address of SEED token contract
     * @param _seedMaxSupply max supply of SEED tokens accepted by this contract
     * @param _tokenAddress address of the corresponding Token contract
     * @param _ATAddress address of the corresponding AdminTools contract
     * @param newLength number of this contract in the corresponding array in the Factory contract
     * @return address of the deployed Token contract
     */
    function newFundingPanel(address _caller, string calldata _setDocURL, bytes32 _setDocHash, uint256 _exchRateSeed, uint256 _exchRateOnTop,
                address _seedTokenAddress, uint256 _seedMaxSupply, address _tokenAddress, address _ATAddress, uint newLength) external onlyFactory returns(address) {
        require(_caller != address(0), "Sender Address is zero");
        FundingPanel c = new FundingPanel(_setDocURL, _setDocHash, _exchRateSeed, _exchRateOnTop,
                                              _seedTokenAddress, _seedMaxSupply, _tokenAddress, _ATAddress, newLength);
        c.transferOwnership(_caller);
        emit FundingPanelDeployed (block.number);
        return address(c);
    }

}