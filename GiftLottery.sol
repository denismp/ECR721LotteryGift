pragma solidity ^0.5.5;

//import "./openzeppelin-contracts/contracts/token/ERC721/ERC721Full.sol";
//import "./openzeppelin-contracts/contracts/drafts/Counters.sol";
//import "@openzeppelin/contracts/token/ERC721/ERC721Full.sol";
import "./node_modules/@openzeppelin/contracts/token/ERC721/ERC721Full.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.3.0-rc.3/contracts/token/ERC721/ERC721Full.sol";

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/drafts/Counters.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721Full.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Full.sol";

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721Full.sol";

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.3.0-rc.3/contracts/token/ERC721/ERC721Full.sol";

contract GiftLottery is ERC721Full {
    struct Gift {
        string title;
        string description;
        string URL;
    }
    address private owner;
    uint256 private endTime;
    address[] private participants;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    mapping(uint256 => Gift) giftIdToGift;

    event CreateGift(address indexed participant, uint256 giftId);
    event ReceivedGift(address indexed winner, uint256 giftId);

    constructor(uint256 _endTime) ERC721Full("GiftLottery", "GLT") public {
        endTime = _endTime;
        owner = msg.sender;
    }

    function createGift(string calldata _title, string calldata _description, string calldata _URL) external {
        require(endTime >= now);

        //uint256 index = allTokens.length.add(1);
        _tokenIds.increment();
        uint256 index = _tokenIds.current();
        _mint(owner,index);

        giftIdToGift[index] = Gift(_title,_description,_URL);
        participants.push(msg.sender);
        emit CreateGift(msg.sender,index);
    }

    function pseudoRandom(uint256 _giftId) private view returns(uint) {
        Gift memory gift = giftIdToGift[_giftId];

        return uint(keccak256(abi.encodePacked(gift.title, gift.description, gift.URL, _giftId))) % participants.length;
    }

    function distributeGifts() public onlyOwner {
        for(uint i = 1; i < _tokenIds.current(); i++) {
            uint randomAddress = pseudoRandom(i);

            address winner = participants[randomAddress];
            transferFrom(msg.sender, winner, i);
            emit ReceivedGift(winner, i);
        }
    }
}