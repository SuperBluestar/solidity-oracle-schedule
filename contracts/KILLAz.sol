// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KILLAzInterface.sol";

contract KILLAz is ERC721, Ownable {
    using SafeMath for uint256;

    uint256 public immutable pricePerKILLA;
    uint256 public immutable maxPerTx;
    uint256 public immutable maxKILLAz;
    bool public isSaleActive;
    
    address private immutable reserveAddress;

    constructor(address _reserveAddress)
        ERC721("KILLAz", "Kz")
    {
        pricePerKILLA = 0.029 * 10 ** 18;
        maxPerTx = 20;
        maxKILLAz = 9971;
        reserveAddress = _reserveAddress;
    }

    function flipSaleState() public onlyOwner {
        isSaleActive = !isSaleActive;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    function reserveKILLAz() public onlyOwner {
        require(totalSupply() < 100);
        for (uint256 i = 0; i < 50; i++) {
            uint256 mintIndex = totalSupply();
            _safeMint(reserveAddress, mintIndex);
        }
    }

     function mintKILLAz(uint256 numberOfTokens) public payable {
        require(isSaleActive, "Sale is not active");
        require(numberOfTokens <= maxPerTx, "No more than 20 tokens per transaction");
        require(totalSupply().add(numberOfTokens) <= maxKILLAz, "Purchase would exceed max supply of KILLAz");
        require(pricePerKILLA.mul(numberOfTokens) == msg.value, "Ether value is not correct");
        
        payable(owner()).transfer(msg.value);

        for (uint256 i = 0; i < numberOfTokens; i++) {
            uint256 mintIndex = totalSupply();
            if (totalSupply() < maxKILLAz) {
                _safeMint(msg.sender, mintIndex);
            }
        }
    }
}