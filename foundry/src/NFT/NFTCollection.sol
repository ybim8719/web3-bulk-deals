pragma solidity 0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

/**
 * @title
 * @author
 * @notice a very basic contract created in order to store the NFTs sold in one lucky dip. Winner is the owner of each NFT.
 * The limit of mintable NFT is the number of NFT described in the former lucky dip.
 * @dev
 */
contract NFTCollection is ERC721, Ownable {
    error NFTCollection__TokenUriNotFound();
    error NFTCollection__MaxNbOfMintableNFTReached();

    mapping(uint256 tokenId => string tokenUri) private s_tokenIdToUri;
    uint256 private s_tokenCounter;
    uint256 private s_maxNumberOfMintableNFT;

    constructor(string memory _name, string memory _symbol, uint256 _maxNumberOfMintableNFT) ERC721(_name, _symbol) {
        s_tokenCounter = 0;
        s_maxNumberOfMintableNFT = _maxNumberOfMintableNFT;
    }

    function mintNft(string memory tokenUri, address owner) public onlyOwner {
        if (s_maxNumberOfMintableNFT == s_tokenCounter + 1) {
            revert NFTCollection__MaxNbOfMintableNFTReached();
        }
        s_tokenIdToUri[s_tokenCounter] = tokenUri;
        _safeMint(owner, s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (ownerOf(tokenId) == address(0)) {
            revert NFTCollection__TokenUriNotFound();
        }
        string memory imageURI = s_tokenIdToUri[tokenId];

        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes( // bytes casting actually unnecessary as 'abi.encodePacked()' returns a bytes
                        abi.encodePacked(
                            '{"name":"',
                            name(), // You can add whatever name here
                            '", "description":"An NFT that reflects the mood of the owner, 100% on Chain!", ',
                            '"attributes": [{"trait_type": "moodiness", "value": 100}], "image":"',
                            imageURI,
                            '"}'
                        )
                    )
                )
            )
        );
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    function getTokenOwner(uint256 tokenId) public view returns (address) {
        return ownerOf(tokenId);
    }
}
