// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

contract ERC721AllTheWayDown is ERC721Royalty, Ownable {
    struct Ids {
        address _address;
        uint256 _tokenId;
    }

    uint256 public tokenIdCounter = 1;
    uint256 public mintCost = 0;
    mapping(uint256 => Ids) public idToIds;

    constructor() ERC721("ERC721AllTheWayDown", "EATWD") {
        _setDefaultRoyalty(msg.sender, 100);
    }

    receive() external payable {}

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        Ids memory ids = idToIds[_tokenId];
        return IERC721Metadata(ids._address).tokenURI(ids._tokenId);
    }

    function mint(address _address, uint256 _tokenId) public payable {
        require(msg.value == mintCost);

        idToIds[tokenIdCounter] = Ids({ _address: _address, _tokenId: _tokenId });

        _safeMint(msg.sender, tokenIdCounter);

        tokenIdCounter += 1;
    }
    
    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = owner().call{value: amount}("");
        require(success, "Failed to send");
    }

    function setRoyalty(address _receiver, uint96 _feeNumerator) public onlyOwner {
        _setDefaultRoyalty(_receiver, _feeNumerator);
    }

	function setMintCost(uint256 _mintCost) public onlyOwner {
		mintCost = _mintCost;
	}
}

