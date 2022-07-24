// SPDX-License-Identifier: view LICENSE IN LICENSE
pragma solidity ^0.8.4;

import "./ProductManufacture.sol";

//This contract contains all details to view the details
//Set using the base Contract
//All functions are only view
contract ProductDetailsViewer is ProductManufacture{

    //Address when the product isn't created
    address INCOMPLETE = 0x0000000000000000000000000000000000000000;

    //To view Manufacturers address
    function viewManufAddress(
        uint _tokenId
        ) external view returns(address) {
            if(_product[_tokenId].ManufacturersAddress == INCOMPLETE)
                revert("The product for the given token number doesn't exist yet");

            return _product[_tokenId].ManufacturersAddress;
    }

    //To view all the tokens user holds
    function viewMyTokens(
        ) external view returns(uint[] memory){
            return ownerOf[msg.sender];
        }

    //To view Product name
    function viewProductDetails(
        uint _tokenId
        ) external view returns(string memory, uint, address){
            if(_product[_tokenId].CurrentOwner == INCOMPLETE)
                revert("The product You are searching isn't created yet");
            
            return (_product[_tokenId].Name, 
                    _product[_tokenId].SerialNumber, 
                    _product[_tokenId].CurrentOwner);
    }
    
    //To view the total warranty priod of product
    function viewWarrantyPeriod(
        uint _tokenId
        ) external view returns(uint){
            return _product[_tokenId].WarrantyPeriod;
    }

    //To view all the previous owners of product
    function viewPreviousOwners(
        uint _tokenId
        )external view returns(address[] memory){
            uint numberOfPreviousOwners = _product[_tokenId].PastOwners.length;

            if(numberOfPreviousOwners == 0)
                revert("The product is still with Manufacturer, So no past Owners");

            address[] memory previousOwners = new address[](numberOfPreviousOwners);
            for(uint i=0; i<numberOfPreviousOwners; i++){
                previousOwners[i] = _product[_tokenId].PastOwners[i];
            }
            return previousOwners;
    }

}
