pragma solidity ^0.5.2;

// File: D:/SEED/SeedPlatform/node_modules/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: D:/SEED/SeedPlatform/node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://eips.ethereum.org/EIPS/eip-20
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return A uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
     * @dev Transfer token to a specified address
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when _allowed[msg.sender][spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when _allowed[msg.sender][spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Transfer token for a specified addresses
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Approve an address to spend another addresses' tokens.
     * @param owner The address that owns the tokens.
     * @param spender The address that will spend the tokens.
     * @param value The number of tokens that can be spent.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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
        require(isOwner());
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
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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

// File: D:/SEED/SeedPlatform/contracts/Whitelistable.sol

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

// File: contracts\SetFundingPool.sol

//import "./SetERC20.sol";

/*
fabbisogno set in seed poi calcolo con exchange rate non c'e' max supply (dichiarato dall'incubatore e variabile)
mint per set dinamici
Funzione di sblocco seed verso le member (si devono accettare gli eth per i trasferimenti di sblocco!!!)
Sblocco seed verso member a giudizio dell'incubatore o di delegato (ruolo)
Incubatore: address, url e hash del documento di business
Member: address, url e hash del documento della member + enabled (enabled modificabile dalla member e dall'incubatore)

Selezione: impostazione voting con contratto esterno su balanceof per lista holders con diritto di voto
*/

contract SetFundingPool is Ownable {
    using SafeMath for uint256;

    // address private owner;
    string private setDocURL;
    string private setDocHash;
    //bytes32 private setDocHash;

    ERC20 private seedToken;
    ERC20 private setToken;
    address private setTokenSetAddress;
    Whitelistable private WLContract;
    address private setWLAddress;

    uint256 private seedMaxSupply;  // can it be changed?

    uint256 private exchangeRate;

    uint private deployBlock;

    struct infoMember {
        bool isInserted;
        bool enabled; 
        string memberURL; 
        string memberHash; 
        //bytes32 memberHash;
        uint listPointer;
    }
    mapping(address => infoMember) private membersArray; // mapping of members
    address[] membersList; //array for counting or accessing in a sequencialing sequencially way the members

    constructor(string memory _setDocURL, 
                string memory _setDocHash, 
                uint256 _exchRate, 
                uint256 _seedMaxSupply, 
                address _seedTokenAddress, 
                address _setTokenSetAddress,
                address _setWLAddress) public {
        setDocURL = _setDocURL;
        setDocHash = _setDocHash;
        exchangeRate = _exchRate;
        seedMaxSupply = _seedMaxSupply;
        setTokenSetAddress = _setTokenSetAddress;
        setWLAddress = _setWLAddress;
        seedToken = ERC20(_seedTokenAddress);
        setToken = ERC20(setTokenSetAddress);
        WLContract = Whitelistable(setWLAddress);
        deployBlock = block.number;  // block number that creates the contract
    }


/**************** Modifiers ***********/

    modifier byMemberEnabledOnly() {
        require(membersArray[msg.sender].isInserted && membersArray[msg.sender].enabled, "Member not present or not enabled");
        _;
    }

    modifier whitelistedOnly(address holder) {
        require(WLContract.isWhitelisted(holder), "Investor is not whitelisted!");
        _;
    }

    modifier holderEnabled(address holder, uint256 amountToAdd) {
        uint256 holderBalanceToBe = setToken.balanceOf(holder) + amountToAdd;
        bool okToInvest = holderBalanceToBe <= WLContract.getMaxWLAmount(holder) && WLContract.isWhitelisted(holder) ? true :
                          holderBalanceToBe <= WLContract.getWLThresholdBalance() ? true : false;
        require(okToInvest, "Investor not allowed to perform operations!");
        _;
    }

    modifier onlyStaffer() {
        require(WLContract.isStaffer(msg.sender));
        _;
    }

    /**
     * @dev staff members can change the set token address
     */
    function changeSetToken(address _setTokenSetAddress) public onlyStaffer {
        require(_setTokenSetAddress != address(0), "Invalid Address");
        require(_setTokenSetAddress == setTokenSetAddress, "No new set Token address");
        setTokenSetAddress = _setTokenSetAddress;
        setToken = ERC20(setTokenSetAddress);
    }

    /**
     * @dev find if a member is inserted
     * @return bool for success
     */
    function isMemberInserted(address memberWallet) public view returns(bool isIndeed) {
        return membersArray[memberWallet].isInserted;
    }

    /**
     * @dev only staff members can add a member
     * @return bool for success
     */
    function addMemberToSet(address memberWallet, bool enabled, string memory memberURL, string memory memberHash) public onlyStaffer returns (bool) {
        require(!isMemberInserted(memberWallet), "Member already inserted!");
        uint memberPlace = membersList.push(memberWallet) - 1;
        infoMember memory tmpStUp = infoMember(true, enabled, memberURL, memberHash, memberPlace); 
        membersArray[memberWallet] = tmpStUp;
        return true;
    }

    /**
     * @dev only staff members can delete a member
     * @return bool for success
     */
    function deleteMemberFromSet(address memberWallet) public onlyStaffer returns (bool) {
        require(isMemberInserted(memberWallet), "Member to delete not found!");
        uint rowToDelete = membersArray[memberWallet].listPointer;
        address keyToMove = membersList[membersList.length-1];
        membersList[rowToDelete] = keyToMove;
        membersArray[keyToMove].listPointer = rowToDelete;
        membersList.length--;
        return true;
    }



    /**
     * @return get the number of inserted members in the set
     */
    function getMemberNumber() public view returns (uint) {
        return membersList.length;
    }

    /**
     * @dev only staff memebers can enable a member
     */
    function enableMember(address _memberAddress) public onlyStaffer {
        require(membersArray[_memberAddress].isInserted, "Member not present"); 
        membersArray[_memberAddress].enabled = true;
    }

    /**
     * @dev staff members can disable an already inserted member
     */
    function disableMemberByStaff(address _memberAddress) public onlyStaffer {
        require(membersArray[_memberAddress].isInserted, "Member not present"); 
        membersArray[_memberAddress].enabled = false;
    }

    /**
     * @dev member can disable itself if already inserted and enabled 
     */
    function disableMemberByMember(address _memberAddress) public byMemberEnabledOnly {
        membersArray[_memberAddress].enabled = false;
    }

    /**
     * @dev staff members can change URL of an already inserted member
     */
    function changeMemberURLByStaff(address _memberAddress, string memory newURL) public onlyStaffer {
        require(membersArray[_memberAddress].isInserted, "Member not present"); 
        membersArray[_memberAddress].memberURL = newURL;
    }

    /**
     * @dev member can change URL by itself if already inserted and enabled 
     */
    function changeMemberURLByMember(address _memberAddress, string memory newURL) public byMemberEnabledOnly {
        membersArray[_memberAddress].memberURL = newURL;
    }

    /**
     * @dev staff members can change hash of an already inserted member
     */
    function changeMemberHashByStaff(address _memberAddress, string memory newHash) public onlyStaffer {
        require(membersArray[_memberAddress].isInserted, "Member not present"); 
        membersArray[_memberAddress].memberHash = newHash;
    }

    /**
     * @dev member can change hash by itself if already inserted and enabled 
     */
    function changeMemberHashByMember(address _memberAddress, string memory newHash) public byMemberEnabledOnly {
        membersArray[_memberAddress].memberURL = newHash;
    }

    /**
     * @dev staff members can change the rate exchange of the set
     */
    function changeTokenExchangeAmount(uint256 newExchRate) external onlyStaffer {
        require(newExchRate > 0, "Wrong exchange rate!");
        exchangeRate = newExchRate;
    }

    /** 
     * @dev Shows the amount of set Token the user will receive for amount of Seed token
     * @param _Amount Exchanged chong amount to convert
     * @return The amount of set Token that will be received
     */
    function getTokenExchangeAmount(uint256 _Amount) internal view returns(uint256) {
        require(_Amount > 0);
        return _Amount.mul(exchangeRate);
    }

    /**
     * @return get the set token address
     */
    function getTokenSetAddress() public view returns (address) {
        return setTokenSetAddress;
    }

    /**
     * @return get the staff members URL and hash
     */
    function getOwnerData() public view returns (string memory, string memory) {
        return (setDocURL, setDocHash);
    }

    /**
     * @return get the number of Seed token inside the contract
     */
    function getTotalRaised() public view returns (uint256) {
        return seedToken.balanceOf(address(this));
    }

    /**
     * Add the subscriber to the whitelist.
     * @param subscriber The subscriber to add to the whitelist.
     */
    function addToWhitelist(address subscriber, uint256 maxAmount) external onlyStaffer {
        WLContract.addToWhitelistInternal(subscriber, maxAmount);
    }

    /**
     * Removed the subscriber from the whitelist.
     * @param subscriber The subscriber to remove from the whitelist.
     */
    function removeFromWhitelist(address subscriber) external onlyStaffer {
        WLContract.removeFromWhitelistInternal(subscriber, seedToken.balanceOf(subscriber));
    }

    /**
     * @dev only staff members can change the threshold
     */    
    function staffSetThreshold(uint256 _newThr) public onlyStaffer {
        WLContract.setNewThresholdInternal(_newThr);
    }

    /**
     * Change Max amount in Seeds for the subscriber in the whitelist.
     * @param subscriber The subscriber to change
     * @param newMaxToken the new amount for the subcriber
     */
    function changeMaxSubscriberAmount(address subscriber, uint256 newMaxToken) external onlyStaffer {
        require(WLContract.isWhitelisted(subscriber), "Investor is not whitelisted!");
        require(newMaxToken != WLContract.getMaxWLAmount(subscriber), "NewMax equal to old MaxAmount");
        WLContract.changeMaxWLAmountInternal(subscriber, newMaxToken);
    }

    /**
     * @dev get the number of Seed token inside the contract
     * @notice owner have to mint tokens BEFORE it can transfer them to holder
     */
    function holderSendSeeds(uint256 _seeds) public holderEnabled(msg.sender, _seeds) {
        require(seedToken.balanceOf(address(this)) + _seeds <= seedMaxSupply, "Maximum supply reached!");
        require(seedToken.balanceOf(msg.sender) >= _seeds, "Not enough seeds in holder wallet");

        //apply conversion seed/set token
        uint256 amount = getTokenExchangeAmount(_seeds);
        address operator = owner();
        require(setToken.balanceOf(operator) >= amount, "Incubator does not have enough tokens to send!");

        seedToken.transferFrom(msg.sender, address(this), _seeds);

        //setToken.mint( msg.sender, amount);
        setToken.transferFrom(operator, msg.sender, amount);
    }

    /**
     * @dev Funds unlock by staff members 
     */
     function unlockFunds(address memberWallet, uint256 amount) external onlyStaffer {
         require(seedToken.balanceOf(address(this)) >= amount, "Not enough seeds to unlock!");
         require(membersArray[memberWallet].isInserted && membersArray[memberWallet].enabled, "Member not present or not enabled");
         seedToken.transferFrom(address(this), memberWallet, amount);
     }


}
