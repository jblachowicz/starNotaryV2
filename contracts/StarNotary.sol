pragma solidity ^0.8.0;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract StarNotary is ERC721 {

    constructor() ERC721("TREASURE","JB"){}
    struct Star {
        string name;
    }
    mapping(uint256 => Star) public tokenIdToStarInfo;
    mapping(uint256 => uint256) public starsForSale;

    // Create Star using the Struct
    function createStar(string memory _name, uint256 _tokenId) public { // Passing the name and tokenId as a parameters
        Star memory newStar = Star(_name); // Star is an struct so we are creating a new Star
        tokenIdToStarInfo[_tokenId] = newStar; // Creating in memory the Star -> tokenId mapping
        _mint(msg.sender, _tokenId); // _mint assign the the star with _tokenId to the sender address (ownership)
    }

    // Putting an Star for sale (Adding the star tokenid into the mapping starsForSale, first verify that the sender is the owner)
    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "You can't sale the Star you don't owned");
        starsForSale[_tokenId] = _price;
    }

    // Function that allows you to convert an address into a payable address
    function _make_payable(address x) internal pure returns (address payable) {
        return payable(address(uint160(x)));
    }

    function buyStar(uint256 _tokenId) public payable {
        require(starsForSale[_tokenId] > 0, "The Star should be up for sale");
        uint256 starCost = starsForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);
        require(msg.value > starCost, "You need to have enough Ether");
        _transfer(ownerAddress, msg.sender, _tokenId);
        address payable ownerAddressPayable = _make_payable(ownerAddress);
        ownerAddressPayable.transfer(starCost);
        if (msg.value > starCost) {
            payable(msg.sender).transfer(msg.value - starCost);
        }
    }

    function lookUptokenIdToStarInfo (uint256 _tokenId) public view returns(string memory){
       return tokenIdToStarInfo[_tokenId].name;
    }

    function exchangeStars (uint256 _firstStarTokenId, uint256 _secondStarTokenId) public payable{
        require(ownerOf(_firstStarTokenId)==msg.sender || ownerOf(_secondStarTokenId)==msg.sender);

        address starOwner1 = ownerOf(_firstStarTokenId);
        address starOwner2 = ownerOf(_secondStarTokenId);
        // Exchange the tokens.
        _transfer(starOwner1, starOwner2, _firstStarTokenId);
        _transfer(starOwner2,starOwner1, _secondStarTokenId);
    }

    function transferStar (address to, uint256 _tokenId) public payable{
        require(ownerOf(_tokenId)==msg.sender);
        _transfer(msg.sender, to, _tokenId);
    }
}
