pragma solidity ^0.5.2;

import "./lib/Ownable.sol";
import "./lib/SafeMath.sol";
import "./IERC20Seed.sol";
import "./IAdminTools.sol";
import "./IATDeployer.sol";
import "./ITDeployer.sol";
import "./IFPDeployer.sol";

/**
 * Utility library of inline functions on addresses
 */
library AddressUtil {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

contract Factory is Ownable {
    using AddressUtil for address;
    using SafeMath for uint256;

    address[] public deployerList;
    uint public deployerLength;
    address[] public ATContractsList;
    address[] public TContractsList;
    address[] public FPContractsList;

    mapping(address => bool) deployers;
    mapping(address => bool) ATContracts;
    mapping(address => bool) TContracts;
    mapping(address => bool) FPContracts;

    IERC20Seed private seedContract;
    address private seedAddress;
    IATDeployer private deployerAT;
    address private ATDAddress;
    ITDeployer private deployerT;
    address private TDAddress;
    IFPDeployer private deployerFP;
    address private FPDAddress;

    address private internalDEXAddress;

    event NewPanelCreated(address, address, address, address, uint);
    event TotalDeployFeesChanged();
    event FeeCollectorChanged();
    event ATFactoryAddressChanged();
    event TFactoryAddressChanged();
    event FPFactoryAddressChanged();
    event InternalDEXAddressChanged();

    constructor (address _seedAddress, address _ATDAddress, address _TDAddress, address _FPDAddress) public {
        seedAddress = _seedAddress;
        seedContract = IERC20Seed(seedAddress);
        ATDAddress = _ATDAddress;
        deployerAT = IATDeployer(ATDAddress);
        TDAddress = _TDAddress;
        deployerT = ITDeployer(_TDAddress);
        FPDAddress = _FPDAddress;
        deployerFP = IFPDeployer(_FPDAddress);
    }

    /**
     * @dev change AdminTols deployer address
     * @param _newATD new AT deployer address
     */
    function changeATFactoryAddress(address _newATD) public onlyOwner {
        require(block.number < 6023000, "Time expired!");  //ropsten (Jul 20)
        //require(block.number < 9500000, "Time expired!");  //mainnet
        //https://codepen.io/adi0v/full/gxEjeP/  Fri Feb 07 2020 11:45:55 GMT+0100 (Ora standard dell’Europa centrale)
        require(_newATD != address(0), "Address not suitable!");
        require(_newATD != ATDAddress, "AT factory address not changed!");
        ATDAddress = _newATD;
        deployerAT = IATDeployer(ATDAddress);
        emit ATFactoryAddressChanged();
    }

    /**
     * @dev change Token deployer address
     * @param _newTD new T deployer address
     */
    function changeTDeployerAddress(address _newTD) public onlyOwner {
        require(block.number < 6023000, "Time expired!");  //ropsten (Jul 20)
        //require(block.number < 9500000, "Time expired!");  //mainnet
        //https://codepen.io/adi0v/full/gxEjeP/ Fri Feb 07 2020 11:45:55 GMT+0100 (Ora standard dell’Europa centrale)
        require(_newTD != address(0), "Address not suitable!");
        require(_newTD != TDAddress, "AT factory address not changed!");
        TDAddress = _newTD;
        deployerT = ITDeployer(TDAddress);
        emit TFactoryAddressChanged();
    }

    /**
     * @dev change Funding Panel deployer address
     * @param _newFPD new FP deployer address
     */
    function changeFPDeployerAddress(address _newFPD) public onlyOwner {
        require(block.number < 6023000, "Time expired!");  //ropsten (Jul 20)
        //require(block.number < 9500000, "Time expired!");  //mainnet
        //https://codepen.io/adi0v/full/gxEjeP/  Fri Feb 07 2020 11:45:55 GMT+0100 (Ora standard dell’Europa centrale)
        require(_newFPD != address(0), "Address not suitable!");
        require(_newFPD != ATDAddress, "AT factory address not changed!");
        FPDAddress = _newFPD;
        deployerFP = IFPDeployer(FPDAddress);
        emit FPFactoryAddressChanged();
    }

    /**
     * @dev set internal DEX address
     * @param _dexAddress internal DEX address
     */
    function setInternalDEXAddress(address _dexAddress) public onlyOwner {
        require(block.number < 6023000, "Time expired!");  //ropsten (Jul 20)
        //require(block.number < 9500000, "Time expired!");  //mainnet
        //https://codepen.io/adi0v/full/gxEjeP/  Fri Feb 07 2020 11:45:55 GMT+0100 (Ora standard dell’Europa centrale)
        require(_dexAddress != address(0), "Address not suitable!");
        require(_dexAddress != internalDEXAddress, "AT factory address not changed!");
        internalDEXAddress = _dexAddress;
        emit InternalDEXAddressChanged();
    }

    /**
     * @dev deploy a new set of contracts for the Panel, with all params needed by contracts. Set the minter address for Token contract,
     * Owner is set as a manager in WL, Funding and FundsUnlocker, DEX is whitelisted
     * @param _name name of the token to be deployed
     * @param _symbol symbol of the token to be deployed
     * @param _setDocURL URL of the document describing the Panel
     * @param _setDocHash hash of the document describing the Panel
     * @param _exchRateSeed exchange rate between SEED tokens received and tokens given to the SEED sender (multiply by 10^_exchRateDecim)
     * @param _exchRateOnTop exchange rate between SEED token received and tokens minted on top (multiply by 10^_exchRateDecim)
     * @param _seedMaxSupply max supply of SEED tokens accepted by this contract
     * @param _WLAnonymThr max anonym threshold
     */
    function deployPanelContracts(string memory _name, string memory _symbol, string memory _setDocURL, bytes32 _setDocHash,
                            uint256 _exchRateSeed, uint256 _exchRateOnTop, uint256 _seedMaxSupply, uint256 _WLAnonymThr) public {
        address sender = msg.sender;

        require(sender != address(0), "Sender Address is zero");
        require(!sender.isContract(), "Sender is a Contract");
        require(internalDEXAddress != address(0), "Internal DEX Address is zero");

        deployers[sender] = true;
        deployerList.push(sender);
        deployerLength = deployerList.length;

        address newAT = deployerAT.newAdminTools(_WLAnonymThr);
        ATContracts[newAT] = true;
        ATContractsList.push(newAT);
        address newT = deployerT.newToken(sender, _name, _symbol, newAT);
        TContracts[newT] = true;
        TContractsList.push(newT);
        address newFP = deployerFP.newFundingPanel(sender, _setDocURL, _setDocHash, _exchRateSeed, _exchRateOnTop,
                                            seedAddress, _seedMaxSupply, newT, newAT, (deployerLength-1));
        FPContracts[newFP] = true;
        FPContractsList.push(newFP);

        IAdminTools ATBrandNew = IAdminTools(newAT);
        ATBrandNew.setFFPAddresses(address(this), newFP);
        ATBrandNew.setMinterAddress(newFP);
        ATBrandNew.addWLManagers(address(this));
        ATBrandNew.addWLManagers(sender);
        ATBrandNew.addFundingManagers(sender);
        ATBrandNew.addFundsUnlockerManagers(sender);
        ATBrandNew.setWalletOnTopAddress(sender);

        uint256 dexMaxAmnt = _exchRateSeed.mul(300000000);  //Seed Max supply
        ATBrandNew.addToWhitelist(internalDEXAddress, dexMaxAmnt);

        uint256 onTopMaxAmnt = _seedMaxSupply.mul(_exchRateSeed);
        ATBrandNew.addToWhitelist(sender, onTopMaxAmnt);

        ATBrandNew.removeWLManagers(address(this));

        Ownable customOwnable = Ownable(newAT);
        customOwnable.transferOwnership(sender);

        emit NewPanelCreated(sender, newAT, newT, newFP, deployerLength);
    }

    /**
     * @dev get internal DEX address
     */
    function getInternalDEXAddress() public view returns(address) {
        return internalDEXAddress;
    }

    /**
     * @dev get deployers number
     */
    function getTotalDeployer() public view returns(uint256) {
        return deployerList.length;
    }

    /**
     * @dev get AT contracts number
     */
    function getTotalATContracts() public view returns(uint256) {
        return ATContractsList.length;
    }

    /**
     * @dev get T contracts number
     */
    function getTotalTContracts() public view returns(uint256) {
        return TContractsList.length;
    }

    /**
     * @dev get FP contracts number
     */
    function getTotalFPContracts() public view returns(uint256) {
        return FPContractsList.length;
    }

    /**
     * @dev get if address is a deployer
     */
    function isFactoryDeployer(address _addr) public view returns(bool) {
        return deployers[_addr];
    }

    /**
     * @dev get if address is an AT contract generated by factory
     */
    function isFactoryATGenerated(address _addr) public view returns(bool) {
        return ATContracts[_addr];
    }

    /**
     * @dev get if address is a T contract generated by factory
     */
    function isFactoryTGenerated(address _addr) public view returns(bool) {
        return TContracts[_addr];
    }

    /**
     * @dev get if address is a T contract generated by factory
     */
    function isFactoryFPGenerated(address _addr) public view returns(bool) {
        return FPContracts[_addr];
    }

    /**
     * @dev get the i-th element in every array
     */
    function getContractsByIndex(uint256 _index) public view returns (address, address, address, address) {
        return(deployerList[_index], ATContractsList[_index], TContractsList[_index], FPContractsList[_index]);
    }

    /**
     * @dev get the i-th element in deployer array
     */
    function getDeployerAddressByIndex(uint256 _index) public view returns (address) {
        return deployerList[_index];
    }

    /**
     * @dev get the i-th element in ATContractsList array
     */
    function getATAddressByIndex(uint256 _index) public view returns (address) {
        return ATContractsList[_index];
    }

    /**
     * @dev get the i-th element in TContractsList array
     */
    function getTAddressByIndex(uint256 _index) public view returns (address) {
        return TContractsList[_index];
    }

    /**
     * @dev get the i-th element in FPContractsList array
     */
    function getFPAddressByIndex(uint256 _index) public view returns (address) {
        return FPContractsList[_index];
    }

    /**
     * @dev withdraw SEED tokens to a collector address
     */
    function withdraw(address _collector) external onlyOwner {
        seedContract.transfer(_collector, seedContract.balanceOf(address(this)));
    }
}