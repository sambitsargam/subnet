// https://github.com/AmazingAng/WTF-Solidity/blob/main/Languages/en/S16...

// SPDX-License-Identifier: MIT
// By 0xAA
// English translation by 22X
pragma solidity ^0.8.21;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract CustomNFT is ERC721 {
    uint256 public totalSupply;
    mapping(address => bool) public mintedAddress;
    constructor() ERC721("Custom NFT", "ReNFT"){}

    function mint() payable external {
        require(mintedAddress[msg.sender] == false);
        totalSupply++;
        _safeMint(msg.sender, totalSupply);
        mintedAddress[msg.sender] = true;
    }
}