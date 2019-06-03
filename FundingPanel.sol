pragma solidity ^0.5.1;

import "./lib/SafeMath.sol";
import "./CustomOwnable.sol";
import "./IAdminTools.sol";
import "./Token.sol";
import "./IFundingPanel.sol";
import "./IERC20Seed.sol";

contract FundingPanel is CustomOwnable, IFundingPanel {
    using SafeMath for uint256;

    // address private owner;
    string private setDocURL;
    bytes32 private setDocHash;

    address public seedAddress;
    IERC20Seed private seedToken;
    Token private token;
    address public tokenAddress;
    IAdminTools private ATContract;
    address public ATAddress;

    uint8 public exchRateDecimals;
    uint8 public exchangeRateOnTop;
    uint8 public exchangeRateSeed;

    uint public factoryDeployIndex;

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
    event MintedImportedToken(uint256 newTokenAmount);

    constructor(string memory _setDocURL,
                bytes32 _setDocHash,
                uint8 _exchRateSeed,
                uint8 _exchRateOnTop,
                uint8 _exchRateDecim,
                address _seedTokenAddress,
                uint256 _seedMaxSupply,
                address _tokenAddress,
                address _ATAddress, uint _deployIndex) public {
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
    function getFactoryDeployIndex() public view returns(uint) {
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
    function addMemberToSet(address memberWallet, uint8 disabled, string memory memberURL,
                            bytes32 memberHash) public onlyFundingOperators returns (bool) {
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

    /**
     * @dev Import old tokens and mints the amount of this new token
     * @param _tokenAddress Token address to convert in this tokens
     * @param _tokenAmount Amount of old tokens to convert
     */
    function importOtherTokens(address _tokenAddress, uint256 _tokenAmount) public onlyOwner {
        require(token.isImportedContract(_tokenAddress), "Address not allowed!");
        require(token.getImportedContractRate(_tokenAddress) >= 0, "Rate exchange not allowed!");
        require(ATContract.isWhitelisted(msg.sender), "Wallet not whitelisted");
        uint256 newTokenAmount = _tokenAmount.mul(token.getImportedContractRate(_tokenAddress));
        uint256 holderBalanceToBe = token.balanceOf(msg.sender) + newTokenAmount;
        bool okToInvest = ATContract.isWhitelisted(msg.sender) && holderBalanceToBe <= ATContract.getMaxWLAmount(msg.sender) ? true :
                          holderBalanceToBe <= ATContract.getWLThresholdBalance() ? true : false;
        require(okToInvest, "Wallet Threshold too low");
        token.mint(msg.sender, newTokenAmount);
        emit MintedImportedToken(newTokenAmount);
    }
}