pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;

struct ProtocolBalance {

    ProtocolMetadata metadata;

    AdapterBalance[] adapterBalances;

}

struct ProtocolMetadata {

    string name;

    string description;

    string websiteURL;

    string iconURL;

    uint256 version;

}

struct AdapterBalance {

    AdapterMetadata metadata;

    FullTokenBalance[] balances;

}

struct AdapterMetadata {

    address adapterAddress;

    string adapterType; // "Asset", "Debt"

}

struct FullTokenBalance {

    TokenBalance base;

    TokenBalance[] underlying;

}

struct TokenBalance {

    TokenMetadata metadata;

    uint256 amount;

}

struct TokenMetadata {

    address token;

    string name;

    string symbol;

    uint8 decimals;

}

struct Component {

    address token;

    string tokenType;  // "ERC20" by default

    uint256 rate;  // price per full share (1e18)

}

interface ERC20 {

    function approve(address, uint256) external returns (bool);

    function transfer(address, uint256) external returns (bool);

    function transferFrom(address, address, uint256) external returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

}

interface TokenAdapter {



    /**

     * @dev MUST return TokenMetadata struct with ERC20-style token info.

     * struct TokenMetadata {

     *     address token;

     *     string name;

     *     string symbol;

     *     uint8 decimals;

     * }

     */

    function getMetadata(address token) external view returns (TokenMetadata memory);



    /**

     * @dev MUST return array of Component structs with underlying tokens rates for the given token.

     * struct Component {

     *     address token;    // Address of token contract

     *     string tokenType; // Token type ("ERC20" by default)

     *     uint256 rate;     // Price per share (1e18)

     * }

     */

    function getComponents(address token) external view returns (Component[] memory);

}

interface SetTokenV2 {

    function getTotalComponentRealUnits(address) external view returns (int256);

    function getComponents() external view returns(address[] memory);

}

contract TokenSetsV2TokenAdapter is TokenAdapter {



    /**

     * @return TokenMetadata struct with ERC20-style token info.

     * @dev Implementation of TokenAdapter interface function.

     */

    function getMetadata(address token) external view override returns (TokenMetadata memory) {

        return TokenMetadata({

            token: token,

            name: ERC20(token).name(),

            symbol: ERC20(token).symbol(),

            decimals: ERC20(token).decimals()

        });

    }



    /**

     * @return Array of Component structs with underlying tokens rates for the given token.

     * @dev Implementation of TokenAdapter interface function.

     */

    function getComponents(address token) external view override returns (Component[] memory) {

        address[] memory components = SetTokenV2(token).getComponents();



        Component[] memory underlyingTokens = new Component[](components.length);



        for (uint256 i = 0; i < underlyingTokens.length; i++) {

            underlyingTokens[i] = Component({

                token: components[i],

                tokenType: "ERC20",

                rate: uint256(SetTokenV2(token).getTotalComponentRealUnits(components[i]))

            });

        }



        return underlyingTokens;

    }

}
