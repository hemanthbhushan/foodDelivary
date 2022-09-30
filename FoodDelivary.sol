// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/ERC1155.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/Pausable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";


contract FoodDelivery is ERC1155,Ownable,Pausable{

    
    uint256[] totalMinted = [0,0];


constructor()ERC1155(""){



}

 

 using Counters for Counters.Counter;
    Counters.Counter hotelCount;
    //the nft if for hotel registration is 1,for the user nft is 2
    Counters.Counter nftIdCount; 


 struct Hotel{
        string hotelName; 
        address hotelManager; 
        address hotelDeposit; 
        uint256 hotelId; 
    }

 //here the nft id are stored for example when the new hotel gets registered the Nft of Id  1 is deposited to the user
 //simiarly to the user who orders gets the thanku nft which has the nft id of 2 and etc   
 struct NftIds{
    string purpose;
    uint nftId;
    uint256 totalSupply;
 }  


    NftIds[] public getThePurposeOfNftIds;
    Hotel[] registeredHotels;
    
    mapping (uint256 => NftIds) public idToNfts;
    mapping  (address=>mapping(address => bool)) public whitelisteManager;
    mapping (address=>mapping(string=>uint)) public hotelId;

    //when hotel gets registered the manager of the hotel get the Nft as the proof use in the future for the hotel registration the nftId will be 1

   mapping (string=>uint) public NftId;

  


//the hotel needs to be registered by hotel manager
    function registetHotel(string memory hotelName,address hotelDeposit) external {

        require(whitelisteManager[owner()][msg.sender] == true,"hotelManger need to get approval from the owner");
        require(hotelDeposit != msg.sender && hotelDeposit != address(0),"check the rules" );

        hotelCount.increment();
        uint Id = hotelCount.current();
        Hotel memory registered = Hotel(hotelName,msg.sender,hotelDeposit,Id);

       

        _mint(msg.sender,NftId["Hotel"],1,"");

        registeredHotels.push(registered);
        hotelId[msg.sender][hotelName] = Id; 

    }

      function changeHotelManager(address _newManager,string memory _hotelName) external returns(address ){
          require(whitelisteManager[owner()][msg.sender] == true,"hotelManger need to get approval from the owner");
          require(_newManager != address(0),"cant the make the zero address as the manager");
          require( balanceOf(msg.sender, NftId["Hotel"])>0,"the hotel is missing the hotel registration nft ");
          uint256 _Id = hotelId[msg.sender][_hotelName];
              
               uint256 count;
               uint256 length = registeredHotels.length;
               for(uint256 i=0;i<length;i++){
                   if(_Id== registeredHotels[i].hotelId){
                       //internal function erc1155
                       _safeTransferFrom(msg.sender, _newManager,NftId["Hotel"] ,1,"");
                       whitelisteManager[owner()][msg.sender] = false;
                       registeredHotels[i].hotelManager = _newManager;
                       hotelId[_newManager][_hotelName] = _Id;
    }
                   count++;
               }
               if(count== length){
                   revert("hotel is not registered");
               }
                
               return _newManager;
               //new manager should get the approval from the owner
 } 



    function hotelManagerGetApproveFromOwner(address hotelManager,bool check) external  onlyOwner returns(bool){
        return whitelisteManager[msg.sender][hotelManager] = check;


    } 

    function checkRegisteredHotels() public view returns(Hotel[] memory){
        return  registeredHotels;
    }
    function setNftIds(string memory typeOfRegisstration,uint256 _NftId) external  onlyOwner{
    NftId[typeOfRegisstration] = _NftId;

}

    function addNewNftType(string memory _purpose, uint256 _totalSupply) external onlyOwner returns(uint256 newNftId ){
        nftIdCount.increment();
        uint _idNo = nftIdCount.current();

          idToNfts[_idNo] = NftIds({
              purpose:_purpose,
              nftId:_idNo,
              totalSupply:_totalSupply
          });
        // newNftId = totalMinted.length-1; 
        // NftIds memory nftIds = NftIds(_purpose,newNftId);
        // totalSupplyOfNFT.push(_totalSupply);
        // totalMinted.push(0);
        getThePurposeOfNftIds.push(idToNfts[_idNo]);

    }

    function getNftIdPurpose() public view returns(NftIds[] memory){
        return getThePurposeOfNftIds;
    }

  }




