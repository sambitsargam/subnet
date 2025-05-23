pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;

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

        // This method relies in extcodesize, which returns 0 for contracts in

        // construction, since the code is only stored at the end of the

        // constructor execution.



        uint256 size;

        // solhint-disable-next-line no-inline-assembly

        assembly { size := extcodesize(account) }

        return size > 0;

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

        (bool success, ) = recipient.call.value(amount)("");

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

        (bool success, bytes memory returndata) = target.call.value(weiValue)(data);

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

interface IERC20 {

    /**

     * @dev Returns the amount of tokens in existence.

     */

    function totalSupply() external view returns (uint256);



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

interface TreasuryPool {

    function updateNextRewards(uint256 amount) external;

}

contract GAMERReserves {



    // Token that serves as a reserve for GAMER

    address public reserveToken;



    address public gov;



    address public pendingGov;



    address public rebaser;



    address public gamerAddress;



    address public treasuryPool;



    /*** Gov Events ***/



    /**

     * @notice Event emitted when pendingGov is changed

     */

    event NewPendingGov(address oldPendingGov, address newPendingGov);



    /**

     * @notice Event emitted when gov is changed

     */

    event NewGov(address oldGov, address newGov);



    /**

     * @notice Event emitted when TreasuryPool is changed

     */

    event NewTreasuryPool(address oldTreasuryPool, address newTreasuryPool);



    /**

     * @notice Event emitted when rebaser is changed

     */

    event NewRebaser(address oldRebaser, address newRebaser);





    modifier onlyGov() {

        require(msg.sender == gov);

        _;

    }



    modifier onlyRebaser() {

        require(msg.sender == rebaser);

        _;

    }



    constructor(

        address reserveToken_,

        address gamerAddress_

    )

        public

    {

        reserveToken = reserveToken_;

        gamerAddress = gamerAddress_;

        gov = msg.sender;

    }



    function _setRebaser(address rebaser_)

        external

        onlyGov

    {

        address oldRebaser = rebaser;

        GAMERTokenInterface(gamerAddress).decreaseAllowance(oldRebaser, uint256(-1));

        rebaser = rebaser_;

        GAMERTokenInterface(gamerAddress).approve(rebaser_, uint256(-1));

        emit NewRebaser(oldRebaser, rebaser_);

    }



    /** @notice sets the pendingGov

     * @param pendingGov_ The address of the rebaser contract to use for authentication.

     */

    function _setPendingGov(address pendingGov_)

        external

        onlyGov

    {

        address oldPendingGov = pendingGov;

        pendingGov = pendingGov_;

        emit NewPendingGov(oldPendingGov, pendingGov_);

    }



    /**

     * @notice lets msg.sender accept governance

     */

    function _acceptGov()

        external

    {

        require(msg.sender == pendingGov, "!pending");

        address oldGov = gov;

        gov = pendingGov;

        pendingGov = address(0);

        emit NewGov(oldGov, gov);

    }



    /** @notice sets the treasuryPool

     * @param treasuryPool_ The address of the treasury pool contract.

     */

    function _setTreasuryPool(address treasuryPool_)

        external

        onlyGov

    {

        address oldTreasuryPool = treasuryPool;

        treasuryPool = treasuryPool_;

        emit NewTreasuryPool(oldTreasuryPool, treasuryPool_);

    }



    /// @notice Moves all tokens to a new reserve contract

    function migrateReserves(

        address newReserve,

        address[] memory tokens

    )

        public

        onlyGov

    {

        for (uint256 i = 0; i < tokens.length; i++) {

            IERC20 token =  IERC20(tokens[i]);

            uint256 bal = token.balanceOf(address(this));

            SafeERC20.safeTransfer(token, newReserve, bal);

        }

    }



    /// @notice Gets the current amount of reserves token held by this contract

    function reserves()

        public

        view

        returns (uint256)

    {

        return IERC20(reserveToken).balanceOf(address(this));

    }



        /// @notice Gets the current amount of reserves token held by this contract

    function distributeTreasuryReward(uint256 amount)

        public

        onlyRebaser

    {

        IERC20(reserveToken).transfer(treasuryPool, amount);

        TreasuryPool(treasuryPool).updateNextRewards(amount);

    }

}

contract GAMERGovernanceStorage {

    /// @notice A record of each accounts delegate

    mapping (address => address) internal _delegates;



    /// @notice A checkpoint for marking number of votes from a given block

    struct Checkpoint {

        uint32 fromBlock;

        uint256 votes;

    }



    /// @notice A record of votes checkpoints for each account, by index

    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;



    /// @notice The number of checkpoints for each account

    mapping (address => uint32) public numCheckpoints;



    /// @notice The EIP-712 typehash for the contract's domain

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");



    /// @notice The EIP-712 typehash for the delegation struct used by the contract

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");



    /// @notice A record of states for signing / validating signatures

    mapping (address => uint) public nonces;

}

contract GAMERTokenStorage {



    using SafeMath for uint256;



    /**

     * @dev Guard variable for re-entrancy checks. Not currently used

     */

    bool internal _notEntered;



    /**

     * @notice EIP-20 token name for this token

     */

    string public name;



    /**

     * @notice EIP-20 token symbol for this token

     */

    string public symbol;



    /**

     * @notice EIP-20 token decimals for this token

     */

    uint8 public decimals;



    /**

     * @notice Governor for this contract

     */

    address public gov;



    /**

     * @notice Pending governance for this contract

     */

    address public pendingGov;



    /**

     * @notice Approved rebaser for this contract

     */

    address public rebaser;



    /**

     * @notice Reserve address of GAMER protocol

     */

    address public incentivizer;



    /**

     * @notice stakingPool address of GAMER protocol

     */

    address public stakingPool;



    /**

     * @notice teamPool address of GAMER protocol

     */

    address public teamPool;



    /**

     * @notice dev address of GAMER protocol

     */

    address public dev;



    /**

     * @notice Total supply of GAMERs

     */

    uint256 internal _totalSupply;



    /**

     * @notice Internal decimals used to handle scaling factor

     */

    uint256 public constant internalDecimals = 10**24;



    /**

     * @notice Used for percentage maths

     */

    uint256 public constant BASE = 10**18;



    /**

     * @notice Scaling factor that adjusts everyone's balances

     */

    uint256 public gamersScalingFactor;



    mapping (address => uint256) internal _gamerBalances;



    mapping (address => mapping (address => uint256)) internal _allowedFragments;



    uint256 public initSupply;



}

contract GAMERTokenInterface is GAMERTokenStorage, GAMERGovernanceStorage {



    /// @notice An event thats emitted when an account changes its delegate

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);



    /// @notice An event thats emitted when a delegate account's vote balance changes

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);



    /**

     * @notice Event emitted when tokens are rebased

     */

    event Rebase(uint256 epoch, uint256 prevGrapsScalingFactor, uint256 newGrapsScalingFactor);



    /*** Gov Events ***/



    /**

     * @notice Event emitted when pendingGov is changed

     */

    event NewPendingGov(address oldPendingGov, address newPendingGov);



    /**

     * @notice Event emitted when gov is changed

     */

    event NewGov(address oldGov, address newGov);



    /**

     * @notice Sets the rebaser contract

     */

    event NewRebaser(address oldRebaser, address newRebaser);



    /**

     * @notice Sets the incentivizer contract

     */

    event NewIncentivizer(address oldIncentivizer, address newIncentivizer);



    /**

     * @notice Sets the StakingPool contract

     */

    event NewStakingPool(address oldStakingPool, address newStakingPool);



    /**

     * @notice Sets the TeamPool contract

     */

    event NewTeamPool(address oldTeamPool, address newTeamPool);



    /**

     * @notice Sets the Dev contract

     */

    event NewDev(address oldDev, address newDev);



    /* - ERC20 Events - */



    /**

     * @notice EIP20 Transfer event

     */

    event Transfer(address indexed from, address indexed to, uint amount);



    /**

     * @notice EIP20 Approval event

     */

    event Approval(address indexed owner, address indexed spender, uint amount);



    /* - Extra Events - */

    /**

     * @notice Tokens minted event

     */

    event Mint(address to, uint256 amount);



    // Public functions

    function totalSupply() external view returns (uint256);

    function transfer(address to, uint256 value) external returns(bool);

    function transferFrom(address from, address to, uint256 value) external returns(bool);

    function balanceOf(address who) external view returns(uint256);

    function balanceOfUnderlying(address who) external view returns(uint256);

    function allowance(address owner_, address spender) external view returns(uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

    function maxScalingFactor() external view returns (uint256);



    /* - Governance Functions - */

    function getPriorVotes(address account, uint blockNumber) external view returns (uint256);

    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) external;

    function delegate(address delegatee) external;

    function delegates(address delegator) external view returns (address);

    function getCurrentVotes(address account) external view returns (uint256);



    /* - Permissioned/Governance functions - */

    function mint(address to, uint256 amount) external returns (bool);

    function rebase(uint256 epoch, uint256 indexDelta, bool positive) external returns (uint256);

    function _setRebaser(address rebaser_) external;

    function _setIncentivizer(address incentivizer_) external;

    function _setPendingGov(address pendingGov_) external;

    function _acceptGov() external;

}

contract GAMERGovernanceToken is GAMERTokenInterface {



      /// @notice An event thats emitted when an account changes its delegate

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);



    /// @notice An event thats emitted when a delegate account's vote balance changes

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);



    /**

     * @notice Delegate votes from `msg.sender` to `delegatee`

     * @param delegator The address to get delegatee for

     */

    function delegates(address delegator)

        external

        view

        returns (address)

    {

        return _delegates[delegator];

    }



   /**

    * @notice Delegate votes from `msg.sender` to `delegatee`

    * @param delegatee The address to delegate votes to

    */

    function delegate(address delegatee) external {

        return _delegate(msg.sender, delegatee);

    }



    /**

     * @notice Delegates votes from signatory to `delegatee`

     * @param delegatee The address to delegate votes to

     * @param nonce The contract state required to match the signature

     * @param expiry The time at which to expire the signature

     * @param v The recovery byte of the signature

     * @param r Half of the ECDSA signature pair

     * @param s Half of the ECDSA signature pair

     */

    function delegateBySig(

        address delegatee,

        uint nonce,

        uint expiry,

        uint8 v,

        bytes32 r,

        bytes32 s

    )

        external

    {

        bytes32 domainSeparator = keccak256(

            abi.encode(

                DOMAIN_TYPEHASH,

                keccak256(bytes(name)),

                getChainId(),

                address(this)

            )

        );



        bytes32 structHash = keccak256(

            abi.encode(

                DELEGATION_TYPEHASH,

                delegatee,

                nonce,

                expiry

            )

        );



        bytes32 digest = keccak256(

            abi.encodePacked(

                "\x19\x01",

                domainSeparator,

                structHash

            )

        );



        address signatory = ecrecover(digest, v, r, s);

        require(signatory != address(0), "GAMER::delegateBySig: invalid signature");

        require(nonce == nonces[signatory]++, "GAMER::delegateBySig: invalid nonce");

        require(now <= expiry, "GAMER::delegateBySig: signature expired");

        return _delegate(signatory, delegatee);

    }



    /**

     * @notice Gets the current votes balance for `account`

     * @param account The address to get votes balance

     * @return The number of current votes for `account`

     */

    function getCurrentVotes(address account)

        external

        view

        returns (uint256)

    {

        uint32 nCheckpoints = numCheckpoints[account];

        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;

    }



    /**

     * @notice Determine the prior number of votes for an account as of a block number

     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.

     * @param account The address of the account to check

     * @param blockNumber The block number to get the vote balance at

     * @return The number of votes the account had as of the given block

     */

    function getPriorVotes(address account, uint blockNumber)

        external

        view

        returns (uint256)

    {

        require(blockNumber < block.number, "GAMER::getPriorVotes: not yet determined");



        uint32 nCheckpoints = numCheckpoints[account];

        if (nCheckpoints == 0) {

            return 0;

        }



        // First check most recent balance

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {

            return checkpoints[account][nCheckpoints - 1].votes;

        }



        // Next check implicit zero balance

        if (checkpoints[account][0].fromBlock > blockNumber) {

            return 0;

        }



        uint32 lower = 0;

        uint32 upper = nCheckpoints - 1;

        while (upper > lower) {

            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow

            Checkpoint memory cp = checkpoints[account][center];

            if (cp.fromBlock == blockNumber) {

                return cp.votes;

            } else if (cp.fromBlock < blockNumber) {

                lower = center;

            } else {

                upper = center - 1;

            }

        }

        return checkpoints[account][lower].votes;

    }



    function _delegate(address delegator, address delegatee)

        internal

    {

        address currentDelegate = _delegates[delegator];

        uint256 delegatorBalance = _gamerBalances[delegator]; // balance of underlying GAMERs (not scaled);

        _delegates[delegator] = delegatee;



        emit DelegateChanged(delegator, currentDelegate, delegatee);



        _moveDelegates(currentDelegate, delegatee, delegatorBalance);

    }



    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {

        if (srcRep != dstRep && amount > 0) {

            if (srcRep != address(0)) {

                // decrease old representative

                uint32 srcRepNum = numCheckpoints[srcRep];

                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;

                uint256 srcRepNew = srcRepOld.sub(amount);

                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);

            }



            if (dstRep != address(0)) {

                // increase new representative

                uint32 dstRepNum = numCheckpoints[dstRep];

                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;

                uint256 dstRepNew = dstRepOld.add(amount);

                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);

            }

        }

    }



    function _writeCheckpoint(

        address delegatee,

        uint32 nCheckpoints,

        uint256 oldVotes,

        uint256 newVotes

    )

        internal

    {

        uint32 blockNumber = safe32(block.number, "GAMER::_writeCheckpoint: block number exceeds 32 bits");



        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {

            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;

        } else {

            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);

            numCheckpoints[delegatee] = nCheckpoints + 1;

        }



        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);

    }



    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);

        return uint32(n);

    }



    function getChainId() internal pure returns (uint) {

        uint256 chainId;

        assembly { chainId := chainid() }

        return chainId;

    }

}

contract GAMERToken is GAMERGovernanceToken {

    // Modifiers

    modifier onlyGov() {

        require(msg.sender == gov, 'not gov');

        _;

    }



    modifier onlyRebaser() {

        require(msg.sender == rebaser);

        _;

    }



    modifier onlyMinter() {

        require(msg.sender == rebaser || msg.sender == incentivizer || msg.sender == stakingPool || msg.sender == teamPool || msg.sender == dev || msg.sender == gov, "not minter");

        _;

    }



    modifier validRecipient(address to) {

        require(to != address(0x0));

        require(to != address(this));

        _;

    }



    function initialize(

        string memory name_,

        string memory symbol_,

        uint8 decimals_

    )

        public

    {

        require(gamersScalingFactor == 0, "already initialized");

        name = name_;

        symbol = symbol_;

        decimals = decimals_;

    }



    /**

    * @notice Computes the current totalSupply

    */

    function totalSupply()

        external

        view

        returns (uint256)

    {

        return _totalSupply.div(10**24/ (BASE));

    }

    

    /**

    * @notice Computes the current max scaling factor

    */

    function maxScalingFactor()

        external

        view

        returns (uint256)

    {

        return _maxScalingFactor();

    }



    function _maxScalingFactor()

        internal

        view

        returns (uint256)

    {

        // scaling factor can only go up to 2**256-1 = initSupply * gamersScalingFactor

        // this is used to check if gamersScalingFactor will be too high to compute balances when rebasing.

        return uint256(-1) / initSupply;

    }



    /**

    * @notice Mints new tokens, increasing totalSupply, initSupply, and a users balance.

    * @dev Limited to onlyMinter modifier

    */

    function mint(address to, uint256 amount)

        external

        onlyMinter

        returns (bool)

    {

        _mint(to, amount);

        return true;

    }



    function _mint(address to, uint256 amount)

        internal

    {

      // increase totalSupply

      _totalSupply = _totalSupply.add(amount.mul(10**24/ (BASE)));



      // get underlying value

      uint256 gamerValue = amount.mul(internalDecimals).div(gamersScalingFactor);



      // increase initSupply

      initSupply = initSupply.add(gamerValue);



      // make sure the mint didnt push maxScalingFactor too low

      require(gamersScalingFactor <= _maxScalingFactor(), "max scaling factor too low");



      // add balance

      _gamerBalances[to] = _gamerBalances[to].add(gamerValue);

      emit Transfer(address(0), to, amount);

    

      // add delegates to the minter

      _moveDelegates(address(0), _delegates[to], gamerValue);

      emit Mint(to, amount);

    }



    /* - ERC20 functionality - */



    /**

    * @dev Transfer tokens to a specified address.

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    * @return True on success, false otherwise.

    */

    function transfer(address to, uint256 value)

        external

        validRecipient(to)

        returns (bool)

    {

        // underlying balance is stored in gamers, so divide by current scaling factor



        // note, this means as scaling factor grows, dust will be untransferrable.

        // minimum transfer value == gamersScalingFactor / 1e24;



        // get amount in underlying

        uint256 gamerValue = value.mul(internalDecimals).div(gamersScalingFactor);



        // sub from balance of sender

        _gamerBalances[msg.sender] = _gamerBalances[msg.sender].sub(gamerValue);



        // add to balance of receiver

        _gamerBalances[to] = _gamerBalances[to].add(gamerValue);

        emit Transfer(msg.sender, to, value);



        _moveDelegates(_delegates[msg.sender], _delegates[to], gamerValue);

        return true;

    }



    /**

    * @dev Transfer tokens from one address to another.

    * @param from The address you want to send tokens from.

    * @param to The address you want to transfer to.

    * @param value The amount of tokens to be transferred.

    */

    function transferFrom(address from, address to, uint256 value)

        external

        validRecipient(to)

        returns (bool)

    {

        // decrease allowance

        _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender].sub(value);



        // get value in gamers

        uint256 gamerValue = value.mul(internalDecimals).div(gamersScalingFactor);



        // sub from from

        _gamerBalances[from] = _gamerBalances[from].sub(gamerValue);

        _gamerBalances[to] = _gamerBalances[to].add(gamerValue);

        emit Transfer(from, to, value);



        _moveDelegates(_delegates[from], _delegates[to], gamerValue);

        return true;

    }



    /**

    * @param who The address to query.

    * @return The balance of the specified address.

    */

    function balanceOf(address who)

      external

      view

      returns (uint256)

    {

      return _gamerBalances[who].mul(gamersScalingFactor).div(internalDecimals);

    }



    /** @notice Currently returns the internal storage amount

    * @param who The address to query.

    * @return The underlying balance of the specified address.

    */

    function balanceOfUnderlying(address who)

      external

      view

      returns (uint256)

    {

      return _gamerBalances[who];

    }



    /**

     * @dev Function to check the amount of tokens that an owner has allowed to a spender.

     * @param owner_ The address which owns the funds.

     * @param spender The address which will spend the funds.

     * @return The number of tokens still available for the spender.

     */

    function allowance(address owner_, address spender)

        external

        view

        returns (uint256)

    {

        return _allowedFragments[owner_][spender];

    }



    /**

     * @dev Approve the passed address to spend the specified amount of tokens on behalf of

     * msg.sender. This method is included for ERC20 compatibility.

     * increaseAllowance and decreaseAllowance should be used instead.

     * Changing an allowance with this method brings the risk that someone may transfer both

     * the old and the new allowance - if they are both greater than zero - if a transfer

     * transaction is mined before the later approve() call is mined.

     *

     * @param spender The address which will spend the funds.

     * @param value The amount of tokens to be spent.

     */

    function approve(address spender, uint256 value)

        external

        returns (bool)

    {

        _allowedFragments[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;

    }



    /**

     * @dev Increase the amount of tokens that an owner has allowed to a spender.

     * This method should be used instead of approve() to avoid the double approval vulnerability

     * described above.

     * @param spender The address which will spend the funds.

     * @param addedValue The amount of tokens to increase the allowance by.

     */

    function increaseAllowance(address spender, uint256 addedValue)

        external

        returns (bool)

    {

        _allowedFragments[msg.sender][spender] =

            _allowedFragments[msg.sender][spender].add(addedValue);

        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);

        return true;

    }



    /**

     * @dev Decrease the amount of tokens that an owner has allowed to a spender.

     *

     * @param spender The address which will spend the funds.

     * @param subtractedValue The amount of tokens to decrease the allowance by.

     */

    function decreaseAllowance(address spender, uint256 subtractedValue)

        external

        returns (bool)

    {

        uint256 oldValue = _allowedFragments[msg.sender][spender];

        if (subtractedValue >= oldValue) {

            _allowedFragments[msg.sender][spender] = 0;

        } else {

            _allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);

        }

        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);

        return true;

    }



    /* - Governance Functions - */



    /** @notice sets the rebaser

     * @param rebaser_ The address of the rebaser contract to use for authentication.

     */

    function _setRebaser(address rebaser_)

        external

        onlyGov

    {

        address oldRebaser = rebaser;

        rebaser = rebaser_;

        emit NewRebaser(oldRebaser, rebaser_);

    }



    /** @notice sets the incentivizer

     * @param incentivizer_ The address of the incentivizer contract to use for authentication.

     */

    function _setIncentivizer(address incentivizer_)

        external

        onlyGov

    {

        address oldIncentivizer = incentivizer;

        incentivizer = incentivizer_;

        emit NewIncentivizer(oldIncentivizer, incentivizer_);

    }



    /** @notice sets the stakingPool

     * @param stakingPool_ The address of the stakingPool contract to use for authentication.

     */

    function _setStakingPool(address stakingPool_)

        external

        onlyGov

    {

        address oldStakingPool = stakingPool;

        stakingPool = stakingPool_;

        emit NewStakingPool(oldStakingPool, stakingPool_);

    }



    /** @notice sets the teamPool

     * @param teamPool_ The address of the teamPool contract to use for authentication.

     */

    function _setTeamPool(address teamPool_)

        external

        onlyGov

    {

        address oldTeamPool = teamPool;

        teamPool = teamPool_;

        emit NewTeamPool(oldTeamPool, teamPool_);

    }



    /** @notice sets the dev

     * @param dev_ The address of the dev contract to use for authentication.

     */

    function _setDev(address dev_)

        external

        onlyGov

    {

        address oldDev = dev;

        dev = dev_;

        emit NewDev(oldDev, dev_);

    }



    /** @notice sets the pendingGov

     * @param pendingGov_ The address of the rebaser contract to use for authentication.

     */

    function _setPendingGov(address pendingGov_)

        external

        onlyGov

    {

        address oldPendingGov = pendingGov;

        pendingGov = pendingGov_;

        emit NewPendingGov(oldPendingGov, pendingGov_);

    }



    /** @notice lets msg.sender accept governance

     *

     */

    function _acceptGov()

        external

    {

        require(msg.sender == pendingGov, "!pending");

        address oldGov = gov;

        gov = pendingGov;

        pendingGov = address(0);

        emit NewGov(oldGov, gov);

    }



    /* - Extras - */



    /**

    * @notice Initiates a new rebase operation, provided the minimum time period has elapsed.

    *

    * @dev The supply adjustment equals (totalSupply * DeviationFromTargetRate) / rebaseLag

    *      Where DeviationFromTargetRate is (MarketOracleRate - targetRate) / targetRate

    *      and targetRate is CpiOracleRate / baseCpi

    */

    function rebase(

        uint256 epoch,

        uint256 indexDelta,

        bool positive

    )

        external

        onlyRebaser

        returns (uint256)

    {

        if (indexDelta == 0) {

          emit Rebase(epoch, gamersScalingFactor, gamersScalingFactor);

          return _totalSupply;

        }



        uint256 prevGrapsScalingFactor = gamersScalingFactor;



        if (!positive) {

           gamersScalingFactor = gamersScalingFactor.mul(BASE.sub(indexDelta)).div(BASE);

        } else {

            uint256 newScalingFactor = gamersScalingFactor.mul(BASE.add(indexDelta)).div(BASE);

            if (newScalingFactor < _maxScalingFactor()) {

                gamersScalingFactor = newScalingFactor;

            } else {

              gamersScalingFactor = _maxScalingFactor();

            }

        }



        _totalSupply = initSupply.mul(gamersScalingFactor).div(BASE);

        emit Rebase(epoch, prevGrapsScalingFactor, gamersScalingFactor);

        return _totalSupply;

    }

}

contract GAMER is GAMERToken {

    /**

     * @notice Initialize the new money market

     * @param name_ ERC-20 name of this token

     * @param symbol_ ERC-20 symbol of this token

     * @param decimals_ ERC-20 decimal precision of this token

     */

    function initialize(

        string memory name_,

        string memory symbol_,

        uint8 decimals_,

        address initial_owner,

        uint256 initSupply_

    )

        public

    {

        require(initSupply_ > 0, "0 init supply");



        super.initialize(name_, symbol_, decimals_);



        initSupply = initSupply_.mul(10**24/ (BASE));

        _totalSupply = initSupply;

        gamersScalingFactor = BASE;

        _gamerBalances[initial_owner] = initSupply_.mul(10**24 / (BASE));



        // owner renounces ownership after deployment as they need to set

        // rebaser and incentivizer

        // gov = gov_;

    }

}
