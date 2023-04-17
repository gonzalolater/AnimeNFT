pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract AnimeNFT is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;
    uint256 public constant MAX_NFTS = 10000;

    struct AnimeNFTMetadata {
        string name;
        string description;
        string image;
        uint256 rarity;
    }

    AnimeNFTMetadata[] public animeNFTs;
    mapping (uint256 => string) private _tokenURIs;

    constructor() ERC721("AnimeNFT", "ANFT") {}
   
    function mint() public {
    require(_tokenIdTracker.current() < MAX_NFTS, "Maximum number of NFTs has been reached");
    bytes32 hash = keccak256(abi.encodePacked(msg.sender, tx.gasprice, block.difficulty, block.timestamp));
    uint256 tokenId = uint256(hash) % MAX_NFTS;

    string memory name = "AnimeNFT";
    string memory description = "A randomly generated anime NFT";
    string memory image = "https://gateway.pinata.cloud/ipfs/QmZo7gsostaUdrV1peFz4cX6Z2TgriFJJP4VahG5knVm29?_gl=1*1hzmfbf*rs_ga*M2Y5OTllM2EtY2U2Ni00MmQ1LWI3YWQtYzNiYzQ0YjFmMzIw*rs_ga_5RMPXG14TE*MTY4MTY5MTQzMS4yLjAuMTY4MTY5MTQzMS42MC4wLjA."; // URL de la imagen de tu NFT
    uint256 rarity = uint256(keccak256(abi.encodePacked(hash, block.coinbase, block.timestamp))) % 5;

    animeNFTs.push(AnimeNFTMetadata(name, description, image, rarity));
    _safeMint(msg.sender, tokenId);
    _tokenIdTracker.increment();
    _setTokenURI(tokenId, tokenURI(tokenId));
}


    function getTokenMetadata(uint256 tokenId) public view returns (bytes memory) {
        return _getMetadata(tokenId);
    }

    function _getMetadata(uint256 tokenId) private view returns (bytes memory) {
        AnimeNFTMetadata memory animeNFT = animeNFTs[tokenId];
        return abi.encodePacked(
            '{"name": "', animeNFT.name,
            '", "description": "', animeNFT.description,
            '", "image": "', animeNFT.image,
            '", "attributes": [{"trait_type": "Rarity", "value": ', uint2str(animeNFT.rarity), '}]}'
        );
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return string(abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(_getMetadata(tokenId))
        ));
    }

    function uint2str(uint256 number) private pure returns (string memory) {
        if (number == 0) {
            return "0";
        }
        uint256 temp = number;
        uint256 digits;

        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);
        while (number != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(number % 10)));
            number /= 10;
        }

        return string(buffer);
    }

   function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }
}
