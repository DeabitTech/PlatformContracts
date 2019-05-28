pragma solidity ^0.5.2;

// File: D:/SEED/SeedPlatform/contracts/IERC20Seed.sol

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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: d:/SEED/SeedPlatform/contracts/CustomOwnable.sol

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

// File: d:/SEED/SeedPlatform/contracts/IAdminTools.sol

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
    function getWLThresholdBalance() external view returns (uint256);
    function getMaxWLAmount(address) external view returns(uint256);
    function getWLLength() external view returns(uint256);
}

// File: d:/SEED/SeedPlatform/contracts/IFactoryFP.sol

interface IFactoryFP {
    function getDeployFPFees() external view returns(uint256);
    function getFundingPanelContractCount() external view returns(uint);
    function newFundingPanel(string calldata, bytes32, uint8, uint8, uint8, address, uint256, address, address) external returns(address);
    function getSingleFundingPanelContract(uint256) external view returns(address);
}

// File: d:/SEED/SeedPlatform/contracts/IFundingPanel.sol

interface IFundingPanel {
    function getFactoryDeployIndex() external view returns(uint8);
    function isMemberInserted(address) external view returns(bool);
    function getMembersNumber() external view returns (uint);
    function getTokenAddress() external view returns (address);
    function getOwnerData() external view returns (string memory, bytes32);
    function getMemberAddressByIndex(uint8) external view returns (address);
    function getMemberDataByAddress(address) external view returns (bool, uint8, string memory, bytes32, uint256, uint);
    function getTotalRaised() external view returns (uint256);
    function burnTokensForMember(address, uint256) external;
}

// File: D:/SEED/SeedPlatform/contracts/AdminTools.sol

contract AdminTools is CustomOwnable, IAdminTools {
    using SafeMath for uint256;

    struct wlVars {
        bool permitted;
        uint256 maxAmount;
    }

    mapping (address => wlVars) private whitelist;

    uint8 private whitelistLength;

    uint256 private whitelistThresholdBalance;

    mapping (address => bool) private _WLManagers;
    mapping (address => bool) private _FundingManagers;
    mapping (address => bool) private _FundsUnlockerManagers;
    mapping (address => bool) private _WLOperators;
    mapping (address => bool) private _FundingOperators;
    mapping (address => bool) private _FundsUnlockerOperators;

    address private _minterAddress;

    address private _walletOnTopAddress;

    address public FPAddress;
    IFundingPanel public FPContract;
    address public factoryFPAddress;
    IFactoryFP public FFPContract;

    event WLManagersAdded();
    event WLManagersRemoved();
    event WLOperatorsAdded();
    event WLOperatorsRemoved();
    event FundingManagersAdded();
    event FundingManagersRemoved();
    event FundingOperatorsAdded();
    event FundingOperatorsRemoved();
    event FundsUnlockerManagersAdded();
    event FundsUnlockerManagersRemoved();
    event FundsUnlockerOperatorsAdded();
    event FundsUnlockerOperatorsRemoved();
    event MaxWLAmountChanged();
    event MinterChanged();
    event WalletOnTopAddressChanged();
    event LogWLThresholdBalanceChanged();
    event LogWLAddressAdded();
    event LogWLAddressRemoved();

    constructor(uint256 _whitelistThresholdBalance) public {
        whitelistThresholdBalance = _whitelistThresholdBalance.mul(10**18);
    }

    function setFundingPanelAddresses(address _factoryFPAddress, address _FPAddress) public onlyOwner{
        factoryFPAddress = _factoryFPAddress;
        FFPContract = IFactoryFP(factoryFPAddress);
        FPAddress = _FPAddress;
        FPContract = IFundingPanel(FPAddress);
    }

    /* Token Minter address, to set like Funding Panel address */
    function getMinterAddress() public view returns(address){
        return _minterAddress;
    }

    function setMinterAddress(address _minter) public onlyOwner returns(address){
        require(_minter != address(0), "Not valid minter address!");
        require(_minter != _minterAddress, " No change in minter contract");
        require(FFPContract.getSingleFundingPanelContract(FPContract.getFactoryDeployIndex()) == _minter,
                        "Minter is not a known funding panel!");
        _minterAddress = _minter;
        emit MinterChanged();
        return _minterAddress;
    }

    /* Wallet receiving extra minted tokens (percentage) */
    function getWalletOnTopAddress() public view returns (address) {
        return _walletOnTopAddress;
    }

    function setWalletOnTopAddress(address _wallet) public onlyOwner returns(address){
        require(_wallet != address(0), "Not valid wallet address!");
        require(_wallet != _walletOnTopAddress, " No change in OnTopWallet");
        _walletOnTopAddress = _wallet;
        emit WalletOnTopAddressChanged();
        return _walletOnTopAddress;
    }


    /* Modifiers */
    modifier onlyWLManagers() {
        require(isWLManager(msg.sender), "Not a Whitelist Manager!");
        _;
    }

    modifier onlyWLOperators() {
        require(isWLOperator(msg.sender), "Not a Whitelist Operator!");
        _;
    }

    modifier onlyFundingManagers() {
        require(isFundingManager(msg.sender), "Not a Funding Panel Manager!");
        _;
    }

    modifier onlyFundingOperators() {
        require(isFundingOperator(msg.sender), "Not a Funding Panel Operator!");
        _;
    }

    modifier onlyFundsUnlockerManagers() {
        require(isFundsUnlockerManager(msg.sender), "Not a Funds Unlocker Manager!");
        _;
    }

    modifier onlyFundsUnlockerOperators() {
        require(isFundsUnlockerOperator(msg.sender), "Not a Funds Unlocker Operator!");
        _;
    }


    /*   WL Roles Mngmt  */
    function addWLManagers(address account) public onlyOwner {
        _addWLManagers(account);
        _addWLOperators(account);
    }

    function removeWLManagers(address account) public onlyOwner {
        _removeWLManagers(account);
        _removeWLManagers(account);
    }

    function isWLManager(address account) public view returns (bool) {
        return _WLManagers[account];
    }

    function addWLOperators(address account) public onlyWLManagers {
        _addWLOperators(account);
    }

    function removeWLOperators(address account) public onlyWLManagers {
        _addWLOperators(account);
    }

    function renounceWLManager() public onlyWLManagers {
        _removeWLManagers(msg.sender);
    }

    function _addWLManagers(address account) internal {
        _WLManagers[account] = true;
        emit WLManagersAdded();
    }

    function _removeWLManagers(address account) internal {
        _WLManagers[account] = false;
        emit WLManagersRemoved();
    }


    function isWLOperator(address account) public view returns (bool) {
        return _WLOperators[account];
    }

    function renounceWLOperators() public onlyWLOperators {
        _removeWLOperators(msg.sender);
    }

    function _addWLOperators(address account) internal {
        _WLOperators[account] = true;
        emit WLOperatorsAdded();
    }

    function _removeWLOperators(address account) internal {
        _WLOperators[account] = false;
        emit WLOperatorsRemoved();
    }


    /*   Funding Roles Mngmt  */
    function addFundingManagers(address account) public onlyOwner {
        _addFundingManagers(account);
        _addFundingOperators(account);
    }

    function removeFundingManagers(address account) public onlyOwner {
        _removeFundingManagers(account);
        _removeFundingManagers(account);
    }

    function isFundingManager(address account) public view returns (bool) {
        return _FundingManagers[account];
    }

    function addFundingOperators(address account) public onlyFundingManagers {
        _addFundingOperators(account);
    }

    function removeFundingOperators(address account) public onlyFundingManagers {
        _addFundingOperators(account);
    }

    function renounceFundingManager() public onlyFundingManagers {
        _removeFundingManagers(msg.sender);
    }

    function _addFundingManagers(address account) internal {
        _FundingManagers[account] = true;
        emit FundingManagersAdded();
    }

    function _removeFundingManagers(address account) internal {
        _FundingManagers[account] = false;
        emit FundingManagersRemoved();
    }


    function isFundingOperator(address account) public view returns (bool) {
        return _FundingOperators[account];
    }

    function renounceFundingOperators() public onlyFundingOperators {
        _removeFundingOperators(msg.sender);
    }

    function _addFundingOperators(address account) internal {
        _FundingOperators[account] = true;
        emit FundingOperatorsAdded();
    }

    function _removeFundingOperators(address account) internal {
        _FundingOperators[account] = false;
        emit FundingOperatorsRemoved();
    }

    /*   Funds Unlockers Roles Mngmt  */
    function addFundsUnlockerManagers(address account) public onlyOwner {
        _addFundsUnlockerManagers(account);
        _addFundsUnlockerOperators(account);
    }

    function removeFundsUnlockerManagers(address account) public onlyOwner {
        _removeFundsUnlockerManagers(account);
        _removeFundsUnlockerManagers(account);
    }

    function isFundsUnlockerManager(address account) public view returns (bool) {
        return _FundsUnlockerManagers[account];
    }

    function addFundsUnlockerOperators(address account) public onlyFundsUnlockerManagers {
        _addFundsUnlockerOperators(account);
    }

    function removeFundsUnlockerOperators(address account) public onlyFundsUnlockerManagers {
        _addFundsUnlockerOperators(account);
    }

    function renounceFundsUnlockerManager() public onlyFundsUnlockerManagers {
        _removeFundsUnlockerManagers(msg.sender);
    }

    function _addFundsUnlockerManagers(address account) internal {
        _FundsUnlockerManagers[account] = true;
        emit FundsUnlockerManagersAdded();
    }

    function _removeFundsUnlockerManagers(address account) internal {
        _FundsUnlockerManagers[account] = false;
        emit FundsUnlockerManagersRemoved();
    }


    function isFundsUnlockerOperator(address account) public view returns (bool) {
        return _FundsUnlockerOperators[account];
    }

    function renounceFundsUnlockerOperators() public onlyFundsUnlockerOperators {
        _removeFundsUnlockerOperators(msg.sender);
    }

    function _addFundsUnlockerOperators(address account) internal {
        _FundsUnlockerOperators[account] = true;
        emit FundsUnlockerOperatorsAdded();
    }

    function _removeFundsUnlockerOperators(address account) internal {
        _FundsUnlockerOperators[account] = false;
        emit FundsUnlockerOperatorsRemoved();
    }


    /*  Whitelisting  Mngmt  */

    /**
     * @return true if subscriber is whitelisted, false otherwise
     */
    function isWhitelisted(address _subscriber) public view returns(bool) {
        return whitelist[_subscriber].permitted;
    }

    /**
     * @return the anonymous threshold
     */
    function getWLThresholdBalance() public view returns (uint256) {
        return whitelistThresholdBalance;
    }

    /**
     * @return maxAmount for holder
     */
    function getMaxWLAmount(address _subscriber) public view returns(uint256) {
        return whitelist[_subscriber].maxAmount;
    }

    /**
     * @dev length of the whitelisted accounts
     */
    function getWLLength() public view returns(uint256) {
        return whitelistLength;
    }

    /**
     * @dev set new anonymous threshold
     * @param _newThreshold The new anonymous threshold.
     */
    function setNewThreshold(uint256 _newThreshold) public onlyWLManagers {
        require(whitelistThresholdBalance != _newThreshold, "New Threshold like the old one!");
        //require(_newThreshold != getWLThresholdBalance(), "NewMax equal to old MaxAmount");
        whitelistThresholdBalance = _newThreshold;
        emit LogWLThresholdBalanceChanged();
    }

    /**
     * @dev Change maxAmount for holder
     * @param _subscriber The subscriber in the whitelist.
     * @param _newMaxToken New max amount that a subscriber can hold (in set tokens).
     */
    function changeMaxWLAmount(address _subscriber, uint256 _newMaxToken) public onlyWLOperators {
        require(isWhitelisted(_subscriber), "Investor is not whitelisted!");
        whitelist[_subscriber].maxAmount = _newMaxToken;
        emit MaxWLAmountChanged();
    }

    /**
     * @dev Add the subscriber to the whitelist.
     * @param _subscriber The subscriber to add to the whitelist.
     * @param _maxAmnt max amount that a subscriber can hold (in set tokens).
     */
    function addToWhitelist(address _subscriber, uint256 _maxAmnt) public onlyWLOperators {
        require(_subscriber != address(0), "_subscriber is zero");
        require(!whitelist[_subscriber].permitted, "already whitelisted");

        whitelistLength++;

        whitelist[_subscriber].permitted = true;
        whitelist[_subscriber].maxAmount = _maxAmnt;

        emit LogWLAddressAdded();
    }

    /**
     * @dev Remove the subscriber to the whitelist.
     * @param _subscriber The subscriber to add to the whitelist.
     * @param _balance balance of a subscriber to be under the anonymous threshold, otherwise de-whilisting not permitted.
     */
    function removeFromWhitelist(address _subscriber, uint256 _balance) public onlyWLOperators {
        require(_subscriber != address(0), "_subscriber is zero");
        require(whitelist[_subscriber].permitted, "not whitelisted");
        require(_balance <= whitelistThresholdBalance, "balance greater than whitelist threshold");

        whitelistLength--;

        whitelist[_subscriber].permitted = false;
        whitelist[_subscriber].maxAmount = 0;

        emit LogWLAddressRemoved();
    }

}

// File: D:/SEED/SeedPlatform/contracts/IFactoryAT.sol

interface IFactoryAT {
    function getDeployATFees() external view returns(uint256);
    function getAdminToolsContractCount() external view returns(uint);
    function newAdminTools() external returns(address newContract);
    function getSingleAdminToolsContract(uint256) external view returns(address);
}

// File: contracts\FactoryAT.sol

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

contract FactoryAT is CustomOwnable, IFactoryAT {
    using AddressUtil for address;
    
    address[] public AdminToolsContracts;

    address public lastATContract;

    uint public lastATLength;

    uint256 public deployATFees;
    address public feeCollectorAT;

    IERC20Seed public seedContract;

    event ATDeployed(address indexed ATContractAddress, address indexed ownerAddress, uint deployedBlock, uint ATLength);
    event DeployATFeesChanged();
    event FeeCollectorATChanged();

    constructor(address _seedContract, uint256 _deployATFees, address _feeCollector) public{
        seedContract = IERC20Seed(_seedContract);  // change with SEED address
        deployATFees = _deployATFees;
        feeCollectorAT = _feeCollector;
    }

    function getDeployATFees() public view returns(uint256) {
        return deployATFees;
    }

    function changeDeployATFees (uint256 _newAmount) public onlyOwner {
        require(_newAmount >= 0, "Deploy fees not suitable!");
        require(_newAmount != deployATFees, "Deploy fees not changed!");
        deployATFees = _newAmount;
        emit DeployATFeesChanged();
    }

    function changeFeeCollector (address _newCollector) public onlyOwner {
        require(_newCollector != address(0), "Address not suitable!");
        require(_newCollector != feeCollectorAT, "Collector address not changed!");
        feeCollectorAT = _newCollector;
        emit FeeCollectorATChanged();
    }

    // useful to know the row count in contracts index
    function getAdminToolsContractCount() public view returns(uint contractCount) {
        return AdminToolsContracts.length;
    }

    /**
     * @dev deploy a new AdminTools contract
     * @notice msg.sender has to approve this contract to spend SEED deployATFees tokens BEFORE calling this function
     */
    function newAdminTools() public returns(address newContract) {
        require(msg.sender != address(0), "Sender Address is zero");
        require(seedContract.balanceOf(msg.sender) > deployATFees, "Not enough Seed Tokens to deploy AT!");
        address temp = msg.sender;
        require(!temp.isContract(), "Sender Address is a contract");
        require(feeCollectorAT != address(0), "Fee Collector is zero");
        require(!feeCollectorAT.isContract(), "Fee Collector is a contract!");
        seedContract.transferFrom(msg.sender, feeCollectorAT, deployATFees);  // this collecting fees
        AdminTools c = new AdminTools(0);
        lastATContract = address(c);
        c.transferOwnership(msg.sender);
        AdminToolsContracts.push(lastATContract);
        lastATLength = AdminToolsContracts.length;
        emit ATDeployed(lastATContract, msg.sender, block.number, lastATLength);
        return lastATContract;
    }

    // useful to know the row count in contracts index
    function getSingleAdminToolsContract(uint256 _index) public view returns(address singleContract) {
        return AdminToolsContracts[_index];
    }

}
