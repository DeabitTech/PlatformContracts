pragma solidity ^0.5.1;

import "./lib/SafeMath.sol";
import "./CustomOwnable.sol";
import "./IAdminTools.sol";
import "./IFactory.sol";
import "./IFundingPanel.sol";

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

    constructor(uint256 _whitelistThresholdBalance) public {
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