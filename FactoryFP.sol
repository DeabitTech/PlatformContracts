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

// File: d:/SEED/SeedPlatform/contracts/IToken.sol

interface IToken {
    function checkTransferAllowed (address from, address to, uint256 value) external view returns (byte);
    function checkTransferFromAllowed (address from, address to, uint256 value) external view returns (byte);
    function checkMintAllowed (address to, uint256 value) external pure returns (byte);
    function checkBurnAllowed (address account, uint256 value) external pure returns (byte);
}

// File: d:/SEED/SeedPlatform/contracts/Token.sol

contract Token is IToken, ERC20, CustomOwnable {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    IAdminTools private ATContract;
    address private ATAddress;

    byte private constant STATUS_ALLOWED = 0x11;
    byte private constant STATUS_DISALLOWED = 0x10;

    constructor(string memory name, string memory symbol, address _ATAddress) public {  // cap? pausable?
        _name = name;
        _symbol = symbol;
        _decimals = 18;
        ATAddress = _ATAddress;
        ATContract = IAdminTools(ATAddress);
    }

    modifier onlyMinterAddress() {
        require(ATContract.getMinterAddress() == msg.sender, "Address can not mint!");
        _;
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(checkTransferAllowed(msg.sender, _to, _value) == STATUS_ALLOWED, "transfer must be allowed");
        return ERC20.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(checkTransferFromAllowed(_from, _to, _value) == STATUS_ALLOWED, "transfer must be allowed");
        return ERC20.transferFrom(_from, _to,_value);
    }

    function mint(address _account, uint256 _amount) public onlyMinterAddress {
        require(checkMintAllowed(_account, _amount) == STATUS_ALLOWED, "mint must be allowed");
        ERC20._mint(_account, _amount);
    }

    function burn(address _account, uint256 _amount) public onlyMinterAddress {
        require(checkBurnAllowed(_account, _amount) == STATUS_ALLOWED, "burn must be allowed");
        ERC20._burn(_account, _amount);
    }

    function okToTransferTokens(address _holder, uint256 _amountToAdd) public view returns (bool){
        uint256 holderBalanceToBe = balanceOf(_holder) + _amountToAdd;
        bool okToTransfer = ATContract.isWhitelisted(_holder) && holderBalanceToBe <= ATContract.getMaxWLAmount(_holder) ? true :
                          holderBalanceToBe <= ATContract.getWLThresholdBalance() ? true : false;
        return okToTransfer;
    }

    function checkTransferAllowed (address _sender, address _receiver, uint256 _amount) public view returns (byte) {
        require(_sender != address(0), "Sender can not be 0!");
        require(_receiver != address(0), "Receiver can not be 0!");
        require(balanceOf(_sender) >= _amount, "Sender does not have enough tokens!");
        require(okToTransferTokens(_receiver, _amount), "Receiver not allowed to perform transfer!");
        return STATUS_ALLOWED;
    }

    function checkTransferFromAllowed (address _sender, address _receiver, uint256 _amount) public view returns (byte) {
        require(_sender != address(0), "Sender can not be 0!");
        require(_receiver != address(0), "Receiver can not be 0!");
        require(balanceOf(_sender) >= _amount, "Sender does not have enough tokens!");
        require(okToTransferTokens(_receiver, _amount), "Receiver not allowed to perform transfer!");
        return STATUS_ALLOWED;
    }

    function checkMintAllowed (address, uint256) public pure returns (byte) {
        //require(ATContract.isOperator(_minter), "Not Minter!");
        return STATUS_ALLOWED;
    }

    function checkBurnAllowed (address, uint256) public pure returns (byte) {
        // default
        return STATUS_ALLOWED;
    }

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

// File: d:/SEED/SeedPlatform/contracts/IERC20Seed.sol

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

// File: D:/SEED/SeedPlatform/contracts/FundingPanel.sol

contract FundingPanel is CustomOwnable, IFundingPanel {
    using SafeMath for uint256;

    // address private owner;
    string private setDocURL;
    bytes32 private setDocHash;

    address private seedAddress;
    IERC20Seed private seedToken;
    Token private token;
    address private tokenAddress;
    IAdminTools private ATContract;
    address private ATAddress;

    uint8 public exchRateDecimals;
    uint8 public exchangeRateOnTop;
    uint8 public exchangeRateSeed;

    uint8 public factoryDeployIndex;

    uint256 public seedMaxSupply;

    struct infoMember {
        bool isInserted;
        uint8 disabled; //0=enabled, 1=exit, 2=SetOwnerDisabled, 3=memberDisabled
        string memberURL;
        bytes32 memberHash;
        uint256 burnedTokens;
        uint listPointer;
    }
    mapping(address => infoMember) public membersArray; // mapping of members
    address[] public membersList; //array for counting or accessing in a sequencialing way the members

    event MemberAdded();
    event MemberRemoved();
    event MemberEnabled();
    event MemberDisabled();
    event MemberDisabledByMember();
    event MemberURLChanged();
    event MemberHashChanged();
    event TokenExchangeRateChanged();
    event TokenExchangeOnTopRateChanged();
    event TokenExchangeDecimalsChanged();
    event OwnerDataURLChanged();
    event OwnerDataHashChanged();
    event NewSeedMaxSupplyChanged();
    event MintedToken(uint256 amount, uint256 amountOnTop);
    event FundsUnlocked();
    event TokensBurnedForMember();

    constructor(string memory _setDocURL,
                bytes32 _setDocHash,
                uint8 _exchRateSeed,
                uint8 _exchRateOnTop,
                uint8 _exchRateDecim,
                address _seedTokenAddress,
                uint256 _seedMaxSupply,
                address _tokenAddress,
                address _ATAddress, uint8 _deployIndex) public {
        setDocURL = _setDocURL;
        setDocHash = _setDocHash;

        exchangeRateSeed = _exchRateSeed;
        exchangeRateOnTop = _exchRateOnTop;
        exchRateDecimals = _exchRateDecim;

        factoryDeployIndex = _deployIndex;

        uint256 multiplier = 10 ** 18;
        seedMaxSupply = _seedMaxSupply.mul(uint256(multiplier));

        tokenAddress = _tokenAddress;
        ATAddress = _ATAddress;
        seedAddress = _seedTokenAddress;
        seedToken = IERC20Seed(seedAddress);
        token = Token(tokenAddress);
        ATContract = IAdminTools(ATAddress);
    }


/**************** Modifiers ***********/

    modifier onlyMemberEnabled() {
        require(membersArray[msg.sender].isInserted && membersArray[msg.sender].disabled==0, "Member not present or not enabled");
        _;
    }

    modifier whitelistedOnly(address holder) {
        require(ATContract.isWhitelisted(holder), "Investor is not whitelisted!");
        _;
    }

    modifier holderEnabledInSeeds(address _holder, uint256 _seedAmountToAdd) {
        uint256 amountInTokens = getTokenExchangeAmount(_seedAmountToAdd);
        uint256 holderBalanceToBe = token.balanceOf(_holder) + amountInTokens;
        bool okToInvest = ATContract.isWhitelisted(_holder) && holderBalanceToBe <= ATContract.getMaxWLAmount(_holder) ? true :
                          holderBalanceToBe <= ATContract.getWLThresholdBalance() ? true : false;
        require(okToInvest, "Investor not allowed to perform operations!");
        _;
    }

    modifier onlyFundingOperators() {
        require(ATContract.isFundingOperator(msg.sender), "Not an authorized operator!");
        _;
    }

    modifier onlyFundsUnlockerOperators() {
        require(ATContract.isFundsUnlockerOperator(msg.sender), "Not an authorized operator!");
        _;
    }

    /**
     * @dev get Factory Deploy Index
     * @return uint8 index
     */
    function getFactoryDeployIndex() public view returns(uint8) {
        return factoryDeployIndex;
    }

    /**
     * @dev find if a member is inserted
     * @return bool for success
     */
    function isMemberInserted(address memberWallet) public view returns(bool isIndeed) {
        return membersArray[memberWallet].isInserted;
    }

    /**
     * @dev only operator members can add a member
     * @return bool for success
     */
    function addMemberToSet(address memberWallet, uint8 disabled, string memory memberURL, bytes32 memberHash) public onlyFundingOperators returns (bool) {
        require(!isMemberInserted(memberWallet), "Member already inserted!");
        uint memberPlace = membersList.push(memberWallet) - 1;
        infoMember memory tmpStUp = infoMember(true, disabled, memberURL, memberHash, 0, memberPlace);
        membersArray[memberWallet] = tmpStUp;
        emit MemberAdded();
        return true;
    }

    /**
     * @dev only operator members can delete a member
     * @return bool for success
     */
/*    function deleteMemberFromSet(address memberWallet) public onlyFundingOperators returns (bool) {
        require(isMemberInserted(memberWallet), "Member to delete not found!");
        membersArray[memberWallet].isInserted = false;
        uint rowToDelete = membersArray[memberWallet].listPointer;
        address keyToMove = membersList[membersList.length-1];
        membersList[rowToDelete] = keyToMove;
        membersArray[keyToMove].listPointer = rowToDelete;
        membersList.length--;
        emit MemberRemoved();
        return true;
    }*/

    /**
     * @return get the number of inserted members in the set
     */
    function getMembersNumber() public view returns (uint) {
        return membersList.length;
    }

    /**
     * @dev only operator memebers can enable a member
     */
    function enableMember(address _memberAddress) public onlyFundingOperators {
        require(membersArray[_memberAddress].isInserted, "Member not present");
        membersArray[_memberAddress].disabled = 0;
        emit MemberEnabled();
    }

    /**
     * @dev operator members can disable an already inserted member
     */
    function disableMemberByStaffRetire(address _memberAddress) public onlyFundingOperators {
        require(membersArray[_memberAddress].isInserted, "Member not present");
        membersArray[_memberAddress].disabled = 2;
        emit MemberDisabled();
    }

    /**
     * @dev operator members can disable an already inserted member
     */
    function disableMemberByStaffForExit(address _memberAddress) public onlyFundingOperators {
        require(membersArray[_memberAddress].isInserted, "Member not present");
        membersArray[_memberAddress].disabled = 1;
        emit MemberDisabled();
    }

    /**
     * @dev member can disable itself if already inserted and enabled
     */
    function disableMemberByMember(address _memberAddress) public onlyMemberEnabled {
        membersArray[_memberAddress].disabled = 3;
        emit MemberDisabledByMember();
    }

    /**
     * @dev operator members can change URL of an already inserted member
     */
    function changeMemberURL(address _memberAddress, string memory newURL) public onlyFundingOperators {
        require(membersArray[_memberAddress].isInserted, "Member not present");
        membersArray[_memberAddress].memberURL = newURL;
        emit MemberURLChanged();
    }

    /**
     * @dev operator members can change hash of an already inserted member
     */
    function changeMemberHash(address _memberAddress, bytes32 newHash) public onlyFundingOperators {
        require(membersArray[_memberAddress].isInserted, "Member not present");
        membersArray[_memberAddress].memberHash = newHash;
        emit MemberHashChanged();
    }

    /**
     * @dev operator members can change the rate exchange of the set
     */
    function changeTokenExchangeRate(uint8 newExchRate) external onlyFundingOperators {
        require(newExchRate > 0, "Wrong exchange rate!");
        exchangeRateSeed = newExchRate;
        emit TokenExchangeRateChanged();
    }

    /**
     * @dev operator members can change the rate exchange on top of the set
     */
    function changeTokenExchangeOnTopRate(uint8 newExchRate) external onlyFundingOperators {
        require(newExchRate > 0, "Wrong exchange rate on top!");
        exchangeRateOnTop = newExchRate;
        emit TokenExchangeOnTopRateChanged();
    }

    /**
     * @dev operator members can change the decimals of the set rate exchange
     */
    function changeTokenExchangeDecimals(uint8 newDecimals) external onlyFundingOperators {
        require(newDecimals >= 0, "Wrong decimals for exchange rate!");
        exchRateDecimals = newDecimals;
        emit TokenExchangeDecimalsChanged();
    }

    /**
     * @dev Shows the amount of tokens the user will receive for amount of Seed token
     * @param _Amount Exchanged seed tokens amount to convert
     * @return The amount of token that will be received
     */
    function getTokenExchangeAmount(uint256 _Amount) internal view returns(uint256) {
        require(_Amount > 0, "Amount must be greater than 0!");
        return _Amount.mul(exchangeRateSeed).div(10 ** uint256(exchRateDecimals));
    }

    /**
     * @dev Shows the amount of token the owner will receive for amount of Seed token
     * @param _Amount Exchanged chong amount to convert
     * @return The amount of set Token that will be received
     */
    function getTokenExchangeAmountOnTop(uint256 _Amount) internal view returns(uint256) {
        require(_Amount > 0, "Amount must be greater than 0!");
        return _Amount.mul(exchangeRateOnTop).div(10 ** uint256(exchRateDecimals));
    }

    /**
     * @return get the set token address
     */
    function getTokenAddress() public view returns (address) {
        return tokenAddress;
    }

    /**
     * @return get the operator members URL and hash
     */
    function getOwnerData() public view returns (string memory, bytes32) {
        return (setDocURL, setDocHash);
    }

    /**
     * @dev set the owner URL
     */
    function setOwnerDataURL(string memory _dataURL) public onlyOwner {
        setDocURL = _dataURL;
        emit OwnerDataURLChanged();
    }

    /**
     * @dev set the owner hash
     */
    function setOwnerDataHash(bytes32 _dataHash) public onlyOwner {
        setDocHash = _dataHash;
        emit OwnerDataHashChanged();
    }

    /**
     * @return get the operator members URL and hash
     */
    function getMemberAddressByIndex(uint8 _index) public view returns (address) {
        return membersList[_index];
    }

    function getMemberDataByAddress(address _memberWallet) public view returns (bool, uint8, string memory, bytes32, uint256, uint) {
        require(membersArray[_memberWallet].isInserted, "Member not inserted");
        return(membersArray[_memberWallet].isInserted, membersArray[_memberWallet].disabled, membersArray[_memberWallet].memberURL,
                membersArray[_memberWallet].memberHash, membersArray[_memberWallet].burnedTokens, membersArray[_memberWallet].listPointer); // mapping of members
    }

    /**
     * @dev change the max Supply of SEED
     */
    function setNewSeedMaxSupply(uint256 _newMaxSeedSupply) public onlyFundingOperators returns (uint256) {
        seedMaxSupply = _newMaxSeedSupply;
        emit NewSeedMaxSupplyChanged();
        return seedMaxSupply;
    }

    /**
     * @return get the number of Seed token inside the contract
     */
    function getTotalRaised() public view returns (uint256) {
        return seedToken.balanceOf(address(this));
    }

    /**
     * @dev get the number of Seed token inside the contract an mint new tokens forthe holders and the wallet "On Top"
     * @notice msg.sender has to approve transfer the tokens BEFORE calling this function
     */
    function holderSendSeeds(uint256 _seeds) public holderEnabledInSeeds(msg.sender, _seeds) {
        require(seedToken.balanceOf(address(this)) + _seeds <= seedMaxSupply, "Maximum supply reached!");
        require(seedToken.balanceOf(msg.sender) >= _seeds, "Not enough seeds in holder wallet");
        address walletOnTop = ATContract.getWalletOnTopAddress();
        require(ATContract.isWhitelisted(walletOnTop), "Owner wallet not whitelisted");
        seedToken.transferFrom(msg.sender, address(this), _seeds);

        //apply conversion seed/set token
        uint256 amount = getTokenExchangeAmount(_seeds);
        token.mint(msg.sender, amount);

        uint256 amountOnTop = getTokenExchangeAmountOnTop(_seeds);
        token.mint(walletOnTop, amountOnTop);
        emit MintedToken(amount, amountOnTop);
    }

    /**
     * @dev Funds unlock by operator members
     */
    function unlockFunds(address memberWallet, uint256 amount) external onlyFundsUnlockerOperators {
         require(seedToken.balanceOf(address(this)) >= amount, "Not enough seeds to unlock!");
         require(membersArray[memberWallet].isInserted && membersArray[memberWallet].disabled==0, "Member not present or not enabled");
         //seedToken.transferFrom(address(this), memberWallet, amount);

         seedToken.transfer(memberWallet, amount);
         emit FundsUnlocked();
    }

    /**
     * @dev Burn tokens for members
     */
    function burnTokensForMember(address memberWallet, uint256 amount) public {
         require(token.balanceOf(msg.sender) >= amount, "Not enough tokens to burn!");
         require(membersArray[memberWallet].isInserted && membersArray[memberWallet].disabled==0, "Member not present or not enabled");
         membersArray[memberWallet].burnedTokens = membersArray[memberWallet].burnedTokens.add(amount);
         token.burn(msg.sender, amount);
         emit TokensBurnedForMember();
    }
}

// File: D:/SEED/SeedPlatform/contracts/IFactoryFP.sol

interface IFactoryFP {
    function getDeployFPFees() external view returns(uint256);
    function getFundingPanelContractCount() external view returns(uint);
    function newFundingPanel(string calldata, bytes32, uint8, uint8, uint8, address, uint256, address, address) external returns(address);
    function getSingleFundingPanelContract(uint256) external view returns(address);
}

// File: contracts\FactoryFP.sol

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

contract FactoryFP is CustomOwnable, IFactoryFP {
    using AddressUtil for address;

    address[] public FundingPanelContracts;

    address public lastFundingPanelContract;

    uint public lastFundingPanelLength;

    uint256 public deployFPFees;
    address public feeCollectorFP;

    IERC20Seed public seedContract;

    event FundingPanelDeployed(address indexed lastFundingPanelContract, address indexed ownerAddress, uint deployedBlock, uint FPLength);
    event DeployFPFeesChanged();
    event FeeCollectorFPChanged();

    constructor(address _seedContract, uint256 _deployFPFees, address _feeCollector) public{
        seedContract = IERC20Seed(_seedContract);  // change with SEED address
        deployFPFees = _deployFPFees;
        feeCollectorFP = _feeCollector;
    }

    function getDeployFPFees() public view returns(uint256) {
        return deployFPFees;
    }

    function changeDeployFPFees (uint256 _newAmount) public onlyOwner {
        require(_newAmount >= 0, "Deploy fees not suitable!");
        require(_newAmount != deployFPFees, "Deploy fees not changed!");
        deployFPFees = _newAmount;
        emit DeployFPFeesChanged();
    }

    function changeFeeCollector (address _newCollector) public onlyOwner {
        require(_newCollector != address(0), "Collector address not suitable!");
        require(_newCollector != feeCollectorFP, "Collector address not changed!");
        feeCollectorFP = _newCollector;
        emit FeeCollectorFPChanged();
    }

    // useful to know the row count in contracts index
    function getFundingPanelContractCount() public view returns(uint contractCount) {
        return FundingPanelContracts.length;
    }

    /**
     * @dev deploy a new Funding Panel contract
     * @notice msg.sender has to approve this contract to spend deployFPFees SEED tokens BEFORE calling this function
     */
    function newFundingPanel(string memory _setDocURL,
                bytes32 _setDocHash,
                uint8 _exchRateSeed,
                uint8 _exchRateOnTop,
                uint8 _exchRateDecim,
                address _seedTokenAddress,
                uint256 _seedMaxSupply,
                address _tokenAddress,
                address _ATAddress) public returns(address newContract) {
        require(msg.sender != address(0), "Sender Address is zero");
        require(seedContract.balanceOf(msg.sender) > deployFPFees, "Not enough Seed Tokens to deploy AT!");
        address temp = msg.sender;
        require(!temp.isContract(), "Sender Address is a contract");
        require(feeCollectorFP != address(0), "Sender Address is zero");
        require(!feeCollectorFP.isContract(), "Fee Collector is a contract!");
        seedContract.transferFrom(msg.sender, feeCollectorFP, deployFPFees);
        FundingPanel c = new FundingPanel(_setDocURL, _setDocHash, _exchRateSeed, _exchRateOnTop, _exchRateDecim,
                                              _seedTokenAddress, _seedMaxSupply, _tokenAddress, _ATAddress, uint8(FundingPanelContracts.length));
        lastFundingPanelContract = address(c);
        c.transferOwnership(msg.sender);
        FundingPanelContracts.push(lastFundingPanelContract);
        lastFundingPanelLength = FundingPanelContracts.length;
        emit FundingPanelDeployed(lastFundingPanelContract, msg.sender, block.number, lastFundingPanelLength);
        return lastFundingPanelContract;
    }

    // useful to know the row count in contracts index
    function getSingleFundingPanelContract(uint256 _index) public view returns(address singleContract) {
        return FundingPanelContracts[_index];
    }

}
