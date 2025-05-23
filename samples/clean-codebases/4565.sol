/**
 *Submitted for verification at Etherscan.io on 2022-04-27
*/

// File: @openzeppelin/contracts/utils/cryptography/MerkleProof.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merklee tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
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

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;


/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/token/ERC1155/IERC1155.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// File: @openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

// File: @openzeppelin/contracts/token/ERC1155/ERC1155.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;







/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

// File: @openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/ERC1155Pausable.sol)

pragma solidity ^0.8.0;



/**
 * @dev ERC1155 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 *
 * _Available since v3.1._
 */
abstract contract ERC1155Pausable is ERC1155, Pausable {
    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        require(!paused(), "ERC1155Pausable: token transfer while paused");
    }
}

// File: contracts/Ragnarok.sol


pragma solidity 0.8.13;




contract Ragnarok is ERC1155Pausable, Ownable {
    uint256 private _tokenIds;

    string public constant name = "Ragnarok";
    string public constant symbol = "RONIN";

    enum SaleType {
        NotStarted,
        FirstPublicMint,
        PixelMint,
        PillMint,
        TeamMint,
        LastPublicMint
    }

    address payable public defaultPlatformAddress;
    address public defaultPlatformMintingAddress;
    bytes32 public merkleRootOfPixelMintWhitelistAddresses;
    bytes32 public merkleRootOfPillMintWhitelistAddresses;

    uint256 public immutable defaultSaleStartTime;
    uint256 public constant DEFAULT_MAX_MINTING_SUPPLY = 7777;
    uint256 public constant DEFAULT_MAX_FIRST_PUBLIC_SUPPLY = 3900;
    uint256 public constant DEFAULT_NFT_PRICE = 0.77 * 1 ether;
    uint256 public constant DEFAULT_DECREASE_NFT_PRICE_AFTER_TIME_INTERVAL =
        0.01925 * 1 ether;
    uint256 public constant DEFAULT_TIME_INTERVAL = 7 minutes;
    uint256 public constant MAX_DECREASE_ITERATIONS = 29;

    uint256 public dutchAuctionLastPrice = 0;

    uint256 public constant DEFAULT_INITIAL_PUBLIC_SALE = 24 hours;
    uint256 public constant DEFAULT_PIXELMINT_SALE = 72 hours;
    uint256 public constant DEFAULT_PILLMINT_SALE = 96 hours;
    uint256 public constant DEFAULT_TEAMMINT_SALE = 120 hours;

    uint256 public constant LIMIT_IN_PUBLIC_SALE_PER_WALLET = 3;
    uint256 public constant TEAM_MINT_COUNT = 277;

    mapping(address => uint256) public pixelMintWhitelistedAddresses;
    mapping(address => uint256) public pillMintWhitelistedAddresses;
    mapping(address => uint256) public firstPublicSale;
    mapping(address => uint256) public lastPublicSale;
    bool public teamMintWhitelistedAddress;

    error InvalidBuyNFTPrice(uint256 actualPrice, uint256 invalidInputPrice);
    error MaximumPublicMintSupplyReached();
    error MaximumMintSupplyReached();
    error MaximumMintLimitReachedByUser();
    error WhitelistedAddressAlreadyClaimedNFT();
    error InvalidMerkleProof();
    error UnAuthorizedRequest();
    error ReimbursementAlreadyClaimed();
    error CannotClaimReimbursementInPublicMint();
    error NothingToClaim();
    error AmountReimbursementFailed();
    error InvalidTokenCountZero();
    error TransactionFailed();
    error AirdropTransactionFailed(
        address airdropAddress,
        uint256 airdropAmount
    );

    event PaymentSentInContractForReimbursements(
        uint256 amount,
        address sendBy
    );

    event ReimbursementClaimedOfPublicSale(
        address[] addresses,
        uint256[] values
    );
    event NewURI(string newURI, address updatedBy);
    event UpdatedMerkleRootOfPixelMint(bytes32 newHash, address updatedBy);
    event UpdatedMerkleRootOfPillMint(bytes32 newHash, address updatedBy);
    event UpdatedPlatformWalletAddress(
        address newPlatformAddress,
        address updatedBy
    );
    event UpdatedPlatformMintingAddress(
        address newMintingAddress,
        address updatedBy
    );
    event NewNFTMintedOnFirstPublicSale(
        uint256 tokenID,
        address mintedBy,
        uint256 price
    );
    event NewNFTBatchMintedOnFirstPublicSale(
        uint256[] tokenIDs,
        address mintedBy,
        uint256 price
    );
    event NewNFTBatchMintedOnLastPublicSale(
        uint256[] tokenIDs,
        address mintedBy,
        uint256 price
    );
    event NewNFTMintedOnPixelSale(
        uint256 tokenID,
        address mintedBy,
        uint256 price
    );
    event NewNFTMintedOnPillSale(
        uint256 tokenID,
        address mintedBy,
        uint256 price
    );
    event GenesisNFTMinted(uint256 tokenID, address mintedBy);
    event NewNFTMintedOnTeamSale(uint256[] tokenIDs, address mintedBy);
    event NewNFTMintedOnLastPublicSale(
        uint256 tokenID,
        address mintedBy,
        uint256 price
    );

    event WithdrawnPayment(uint256 contractBalance, address transferTo);
    event UpdatedSaleStartTime(uint256 saleStartTime, address updatedBy);

    constructor(
        address platformAddress,
        address platformMintingAddress,
        bytes32 pixelMerkleRoot,
        bytes32 pillMerkleRoot,
        uint256 startTimestamp,
        string memory newURI
    ) ERC1155(newURI) {
        defaultSaleStartTime = startTimestamp;
        defaultPlatformAddress = payable(platformAddress);
        defaultPlatformMintingAddress = platformMintingAddress;
        merkleRootOfPixelMintWhitelistAddresses = pixelMerkleRoot;
        merkleRootOfPillMintWhitelistAddresses = pillMerkleRoot;

        _mintGenesisNFT();

        emit NewURI(newURI, msg.sender);
        emit UpdatedMerkleRootOfPixelMint(pixelMerkleRoot, msg.sender);
        emit UpdatedMerkleRootOfPillMint(pillMerkleRoot, msg.sender);
        emit UpdatedPlatformWalletAddress(platformAddress, msg.sender);
        emit UpdatedPlatformMintingAddress(platformMintingAddress, msg.sender);
        emit UpdatedSaleStartTime(startTimestamp, msg.sender);
    }

    /**
     * @dev _mintGenesisNFT mints the NFT when the contract gets deployed
     * and genesis NFT will be sent to contract creator
     *
     * Emits a {GenesisNFTMinted} event.
     *
     **/

    function _mintGenesisNFT() internal {
        _tokenIds++;

        emit GenesisNFTMinted(_tokenIds, msg.sender);

        _mint(msg.sender, _tokenIds, 1, "");
    }

    /**
     * @dev getCurrentMintingCount returns the current minting count of NFT .
     *
     */
    function getCurrentMintingCount() external view returns (uint256) {
        return _tokenIds;
    }

    /**
     * @dev getCurrentNFTMintingPrice returns the current minting price of NFT .
     *
     */

    function getCurrentNFTMintingPrice() public view returns (uint256) {
        if (block.timestamp < defaultSaleStartTime) return DEFAULT_NFT_PRICE;

        uint256 calculateTimeDifference = block.timestamp -
            defaultSaleStartTime;

        uint256 calculateIntervals = calculateTimeDifference /
            DEFAULT_TIME_INTERVAL;

        if (calculateIntervals >= MAX_DECREASE_ITERATIONS) {
            uint256 calculatePrice = (DEFAULT_NFT_PRICE -
                (DEFAULT_DECREASE_NFT_PRICE_AFTER_TIME_INTERVAL *
                    MAX_DECREASE_ITERATIONS));

            return calculatePrice;
        } else {
            uint256 calculatePrice = (DEFAULT_NFT_PRICE -
                (DEFAULT_DECREASE_NFT_PRICE_AFTER_TIME_INTERVAL *
                    calculateIntervals));

            return calculatePrice;
        }
    }

    /**
     * @dev checkSaleType returns the current sale type status.
     *
     */

    function checkSaleType() external view returns (SaleType activeSale) {
        if (block.timestamp < defaultSaleStartTime) {
            return SaleType.NotStarted;
        } else if (
            (block.timestamp >= defaultSaleStartTime) &&
            (block.timestamp <
                defaultSaleStartTime + DEFAULT_INITIAL_PUBLIC_SALE)
        ) {
            return SaleType.FirstPublicMint;
        } else if (
            (block.timestamp >=
                defaultSaleStartTime + DEFAULT_INITIAL_PUBLIC_SALE) &&
            (block.timestamp < defaultSaleStartTime + DEFAULT_PIXELMINT_SALE)
        ) {
            return SaleType.PixelMint;
        } else if (
            (block.timestamp >=
                defaultSaleStartTime + DEFAULT_PIXELMINT_SALE) &&
            (block.timestamp < defaultSaleStartTime + DEFAULT_PILLMINT_SALE)
        ) {
            return SaleType.PillMint;
        } else if (
            (block.timestamp >= defaultSaleStartTime + DEFAULT_PILLMINT_SALE) &&
            (block.timestamp < defaultSaleStartTime + DEFAULT_TEAMMINT_SALE)
        ) {
            return SaleType.TeamMint;
        } else if (
            (block.timestamp >= defaultSaleStartTime + DEFAULT_TEAMMINT_SALE)
        ) {
            return SaleType.LastPublicMint;
        }
    }

    /**
     * @dev updateTokenURI updates the new token URI in contract.
     *
     * Emits a {NewURI} event.
     *
     * Requirements:
     *
     * - Only owner of contract can call this function
     **/

    function updateTokenURI(string memory newuri)
        external
        onlyOwner
        returns (bool)
    {
        _setURI(newuri);
        emit NewURI(newuri, msg.sender);
        return true;
    }

    /**
     * @dev updatePixelMintMerkleRoot updates the pixel mint merkle hash in contract.
     *
     * Emits a {UpdatedMerkleRootOfPixelMint} event.
     *
     * Requirements:
     *
     * - Only owner of contract can call this function
     **/

    function updatePixelMintMerkleRoot(bytes32 hash)
        external
        onlyOwner
        returns (bool)
    {
        merkleRootOfPixelMintWhitelistAddresses = hash;
        emit UpdatedMerkleRootOfPixelMint(hash, msg.sender);

        return true;
    }

    /**
     * @dev updatePixelMintMerkleRoot updates the pill mint merkle hash in contract.
     *
     * Emits a {UpdatedMerkleRootOfPillMint} event.
     *
     * Requirements:
     *
     * - Only owner of contract can call this function
     **/

    function updatePillMintMerkleRoot(bytes32 hash)
        external
        onlyOwner
        returns (bool)
    {
        merkleRootOfPillMintWhitelistAddresses = hash;
        emit UpdatedMerkleRootOfPillMint(hash, msg.sender);

        return true;
    }

    /**
     * @dev updatePlatformWalletAddress updates the platform wallet address in contract.
     *
     * Emits a {UpdatedPlatformWalletAddress} event.
     *
     * Requirements:
     *
     * - Only owner of contract can call this function
     **/

    function updatePlatformWalletAddress(address newAddress)
        external
        onlyOwner
        returns (bool)
    {
        defaultPlatformAddress = payable(newAddress);
        emit UpdatedPlatformWalletAddress(newAddress, msg.sender);

        return true;
    }

    /**
     * @dev pauseContract is used to pause contract.
     *
     * Emits a {Paused} event.
     *
     * Requirements:
     *
     * - Only the owner can call this function
     **/

    function pauseContract() external onlyOwner returns (bool) {
        _pause();
        return true;
    }

    /**
     * @dev unpauseContract is used to unpause contract.
     *
     * Emits a {Unpaused} event.
     *
     * Requirements:
     *
     * - Only the owner can call this function
     **/

    function unpauseContract() external onlyOwner returns (bool) {
        _unpause();
        return true;
    }

    /**
     * @dev firstPublicMintingSale mints single NFT in one transaction in First Public Minting.
     *
     * Emits a {NewNFTMintedOnFirstPublicSale} event.
     *
     * Requirements:
     *
     * - User can mint max 3 NFTs in each First Public Sale
     **/

    function firstPublicMintingSale() external payable returns (bool) {
        if (
            (block.timestamp >= defaultSaleStartTime) &&
            (block.timestamp <
                defaultSaleStartTime + DEFAULT_INITIAL_PUBLIC_SALE)
        ) {
            _tokenIds++;

            if (_tokenIds > DEFAULT_MAX_FIRST_PUBLIC_SUPPLY)
                revert MaximumPublicMintSupplyReached();

            if (firstPublicSale[msg.sender] >= LIMIT_IN_PUBLIC_SALE_PER_WALLET)
                revert MaximumMintLimitReachedByUser();

            uint256 getPriceOFNFT = getCurrentNFTMintingPrice();

            if (getPriceOFNFT != msg.value)
                revert InvalidBuyNFTPrice(getPriceOFNFT, msg.value);

            dutchAuctionLastPrice = getPriceOFNFT;

            firstPublicSale[msg.sender] = firstPublicSale[msg.sender] + 1;

            emit NewNFTMintedOnFirstPublicSale(
                _tokenIds,
                msg.sender,
                msg.value
            );

            _mint(msg.sender, _tokenIds, 1, "");

            return true;
        } else {
            revert UnAuthorizedRequest();
        }
    }

    /**
     * @dev pixelMintingSale mints single NFT in one transaction for whitelist address in Pixel Minting.
     *
     * Emits a {NewNFTMintedOnPixelSale} event.
     *
     * Requirements:
     *
     * - User can mint 1 NFT in Pixel sale if his address is whitelisted
     **/

    function pixelMintingSale(bytes32[] calldata _merkleProof)
        external
        payable
        returns (bool)
    {
        if (
            (block.timestamp >=
                defaultSaleStartTime + DEFAULT_INITIAL_PUBLIC_SALE) &&
            (block.timestamp < defaultSaleStartTime + DEFAULT_PIXELMINT_SALE)
        ) {
            _tokenIds++;

            if (dutchAuctionLastPrice != msg.value)
                revert InvalidBuyNFTPrice(dutchAuctionLastPrice, msg.value);

            if (pixelMintWhitelistedAddresses[msg.sender] != 0)
                revert WhitelistedAddressAlreadyClaimedNFT();

            bytes32 leaf = keccak256(abi.encodePacked(msg.sender));

            if (
                !MerkleProof.verify(
                    _merkleProof,
                    merkleRootOfPixelMintWhitelistAddresses,
                    leaf
                )
            ) revert InvalidMerkleProof();

            pixelMintWhitelistedAddresses[msg.sender] = 1;

            emit NewNFTMintedOnPixelSale(_tokenIds, msg.sender, msg.value);

            _mint(msg.sender, _tokenIds, 1, "");

            return true;
        } else {
            revert UnAuthorizedRequest();
        }
    }

    /**
     * @dev pillMintingSale mints single NFT in one transaction for whitelist address in Pill Minting.
     *
     * Emits a {NewNFTMintedOnPillSale} event.
     *
     * Requirements:
     *
     * - User can mint 1 NFT in Pill sale if his address is whitelisted
     **/

    function pillMintingSale(bytes32[] calldata _merkleProof)
        external
        payable
        returns (bool)
    {
        if (
            (block.timestamp >=
                defaultSaleStartTime + DEFAULT_PIXELMINT_SALE) &&
            (block.timestamp < defaultSaleStartTime + DEFAULT_PILLMINT_SALE)
        ) {
            _tokenIds++;

            if (pillMintWhitelistedAddresses[msg.sender] != 0)
                revert WhitelistedAddressAlreadyClaimedNFT();

            if ((dutchAuctionLastPrice / 2) != msg.value)
                revert InvalidBuyNFTPrice(
                    (dutchAuctionLastPrice / 2),
                    msg.value
                );

            bytes32 leaf = keccak256(abi.encodePacked(msg.sender));

            if (
                !MerkleProof.verify(
                    _merkleProof,
                    merkleRootOfPillMintWhitelistAddresses,
                    leaf
                )
            ) revert InvalidMerkleProof();

            pillMintWhitelistedAddresses[msg.sender] = 1;

            emit NewNFTMintedOnPillSale(_tokenIds, msg.sender, msg.value);

            _mint(msg.sender, _tokenIds, 1, "");

            return true;
        } else {
            revert UnAuthorizedRequest();
        }
    }

    /**
     * @dev teamMintingSale mints 277 NFTs in one transaction for platform wallet address in Team Minting.
     *
     * Emits a {NewNFTMintedOnPillSale} event.
     *
     * Requirements:
     *
     * - Team can mint 277 NFTs once in Team sale
     **/

    function teamMintingSale() external returns (bool) {
        if (
            (block.timestamp >= defaultSaleStartTime + DEFAULT_PILLMINT_SALE) &&
            (block.timestamp < defaultSaleStartTime + DEFAULT_TEAMMINT_SALE)
        ) {
            if (msg.sender != defaultPlatformMintingAddress)
                revert UnAuthorizedRequest();
            if (teamMintWhitelistedAddress)
                revert WhitelistedAddressAlreadyClaimedNFT();

            teamMintWhitelistedAddress = true;

            uint256[] memory newIDs = new uint256[](TEAM_MINT_COUNT);
            uint256[] memory newAmounts = new uint256[](TEAM_MINT_COUNT);

            uint256 _internalTokenID = _tokenIds;

            for (uint256 i = 0; i < TEAM_MINT_COUNT; i++) {
                _internalTokenID++;

                newIDs[i] = _internalTokenID;
                newAmounts[i] = 1;
            }

            _tokenIds = _internalTokenID;

            emit NewNFTMintedOnTeamSale(newIDs, msg.sender);

            _mintBatch(msg.sender, newIDs, newAmounts, "");

            return true;
        } else {
            revert UnAuthorizedRequest();
        }
    }

    /**
     * @dev lastPublicMintingSale mints the new NFT depending upon the sale type.
     *
     * Emits a {NewNFTMintedOnLastPublicSale} event.
     *
     * Requirements:
     *
     * - User can mint max 3 NFTs in Last Public Sale
     **/

    function lastPublicMintingSale() external payable returns (bool) {
        if ((block.timestamp >= defaultSaleStartTime + DEFAULT_TEAMMINT_SALE)) {
            _tokenIds++;

            if (_tokenIds > DEFAULT_MAX_MINTING_SUPPLY)
                revert MaximumMintSupplyReached();

            if (lastPublicSale[msg.sender] >= LIMIT_IN_PUBLIC_SALE_PER_WALLET)
                revert MaximumMintLimitReachedByUser();

            if (dutchAuctionLastPrice != msg.value)
                revert InvalidBuyNFTPrice(dutchAuctionLastPrice, msg.value);

            lastPublicSale[msg.sender] = lastPublicSale[msg.sender] + 1;

            emit NewNFTMintedOnLastPublicSale(_tokenIds, msg.sender, msg.value);

            _mint(msg.sender, _tokenIds, 1, "");

            return true;
        } else {
            revert UnAuthorizedRequest();
        }
    }

    /**
     * @dev firstPublicSaleBatchMint mints batch of new NFTs.
     *
     * Emits a {NewNFTBatchMintedOnFirstPublicSale} event.
     *
     * Requirements:
     *
     * - User can mint max 3 NFTs in each First Public Sale
     **/

    function firstPublicSaleBatchMint(uint256 tokenCount)
        external
        payable
        returns (bool)
    {
        if (
            (block.timestamp >= defaultSaleStartTime) &&
            (block.timestamp <
                defaultSaleStartTime + DEFAULT_INITIAL_PUBLIC_SALE)
        ) {
            if (tokenCount == 0) revert InvalidTokenCountZero();

            uint256 getPriceOFNFT = getCurrentNFTMintingPrice();

            if ((getPriceOFNFT * tokenCount) != msg.value)
                revert InvalidBuyNFTPrice(
                    (getPriceOFNFT * tokenCount),
                    msg.value
                );

            if (
                firstPublicSale[msg.sender] + tokenCount >
                LIMIT_IN_PUBLIC_SALE_PER_WALLET
            ) revert MaximumMintLimitReachedByUser();

            firstPublicSale[msg.sender] =
                firstPublicSale[msg.sender] +
                tokenCount;

            uint256[] memory newIDs = new uint256[](tokenCount);
            uint256[] memory newAmounts = new uint256[](tokenCount);

            if (_tokenIds + tokenCount > DEFAULT_MAX_FIRST_PUBLIC_SUPPLY)
                revert MaximumPublicMintSupplyReached();

            dutchAuctionLastPrice = getPriceOFNFT;

            for (uint256 i = 0; i < tokenCount; i++) {
                _tokenIds++;

                newIDs[i] = _tokenIds;
                newAmounts[i] = 1;
            }

            emit NewNFTBatchMintedOnFirstPublicSale(
                newIDs,
                msg.sender,
                msg.value
            );

            _mintBatch(msg.sender, newIDs, newAmounts, "");

            return true;
        } else {
            revert UnAuthorizedRequest();
        }
    }

    /**
     * @dev lastPublicSaleBatchMint mints batch of new NFTs.
     *
     * Emits a {NewNFTBatchMintedOnLastPublicSale} event.
     *
     * Requirements:
     *
     * - User can mint max 3 NFTs in each First Public Sale
     **/

    function lastPublicSaleBatchMint(uint256 tokenCount)
        external
        payable
        returns (bool)
    {
        if ((block.timestamp >= defaultSaleStartTime + DEFAULT_TEAMMINT_SALE)) {
            if (tokenCount == 0) revert InvalidTokenCountZero();

            if (
                lastPublicSale[msg.sender] + tokenCount >
                LIMIT_IN_PUBLIC_SALE_PER_WALLET
            ) revert MaximumMintLimitReachedByUser();

            if ((dutchAuctionLastPrice * tokenCount) != msg.value)
                revert InvalidBuyNFTPrice(
                    (dutchAuctionLastPrice * tokenCount),
                    msg.value
                );

            lastPublicSale[msg.sender] =
                lastPublicSale[msg.sender] +
                tokenCount;

            uint256[] memory newIDs = new uint256[](tokenCount);
            uint256[] memory newAmounts = new uint256[](tokenCount);

            if (_tokenIds + tokenCount > DEFAULT_MAX_MINTING_SUPPLY)
                revert MaximumMintSupplyReached();

            for (uint256 i = 0; i < tokenCount; i++) {
                _tokenIds++;

                newIDs[i] = _tokenIds;
                newAmounts[i] = 1;
            }

            emit NewNFTBatchMintedOnLastPublicSale(
                newIDs,
                msg.sender,
                msg.value
            );

            _mintBatch(msg.sender, newIDs, newAmounts, "");

            return true;
        } else {
            revert UnAuthorizedRequest();
        }
    }

    /**
     * @dev sendPaymentForReimbursement is used to send reimbursement payment on contract for FirstPublicMint buyers can claim it.
     *
     * Emits a {PaymentSentInContractForReimbursements} event.
     *
     * Requirements:
     *
     * - Only the defaultPlatformAddress can call this function
     **/

    function sendPaymentForReimbursement() external payable returns (bool) {
        if (msg.sender != defaultPlatformAddress) revert UnAuthorizedRequest();

        if (msg.value == 0) revert UnAuthorizedRequest();

        emit PaymentSentInContractForReimbursements(msg.value, msg.sender);
        return true;
    }

    /**
     * @dev withdrawPayment is used to withdraw payment from contract.
     *
     * Emits a {WithdrawnPayment} event.
     *
     * Requirements:
     *
     * - Only the defaultPlatformAddress can call this function
     **/

    function withdrawPayment() external returns (bool) {
        if (msg.sender != defaultPlatformAddress) revert UnAuthorizedRequest();

        uint256 contractBalance = address(this).balance;

        if (contractBalance == 0) revert UnAuthorizedRequest();

        (bool sent, ) = defaultPlatformAddress.call{value: contractBalance}("");

        if (!sent) revert TransactionFailed();

        emit WithdrawnPayment(contractBalance, msg.sender);
        return true;
    }

    /**
     * @dev reimbursementAirdrop is used to transfer reimbursement payment to
     * buyers of First Public Sale
     * if they bought the NFT at high price. They'll get return of difference
     * of bought price and last price
     *
     * Emits a {ReimbursementClaimedOfPublicSale} event.
     *
     * Requirements:
     *
     * - Only the First Public Mint holders can claim funds once
     **/

    function reimbursementAirdrop(
        address[] memory addresses,
        uint256[] memory values
    ) external returns (bool) {
        if (
            (block.timestamp >= defaultSaleStartTime) &&
            (block.timestamp <
                defaultSaleStartTime + DEFAULT_INITIAL_PUBLIC_SALE)
        ) revert CannotClaimReimbursementInPublicMint();

        if (msg.sender != defaultPlatformAddress) revert UnAuthorizedRequest();

        if (addresses.length != values.length) revert UnAuthorizedRequest();

        for (uint256 i = 0; i < addresses.length; i++) {
            (bool sent, ) = addresses[i].call{value: values[i]}("");
            if (!sent) revert AirdropTransactionFailed(addresses[i], values[i]);
        }

        emit ReimbursementClaimedOfPublicSale(addresses, values);
        return true;
    }
}