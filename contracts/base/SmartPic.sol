pragma solidity ^0.5.0;

import "../core/Ownable.sol";
import "../access-control/UserRole.sol";

contract SmartPic is Ownable, UserRole {
    // Id for the picture using the created hash in IPFS
    uint ipfsHashId;

    mapping (string => Picture) pictures;

    enum State { 
        Uploaded,   // Picture uploaded to IPFS
        ForSale,    // Picture ready for sale
        Sold        // Picture sold
    }

    // Define a struct 'Item' with the following fields:
    struct Picture { 
        string  ipfsHashId;         // ipfs hash of the uploaded file
        address ownerID;            // Owner address of the picture
        string  picDescription;     // Short description about the picture
        uint    picPrice;           // Price in Eth of the picture
        State   picState;           // Picture state
        bool    existPicture;       // Bool variable to check easily the existence of the picture in the mapping
    }

    // Events definition
    event Uploaded(string ipfsHashId, address emiter);
    
    // Constructor function
    constructor() public payable {
    }

    // Modifier: Check if a _dna is not already in the items mapping
    modifier checkIpfsHashIdInNotPictures (string memory _ipfsHashId) {
        require(!pictures[_ipfsHashId].existPicture, "Picture already exist in pictures mapping");
        _;
    }

    // Modifier: Check if a _dna is already in the items mapping
    modifier checkIpfsHashIdInPictures (string memory _ipfsHashId) {
        require(pictures[_ipfsHashId].existPicture, "Picture doesn`t exist in pictures mapping");
        _;
    }

    // Define a function 'kill' if required
    function kill() public onlyOwner() {
        selfdestruct(this.owner());
    }

    // Function to add picture in the mapping after the picture is uploaded to IPFS
    function uploadPicturetoIpfs (
        string memory _ipfsHashId,
        address _ownerId,
        string memory _picDescription
    ) public checkIpfsHashIdInNotPictures (_ipfsHashId) {
        Picture memory newPicture = Picture (
            _ipfsHashId,
            _ownerId,
            _picDescription,
            0,
            State.Uploaded,
            true
        );

        pictures[_ipfsHashId] = newPicture;

        // Emit the appropiate event
        emit Uploaded(_ipfsHashId, msg.sender);
    }

    // Define a function 'fetchItemBufferPublic' that fetches public data
    function fetchPictureBufferPublic(string memory _ipfsHashId) public checkIpfsHashIdInPictures (_ipfsHashId) view returns 
    (
        string memory pictureIpfsHashId,
        address pictureOwnerID,
        string memory picturePicDescription,
        uint picturePicPrice,
        State picturePicState
    )
    {
        // Assign values to the parameters
        Picture memory pictureFound = pictures[_ipfsHashId];
        pictureIpfsHashId = pictureFound.ipfsHashId;
        pictureOwnerID = pictureFound.ownerID;
        picturePicDescription = pictureFound.picDescription;
        picturePicPrice = pictureFound.picPrice;
        picturePicState = pictureFound.picState;
    
        return 
        (
            pictureIpfsHashId,
            pictureOwnerID,
            picturePicDescription,
            picturePicPrice,
            picturePicState
        );
    }
}