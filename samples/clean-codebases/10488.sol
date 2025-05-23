// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);
    
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.6.0;

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
     *
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

pragma solidity ^0.6.0;

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: @openzeppelin/contracts/GSN/Context.sol

pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

pragma solidity ^0.6.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * Returns the address of the current owner.
     */
    function governance() public view returns (address) {
        return _owner;
    }

    /**
     * Throws if called by any account other than the owner.
     */
    modifier onlyGovernance() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferGovernance(address newOwner) internal virtual onlyGovernance {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: contracts/StabinolClaimerV2.sol

pragma solidity =0.6.6;

// The claimer is used to mint new tokens to the user based on eth spent during the claim duration
// After the minting period has expired, the claimer will pull from its own funds to pay cashback to user
// This claimer allows for accumulation, initially up to 96% at 6 months in addition to 4%, 3 day cashback
// This claimer also contains code to use the eth spent oracle when activated
// Each new iteration of the claimer will store a record to the previous claimer

interface Staker {
    function getLPBalance(address) external view returns (uint256);
    function getSTBZBalance(address) external view returns (uint256);
    function getDepositTime(address) external view returns (uint256);
    function getSTOLInLP(address) external view returns (uint256);
    function claimerAddress() external view returns (address);
}

interface StabinolToken {
    function getMaxSupply() external pure returns (uint256);
    function mint(address, uint256) external returns (bool);
}

interface PriceOracle {
    function getLatestSTOLUSD() external view returns (uint256);
    function getETHUSD() external view returns (uint256);
    function updateSTOLPrice() external;
}

interface SpentOracle {
    function getUserETHSpent(address) external view returns (uint256); // Gets the cumulative eth spent by user
    function addUserETHSpent(address, uint256) external returns (bool); // Send spent data to oracle
}

contract StabinolClaimerV2 is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    // variables
    address public stolAddress; // The address for the STOL tokens
    uint256 public minPercentClaim = 4000; // Initial conditions are 4% of USD value of STOL holdings can be claimed
    uint256 public minClaimWindow = 3 days; // User must wait at least 3 days after last deposit action to claim
    uint256 public maxAccumulatedClaim = 96000; // The maximum claim percent after the accumulation period has expired
    uint256 public accumulationWindow = 177 days; // Window when accumulation will grow
    bool public usingEthSpentOracle = false; // Governance can switch to ETH oracle or not to determine eth balances
    uint256 private _minSTBZStaked = 50e18; // Initially requires 50 STBZ to stake in order to be eligible
    address public stakerAddress; // The address for the staker
    address public priceOracleAddress; // The address of the price oracle
    address public ethSpentOracleAddress; // Address of the eth spent oracle
    
    uint256 constant DIVISION_FACTOR = 100000;
    uint256 constant CLAIM_STIPEND = 250000; // The amount of stipend we will give to the user for claiming in gas units
    address constant WETH_ADDRESS = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // WETH address
    address constant PREVIOUS_CLAIMER = address(0x71Ce0fb59f17894A70f1D1b4F6eb03cA93E96858); // Address of last claimer
    
    mapping(address => UserInfo) private allUsersInfo;
    
    // Structs
    struct UserInfo {
        bool existing; // This becomes true once the user interacts with the new claimer
        uint256 ethBalance; // The balance of ETH and WETH the last time the claim was made or a deposit was made in staker
        uint256 totalEthSpent; // Stores the total amount of eth spent by user, based on oracle
        uint256 lastClaimTime; // Time at last claim
    }

    // Events
    event ClaimedSTOL(address indexed user, uint256 amount, uint256 expectedAmount);
    
    constructor(
        address _stol,
        address _staker,
        address _oracle,
        address _ethspent
    ) public {
        stolAddress = _stol;
        stakerAddress = _staker;
        priceOracleAddress = _oracle;
        ethSpentOracleAddress = _ethspent;
    }
    
    modifier onlyStaker() {
        require(_msgSender() == stakerAddress, "Only staker can call this function");
        _;
    }
    
    // functions
    function getETHSpentSinceClaim(address _user) public view returns (uint256) {
        // Will return the amount of ETH spent since last call
        uint256 total = SpentOracle(ethSpentOracleAddress).getUserETHSpent(_user);
        if(total > allUsersInfo[_user].totalEthSpent){
            return total.sub(allUsersInfo[_user].totalEthSpent);
        }else{
            // Possibly switched to a new iteration
            return 0;
        }
    }
    
    function getTotalETHSpent(address _user) external view returns (uint256) {
        return allUsersInfo[_user].totalEthSpent;
    }
    
    function getETHBalance(address _user) public view returns (uint256){
        if(allUsersInfo[_user].existing == false){
            // Pull from old contract if no new data moved here
            return StabinolClaimerV2(PREVIOUS_CLAIMER).getETHBalance(_user); // Get data from previous claimer
        }else{
            return allUsersInfo[_user].ethBalance;
        }
    }
    
    function getLastClaimTime(address _user) public view returns (uint256){
        if(allUsersInfo[_user].existing == false){
            return StabinolClaimerV2(PREVIOUS_CLAIMER).getLastClaimTime(_user); // Get data from previous claimer
        }else{
            return allUsersInfo[_user].lastClaimTime;
        }
    }
    
    function getMinSTBZStake() external view returns (uint256){
        return _minSTBZStaked;
    }
    
    function stakerUpdateBalance(address _user, uint256 gasLimit) external onlyStaker {
        if(allUsersInfo[_user].existing == false){
           updateUserData(_user);
        }
        allUsersInfo[_user].ethBalance = _user.balance.add(IERC20(WETH_ADDRESS).balanceOf(_user)).add(gasLimit); // ETH balance + WETH balance + Gas Limit
    }
    
    function updateUserData(address _user) internal {
         // We need to upate the user to the current claimer
        allUsersInfo[_user].lastClaimTime = getLastClaimTime(_user);
        allUsersInfo[_user].ethBalance = getETHBalance(_user);
        allUsersInfo[_user].existing = true;
        // Add more fields when we upgrade the claimer again
    }
    
    function getClaimBackPercent(address _user) public view returns (uint256) {
        // This function will calculate the max amount of claimback percent the user can expect based on accumulation time
        Staker _stake = Staker(stakerAddress);
        if(_stake.claimerAddress() != address(this)){
            return 0;
        }
        uint256 lastTime = _stake.getDepositTime(_user);
        uint256 lastClaimTime = getLastClaimTime(_user);
        if(lastClaimTime > lastTime){
            lastTime = lastClaimTime;
        }
        if(lastTime == 0){
            return 0; // No deposits ever
        }
        if(now < lastTime + minClaimWindow){
            return 0; // Too soon to claim
        }
        lastTime = lastTime + minClaimWindow; // This is the start of the accumulation time
        uint256 timeDiff = now - lastTime; // Will be at least 0
        uint256 maxPercent = timeDiff * maxAccumulatedClaim / accumulationWindow;
        if(maxPercent > maxAccumulatedClaim){maxPercent = maxAccumulatedClaim;}
        return minPercentClaim + maxPercent;
    }
    
    // Claim call
    function claim() external nonReentrant
    {
        uint256 gasLimit = gasleft().mul(tx.gasprice);
        
        address _user = _msgSender();
        if(allUsersInfo[_user].existing == false){
            // Update the user data to current claimer
            updateUserData(_user);
        }
        
        require(stakerAddress != address(0), "Staker not set yet");
        require(priceOracleAddress != address(0), "Price oracle not set yet");
        require(PriceOracle(priceOracleAddress).getLatestSTOLUSD() > 0, "There is no price yet determined for STOL");
        Staker _stake = Staker(stakerAddress);
        // First check if enough STBZ is staked in staker
        require(_stake.claimerAddress() == address(this), "Staker doesn't have this as the claimer");
        require(_stake.getSTBZBalance(_user) >= _minSTBZStaked, "User doesn't have enough STBZ staked to qualify");
        require(_stake.getLPBalance(_user) > 0, "User hasn't staked any LP tokens into the contract");
        // Now require deposit time / claim time to be at least min time to claim
        require(now >= allUsersInfo[_user].lastClaimTime + minClaimWindow, "Previous claim was too recent to claim again");
        require(now >= _stake.getDepositTime(_user) + minClaimWindow, "Deposit time was too recent to claim");
        uint256 claimPercent = getClaimBackPercent(_user);
        require(claimPercent > 0, "Unable to determine the percentage eligible to claim");
        allUsersInfo[_user].lastClaimTime = now; // Set the claim time to now
        uint256 claimedAmount = 0;
        uint256 spent = 0;
        
        // Now divide the calculation based on claim type used
        if(usingEthSpentOracle == true){
            // We will get the eth spent since last use
            spent = getETHSpentSinceClaim(_user);
            allUsersInfo[_user].totalEthSpent = SpentOracle(ethSpentOracleAddress).getUserETHSpent(_user);
            
            // Update the eth spent on the oracle for the next claim once whitelisted
            SpentOracle(ethSpentOracleAddress).addUserETHSpent(_user, CLAIM_STIPEND.mul(tx.gasprice));
        }else{
            // Using balance changes
            uint256 currentBalance = _user.balance.add(IERC20(WETH_ADDRESS).balanceOf(_user)).add(gasLimit);
            if(currentBalance < allUsersInfo[_user].ethBalance){
                spent = allUsersInfo[_user].ethBalance.sub(currentBalance);
            }else{
                spent = 0;
            }
            allUsersInfo[_user].ethBalance = currentBalance;
        }
        
        if(spent > 0){
            // User has spent some eligible ETH
            spent = spent.mul(PriceOracle(priceOracleAddress).getETHUSD()).div(1e18); // Normalize USD price into wei units
            PriceOracle(priceOracleAddress).updateSTOLPrice(); // This will force update the price oracle
            uint256 stolPrice = PriceOracle(priceOracleAddress).getLatestSTOLUSD();
            require(stolPrice > 0, "STOL price cannot be determined");
            uint256 maxSTOL = spent.mul(1e18).div(stolPrice); // This will give use maximum amount of STOL redeemable based on spent ETH
            // This will give us maximum amount of STOL redeemable based on holdings
            claimedAmount = _stake.getSTOLInLP(_user).mul(claimPercent).div(DIVISION_FACTOR); // Returns STOL in user's LP share, then takes percent
            if(claimedAmount > maxSTOL){
                claimedAmount = maxSTOL;
            }
            if(claimedAmount > 0){
                // Now give user some STOL
                IERC20 stol = IERC20(stolAddress);
                uint256 maxSupply = StabinolToken(stolAddress).getMaxSupply();
                if(stol.totalSupply() < maxSupply){
                    // We will mint or mint and take from vault
                    if(claimedAmount.add(stol.totalSupply()) > maxSupply){
                        // Mint upto the maximum supply from the token then take rest from vault
                        uint256 overage = claimedAmount.add(stol.totalSupply()).sub(maxSupply);
                        claimedAmount = claimedAmount.sub(overage); // Reduce the amount
                        StabinolToken(stolAddress).mint(_user, claimedAmount);
                        if(stol.balanceOf(address(this)) >= overage){
                            // Send the overage amount to the user
                            stol.safeTransfer(_user, overage);
                            emit ClaimedSTOL(_user, claimedAmount.add(overage), claimedAmount.add(overage));
                        }else if(stol.balanceOf(address(this)) > 0){
                            // Not enough STOL to fill claim, just send the balance left
                            emit ClaimedSTOL(_user, claimedAmount.add(stol.balanceOf(address(this))), claimedAmount.add(overage));
                            stol.safeTransfer(_user, stol.balanceOf(address(this)));
                        }else{
                            emit ClaimedSTOL(_user, claimedAmount, claimedAmount.add(overage));
                        }
                        return;
                    }else{
                        // We just mint freely
                        StabinolToken(stolAddress).mint(_user, claimedAmount);
                        emit ClaimedSTOL(_user, claimedAmount, claimedAmount);
                    }
                }else{
                    // We will just take from vault
                    if(stol.balanceOf(address(this)) >= claimedAmount){
                        // Send the claimedAmount to the user from vault
                        stol.safeTransfer(_user, claimedAmount);
                        emit ClaimedSTOL(_user, claimedAmount, claimedAmount);
                    }else if(stol.balanceOf(address(this)) > 0){
                        // Not enough STOL to fill claim, just send the balance left
                        emit ClaimedSTOL(_user, stol.balanceOf(address(this)), claimedAmount);
                        stol.safeTransfer(_user, stol.balanceOf(address(this)));
                    }else{
                        // Vault doesn't have enough STOL for user
                        emit ClaimedSTOL(_user, 0, claimedAmount);
                    }
                }                
            }
        }
    }
    
    // Governance only functions
    
    // Timelock variables
    
    uint256 private _timelockStart; // The start of the timelock to change governance variables
    uint256 private _timelockType; // The function that needs to be changed
    uint256 constant TIMELOCK_DURATION = 86400; // Timelock is 24 hours
    
    // Reusable timelock variables
    address private _timelock_address;
    uint256[2] private _timelock_data;
    
    modifier timelockConditionsMet(uint256 _type) {
        require(_timelockType == _type, "Timelock not acquired for this function");
        _timelockType = 0; // Reset the type once the timelock is used
        require(now >= _timelockStart + TIMELOCK_DURATION, "Timelock time not met");
        _;
    }
    
    // Change the owner of the token contract
    // --------------------
    function startGovernanceChange(address _address) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 1;
        _timelock_address = _address;       
    }
    
    function finishGovernanceChange() external onlyGovernance timelockConditionsMet(1) {
        transferGovernance(_timelock_address);
    }
    // --------------------
    
    // Change the staker contract
    // --------------------
    function startStakerChange(address _address) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 2;
        _timelock_address = _address;       
    }
    
    function finishStakerChange() external onlyGovernance timelockConditionsMet(2) {
        stakerAddress = _timelock_address;
    }
    // --------------------
    
    // Change the price oracle contract
    // --------------------
    function startPriceOracleChange(address _address) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 3;
        _timelock_address = _address;       
    }
    
    function finishPriceOracleChange() external onlyGovernance timelockConditionsMet(3) {
        priceOracleAddress = _timelock_address;
    }
    // --------------------
    
    // Change the price oracle contract
    // --------------------
    function startETHSpentOracleChange(address _address) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 4;
        _timelock_address = _address;       
    }
    
    function finishETHSpentOracleChange() external onlyGovernance timelockConditionsMet(4) {
        ethSpentOracleAddress = _timelock_address;
    }
    // --------------------
    
    // Change the max percent cashback
    // --------------------
    function startChangeInitialPercentAndTime(uint256 _percent, uint256 _time) external onlyGovernance {
        require(_percent <= 100000, "Percent too high");
        _timelockStart = now;
        _timelockType = 5;
        _timelock_data[0] = _percent;
        _timelock_data[1] = _time;
    }
    
    function finishChangeInitialPercentAndTime() external onlyGovernance timelockConditionsMet(5) {
        minPercentClaim = _timelock_data[0];
        minClaimWindow = _timelock_data[1];
    }
    // --------------------
    
    // Change the max accumulation percent cashback
    // --------------------
    function startChangeMaxPercentAndTime(uint256 _percent, uint256 _time) external onlyGovernance {
        require(_percent <= 100000, "Percent too high");
        _timelockStart = now;
        _timelockType = 6;
        _timelock_data[0] = _percent;
        _timelock_data[1] = _time;
    }
    
    function finishChangeMaxPercentAndTime() external onlyGovernance timelockConditionsMet(6) {
        maxAccumulatedClaim = _timelock_data[0];
        accumulationWindow = _timelock_data[1];
    }
    // --------------------
    
    // Change the min STBZ staked
    // --------------------
    function startChangeMinSTBZ(uint256 _stbz) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 7;
        _timelock_data[0] = _stbz;
    }
    
    function finishChangeMinSTBZ() external onlyGovernance timelockConditionsMet(7) {
        _minSTBZStaked = _timelock_data[0];
    }
    // --------------------

    // Transfer vault STOL to new claimer if necessary
    // --------------------
    function startTransferVaultToNewClaimer(address _address) external onlyGovernance {
        require(IERC20(stolAddress).balanceOf(address(this)) > 0, "No STOL in Claimer yet");
        _timelockStart = now;
        _timelockType = 8;
        _timelock_address = _address;       
    }
    
    function finishTransferVaultToNewClaimer() external onlyGovernance timelockConditionsMet(8) {
        // Move STOL to new claimer
        IERC20(stolAddress).safeTransfer(_timelock_address, IERC20(stolAddress).balanceOf(address(this)));
    }
    // --------------------
    
    // Change the min STBZ staked
    // --------------------
    function startChangeETHSpentOracleUse(uint256 _use) external onlyGovernance {
        _timelockStart = now;
        _timelockType = 9;
        _timelock_data[0] = _use;
    }
    
    function finishChangeETHSpentOracleUse() external onlyGovernance timelockConditionsMet(9) {
        if(_timelock_data[0] == 0){
            usingEthSpentOracle = false;
        }else{
            usingEthSpentOracle = true;
        }
    }
    // --------------------
   
}