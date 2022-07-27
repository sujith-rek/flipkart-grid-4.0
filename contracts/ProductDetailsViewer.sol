// SPDX-License-Identifier: view LICENSE IN LICENSE
pragma solidity ^0.8.4;

import "./ProductManufacture.sol";

//This contract contains all details to view the details
//Set using the base Contract
//All functions are only view
contract ProductDetailsViewer is ProductManufacture{

    //Address when the product isn't created
    address INCOMPLETE = 0x0000000000000000000000000000000000000000;

    //To view all the tokens user holds
    function viewMyTokens(
        ) external view returns(uint[] memory){
            if(userOwns[msg.sender] == 0)
                revert("You don't own any products");
            return ownerOf[msg.sender];
    }

    //To view Manufacturers address
    function viewManufAddress(
        uint _tokenId
        ) external view returns(address) {
            if(_product[_tokenId].ManufacturersAddress == INCOMPLETE)
                revert("The product for the given token number doesn't exist yet");

            return _product[_tokenId].ManufacturersAddress;
    }

    //To view Product Details i.e name, serial number and current owner
    function viewProductDetails(
        uint _tokenId
        ) external view returns(string memory, uint, address){
            if(_product[_tokenId].CurrentOwner == INCOMPLETE)
                revert("The product You are searching isn't created yet");
            
            if(_product[_tokenId].SerialNumber == 0)
                revert("The product details are yet to be set");

            return (_product[_tokenId].Name, 
                    _product[_tokenId].SerialNumber, 
                    _product[_tokenId].CurrentOwner);
    }
    
    //To view the total warranty period of product
    function viewWarrantyPeriod(
        uint _tokenId
        ) external view returns(uint){
            if(_product[_tokenId].SerialNumber == 0)
                    revert("Warranty details are yet to be set");
            return _product[_tokenId].WarrantyPeriod/86400;
    }

    //To view all the previous owners of product
    function viewPreviousOwners(
        uint _tokenId
        )external view returns(address[] memory){
            uint numberOfPreviousOwners = _product[_tokenId].PastOwners.length;

            if(_product[_tokenId].CurrentOwner == INCOMPLETE)
                revert("The product You are searching for isn't created yet");
            if(numberOfPreviousOwners == 0)
                revert("The product is still with Manufacturer, So no past Owners");

            address[] memory previousOwners = new address[](numberOfPreviousOwners);
            for(uint i=0; i<numberOfPreviousOwners; i++){
                previousOwners[i] = _product[_tokenId].PastOwners[i];
            }
            return previousOwners;
    }

    //Function to see the time remaining for warranty
    function viewWarrantyStatus(
        uint _tokenId
        ) public view returns(string memory, uint){
            if(!_product[_tokenId].WarrantyActivated)
                revert("warranty of the token you are looking for isn't activated yet");
                
            if((_product[_tokenId].FirstPurchaseDate + _product[_tokenId].WarrantyPeriod) > block.timestamp){
                return ("Active",
                       (_product[_tokenId].FirstPurchaseDate + _product[_tokenId].WarrantyPeriod - block.timestamp)/86400 );
            } else {
                return ("Expired", 0);
            }
    }

}
