// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/Counters.sol";


contract BoxedNFT is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;

    mapping (uint => uint) public nullifiersAssigned; //TokenId -> Nullifier; 
    mapping (uint => uint) public tokenIdAssigned; //Nullifier -> TokenId; 
    Counters.Counter private _tokenIdCounter;
    event newMint(address, uint);
    constructor() ERC721("Certificate", "BXD") {}

    function safeMint(address to, uint nullifier) public  {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        nullifiersAssigned[tokenId]=nullifier;
        tokenIdAssigned[nullifier]=tokenId;
        emit newMint(to, tokenId);
    }


    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
       function getNullifier(uint tokenId)
        public
        view
        returns (uint)
    {
        return nullifiersAssigned[tokenId];
    }

        function getTokenId(uint nullifier)
        public
        view
        returns (uint)
    {
        return tokenIdAssigned[nullifier];
    }

    function burn(uint256 tokenId) external  {
       address owner = ownerOf(tokenId);
       require(owner == msg.sender, "Only the owner of NFT can burn it");
       nullifiersAssigned; //TokenId -> Nullifier; 
       tokenIdAssigned; //Nullifier -> TokenId; 
       super._burn(tokenId);
    }
}