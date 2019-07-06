pragma solidity ^0.5.2;


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


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
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
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

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


interface IAdminTools {
    function isFundingOperator(address) external view returns (bool);
    function isFundsUnlockerOperator(address) external view returns (bool);
    function setFFPAddresses(address, address) external;
    function setMinterAddress(address) external returns(address);
    function getMinterAddress() external view returns(address);
    function getWalletOnTopAddress() external view returns (address);
    function isWhitelisted(address) external view returns(bool);
    function getWLThresholdBalance() external view returns (uint256);
    function getMaxWLAmount(address) external view returns(uint256);
    function addWLManagers(address account) external;
    function addFundingManagers(address account) external;
    function addFundsUnlockerManagers(address account) external;
    function addToWhitelist(address _subscriber, uint256 _maxAmnt) external;
    function removeWLManagers(address account) external;
}


interface IFactory {
    function changeATFactoryAddress(address) external;
    function changeTDeployerAddress(address) external;
    function changeFPDeployerAddress(address) external;
    function deployPanelContracts(string calldata, string calldata, string calldata, bytes32, uint8, uint8, uint256, uint256) external;
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


interface IFundingPanel {
    function getFactoryDeployIndex() external view returns(uint);
    function isMemberInserted(address) external view returns(bool);
    function getMembersNumber() external view returns (uint);
    function getMemberAddressByIndex(uint8) external view returns (address);
}


contract AdminTools is Ownable, IAdminTools {
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
    address public FAddress;
    IFactory public FContract;

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
    event MinterOrigins();
    event MinterChanged();
    event WalletOnTopAddressChanged();
    event LogWLThresholdBalanceChanged();
    event LogWLAddressAdded();
    event LogWLMassiveAddressesAdded();
    event LogWLAddressRemoved();

    constructor (uint256 _whitelistThresholdBalance) public {
        whitelistThresholdBalance = _whitelistThresholdBalance.mul(10**18);
    }

    function setFFPAddresses(address _factoryAddress, address _FPAddress) public onlyOwner {
        FAddress = _factoryAddress;
        FContract = IFactory(FAddress);
        FPAddress = _FPAddress;
        FPContract = IFundingPanel(FPAddress);
        emit MinterOrigins();
    }

    /* Token Minter address, to set like Funding Panel address */
    function getMinterAddress() public view returns(address) {
        return _minterAddress;
    }

    function setMinterAddress(address _minter) public onlyOwner returns(address) {
        require(_minter != address(0), "Not valid minter address!");
        require(_minter != _minterAddress, " No change in minter contract");
        require(FAddress != address(0), "Not valid factory address!");
        require(FPAddress != address(0), "Not valid FP Contract address!");
        require(FContract.getFPAddressByIndex(FPContract.getFactoryDeployIndex()) == _minter,
                        "Minter is not a known funding panel!");
        _minterAddress = _minter;
        emit MinterChanged();
        return _minterAddress;
    }

    /* Wallet receiving extra minted tokens (percentage) */
    function getWalletOnTopAddress() public view returns (address) {
        return _walletOnTopAddress;
    }

    function setWalletOnTopAddress(address _wallet) public onlyOwner returns(address) {
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
     * @dev Add the subscriber list to the whitelist (max 100)
     * @param _subscriber The subscriber list to add to the whitelist.
     * @param _maxAmnt max amount list that a subscriber can hold (in set tokens).
     */
    function addToWhitelistMassive(address[] memory _subscriber, uint256[] memory _maxAmnt) public onlyWLOperators returns (bool _success) {
        assert(_subscriber.length == _maxAmnt.length);
        assert(_subscriber.length <= 100);

        for (uint8 i = 0; i < _subscriber.length; i++) {
            require(_subscriber[i] != address(0), "_subscriber is zero");
            require(!whitelist[_subscriber[i]].permitted, "already whitelisted");

            whitelistLength++;

            whitelist[_subscriber[i]].permitted = true;
            whitelist[_subscriber[i]].maxAmount = _maxAmnt[i];
        }

        emit LogWLMassiveAddressesAdded();
        return true;
    }

    /**
     * @dev Remove the subscriber from the whitelist.
     * @param _subscriber The subscriber remove from the whitelist.
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


interface IATDeployer {
    function newAdminTools(uint256) external returns(address);
    function setFactoryAddress(address) external;
    function getFactoryAddress() external view returns(address);
}


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
        require(block.number < 5998000, "Time expired!");  //ropsten (Jul 15)
        //require(block.number < 9500000, "Time expired!");  //mainnet
        //https://codepen.io/adi0v/full/gxEjeP/  Fri Feb 07 2020 11:45:55 GMT+0100 (Ora standard dell’Europa centrale)
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
