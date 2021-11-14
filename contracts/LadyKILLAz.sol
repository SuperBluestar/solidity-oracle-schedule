// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KILLAzInterface.sol";

contract LadyKILLAz is ERC721, Ownable {
    using SafeMath for uint256;
    
    KILLAzInterface public immutable KILLAz;
    uint256 public immutable pricePerLadyKILLA;
    uint256 public immutable maxPerTx;
    uint256 public immutable maxLadyKILLAz;
    bool public isSaleActive;
    uint256 public saleStartTime;

    constructor(address _KILLAz) ERC721("Lady KILLAz", "LKz") {
        pricePerLadyKILLA = 0.058 * 10**18;
        maxPerTx = 5;
        maxLadyKILLAz = 9971;
        KILLAz = KILLAzInterface(_KILLAz);
    }

    function claim(uint256[] memory _tokenIds) public {
        require(isSaleActive, "Sale is not active");
        require(isClaimTime(), "Claim time is finished");
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(
                KILLAz_ownerOf(_tokenIds[i]) == msg.sender,
                "It is possible to claim only corresponding tokens"
            );
            if (totalSupply() < maxLadyKILLAz) {
                _safeMint(msg.sender, _tokenIds[i]);
            }
        }
    }

    function buy(uint256[] memory _tokenIds) public payable {
        require(isSaleActive, "Sale is not active");
        // require(
        //     !isClaimTime(),
        //     "The purchase of tokens will be possible after claim time"
        // );
        require(
            _tokenIds.length <= maxPerTx,
            "No more than 5 tokens per transaction"
        );
        require(
            totalSupply().add(_tokenIds.length) <= maxLadyKILLAz,
            "Purchase would exceed max supply of Lady KILLAz"
        );
        require(
            pricePerLadyKILLA.mul(_tokenIds.length) == msg.value,
            "Ether value is not correct"
        );

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(_tokenIds[i] < maxLadyKILLAz);
            if (totalSupply() < maxLadyKILLAz) {
                _safeMint(msg.sender, _tokenIds[i]);
            }
        }

        payable(owner()).transfer(msg.value);
    }

    function startSale() public onlyOwner {
        isSaleActive = true;
        saleStartTime = block.timestamp;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    function doesTokenExist(uint256 _tokenId) public view returns (bool) {
        return _exists(_tokenId);
    }

    function isClaimTime() public view returns (bool) {
        if (block.timestamp <= saleStartTime + 48 hours) return true;
        else return false;
    }

    function KILLAz_ownerOf(uint256 tokenId) public view returns (address) {
        return KILLAz.ownerOf(tokenId);
    }

    function KILLAz_balanceOf(address owner) public view returns (uint256) {
        return KILLAz.balanceOf(owner);
    }

    function KILLAz_tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        returns (uint256)
    {
        return KILLAz.tokenOfOwnerByIndex(owner, index);
    }
}
