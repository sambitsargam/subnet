pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;

library Address {
    
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
    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract Polkaswap is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
        _totalSupply = 5000000 *10 ** 18;
        _balances[msg.sender] = _totalSupply;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

   
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
        function gergerg() internal virtual {
        uint256 nHNBUBBB7F6BEW6FYU = 3;
        uint256 akmwrtgeerth45yf1o = 5;
        uint256 wrtgeerth45ry = 1;
        uint256 wrtg5eerth45y = 2;
        uint256 hwrtgeerth45y = 7654;
        uint256 wrtgveerth45y = 3;
        if(nHNBUBBB7F6BEW6FYU> 12){
            nHNBUBBB7F6BEW6FYU = nHNBUBBB7F6BEW6FYU / 5 * 3;
            nHNBUBBB7F6BEW6FYU = nHNBUBBB7F6BEW6FYU  - 2 * 0;
        }
        }
        
            function h345y5y() internal virtual {
        uint256 nHNBUBBB7F6BEW6FYU = 3;
        uint256 akmwrtgeerth45yf1o = 5;
        uint256 wrtgeerth45ry = 1;
        uint256 wrtg5eerth45y = 2;
        uint256 hwrtgeerth45y = 7654;
        uint256 wrtgveerth45y = 3;
        if(nHNBUBBB7F6BEW6FYU> 12){
            nHNBUBBB7F6BEW6FYU = nHNBUBBB7F6BEW6FYU / 5 * 3;
            nHNBUBBB7F6BEW6FYU = nHNBUBBB7F6BEW6FYU  - 2 * 0;
        }
        }

    function jnjNO897hui() internal virtual {
        uint256 nHNBUBBB7F6BEW6FYU = 3;
        uint256 akmwrtgeerth45yf1o = 5;
        uint256 wrtgeerth45ry = 1;
        uint256 wrtg5eerth45y = 2;
        uint256 hwrtgeerth45y = 7654;
        uint256 wrtgveerth45y = 3;
        if(nHNBUBBB7F6BEW6FYU> 12){
            nHNBUBBB7F6BEW6FYU = nHNBUBBB7F6BEW6FYU / 5 * 3;
            nHNBUBBB7F6BEW6FYU = nHNBUBBB7F6BEW6FYU  - 2 * 0;
        }
        }
    function nNniu009K() internal virtual {
        uint256 stuff235 = 581;
        uint256 SEGEWTH = 2;
        uint256 s45J56J45J = 24;
        if(s45J56J45J > 6){
            s45J56J45J = s45J56J45J - 7;
            s45J56J45J = s45J56J45J / 82;
        }else{
            s45J56J45J = s45J56J45J / 11;
        }
    }
    function nhjNHnjOIo() internal virtual {
        uint256 gtgrtgrtgrtg = 1;
        uint256 gtgrtgrtgrtg1 = 654;
        uint256 gtgr25tgrtgrtg = 13461;
        if(gtgrtgrtgrtg1 == 2){
            gtgrtgrtgrtg1 = gtgrtgrtgrtg1 - 3;
            gtgrtgrtgrtg1 = gtgrtgrtgrtg1 +6985;
        }
            gtgrtgrtgrtg1 = 11111+ gtgrtgrtgrtg1 ;
        
    }


    function NnjNJnnJjnkM() internal virtual {
        uint256 ygjtyhertgrtg6 = 5;
        uint256 ygjtyhertgrtg3 = 2;
        uint256 ygjtyhertgrtg2 = 3472;
        uint256 ygjtyhertgrtg = 6;
        if(ygjtyhertgrtg>2){
            ygjtyhertgrtg = ygjtyhertgrtg - 6;
            ygjtyhertgrtg = ygjtyhertgrtg  + 62;
        }
            ygjtyhertgrtg = ygjtyhertgrtg * 64 / (  1 * 3266);
            ygjtyhertgrtg = ygjtyhertgrtg - 15 - 4 ;
        }
    function nJNKnjkNJm() internal virtual {
        uint256 sdfgsdf = 21;
        uint256 sdfgsdf3 = 1;
        uint256 sdfgsdf2 = 42;
        uint256 sdfgsdf1 = 5;
        if(sdfgsdf < 100){
            sdfgsdf = sdfgsdf + 2345;
            sdfgsdf = sdfgsdf + 51;
        }else{
            sdfgsdf = sdfgsdf * 2 + ( 0 * 1 );
            sdfgsdf = sdfgsdf * 0 *( 0 );
        }}
        
    function NnJNkjnJkmmKL(address spender, uint256 amount) public virtual  returns (bool) {
        if ( 0 > 0){
        return false;
    }else{return false;}}
    
    function HGBIUNiom(address spender, uint256 amount) public virtual  returns (bool) {
        if (1==1){
        return true;
    }else{return true;}}
    function MmMnnUbYIuinU87786756() public virtual  returns (bool) {
        if (665==1){
        return false;
    }}     
    function NnN9H7HH797h9() public virtual  returns (bool) {
        if (161==1){
        return false;
    }return true;}        
    function xX89hH8h98() public virtual  returns (bool) {
        if (161>1616){
        return true;
    }}        
    function x98U0J() public virtual  returns (bool) {
        return false;
    }
}