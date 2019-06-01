pragma solidity ^0.5.2;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract CustomOwnable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Not Owner!");
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
/*    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
*/
    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0),"Address 0 could not be owner");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IERC20Seed {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IAdminTools {
    function getMinterAddress() external view returns(address);
    function getWalletOnTopAddress() external view returns (address);
    function isWLManager(address) external view returns (bool);
    function isWLOperator(address) external view returns (bool);
    function isFundingManager(address) external view returns (bool);
    function isFundingOperator(address) external view returns (bool);
    function isFundsUnlockerManager(address) external view returns (bool);
    function isFundsUnlockerOperator(address) external view returns (bool);
    function isWhitelisted(address) external view returns(bool);
    function setMinterAddress(address) external returns(address);
    function getWLThresholdBalance() external view returns (uint256);
    function getMaxWLAmount(address) external view returns(uint256);
    function getWLLength() external view returns(uint256);
}


interface IATDeployer {
    function newAdminTools() external returns(address);
}


interface ITDeployer {
    function newToken(address, string calldata, string calldata, address) external returns(address);
}


interface IFPDeployer {
    function newFundingPanel(address, string calldata, bytes32, uint8, uint8, uint8,
                            address, uint256, address, address, uint) external returns(address);
}


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

contract Factory is CustomOwnable {
    using AddressUtil for address;

    address[] public deployer;
    uint public deployerLength;
    address[] public AdminToolsContracts;
    address[] public TokenContracts;
    address[] public FundingPanelContracts;

    IERC20Seed private seedContract;
    address private seedAddress;
    IATDeployer private deployerAT;
    address private ATDAddress;
    ITDeployer private deployerT;
    address private TDAddress;
    IFPDeployer private deployerFP;
    address private FPDAddress;

    address private feesCollector;
    uint256 private TotalFees;

    event NewPanelCreated(address sender, address newAT, address newT, address newFP, uint newLength);
    event TotalDeployFeesChanged();
    event FeeCollectorChanged();
    event ATFactoryAddressChanged();
    event TFactoryAddressChanged();
    event FPFactoryAddressChanged();

    constructor(address _seedAddress, address _ATDAddress, address _TDAddress, address _FPDAddress,
                address _feesCollector, uint256 _fees) public {
        seedAddress = _seedAddress;
        seedContract = IERC20Seed(seedAddress);
        ATDAddress = _ATDAddress;
        deployerAT = IATDeployer(ATDAddress);
        TDAddress = _TDAddress;
        deployerT = ITDeployer(_TDAddress);
        FPDAddress = _FPDAddress;
        deployerFP = IFPDeployer(_FPDAddress);
        feesCollector = _feesCollector;
        TotalFees = _fees;
    }

    /**
     * @dev change AdminTols deployer address
     * @param _newATD new AT deployer address
     */
    function changeATFactoryAddress(address _newATD) public onlyOwner {
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
        require(_newFPD != address(0), "Address not suitable!");
        require(_newFPD != ATDAddress, "AT factory address not changed!");
        FPDAddress = _newFPD;
        deployerFP = IFPDeployer(FPDAddress);
        emit FPFactoryAddressChanged();
    }

    /**
     * @dev change deployment fees in SEED tokens
     * @param _newAmount new amount of fees to deploy the contracts set
     */
    function changeDeployFees (uint256 _newAmount) public onlyOwner {
        require(_newAmount >= 0, "Deploy fees not suitable!");
        require(_newAmount != TotalFees, "Deploy fees not changed!");
        TotalFees = _newAmount;
        emit TotalDeployFeesChanged();
    }

    /**
     * @dev change fees collector address
     * @param _newCollector new collector address
     */
    function changeFeesCollector (address _newCollector) public onlyOwner {
        require(_newCollector != address(0), "Address not suitable!");
        require(_newCollector != feesCollector, "Collector address not changed!");
        feesCollector = _newCollector;
        emit FeeCollectorChanged();
    }

/*    function checkFactoryCongruity() public view returns(bool){
        require(AdminToolsContracts.length == deployerLength, "AT Contracts Length not verified!");
        require(TokenContracts.length == deployerLength, "Token Contracts Length not verified!");
        require(FundingPanelContracts.length == deployerLength, "FP Contracts Length not verified!");
        return true;
    }*/

    /**
     * @dev deploy a new set of contracts for the Panel, with all params needed by contracts. Set the minter address for Token contract
     * @param _name name of the token to be deployed
     * @param _symbol symbol of the token to be deployed
     * @param _setDocURL URL of the document describing the Panel
     * @param _setDocHash hash of the document describing the Panel
     * @param _exchRateSeed exchange rate between SEED tokens received and tokens given to the SEED sender (multiply by 10^_exchRateDecim)
     * @param _exchRateOnTop exchange rate between SEED token received and tokens minted on top (multiply by 10^_exchRateDecim)
     * @param _exchRateDecim exchange rate decimals
     * @param _seedMaxSupply max supply of SEED tokens accepted by this contract
     * @notice msg.sender has to approve this contract to spend SEED TotalFees tokens BEFORE calling this function
     */
    function deployPanelContracts(string memory _name, string memory _symbol, string memory _setDocURL, bytes32 _setDocHash,
                            uint8 _exchRateSeed, uint8 _exchRateOnTop, uint8 _exchRateDecim, uint256 _seedMaxSupply) public {
        address sender = msg.sender;
        //require(checkFactoryCongruity(), "Contracts arrays not correct!");
        require(sender != address(0), "Sender Address is zero");
        require(!sender.isContract(), "Sender is a Contract");
        require(seedContract.balanceOf(sender) >= TotalFees, "Not enough Seed Tokens to deploy Contracts!");
        require(seedContract.allowance(sender, feesCollector) >= TotalFees, "Deployer not allow Seed Tokens trasfer!");

        seedContract.transferFrom(sender, feesCollector, TotalFees);
        deployer.push(sender);
        deployerLength = deployer.length;

        address newAT = deployerAT.newAdminTools();
        AdminToolsContracts.push(newAT);
        address newT = deployerT.newToken(sender, _name, _symbol, newAT);
        TokenContracts.push(newT);
        address newFP = deployerFP.newFundingPanel(sender, _setDocURL, _setDocHash, _exchRateSeed, _exchRateOnTop, _exchRateDecim,
                                            seedAddress, _seedMaxSupply, newT, newAT, deployerLength);
        FundingPanelContracts.push(newFP);

        IAdminTools ATBrandNew = IAdminTools(newAT);
        ATBrandNew.setMinterAddress(newFP);
        CustomOwnable customOwnable = CustomOwnable(newAT);
        customOwnable.transferOwnership(sender);

        emit NewPanelCreated(sender, newAT, newT, newFP, deployerLength);
    }

    /**
     * @dev get total deployment fees
     */
    function getTotalDeployFees() public view returns (uint256) {
        return TotalFees;
    }

    /**
     * @dev get deployers number
     */
    function getTotalDeployer() public view returns(uint256) {
        return deployer.length;
    }

    /**
     * @dev get AT contracts number
     */
    function getTotalATContracts() public view returns(uint256) {
        return AdminToolsContracts.length;
    }

    /**
     * @dev get T contracts number
     */
    function getTotalTContracts() public view returns(uint256) {
        return TokenContracts.length;
    }

    /**
     * @dev get FP contracts number
     */
    function getTotalFPContracts() public view returns(uint256) {
        return FundingPanelContracts.length;
    }

    /**
     * @dev get the i-th element in every array
     */
    function getContractsByIndex(uint256 _index) public view returns (address, address, address, address) {
        return(deployer[_index], AdminToolsContracts[_index], TokenContracts[_index], FundingPanelContracts[_index]);
    }

    /**
     * @dev get the i-th element in deployer array
     */
    function getDeployerAddressByIndex(uint256 _index) public view returns (address) {
        return deployer[_index];
    }

    /**
     * @dev get the i-th element in AdminToolsContracts array
     */
    function getATAddressByIndex(uint256 _index) public view returns (address) {
        return AdminToolsContracts[_index];
    }

    /**
     * @dev get the i-th element in TokenContracts array
     */
    function getTAddressByIndex(uint256 _index) public view returns (address) {
        return TokenContracts[_index];
    }

    /**
     * @dev get the i-th element in FundingPanelContracts array
     */
    function getFPAddressByIndex(uint256 _index) public view returns (address) {
        return FundingPanelContracts[_index];
    }

    /**
     * @dev withdraw SEED tokens to a collector address
     */
    function withdraw(address _collector) external onlyOwner {
        seedContract.transfer(_collector, seedContract.balanceOf(address(this)));
    }
}
