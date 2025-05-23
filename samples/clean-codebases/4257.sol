/**
 *Submitted for verification at Etherscan.io on 2022-03-17
*/

// SPDX-License-Identifier: UNLICENSED

// File: contracts/abstract/OwnableDelegateProxy.sol


pragma solidity 0.8.9;

contract OwnableDelegateProxy {}
// File: contracts/abstract/ProxyRegistry.sol


pragma solidity 0.8.9;


// Part: ProxyRegistry

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

// File: contracts/abstract/Roles.sol


pragma solidity 0.8.9;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {

    struct Role {
        mapping(address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view
        returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}



// File: contracts/abstract/IERC1155TokenReceiver.sol


pragma solidity 0.8.9;

/**
 * @dev ERC-1155 interface for accepting safe transfers.
 */
interface IERC1155TokenReceiver {

    /**
     * @notice Handle the receipt of a single ERC1155 token type
     * @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeTransferFrom` after the balance has been updated
     * This function MAY throw to revert and reject the transfer
     * Return of other amount than the magic value MUST result in the transaction being reverted
     * Note: The token contract address is always the message sender
     * @param _operator  The address which called the `safeTransferFrom` function
     * @param _from      The address which previously owned the token
     * @param _id        The id of the token being transferred
     * @param _amount    The amount of tokens being transferred
     * @param _data      Additional data with no specified format
     * @return           `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     */
    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _amount,
        bytes calldata _data
    )
        external returns (
            bytes4
        )
    ;

    /**
     * @notice Handle the receipt of multiple ERC1155 token types
     * @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeBatchTransferFrom` after the balances have been updated
     * This function MAY throw to revert and reject the transfer
     * Return of other amount than the magic value WILL result in the transaction being reverted
     * Note: The token contract address is always the message sender
     * @param _operator  The address which called the `safeBatchTransferFrom` function
     * @param _from      The address which previously owned the token
     * @param _ids       An array containing ids of each token being transferred
     * @param _amounts   An array containing amounts of each token being transferred
     * @param _data      Additional data with no specified format
     * @return           `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     */
    function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _amounts,
        bytes calldata _data
    )
        external returns (
            bytes4
        )
    ;

    /**
     * @notice Indicates whether a contract implements the `ERC1155TokenReceiver` functions and so can accept ERC1155 token types.
     * @param  interfaceID The ERC-165 interface ID that is queried for support.s
     * @dev This function MUST return true if it implements the ERC1155TokenReceiver interface and ERC-165 interface.
     *      This function MUST NOT consume more than 5,000 gas.
     * @return Wheter ERC-165 or ERC1155TokenReceiver interfaces are supported.
     */
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
// File: contracts/abstract/ERC1155Metadata.sol


pragma solidity 0.8.9;

/**
 * @notice Contract that handles metadata related methods.
 * @dev Methods assume a deterministic generation of URI based on token IDs.
 *      Methods also assume that URI uses hex representation of token IDs.
 */
abstract contract ERC1155Metadata {

    /***********************************|
     *   |     Metadata Public Function s    |
     |__________________________________*/
    /**
     * @notice A distinct Uniform Resource Identifier (URI) for a given token.
     * @dev URIs are defined in RFC 3986.
     *      URIs are assumed to be deterministically generated based on token ID
     *      Token IDs are assumed to be represented in their hex format in URIs
     * @return URI string
     */
    function uri(uint256 _id) external view virtual returns (string memory);
}



// File: contracts/abstract/IERC1155.sol


pragma solidity 0.8.9;

interface IERC1155 {
    // Events
    /**
     * @dev Either TransferSingle or TransferBatch MUST emit when tokens are transferred, including zero amount transfers as well as minting or burning
     *   Operator MUST be msg.sender
     *   When minting/creating tokens, the `_from` field MUST be set to `0x0`
     *   When burning/destroying tokens, the `_to` field MUST be set to `0x0`
     *   The total amount transferred from address 0x0 minus the total amount transferred to 0x0 may be used by clients and exchanges to be added to the "circulating supply" for a given token ID
     *   To broadcast the existence of a token ID with no initial balance, the contract SHOULD emit the TransferSingle event from `0x0` to `0x0`, with the token creator as `_operator`, and a `_amount` of 0
     */
    event TransferSingle(address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _amount);

    /**
     * @dev Either TransferSingle or TransferBatch MUST emit when tokens are transferred, including zero amount transfers as well as minting or burning
     *   Operator MUST be msg.sender
     *   When minting/creating tokens, the `_from` field MUST be set to `0x0`
     *   When burning/destroying tokens, the `_to` field MUST be set to `0x0`
     *   The total amount transferred from address 0x0 minus the total amount transferred to 0x0 may be used by clients and exchanges to be added to the "circulating supply" for a given token ID
     *   To broadcast the existence of multiple token IDs with no initial balance, this SHOULD emit the TransferBatch event from `0x0` to `0x0`, with the token creator as `_operator`, and a `_amount` of 0
     */
    event TransferBatch(address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256[] _ids,
        uint256[] _amounts);

    /**
     * @dev MUST emit when an approval is updated
     */
    event ApprovalForAll(address indexed _owner,
        address indexed _operator,
        bool _approved);

    /**
     * @dev MUST emit when the URI is updated for a token ID
     *   URIs are defined in RFC 3986
     *   The URI MUST point a JSON file that conforms to the "ERC-1155 Metadata JSON Schema"
     */
    event URI(string _uri, uint256 indexed _id);

    /**
     * @notice Transfers amount of an _id from the _from address to the _to address specified
     * @dev MUST emit TransferSingle event on success
     * Caller must be approved to manage the _from account's tokens (see isApprovedForAll)
     * MUST throw if `_to` is the zero address
     * MUST throw if balance of sender for token `_id` is lower than the `_amount` sent
     * MUST throw on any other error
     * When transfer is complete, this function MUST check if `_to` is a smart contract (code size > 0). If so, it MUST call `onERC1155Received` on `_to` and revert if the return amount is not `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * @param _from    Source address
     * @param _to      Target address
     * @param _id      ID of the token type
     * @param _amount  Transfered amount
     * @param _data    Additional data with no specified format, sent in call to `_to`
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes calldata _data
    )
        external;

    /**
     * @notice Send multiple types of Tokens from the _from address to the _to address (with safety call)
     * @dev MUST emit TransferBatch event on success
     * Caller must be approved to manage the _from account's tokens (see isApprovedForAll)
     * MUST throw if `_to` is the zero address
     * MUST throw if length of `_ids` is not the same as length of `_amounts`
     * MUST throw if any of the balance of sender for token `_ids` is lower than the respective `_amounts` sent
     * MUST throw on any other error
     * When transfer is complete, this function MUST check if `_to` is a smart contract (code size > 0). If so, it MUST call `onERC1155BatchReceived` on `_to` and revert if the return amount is not `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * Transfers and events MUST occur in the array order they were submitted (_ids[0] before _ids[1], etc)
     * @param _from     Source addresses
     * @param _to       Target addresses
     * @param _ids      IDs of each token type
     * @param _amounts  Transfer amounts per token type
     * @param _data     Additional data with no specified format, sent in call to `_to`
     */
    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _amounts,
        bytes calldata _data
    )
        external;

    /**
     * @notice Get the balance of an account's Tokens
     * @param _owner  The address of the token holder
     * @param _id     ID of the Token
     * @return        The _owner's balance of the Token type requested
     */
    function balanceOf(address _owner, uint256 _id) external view
        returns (uint256);

    /**
     * @notice Get the balance of multiple account/token pairs
     * @param _owners The addresses of the token holders
     * @param _ids    ID of the Tokens
     * @return        The _owner's balance of the Token types requested (i.e. balance for each (owner, id) pair)
     */
    function balanceOfBatch(
        address[] calldata _owners,
        uint256[] calldata _ids
    )
        external
        view
        returns (
            uint256[] memory
        )
    ;

    /**
     * @notice Enable or disable approval for a third party ("operator") to manage all of caller's tokens
     * @dev MUST emit the ApprovalForAll event on success
     * @param _operator  Address to add to the set of authorized operators
     * @param _approved  True if the operator is approved, false to revoke approval
     */
    function setApprovalForAll(address _operator, bool _approved) external;

    /**
     * @notice Queries the approval status of an operator for a given owner
     * @param _owner      The owner of the Tokens
     * @param _operator   Address of authorized operator
     * @return isOperator True if the operator is approved, false if not
     */
    function isApprovedForAll(
        address _owner,
        address _operator
    )
        external
        view
        returns (
            bool isOperator
        )
    ;
}

// File: contracts/abstract/IERC165.sol


pragma solidity 0.8.9;

/**
 * @title ERC165
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */
interface IERC165 {

    /**
     * @notice Query if a contract implements an interface
     * @dev Interface identification is specified in ERC-165. This function
     * uses less than 30,000 gas
     * @param _interfaceId The interface identifier, as specified in ERC-165
     */
    function supportsInterface(bytes4 _interfaceId) external view
        returns (bool);
}
// File: contracts/abstract/FundDistribution.sol


pragma solidity 0.8.9;

/**
 * @title Fund Distribution interface that could be used by other contracts to reference
 * TokenFactory/MasterChef in order to enable minting/rewarding to a designated fund address.
 */
interface FundDistribution {
    /**
     * @dev an operation that triggers reward distribution by minting to the designated address
     * from TokenFactory. The fund address must be already configured in TokenFactory to receive
     * funds, else no funds will be retrieved.
     */
    function sendReward(address _fundAddress) external returns (bool);
}

// File: contracts/abstract/Address.sol


pragma solidity 0.8.9;

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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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



// File: contracts/abstract/Context.sol


pragma solidity 0.8.9;

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
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}



// File: contracts/abstract/Ownable.sol


pragma solidity 0.8.9;


// Part: OpenZeppelin/[email protected]/Ownable

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/abstract/MinterRole.sol


pragma solidity 0.8.9;




/**
 * @title MinterRole
 * @dev Owner is responsible to add/remove minter
 */
contract MinterRole is Context, Ownable {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);

    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    modifier onlyMinter() {
        require(
            isMinter(_msgSender()),
            "MinterRole: caller does not have the Minter role"
        );
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyOwner {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

// File: contracts/abstract/SafeMath.sol


pragma solidity 0.8.9;

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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     * 
     * Counterpart to Solidity's `-` operator.
     * 
     * Requirements:
     * - Subtraction cannot overflow.
     * 
     * _Available since v2.4.0._
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
     * - The divisor cannot be zero.
     * 
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * - The divisor cannot be zero.
     * 
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}



// File: contracts/abstract/ERC1155.sol


pragma solidity 0.8.9;







/**
 * @dev Implementation of Multi-Token Standard contract
 */
abstract contract ERC1155 is IERC1155, IERC165, ERC1155Metadata {
    using SafeMath for uint256;
    using Address for address;

    /***********************************|
     *   |        Variables and Events       |
     |__________________________________*/
    // onReceive function signatures
    bytes4 internal constant ERC1155_RECEIVED_VALUE = 0xf23a6e61;
    bytes4 internal constant ERC1155_BATCH_RECEIVED_VALUE = 0xbc197c81;

    // Objects balances
    mapping(address => mapping(uint256 => uint256)) internal balances;

    // Operator Functions
    mapping(address => mapping(address => bool)) internal operators;

    /***********************************|
     *   |     Public Transfer Functions     |
     |__________________________________*/
    /**
     * @notice Transfers amount amount of an _id from the _from address to the _to address specified
     * @param _from    Source address
     * @param _to      Target address
     * @param _id      ID of the token type
     * @param _amount  Transfered amount
     * @param _data    Additional data with no specified format, sent in call to `_to`
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    )
        public override virtual {
        require((
                msg.sender == _from
                )
            || _isApprovedForAll(_from, msg.sender), "ERC1155#safeTransferFrom: INVALID_OPERATOR");
        require(_to != address(0), "ERC1155#safeTransferFrom: INVALID_RECIPIENT");
        // require(_amount >= balances[_from][_id]) is not necessary since checked with safemath operations
        _safeTransferFrom(_from, _to, _id, _amount);
        _callonERC1155Received(_from, _to, _id, _amount, _data);
    }

    /**
     * @notice Send multiple types of Tokens from the _from address to the _to address (with safety call)
     * @param _from     Source addresses
     * @param _to       Target addresses
     * @param _ids      IDs of each token type
     * @param _amounts  Transfer amounts per token type
     * @param _data     Additional data with no specified format, sent in call to `_to`
     */
    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    )
        public override virtual {
        // Requirements
        require((
                msg.sender == _from
                )
            || _isApprovedForAll(_from, msg.sender), "ERC1155#safeBatchTransferFrom: INVALID_OPERATOR");
        require(_to != address(0), "ERC1155#safeBatchTransferFrom: INVALID_RECIPIENT");

        _safeBatchTransferFrom(_from, _to, _ids, _amounts);
        _callonERC1155BatchReceived(_from, _to, _ids, _amounts, _data);
    }

    /***********************************|
     *   |    Internal Transfer Functions    |
     |__________________________________*/
    /**
     * @dev Transfers amount amount of an _id from the _from address to the _to address specified
     * @param _from    Source address
     * @param _to      Target address
     * @param _id      ID of the token type
     * @param _amount  Transfered amount
     */
    function _safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount
    )
        internal {
        // Update balances
        balances[_from][_id] = balances[_from][_id].sub (
            _amount
            )
        ; // Subtract amount
        balances[_to][_id] = balances[_to][_id].add(_amount); // Add amount
        // Emit event
        emit TransferSingle(msg.sender, _from, _to, _id, _amount);
    }

    /**
     * @dev Verifies if receiver is contract and if so, calls (_to).onERC1155Received(...)
     */
    function _callonERC1155Received(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    )
        internal {
        if (_to.isContract()) {
            try IERC1155TokenReceiver(_to).onERC1155Received(msg.sender, _from, _id, _amount, _data) returns (bytes4 response) {
                if (response != ERC1155_RECEIVED_VALUE) {
                    revert("ERC1155#_callonERC1155Received: INVALID_ON_RECEIVE_MESSAGE");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155#_callonERC1155Received: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    /**
     * @dev Send multiple types of Tokens from the _from address to the _to address (with safety call)
     * @param _from     Source addresses
     * @param _to       Target addresses
     * @param _ids      IDs of each token type
     * @param _amounts  Transfer amounts per token type
     */
    function _safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts
    )
        internal {
        require (
            _ids.length == _amounts.length, "ERC1155#_safeBatchTransferFrom: INVALID_ARRAYS_LENGTH"
            )
        ;

        // Number of transfer to execute
        uint256 nTransfer = _ids.length;

        // Executing all transfers
        for (uint256 i = 0; i < nTransfer;i++) {
            // Update storage balance of previous bin
            balances[_from][_ids[i]] = balances[_from][_ids[i]].sub(_amounts[i]);
            balances[_to][_ids[i]] = balances[_to][_ids[i]].add(_amounts[i]);
        }

        // Emit event
        emit TransferBatch(msg.sender, _from, _to, _ids, _amounts);
    }

    /**
     * @dev Verifies if receiver is contract and if so, calls (_to).onERC1155BatchReceived(...)
     */
    function _callonERC1155BatchReceived(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    )
        internal {
        // Check if recipient is contract
        if (_to.isContract()
        ) {
            try IERC1155TokenReceiver(_to).onERC1155BatchReceived(msg.sender, _from, _ids, _amounts, _data) returns (bytes4 response) {
                if (response != ERC1155_BATCH_RECEIVED_VALUE) {
                    revert("ERC1155#_callonERC1155BatchReceived: INVALID_ON_RECEIVE_MESSAGE");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155#_callonERC1155BatchReceived: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    /**
     * @notice Enable or disable approval for a third party ("operator") to manage all of caller's tokens
     * @param _operator  Address to add to the set of authorized operators
     * @param _approved  True if the operator is approved, false to revoke approval
     */
    function setApprovalForAll(address _operator, bool _approved) external override {
        // Update operator status
        operators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    /**
     * @dev Queries the approval status of an operator for a given owner
     * @param _owner      The owner of the Tokens
     * @param _operator   Address of authorized operator
     * @return isOperator true if the operator is approved, false if not
     */
    function _isApprovedForAll(
        address _owner,
        address _operator
    )
        internal
        view
        returns (bool isOperator) {
        return operators[_owner][_operator];
    }

    /**
     * @notice Get the balance of an account's Tokens
     * @param _owner  The address of the token holder
     * @param _id     ID of the Token
     * @return The _owner's balance of the Token type requested
     */
    function balanceOf(address _owner, uint256 _id) override public view returns (uint256) {
        return balances[_owner][_id];
    }

    /**
     * @notice Get the balance of multiple account/token pairs
     * @param _owners The addresses of the token holders
     * @param _ids    ID of the Tokens
     * @return        The _owner's balance of the Token types requested (i.e. balance for each (owner, id) pair)
     */
    function balanceOfBatch(address[] memory _owners, uint256[] memory _ids)
        override
        public
        view
        returns (uint256[] memory) {
        require(_owners.length == _ids.length, "ERC1155#balanceOfBatch: INVALID_ARRAY_LENGTH");

        // Variables
        uint256[] memory batchBalances = new uint256[](_owners.length);

        // Iterate over each owner and token ID
        for (uint256 i = 0; i < _owners.length;i++) {
            batchBalances[i] = balances[_owners[i]][_ids[i]];
        }

        return batchBalances;
    }

    /*
     * INTERFACE_SIGNATURE_ERC165 = bytes4(keccak256("supportsInterface(bytes4)"));
     */
    bytes4 private constant INTERFACE_SIGNATURE_ERC165 = 0x01ffc9a7;

    /*
     * INTERFACE_SIGNATURE_ERC1155 =
     * bytes4(keccak256("safeTransferFrom(address,address,uint256,uint256,bytes)")) ^
     * bytes4(keccak256("safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)")) ^
     * bytes4(keccak256("balanceOf(address,uint256)")) ^
     * bytes4(keccak256("balanceOfBatch(address[],uint256[])")) ^
     * bytes4(keccak256("setApprovalForAll(address,bool)")) ^
     * bytes4(keccak256("isApprovedForAll(address,address)"));
     */
    bytes4 private constant INTERFACE_SIGNATURE_ERC1155 = 0xd9b67a26;

    /**
     * @notice Query if a contract implements an interface
     * @param _interfaceID  The interface identifier, as specified in ERC-165
     * @return `true` if the contract implements `_interfaceID` and
     */
    function supportsInterface(bytes4 _interfaceID) override external pure returns (bool) {
        if (_interfaceID == INTERFACE_SIGNATURE_ERC165 || _interfaceID == INTERFACE_SIGNATURE_ERC1155) {
            return true;
        }
        return false;
    }
}



// File: contracts/abstract/ERC1155MintBurn.sol


pragma solidity 0.8.9;



/**
 * @dev Multi-Fungible Tokens with minting and burning methods. These methods assume
 *      a parent contract to be executed as they are `internal` functions
 */
abstract contract ERC1155MintBurn is ERC1155 {
    using SafeMath for uint256;

    /****************************************|
     *   |            Minting Functions           |
     |_______________________________________*/
    /**
     * @dev Mint _amount of tokens of a given id
     * @param _to      The address to mint tokens to
     * @param _id      Token id to mint
     * @param _amount  The amount to be minted
     * @param _data    Data to pass if receiver is contract
     */
    function _mint(address _to, uint256 _id, uint256 _amount, bytes memory _data) internal {
        // Add _amount
        balances[_to][_id] = balances[_to][_id].add(_amount);

        // Emit event
        emit TransferSingle(msg.sender, address(0x0), _to, _id, _amount);

        // Calling onReceive method if recipient is contract
        _callonERC1155Received(address(0x0), _to, _id, _amount, _data);
    }

    /**
     * @dev Mint tokens for each ids in _ids
     * @param _to       The address to mint tokens to
     * @param _ids      Array of ids to mint
     * @param _amounts  Array of amount of tokens to mint per id
     * @param _data    Data to pass if receiver is contract
     */
    function _batchMint(
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    )
        internal {
        require (
            _ids.length == _amounts.length, "ERC1155MintBurn#batchMint: INVALID_ARRAYS_LENGTH"
            )
        ;

        // Number of mints to execute
        uint256 nMint = _ids.length;

        // Executing all minting
        for (uint256 i = 0; i < nMint;i++) {
            // Update storage balance
            balances[_to][_ids[i]] = balances[_to][_ids[i]].add(_amounts[i]);
        }

        // Emit batch mint event
        emit TransferBatch(msg.sender, address(0x0), _to, _ids, _amounts);

        // Calling onReceive method if recipient is contract
        _callonERC1155BatchReceived(address(0x0), _to, _ids, _amounts, _data);
    }

    /****************************************|
     *   |            Burning Functions           |
     |_______________________________________*/
    /**
     * @dev Burn _amount of tokens of a given token id
     * @param _from    The address to burn tokens from
     * @param _id      Token id to burn
     * @param _amount  The amount to be burned
     */
    function _burn(address _from, uint256 _id,
        uint256 _amount) internal {
        // Substract _amount
        balances[_from][_id] = balances[_from][_id].sub(_amount);

        // Emit event
        emit TransferSingle(msg.sender, _from, address(0x0), _id, _amount);
    }

    /**
     * @dev Burn tokens of given token id for each (_ids[i], _amounts[i]) pair
     * @param _from     The address to burn tokens from
     * @param _ids      Array of token ids to burn
     * @param _amounts  Array of the amount to be burned
     */
    function _batchBurn(
        address _from,
        uint256[] memory _ids,
        uint256[] memory _amounts
    )
        internal {
        require (
            _ids.length == _amounts.length, "ERC1155MintBurn#batchBurn: INVALID_ARRAYS_LENGTH"
            )
        ;

        // Number of mints to execute
        uint256 nBurn = _ids.length;

        // Executing all minting
        for (uint256 i = 0; i < nBurn;i++) {
            // Update storage balance
            balances[_from][_ids[i]] = balances[_from][_ids[i]].sub(_amounts[i]);
        }

        // Emit batch mint event
        emit TransferBatch(msg.sender, _from, address(0x0), _ids, _amounts);
    }
}



// File: contracts/abstract/ERC1155Tradable.sol


pragma solidity 0.8.9;








/**
 * @title ERC1155Tradable
 * ERC1155Tradable - ERC1155 contract that whitelists an operator address, 
 * has create and mint functionality, and supports useful standards from OpenZeppelin,
 *   like _exists(), name(), symbol(), and totalSupply()
 */
abstract contract ERC1155Tradable is ERC1155MintBurn, Ownable, MinterRole {
    using SafeMath for uint256;
    using Address for address;

    // OpenSea proxy registry to ease selling NFTs on OpenSea
    address public proxyRegistryAddress;

    mapping(uint256 => address) public creators;
    mapping(uint256 => uint256) public tokenSupply;
    mapping(uint256 => uint256) public tokenMaxSupply;
    mapping(uint256 => uint8) public tokenCityIndex;
    mapping(uint256 => uint8) public tokenType;

    // Contract name
    string public name;

    // Contract symbol
    string public symbol;

    // URI's default URI prefix
    string internal baseMetadataURI;

    uint256 internal _currentTokenID = 0;

    constructor (string memory _name, string memory _symbol, address _proxyRegistryAddress, string memory _baseMetadataURI) {
        name = _name;
        symbol = _symbol;
        proxyRegistryAddress = _proxyRegistryAddress;
        baseMetadataURI = _baseMetadataURI;
    }

    function contractURI() public view returns (string memory) {
        return string(abi.encodePacked(baseMetadataURI));
    }

    /**
     * @dev Returns URIs are defined in RFC 3986.
     *      URIs are assumed to be deterministically generated based on token ID
     *      Token IDs are assumed to be represented in their hex format in URIs
     * @return URI string
     */
    function uri(uint256 _id) override external view returns (string memory) {
        require(_exists(_id), "Deed NFT doesn't exists");
        return string(abi.encodePacked(baseMetadataURI, _uint2str(_id)));
    }

    /**
     * @dev Returns the total quantity for a token ID
     * @param _id uint256 ID of the token to query
     * @return amount of token in existence
     */
    function totalSupply(uint256 _id) public view returns (uint256) {
        return tokenSupply[_id];
    }

    /**
     * @dev Returns the max quantity for a token ID
     * @param _id uint256 ID of the token to query
     * @return amount of token in existence
     */
    function maxSupply(uint256 _id) public view returns (uint256) {
        return tokenMaxSupply[_id];
    }

    /**
     * @dev return city index of designated NFT with its identifier
     */
    function cityIndex(uint256 _id) public view returns (uint256) {
        require(_exists(_id), "Deed NFT doesn't exists");
        return tokenCityIndex[_id];
    }

    /**
     * @dev return card type of designated NFT with its identifier
     */
    function cardType(uint256 _id) public view returns (uint256) {
        require(_exists(_id), "Deed NFT doesn't exists");
        return tokenType[_id];
    }

    /**
     * @dev Creates a new token type and assigns _initialSupply to an address
     * @param _initialOwner the first owner of the Token
     * @param _initialSupply Optional amount to supply the first owner (1 for NFT)
     * @param _maxSupply max supply allowed (1 for NFT)
     * @param _cityIndex city index of NFT
     *    (0 = Tanit, 1 = Reshef, 2 = Ashtarte, 3 = Melqart, 4 = Eshmun, 5 = Kushor, 6 = Hammon)
     * @param _type card type of NFT
     *    (0 = Common, 1 = Uncommon, 2 = Rare, 3 = Legendary)
     * @param _data Optional data to pass if receiver is contract
     * @return The newly created token ID
     */
    function create(
        address _initialOwner,
        uint256 _initialSupply,
        uint256 _maxSupply,
        uint8 _cityIndex,
        uint8 _type,
        bytes memory _data
    ) public onlyMinter returns (uint256) {
        require(_initialSupply <= _maxSupply, "_initialSupply > _maxSupply");
        uint256 _id = _getNextTokenID();
        _incrementTokenTypeId();
        creators[_id] = _initialOwner;

        if (_initialSupply != 0) {
            _mint(_initialOwner, _id, _initialSupply, _data);
        }
        tokenSupply[_id] = _initialSupply;
        tokenMaxSupply[_id] = _maxSupply;
        tokenCityIndex[_id] = _cityIndex;
        tokenType[_id] = _type;
        return _id;
    }

    /**
     * @dev Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-free listings.
     * @param _owner      The owner of the Tokens
     * @param _operator   Address of authorized operator
     * @return isOperator true if the operator is approved, false if not
     */
    function isApprovedForAll(address _owner, address _operator) override public view returns (bool isOperator) {
        // Whitelist OpenSea proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(_owner)) == _operator) {
            return true;
        }

        return _isApprovedForAll(_owner, _operator);
    }

    /**
     * @dev Returns whether the specified token exists by checking to see if it has a creator
     * @param _id uint256 ID of the token to query the existence of
     * @return bool whether the token exists
     */
    function _exists(uint256 _id) internal view returns (bool) {
        return creators[_id] != address(0);
    }

    /**
     * @dev calculates the next token ID based on value of _currentTokenID
     * @return uint256 for the next token ID
     */
    function _getNextTokenID() private view returns (uint256) {
        return _currentTokenID.add(1);
    }

    /**
     * @dev increments the value of _currentTokenID
     */
    function _incrementTokenTypeId() private {
        _currentTokenID++;
    }

    /**
     * @dev Convert uint256 to string
     * @param _i Unsigned integer to convert to string
     */
    function _uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
            if (k > 0) {
                k--;
            }
        }
        return string(bstr);
    }

}
// File: contracts/abstract/IERC20.sol


pragma solidity 0.8.9;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
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



// File: contracts/abstract/ERC20.sol


pragma solidity 0.8.9;





/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
abstract contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory tokenName, string memory tokenSymbol) {
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        virtual
        override
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: contracts/abstract/XMeedsToken.sol


pragma solidity 0.8.9;








abstract contract XMeedsToken is ERC20("Staked MEED", "xMEED"), Ownable {
    using SafeMath for uint256;
    IERC20 public meed;
    FundDistribution public rewardDistribution;

    constructor(IERC20 _meed, FundDistribution _rewardDistribution) {
        meed = _meed;
        rewardDistribution = _rewardDistribution;
    }

    /**
     * @dev This method will:
     * 1/ retrieve staked amount of MEEDs that should already been approved on ERC20 MEED Token
     * 2/ Send back some xMEED ERC20 Token for staker
     */
    function _stake(uint256 _amount) internal {
        // Retrieve MEEDs from Reserve Fund (TokenFactory)
        require(rewardDistribution.sendReward(address(this)) == true, "Error retrieving funds from reserve");

        uint256 totalMeed = meed.balanceOf(address(this));
        uint256 totalShares = totalSupply();
        if (totalShares == 0 || totalMeed == 0) {
            _mint(_msgSender(), _amount);
        } else {
            uint256 what = _amount.mul(totalShares).div(totalMeed);
            _mint(_msgSender(), what);
        }
        meed.transferFrom(_msgSender(), address(this), _amount);
    }

    /**
     * @dev This method will:
     * 1/ Withdraw staked amount of MEEDs that wallet has already staked in this contract
     *  plus a proportion of Rewarded MEEDs sent from TokenFactory/MasterChef
     * 2/ Burn equivalent amount of xMEED from caller account
     */
    function _withdraw(uint256 _amount) internal {
        // Retrieve MEEDs from Reserve Fund (TokenFactory)
        require(rewardDistribution.sendReward(address(this)) == true, "Error retrieving funds from reserve");

        uint256 totalMeed = meed.balanceOf(address(this));
        uint256 totalShares = totalSupply();
        uint256 what = _amount.mul(totalMeed).div(totalShares);
        _burn(_msgSender(), _amount);
        meed.transfer(_msgSender(), what);
    }
}
// File: contracts/abstract/MeedsPointsRewarding.sol


pragma solidity 0.8.9;



contract MeedsPointsRewarding is XMeedsToken {
    using SafeMath for uint256;

    // The block time when Points rewarding will starts
    uint256 public startRewardsTime;

    mapping(address => uint256) internal points;
    mapping(address => uint256) internal pointsLastUpdateTime;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    /**
     * @dev a modifier to store earned points for a designated address until
     * current block after having staked some MEEDs. if the Points rewarding didn't started yet
     * the address will not receive points yet.
     */
    modifier updateReward(address account) {
        if (account != address(0)) {
          if (block.timestamp < startRewardsTime) {
            points[account] = 0;
            pointsLastUpdateTime[account] = startRewardsTime;
          } else {
            points[account] = earned(account);
            pointsLastUpdateTime[account] = block.timestamp;
          }
        }
        _;
    }

    constructor (IERC20 _meed, FundDistribution _rewardDistribution, uint256 _startRewardsTime) XMeedsToken(_meed, _rewardDistribution) {
        startRewardsTime = _startRewardsTime;
    }

    /**
     * @dev returns the earned points for the designated address after having staked some MEEDs
     * token. If the Points rewarding distribution didn't started yet, 0 will be returned instead.
     */
    function earned(address account) public view returns (uint256) {
        if (block.timestamp < startRewardsTime) {
          return 0;
        } else {
          uint256 timeDifference = block.timestamp.sub(pointsLastUpdateTime[account]);
          uint256 balance = balanceOf(account);
          uint256 decimals = 1e18;
          uint256 x = balance / decimals;
          uint256 ratePerSecond = decimals.mul(x).div(x.add(12000)).div(240);
          return points[account].add(ratePerSecond.mul(timeDifference));
        }
    }

    /**
     * @dev This method will:
     * 1/ Update Rewarding Points for address of caller (using modifier)
     * 2/ retrieve staked amount of MEEDs that should already been approved on ERC20 MEED Token
     * 3/ Send back some xMEED ERC20 Token for staker
     */
    function stake(uint256 amount) public updateReward(msg.sender) {
        require(amount > 0, "Invalid amount");

        _stake(amount);
        emit Staked(msg.sender, amount);
    }

    /**
     * @dev This method will:
     * 1/ Update Rewarding Points for address of caller (using modifier)
     * 2/ Withdraw staked amount of MEEDs that wallet has already staked in this contract
     *  plus a proportion of Rewarded MEEDs sent from TokenFactory/MasterChef
     * 3/ Burn equivalent amount of xMEED from caller account
     */
    function withdraw(uint256 amount) public updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");

        _withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @dev This method will:
     * 1/ Update Rewarding Points for address of caller (using modifier)
     * 2/ Withdraw all staked MEEDs that are wallet has staked in this contract
     *  plus a proportion of Rewarded MEEDs sent from TokenFactory/MasterChef
     * 3/ Burn equivalent amount of xMEED from caller account
     */
    function exit() external {
        withdraw(balanceOf(msg.sender));
    }

    /**
     * @dev ERC-20 transfer method in addition to updating earned points
     * of spender and recipient (using modifiers)
     */
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        updateReward(msg.sender)
        updateReward(recipient)
        returns (bool) {
        return super.transfer(recipient, amount);
    }

    /**
     * @dev ERC-20 transferFrom method in addition to updating earned points
     * of spender and recipient (using modifiers)
     */
    function transferFrom(address sender, address recipient, uint256 amount)
        public
        virtual
        override
        updateReward(sender)
        updateReward(recipient)
        returns (bool) {
        return super.transferFrom(sender, recipient, amount);
    }

}



// File: contracts/XMeedsNFTRewarding.sol


pragma solidity 0.8.9;




contract XMeedsNFTRewarding is MeedsPointsRewarding {
    using SafeMath for uint256;

    // Info of each Card Type
    struct CardTypeDetail {
        string name;
        uint8 cityIndex;
        uint8 cardType;
        uint32 supply;
        uint32 maxSupply;
        uint256 amount;
    }

    // Info of each City
    struct CityDetail {
        string name;
        uint32 population;
        uint32 maxPopulation;
        uint256 availability;
    }

    ERC1155Tradable public nft;

    CardTypeDetail[] public cardTypeInfo;
    CityDetail[] public cityInfo;
    uint8 public currentCityIndex = 0;
    uint256 public lastCityMintingCompleteDate = 0;

    event Redeemed(address indexed user, string city, string cardType, uint256 id);
    event NFTSet(ERC1155Tradable indexed newNFT);

    constructor (
        IERC20 _meed,
        FundDistribution _rewardDistribution,
        ERC1155Tradable _nftAddress,
        uint256 _startRewardsTime,
        string[] memory _cityNames,
        string[] memory _cardNames,
        uint256[] memory _cardPrices,
        uint32[] memory _cardSupply
    ) MeedsPointsRewarding(_meed, _rewardDistribution, _startRewardsTime) {
        nft = _nftAddress;
        lastCityMintingCompleteDate = block.timestamp;

        uint256 citiesLength = _cityNames.length;
        uint256 cardsLength = _cardNames.length;
        uint32 citiesCardsLength = uint32(citiesLength * cardsLength);
        require(uint32(_cardSupply.length) == citiesCardsLength, "Provided Supply list per card per city must equal to Card Type length");

        uint256 _month = 30 days;
        uint256 _index = 0;
        for (uint8 i = 0; i < citiesLength; i++) {
            uint32 _maxPopulation = 0;
            for (uint8 j = 0; j < cardsLength; j++) {
                string memory _cardName = _cardNames[j];
                uint256 _cardPrice = _cardPrices[j];
                uint32 _maxSupply = _cardSupply[_index];
                cardTypeInfo.push(CardTypeDetail({
                    name: _cardName,
                    cityIndex: i,
                    cardType: j,
                    amount: _cardPrice,
                    supply: 0,
                    maxSupply: _maxSupply
                }));
                _maxPopulation += _maxSupply;
                _index++;
            }

            uint256 _availability = i > 0 ? ((2 ** (i + 1)) * _month) : 0;
            string memory _cityName = _cityNames[i];
            cityInfo.push(CityDetail({
                name: _cityName,
                population: 0,
                maxPopulation: _maxPopulation,
                availability: _availability
            }));
        }
    }

    /**
     * @dev Set MEED NFT address
     */
    function setNFT(ERC1155Tradable _nftAddress) public onlyOwner {
        nft = _nftAddress;
        emit NFTSet(_nftAddress);
    }

    /**
     * @dev Checks if current city is mintable
     */
    function isCurrentCityMintable() public view returns (bool) {
        return block.timestamp > cityMintingStartDate();
    }

    /**
     * @dev returns current city minting start date
     */
    function cityMintingStartDate() public view returns (uint256) {
        CityDetail memory city = cityInfo[currentCityIndex];
        return city.availability.add(lastCityMintingCompleteDate);
    }

    /**
     * @dev Redeem an NFT by minting it and substracting the amount af Points (Card Type price)
     * from caller balance of points.
     */
    function redeem(uint8 cardTypeId) public updateReward(msg.sender) returns (uint256 tokenId) {
        require(cardTypeId < cardTypeInfo.length, "Card Type doesn't exist");

        CardTypeDetail storage cardType = cardTypeInfo[cardTypeId];
        require(cardType.maxSupply > 0, "Card Type not available for minting");
        require(points[msg.sender] >= cardType.amount, "Not enough points to redeem for card");
        require(cardType.supply < cardType.maxSupply, "Max cards supply reached");
        require(cardType.cityIndex == currentCityIndex, "Designated city isn't available for minting yet");

        CityDetail storage city = cityInfo[cardType.cityIndex];
        require(block.timestamp > city.availability.add(lastCityMintingCompleteDate), "Designated city isn't available for minting yet");

        city.population = city.population + 1;
        cardType.supply = cardType.supply + 1;
        if (city.population >= city.maxPopulation) {
            currentCityIndex++;
            lastCityMintingCompleteDate = block.timestamp;
        }

        points[msg.sender] = points[msg.sender].sub(cardType.amount);
        uint256 _tokenId = nft.create(msg.sender, 1, 1, cardType.cityIndex, cardType.cardType, "");
        emit Redeemed(msg.sender, city.name, cardType.name, _tokenId);
        return _tokenId;
    }

}