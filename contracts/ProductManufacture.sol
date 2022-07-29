// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/*
  @title: SandBox
  @notice This contract can be used to show ownership of a product you own using blockchain
  @dev All the functions will handle with the data of the product and use gas for every function 
  no function is set to view the details of it
*/

//@notice Error when unauthorised tries to access the functions
error Unauthorized();

contract ProductManufacture{

    //@notice The following details of a product will be stored in the blockchain 
    //@dev similar datatypes are grouped together to optimize gas consumption
    struct WarrantyCard{
        uint WarrantyPeriod;                   //Warranty period in days which is stored in seconds
        uint FirstPurchaseDate;                //The first purchase date from which warranty starts
        uint SerialNumber;                     //Manufacture Number or serial Number
        string Name;                           //Name, Model of the product
        bool ManufacturerStatus ;              //manufacturersAddress status, True if it's set
        bool DetailsStatus ;                   //Details Status, True if product Exists
        bool WarrantyActivated ;               //True if warranty activated
        address ManufacturersAddress;          //Adddress of the product manufacturer
        address CurrentOwner;                  //The Current owners address
        address[] PastOwners;                  //Addresses of past owners
    }

    //@notice every tokenId is linked to a specific product info
    mapping (uint => WarrantyCard) _product;

    //@notice this mapping counts numbers of tokens a user holds
    mapping (address => uint) userOwns;

    //@notice it holds the tokenIds of all the products a user owns
    mapping (address => uint[]) ownerOf;

    //Event announcing the manufacturing of a product
    event newProductCreated(uint _tokenId, string _name, uint _SerialNumber);

    //MODIFIERS

    //@notice functions with this modifier will only accessible to the current owner of token
    modifier onlyCurrentOwner (
            uint _tokenId) {
                if (msg.sender != _product[_tokenId].CurrentOwner)
                    revert Unauthorized();
                _;
    }

    //@notice functions with this modifier will only accessible to the Manufacturer of token
    modifier onlyManufacturer (
        uint _tokenId) {
            if (msg.sender != _product[_tokenId].ManufacturersAddress)
                revert Unauthorized();
            _;
    }

    //FUNCTIONS

    //@notice this will create new product with the given token ID by the manufacturer
    /*@dev creates new product with given token number if it doesn't exists already
           sets manufacturer and current owner as the function caller
           adds the current token ID to user holdings
           increments number of tokens user owns
           changes the status to true indicating that the product is created
    */
    function createNewToken(
        uint _tokenId) external {
            if(_product[_tokenId].ManufacturerStatus) 
                revert("try differnt token ID");

            _product[_tokenId].ManufacturersAddress = msg.sender;
            _product[_tokenId].CurrentOwner = msg.sender;
            ownerOf[msg.sender].push(_tokenId); 
            userOwns[msg.sender]++;
            _product[_tokenId].ManufacturerStatus = true;
    }

    //@notice This will set Product name, serial number, warranty period for the given token ID
    /*@dev The product details will be set only once
           To deal with time we take warranty in days and store it in seconds
    */
    function setProductDetails(
        uint _tokenId,
        string memory _name, 
        uint _serialNumber, 
        uint _warrantyPeriod
        ) external onlyManufacturer(_tokenId) {
            if(_product[_tokenId].DetailsStatus) 
                revert("Details to be set only once");

            if(_serialNumber < 1)
                revert("Serial number should be above 0");

            _product[_tokenId].Name = _name;
            _product[_tokenId].SerialNumber = _serialNumber;
            _product[_tokenId].WarrantyPeriod = _warrantyPeriod * 86400;
            _product[_tokenId].DetailsStatus = true;
            emit newProductCreated (_tokenId, _name, _serialNumber);
    }

    //@notice time at which the product leaves manufacturer
    //@dev this timestamp will be used to apply warranty
    function setFirstPurchaseDate(
        uint _tokenId
        ) internal {
            _product[_tokenId].FirstPurchaseDate = block.timestamp;
            _product[_tokenId].WarrantyActivated = true;
    }    

    //@notice to remove the token ID from user owns while trnsfer of token
    /*@dev the required token ID will be searched and deleted
           We could use other searching methods instead of linear search as used in here
    */
    function removeUserToken(
        uint _tokenId,
        address _owner
        ) internal {
            uint numberOfTokens = ownerOf[_owner].length;
            for(uint i=0; i < numberOfTokens ; i++){
                if(ownerOf[_owner][i] == _tokenId){
                    ownerOf[_owner][i] = ownerOf[_owner][numberOfTokens - 1];
                    ownerOf[_owner].pop();
                    break;
                }
            }
    }         

    //@notice to change Ownership/sell the product
    /*@dev token count decreased from owner and increased to reciever
           it'll be removed from user owns and will be added to reciever
           In the event of first transaction i.e product goes to first consumer
           Warranty will be activated after the first transaction
    */
    function transferToken(
        uint _tokenId, 
        address recieversAddress
        ) external onlyCurrentOwner(_tokenId) {
            if(!_product[_tokenId].WarrantyActivated){
                setFirstPurchaseDate(_tokenId);
            }
            _product[_tokenId].PastOwners.push(_product[_tokenId].CurrentOwner);
            removeUserToken(_tokenId, _product[_tokenId].CurrentOwner);
            userOwns[msg.sender]--;
            _product[_tokenId].CurrentOwner = recieversAddress ;
            ownerOf[recieversAddress].push(_tokenId);
            userOwns[recieversAddress]++;
    }
    
}