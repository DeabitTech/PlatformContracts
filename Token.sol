pragma solidity ^0.5.2;

import "./lib/ERC20.sol";
import "./lib/Ownable.sol";
import "./IAdminTools.sol";
import "./IToken.sol";

contract Token is IToken, ERC20, Ownable {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    IAdminTools private ATContract;
    address private ATAddress;

    byte private constant STATUS_ALLOWED = 0x11;
    byte private constant STATUS_DISALLOWED = 0x10;

    bool private _paused;

    struct contractsFeatures {
        bool permission;
        uint256 tokenRateExchange;
    }

    mapping(address => contractsFeatures) private contractsToImport;

    event Paused(address account);
    event Unpaused(address account);

    constructor(string memory name, string memory symbol, address _ATAddress) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
        ATAddress = _ATAddress;
        ATContract = IAdminTools(ATAddress);
        _paused = false;
    }

    modifier onlyMinterAddress() {
        require(ATContract.getMinterAddress() == msg.sender, "Address can not mint!");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Token Contract paused...");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Token Contract not paused");
        _;
    }

    /**
     * @return the name of the token.
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() external view returns (bool) {
        return _paused;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() external onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() external onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    /**
     * @dev check if the contract can be imported to change with this token.
     * @param _contract address of token to be imported
     */
    function isImportedContract(address _contract) external view returns (bool) {
        return contractsToImport[_contract].permission;
    }

    /**
     * @dev get the exchange rate between token to be imported and this token.
     * @param _contract address of token to be exchange
     */
    function getImportedContractRate(address _contract) external view returns (uint256) {
        return contractsToImport[_contract].tokenRateExchange;
    }

    /**
     * @dev set the address of the token to be imported and its exchange rate.
     * @param _contract address of token to be imported
     * @param _exchRate exchange rate between token to be imported and this token.
     */
    function setImportedContract(address _contract, uint256 _exchRate) external onlyOwner {
        require(_contract != address(0), "Address not allowed!");
        require(_exchRate >= 0, "Rate exchange not allowed!");
        contractsToImport[_contract].permission = true;
        contractsToImport[_contract].tokenRateExchange = _exchRate;
    }

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        require(checkTransferAllowed(msg.sender, _to, _value) == STATUS_ALLOWED, "transfer must be allowed");
        return ERC20.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        require(checkTransferFromAllowed(_from, _to, _value) == STATUS_ALLOWED, "transfer must be allowed");
        return ERC20.transferFrom(_from, _to,_value);
    }

    function mint(address _account, uint256 _amount) public whenNotPaused onlyMinterAddress {
        require(checkMintAllowed(_account, _amount) == STATUS_ALLOWED, "mint must be allowed");
        ERC20._mint(_account, _amount);
    }

    function burn(address _account, uint256 _amount) public whenNotPaused onlyMinterAddress {
        require(checkBurnAllowed(_account, _amount) == STATUS_ALLOWED, "burn must be allowed");
        ERC20._burn(_account, _amount);
    }

    /**
     * @dev check if the SEED sender address could receive new tokens.
     * @param _holder address of the SEED sender
     * @param _amountToAdd amount of tokens to be added to sender balance.
     */
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

