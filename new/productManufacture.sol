// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.4;

//This contract contains all the key functions i.e to set all the
//Details of the product
contract ProductManufacture{

    //Structure of a warranty card 
    struct WarrantyCard{
        address ManufacturersAddress;          //Adddress of the product manufacturer
        address CurrentOwner;                  //The Current owners address
        address[] PastOwners;                  //Addresses of past owners
        string Name;                           //Name, Model of the product
        string ActivationCode;                 //Code to activate warranty
        uint SerialNumber;                     //Manufacture Number or serial Number
        uint WarrantyPeriod;                   //Warranty period in days which is stored in seconds
        uint LatestPurchaseDate;               //The latest purchase date from which warranty starts
        bool ManufacturerStatus ;              //manufacturersAddress status, True if it's set
        bool DetailsStatus ;                   //Details Status, True if product Exists
        bool WarrantyActivated ;               //True if warranty activated
    }

    //Mapping a product with refernce to a tokenID
    mapping (uint => WarrantyCard) _product;

    //Mapping to count number of tokens user own
    mapping (address => uint) userOwns;

    //Mapping holding the details of all tokens owned by owner
    mapping (address => uint[]) ownerOf;

    //Event announcing the manufacturing of a product
    event newProductCreated(uint _tokenId, string _name, uint _SerialNumber);

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
    function createNewToken(
        uint _tokenId) external {
            if(_product[_tokenId].ManufacturerStatus) 
                revert("token you are trying to create already exists, try differnt token ID");

            _product[_tokenId].ManufacturersAddress = msg.sender;
            _product[_tokenId].CurrentOwner = msg.sender;
            ownerOf[msg.sender].push(_tokenId); 
            userOwns[msg.sender]++;
            _product[_tokenId].ManufacturerStatus = true;
    }

    //Function to set Product name, serial number, warranty period
    function setProductDetails(
        uint _tokenId,
        string memory _name, 
        uint _serialNumber, 
        uint _warrantyPeriod,
        string memory _activationCode
        ) external onlyManufacturer(_tokenId) {
            if(_product[_tokenId].DetailsStatus) 
                revert("Details to be set only once");

            if(_serialNumber < 1)
                revert("Serial number should be greater than 0 ");

            _product[_tokenId].Name = _name;
            _product[_tokenId].SerialNumber = _serialNumber;
            _product[_tokenId].WarrantyPeriod = _warrantyPeriod * 86400;
            _product[_tokenId].ActivationCode = _activationCode;
            _product[_tokenId].DetailsStatus = true;
            emit newProductCreated (_tokenId, _name, _serialNumber);
    }

    //Function to set firstPurchaseDate from which warranty gets activated
    function setLatestPurchaseDate(
        uint _tokenId
        ) internal {
            _product[_tokenId].LatestPurchaseDate = block.timestamp;
            //_product[_tokenId].WarrantyActivated = true;
    }    

    //Function to activate Warranty
    function activateWarranty(
        string memory _activationCode,
        uint _tokenId
        ) external isCurrentOwner(_tokenId){
            require (keccak256(abi.encodePacked(_product[_tokenId].ActivationCode)) == keccak256(abi.encodePacked(_activationCode)) , "Wrong Activation code");
            _product[_tokenId].WarrantyActivated = true;
    }

    //function to remove a user token when he sells it to other user
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

    //Function to change Ownership or sell the Contract
    function transferToken(
        uint _tokenId, 
        address recieversAddress
        ) external isCurrentOwner(_tokenId) {
            setLatestPurchaseDate(_tokenId);
            _product[_tokenId].PastOwners.push(_product[_tokenId].CurrentOwner);
            removeUserToken(_tokenId, _product[_tokenId].CurrentOwner);
            userOwns[msg.sender]--;
            _product[_tokenId].CurrentOwner = recieversAddress ;
            ownerOf[recieversAddress].push(_tokenId);
            userOwns[recieversAddress]++;
    }
    
}