pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;

struct PoolInfo {

    address swap;       // stableswap contract address.

    uint256 totalCoins; // Number of coins used in stableswap contract.

    string name;        // Pool name ("... Pool").

}

abstract contract Ownable {



    modifier onlyOwner {

        require(msg.sender == owner, "O: onlyOwner function!");

        _;

    }



    address public owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @notice Initializes owner variable with msg.sender address.

     */

    constructor() internal {

        owner = msg.sender;

        emit OwnershipTransferred(address(0), msg.sender);

    }



    /**

     * @notice Transfers ownership to the desired address.

     * The function is callable only by the owner.

     */

    function transferOwnership(address _owner) external onlyOwner {

        require(_owner != address(0), "O: new owner is the zero address!");

        emit OwnershipTransferred(owner, _owner);

        owner = _owner;

    }

}

contract SwerveRegistry is Ownable {



    mapping (address => PoolInfo) internal poolInfo;



    constructor() public {

        poolInfo[0x77C6E4a580c0dCE4E5c7a17d0bc077188a83A059] = PoolInfo({

            swap: 0x329239599afB305DA0A2eC69c58F8a6697F9F88d,

            totalCoins: 4,

            name: "swUSD Pool"

        });

    }



    function setPoolInfo(

        address token,

        address swap,

        uint256 totalCoins,

        string calldata name

    )

        external

        onlyOwner

    {

        poolInfo[token] = PoolInfo({

            swap: swap,

            totalCoins: totalCoins,

            name: name

        });

    }



    function getSwapAndTotalCoins(address token) external view returns (address, uint256) {

        return (poolInfo[token].swap, poolInfo[token].totalCoins);

    }



    function getName(address token) external view returns (string memory) {

        return poolInfo[token].name;

    }

}
