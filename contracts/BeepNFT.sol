// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract BeepNFT is ERC721,  Ownable {


    using SafeMath for uint256;


    uint256 public _tokenIdCounter;
    address public transferWallet;
    string public baseTokenURI;

    constructor(
        string memory _name, 
        string memory _symbol, 
        string memory _baseURI,
        address _tranferWallet
    ) ERC721(_name, _symbol) {
        setBaseURI(_baseURI);
        setTransferWallet(_tranferWallet);
    }



    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }



    function setTransferWallet(address _tranferWallet) public onlyOwner {
       transferWallet = _tranferWallet;
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter;
    }



    function mint(address _to, uint256 _count) external  {
        require(_count > 0, "Mint count should be greater than zero");
        for (uint256 i = 0; i < _count; i++) {
            _mintOneItem(_to);
        }

    }


    function ownerMint(address _to, uint256 _count) external onlyOwner  {
        require(_count > 0, "Mint count should be greater than zero");
        for (uint256 i = 0; i < _count; i++) {
            _mintOneItem(_to);
        }

    }

    function _mintOneItem(address _to) private {
        _mint(_to, ++_tokenIdCounter);
    }


    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(baseTokenURI, Strings.toString(tokenId)));
    }


    function transferOwnership(address newOwner) public virtual override onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(address(0), newOwner);
    }


    function withdrawAll() public payable onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0);
        _withdraw(transferWallet, balance);
    }

    function _withdraw(address _address, uint256 _amount) private {
        (bool success, ) = _address.call{ value: _amount }("");
        require(success, "Transfer failed.");
    }


    
}