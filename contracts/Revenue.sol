// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

interface KILLAzInterface {
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function balanceOf(address owner) external view returns (uint256 balance);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function totalSupply() external view returns (uint256);
    function getApproved(uint256 tokenId) external view returns (address operator);
}

contract Revenue is Ownable {
    // the account's address starting oracle service
    address private immutable ORACLE;
    // 0x21850dcfe24874382b12d05c5b189f5a2acf0e5b
    address private immutable KILLAz;
    // 0xe4d0e33021476ca05ab22c8bf992d3b013752b80
    address private immutable LadyKILLAz;

    uint256 private updateTime;
    uint256 private totalPairs;

    mapping(uint256 => uint256) private listedMales;
    mapping(uint256 => uint256) private listedFeMales;
    mapping(uint256 => uint256) private usedMales;
    mapping(uint256 => uint256) private usedFeMales;
    mapping(address => uint256) private revenues;

    constructor(
        address _ORACLE,
        address _KILLAz,
        address _LadyKILLAz
    ) {
        ORACLE = _ORACLE;
        KILLAz = _KILLAz;
        LadyKILLAz = _LadyKILLAz;
    }

    event Claimed(uint256 share, uint256 amount);
    event Withrawn(uint256 amount, uint256 balance);

    modifier onlyOracle() {
        require(msg.sender == ORACLE, "You are not oracle provider");
        _;
    }

    /**
     * Set starting update since right now when you are oracle provider.
     */
    function startUpdate() public onlyOracle {
        totalPairs = 0;
        updateTime = block.timestamp;
    }

    /**
     * End updating when you are oracle provider.
     */
    function endUpdate(uint256 totalKillaz, uint256 totalLadyKillaz) public onlyOracle {
        totalKillaz = KILLAzInterface(KILLAz).totalSupply() - totalKillaz;
        totalLadyKillaz = KILLAzInterface(LadyKILLAz).totalSupply() - totalLadyKillaz;
        totalPairs = totalKillaz > totalLadyKillaz ? totalLadyKillaz : totalKillaz;
    }

    /**
     * Update the token's listing status for sale on OpenSea
     */
    function updateListing(address token, uint256[] memory tokenIds) public onlyOracle {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (token == KILLAz) {
                listedMales[tokenIds[i]] = block.timestamp;
            } else if (token == LadyKILLAz) {
                listedFeMales[tokenIds[i]] = block.timestamp;
            }
        }
    }

    /**
     * Claim the share proportional to the total of supplied male and female tokens according to the restricted condition
     */
    function claimShare() public {
        require(totalPairs > 0, "You can't claim while processing update");
        // get available male tokens
        (uint256 males, uint256[] memory maleIds) = getPairsOf(
            KILLAz,
            msg.sender
        );
        require(males > 0, "You don't have any token pairs");

        // get available female tokens
        (uint256 females, uint256[] memory femaleIds) = getPairsOf(
            LadyKILLAz,
            msg.sender
        );
        require(females > 0, "You don't have any token pairs");

        // choose less value between male and female's count as pairs
        uint256 pairs = males > females ? females : males;

        // calculate share and amount proportional to the total pairs
        uint256 share = (pairs * 10000000000) / totalPairs;
        uint256 amount = (address(this).balance * share) / 10000000000;

        // set the timestamp when NFT is used as a pair in this period
        while (pairs > 0) {
            pairs--;
            usedMales[maleIds[pairs]] = block.timestamp;
            usedFeMales[femaleIds[pairs]] = block.timestamp;
        }
        revenues[msg.sender] += amount;

        emit Claimed(share, amount);
    }

    function getPairsOf(address token, address from)
        public
        view
        returns (uint256, uint256[] memory)
    {
        uint256 balance = KILLAzInterface(token).balanceOf(from);
        require(balance > 0, "You don't have any token pairs");

        uint256[] memory tokenIds = new uint256[](balance);
        uint256 length = 0;

        while (balance > 0) {
            balance--;
            uint256 tokenId = KILLAzInterface(token).tokenOfOwnerByIndex(
                from,
                balance
            );
            // check if it is listed or used in the past in this period
            if (
                token == KILLAz &&
                (listedMales[tokenId] >= updateTime ||
                    usedMales[tokenId] >= updateTime)
            ) {
                continue;
            }
            if (
                token == LadyKILLAz &&
                (listedFeMales[tokenId] >= updateTime ||
                    usedFeMales[tokenId] > updateTime)
            ) {
                continue;
            }
            tokenIds[length] = tokenId;
            length++;
        }

        return (length, tokenIds);
    }

    /**
     * get the revenue's balance of account
     */
    function balanceOf(address from) public view returns (uint256) {
        return revenues[from];
    }

    /**
     * withraw revenue of argumented amount
     */
    function withrawShare(uint256 amount) public {
        require(
            address(this).balance >= amount && revenues[msg.sender] >= amount,
            "Requested amount exceeds the balance"
        );
        revenues[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);

        emit Withrawn(amount, revenues[msg.sender]);
    }

    receive() external payable {}
}
