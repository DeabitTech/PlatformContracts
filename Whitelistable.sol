pragma solidity ^0.5.2;

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

// File: contracts\Whitelistable.sol

//import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title Whitelistable
 * @dev Base contract implementing a whitelist to keep track of holders.
 * The construction parameters allow for both whitelisted and non-whitelisted contracts:
 * 1) maxWhitelistLength = 0 and whitelistThresholdBalance > 0: whitelist disabled
 * 2) maxWhitelistLength > 0 and whitelistThresholdBalance = 0: whitelist enabled, full whitelisting
 * 3) maxWhitelistLength > 0 and whitelistThresholdBalance > 0: whitelist enabled, partial whitelisting
 */
contract Whitelistable {
    using SafeMath for uint256;

    event LogWLThresholdBalanceChanged(address indexed caller, uint256 indexed whitelistThresholdBalance);
    event LogWLAddressAdded(address indexed caller, address indexed subscriber, uint256 maxAmount);
    event LogWLAddressRemoved(address indexed caller, address indexed subscriber);

    struct wlVars {
        bool permitted;
        uint256 maxAmount;
    }

    mapping (address => wlVars) private whitelist;

    uint256 private whitelistLength;

    uint256 private whitelistThresholdBalance;

    event StafferAdded(address indexed account);
    event StafferRemoved(address indexed account);

    mapping (address => bool) private _staffers;

    constructor(uint256 _whitelistThresholdBalance) public {
        _addStaffer(msg.sender);
        whitelistThresholdBalance = _whitelistThresholdBalance.mul(10**18);
    }

    modifier onlyStaffer() {
        require(isStaffer(msg.sender));
        _;
    }

    function isStaffer(address account) public view returns (bool) {
        return _staffers[account];
    }

    function addStaffer(address account) public onlyStaffer {
        _addStaffer(account);
    }

    function renounceStaffer() public {
        _removeStaffer(msg.sender);
    }

    function _addStaffer(address account) internal {
        _staffers[account] = true;
        emit StafferAdded(account);
    }

    function _removeStaffer(address account) internal {
        _staffers[account] = false;
        emit StafferRemoved(account);
    }

    /**
     * @return true if subscriber is whitelisted, false otherwise
     */
    function isWhitelisted(address _subscriber) public view returns(bool isReallyWhitelisted) {
        return whitelist[_subscriber].permitted;
    }

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
     * @return maxAmount for holder
     */
    function getWLLength() public view returns(uint256) {
        return whitelistLength;
    }
    
    /**
     * @return maxAmount for holder
     */
    function setNewThresholdInternal(uint256 _newThreshold) external onlyStaffer {
        require(_newThreshold == whitelistThresholdBalance, "New Threshold like the old one!");
        whitelistThresholdBalance = _newThreshold;
        emit LogWLThresholdBalanceChanged(msg.sender, whitelistThresholdBalance);
    }

    /**
     * @return change maxAmount for holder
     */
    function changeMaxWLAmountInternal(address _subscriber, uint256 newMaxToken) external onlyStaffer {
        whitelist[_subscriber].maxAmount = newMaxToken;
    }

    function addToWhitelistInternal(address _subscriber, uint256 _maxAmnt) external onlyStaffer {
        require(_subscriber != address(0), "_subscriber is zero");
        require(!whitelist[_subscriber].permitted, "already whitelisted");

        whitelistLength++;

        whitelist[_subscriber].permitted = true;
        whitelist[_subscriber].maxAmount = _maxAmnt;

        emit LogWLAddressAdded(msg.sender, _subscriber, _maxAmnt);
    }

    function removeFromWhitelistInternal(address _subscriber, uint256 _balance) external onlyStaffer {
        require(_subscriber != address(0), "_subscriber is zero");
        require(whitelist[_subscriber].permitted, "not whitelisted");
        require(_balance <= whitelistThresholdBalance, "_balance greater than whitelist threshold");

        whitelistLength--;

        whitelist[_subscriber].permitted = false;
        whitelist[_subscriber].maxAmount = 0;

        emit LogWLAddressRemoved(msg.sender, _subscriber);
    }

}
