// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.4;

//This contract contains all the key functions i.e to set all the
//Details of the product
contract ProductManufacture{

    //Structure of a warranty card 
    struct WarrantyCard{
        address ManufacturersAddress;          //Adddress of the product manufacturer
        string Name;                           //Name, Model of the product
        uint SerialNumber;                     //Manufacture Number or serial Number
        uint WarrantyPeriod;                   //Warranty period in seconds
        address CurrentOwner;                  //The Current owners address
        address[] PastOwners;                  //Addresses of past owners
        uint FirstPurchaseDate;                //The first purchase date from which warranty starts
        bool ManufacturerStatus ;              //manufacturersAddress status, True if it's set
        bool DetailsStatus ;                   //Details Status, True if product Exists
        bool WarrantyActivated ;               //True if warranty activated
    }

    //Mapping a product with refernce to a tokenID
    mapping (uint => WarrantyCard) _product; 

    //Event announcing the manufacturing of a product
    event newProductCreated(
        uint _tokenId, 
        string _name, 
        uint _SerialNumber);


    //MODIFIERS

    //Modifier to check if the person initiating the request is owner or not
    modifier isCurrentOwner (
            uint _tokenId) {
                require (msg.sender == _product[_tokenId].CurrentOwner, "You should be the current owner");
                _;
    }

    //Modifier to check the manufacturer
    modifier onlyManufacturer (
        uint _tokenId) {
            require(msg.sender == _product[_tokenId].ManufacturersAddress, "Only manufacturer could use this");
            _;
    }


    //FUNCTIONS

    //Function to set Manufacturer Address
    function setManufacturerAddress(
        uint _tokenId) external {
            if(_product[_tokenId].ManufacturerStatus) 
                revert("Manufacturers address to be set only once");

            _product[_tokenId].ManufacturersAddress = msg.sender;
            _product[_tokenId].CurrentOwner = msg.sender;
            _product[_tokenId].ManufacturerStatus = true;
    }

    //Function to set Product name, serial number, warranty period
    function setDetails(
        uint _tokenId,
        string memory _name, 
        uint _serialNumber, 
        uint _warrantyPeriod
        ) external onlyManufacturer(_tokenId) {
            if(_product[_tokenId].DetailsStatus) 
                revert("Details to be set only once");

            _product[_tokenId].Name = _name;
            _product[_tokenId].SerialNumber = _serialNumber;
            _product[_tokenId].WarrantyPeriod = _warrantyPeriod;
            _product[_tokenId].DetailsStatus = true;
            emit newProductCreated (_tokenId, _name, _serialNumber);
    }

    //Function to view warranty status
    function warrantyStatus(
        uint _tokenId
        )public view returns(bool){
            if((_product[_tokenId].FirstPurchaseDate + _product[_tokenId].WarrantyPeriod) > block.timestamp){
                return true;
            } else {
                return false;
            }
    }

    //Function to see the time remaining for warranty
    function remainingWarrantyTime(
        uint _tokenId
        ) external view returns(uint){
            if(warrantyStatus(_tokenId)){
                return (_product[_tokenId].FirstPurchaseDate + _product[_tokenId].WarrantyPeriod - block.timestamp);
            } else {
                return 0;
            }
    }

    //Function to set firstPurchaseDate
    function setFirstPurchaseDate(
        uint _tokenId
        ) internal {
            _product[_tokenId].FirstPurchaseDate = block.timestamp;
            _product[_tokenId].WarrantyActivated = true;
    }    

    //Function to change Ownership or sell the Contract
    function sendContract(
        uint _tokenId, 
        address recieversAddress
        ) external isCurrentOwner(_tokenId) {
            if(!_product[_tokenId].WarrantyActivated){
                setFirstPurchaseDate(_tokenId);
            }
            _product[_tokenId].PastOwners.push(_product[_tokenId].CurrentOwner);
            _product[_tokenId].CurrentOwner = recieversAddress ;
    }
    
}