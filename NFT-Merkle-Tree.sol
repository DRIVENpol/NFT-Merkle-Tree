// NOTE
// In order to generate the Merkle Root you need to do it off-chain using javascript

// Example Code:

// const addresses = [
//         "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
//         "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
//         "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"
//         ];  
// const leaves = addresses.map(x => keccak256(x));
// const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });

// const buf2hex = x => '0x' + x.toString('hex');

// console.log(buf2hex(tree.getRoot())); // Display the root

// const proof = tree.getProof(leaf).map(x => buf2hex(x.data)); // Compute the proof
// console.log(proof); // Display the proof

// await connectedContract.preSaleMint(address, "SOME_URI", proof);

// SMART CONTRACT ------------------------------------------------------------------------------------------------------------------------

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

  // 1. IMPORT --------------------------------------------------------------------------------------------------------------------------- (1)
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Nft_Merkle_Tree is ERC721, ERC721URIStorage, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    // 2. MERKLE ROOT -------------------------------------------------------------------------------------------------------------------- (2)
    bytes32 public merkleRoot;

    constructor() ERC721("Token Name", "Token Symbol") {}

    // 3. WE ADD THE "_proof" PARAMETER  ------------------------------------------------------------------------------------------------- (4)
    function preSaleMint(address to, string memory uri, bytes32[] memory _proof) public {

        // 4. WE CHECK IF THE SUBMITTED PROOF AND THE LEAF - keccak256(abi.encodePacked(msg.sender))) - 
        // ARE COMPONENTS OF OUR MERKLE TREE  -------------------------------------------------------------------------------------------- (5)
        require(isInAllowList(_proof, keccak256(abi.encodePacked(msg.sender))), "You are not allowed to do this action!");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function publicSaleMint(address to, string memory uri) public {
        // WRITE YOUR PUBLIC MINT FUNCTION
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    // CHANGE THE MERKLE ROOT
    function changeRoot(bytes32 _newRoot) public onlyOwner {
        merkleRoot = _newRoot;
    }

    // 3. VERIFIY IF THE USER IS IN THE WHITE LIST --------------------------------------------------------------------------------------- (3)
    function isInAllowList(bytes32[] memory _proof, bytes32 _leaf) public view returns (bool) {
        return MerkleProof.verify(_proof, merkleRoot, _leaf);
    }
}
