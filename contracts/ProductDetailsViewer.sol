// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ProductManufacture.sol";

/*@title: SandBox
  @notice This contract is to view all the details of a product created using product manufacture contract
  @dev all functions are view and doesn't cost any gas to run them
*/

//@notice error if the product is not created
error NotYetCreated();

contract ProductDetailsViewer is ProductManufacture{

    //@notice this helps to check if the product is created or not
    //@dev uncreated products will have null address as any un-initialised addresses
    modifier isProductCreated(
        uint _tokenId){
            if(_product[_tokenId].ManufacturersAddress == 0x0000000000000000000000000000000000000000)
                revert NotYetCreated();
            _;
        }

    //@notice displays all the products user owns
    function viewMyTokens(
        ) external view returns(uint[] memory){
            if(userOwns[msg.sender] == 0)
                revert("You don't own any products");
            return ownerOf[msg.sender];
    }

    //@notice displays manufacturers address
    function viewManufacturerAddress(
        uint _tokenId
        ) external view isProductCreated(_tokenId) returns(address) {
            return _product[_tokenId].ManufacturersAddress;
    }

    //@notice displays product details Name, seial number and its current owner
    function viewProductDetails(
        uint _tokenId
        ) external view isProductCreated(_tokenId) returns(string memory, uint, address){
            if(_product[_tokenId].SerialNumber == 0)
                revert("product details are to be set");

            return (_product[_tokenId].Name, 
                    _product[_tokenId].SerialNumber, 
                    _product[_tokenId].CurrentOwner);
    }
    
    //@notice  displays total warranty period of product
    function viewWarrantyPeriod(
        uint _tokenId
        ) external view returns(uint){
            if(_product[_tokenId].SerialNumber == 0)
                    revert("Warranty details are to be set");
            return _product[_tokenId].WarrantyPeriod/86400;
    }

    //@notice displays all the previous owners of product
    function viewPreviousOwners(
        uint _tokenId
        )external view isProductCreated(_tokenId) returns(address[] memory){
            if(_product[_tokenId].PastOwners.length == 0)
                revert("no previous Owners");

            return _product[_tokenId].PastOwners;
    }

    //@notice displays warranty status and remaining warranty time
    /*@dev returns a string warranty status and uint remaining warranty period
           which will be caluculated useing current blocks timestamp
    */
    function viewWarrantyStatus(
        uint _tokenId
        ) public view returns(string memory, uint){
            if(!_product[_tokenId].WarrantyActivated)
                revert("warranty isn't activated");
                
            if((_product[_tokenId].FirstPurchaseDate + _product[_tokenId].WarrantyPeriod) > block.timestamp){
                return ("Active",
                       (_product[_tokenId].FirstPurchaseDate + _product[_tokenId].WarrantyPeriod - block.timestamp)/86400 );
            } else {
                return ("Expired", 0);
            }
    }

}
