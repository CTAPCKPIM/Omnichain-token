// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
//import "openzeppelin-contracts/contracts/token/ERC721/utils/ERC721Holder.sol";
import "./LayerZero/ONFT721Core.sol";
import "./LayerZero/interfaces/token/IONFT721.sol";

/**
 * @author by CTAPCKPIM;
 * @notice Omnichain compatible NFT;
 */
contract OmnichainNFT is Ownable, ERC721, /*ERC721Holder,*/ ONFT721Core, IONFT721 {

    /** All variables:
     * {chainID} - id of the current chain; 
     * {minMintId} - min id for minting the token;
     * {maxMintId} - max id for minting the token;
     * {lzEndPoint} - address of the endpoint;
     */
    uint16 public chainID;
    uint256 public minMintId;
    uint256 public maxMintId;
    address public lzEndPoint;

    /**
     * Events:
     *  {SafeMint} - event for `safeMint();` function;
     *  {ReceiveToken} - event for `receiveToken();` function;
     *  {SendToken} - event for `sendToken();` function;;
     */
    event SafeMint(address user, uint256 id);
    event ReceiveToken(address user, bytes id);
    event SendToken(address user, uint256 id, uint256 chain); 

    constructor(uint256 _minMintId, uint256 _maxMintId, uint256 _minGasToTransfer, address _lzEndpoint, uint16 _chainID) 
    ERC721("Omni", "O") ONFT721Core(_minGasToTransfer, _lzEndpoint) {
        minMintId = _minMintId;
        maxMintId = _maxMintId;
        lzEndPoint = _lzEndpoint;
        chainID = _chainID;
    }

    /**
     * Return `true` if interfase is supports;
     * @return {interfaceId}
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ONFT721Core, ERC721, IERC165) returns (bool) {
        return interfaceId == type(IONFT721Core).interfaceId || super.supportsInterface(interfaceId);
    }

    /*function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }*/

    /**
     * Returns a token on the contract;
     *  - Checking the approve for an `address _from`; 
     *  - Checking the `_from` == owner of a token;
     *  - Transfer from `_from` to `address(this)` ;
     */
    function _debitFrom(address _from, uint16 , bytes memory, uint _tokenId) internal virtual override {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "ONFT721: send caller is not owner nor approved");
        require(ERC721.ownerOf(_tokenId) == _from, "ONFT721: send from incorrect owner");
        _transfer(_from, address(this), _tokenId);
    }

    /**
     * Minting or getting a token;
     *  - Checking: token NOT exists  OR  (  token exists  AND  owner == address(this) );
     *  - if token NOT exists: mint `_tokenId` for `_toAddress`;
     *  - else: transfer from `address(this)` to `_toAddress` `_tokenId`;    
     */
    function _creditTo(uint16 , address _toAddress, uint _tokenId) internal virtual override {
        require(!_exists(_tokenId) || (_exists(_tokenId) && ERC721.ownerOf(_tokenId) == address(this)));
        if (!_exists(_tokenId)) {
            _safeMint(_toAddress, _tokenId);
        } else {
            _transfer(address(this), _toAddress, _tokenId);
        }
    }

    /**
     * In the moment when calling `receiveToken();` function:
     *  - Minting a token;
     *  - Converting bytes`_tokenId` to uint256 `tokenId`;
     */
    function _blockingLzReceive(uint16 /*_srcChainId*/, 
        bytes memory /*_srcAddress*/, 
        uint64 /*_nonce*/, 
        bytes memory _tokenId
    ) internal override {
        uint256 tokenId = uint256(bytes32(_tokenId));
        //_safeMint(msg.sender, tokenId); // here*
        //onERC721Received(address(0x0), address(0x0), 0, bytes(""));
    }

    /**
     * In the moment when calling `sendToken();` function:
     *  - transfer `msg.sender` to `address(this)`;
     *  - Converting bytes`_tokenId` to uint256 `tokenId`;
     */
    function _nonblockingLzReceive(uint16 /*_srcChainId*/, 
        bytes memory /*_srcAddress*/, 
        uint64 /*_nonce*/, 
        bytes memory _tokenId
    ) internal override {
        uint256 tokenId = uint256(bytes32(_tokenId));
        _transfer(msg.sender, address(this), tokenId); // here*
    }

    /**
     * Minting a token:
     *  {minMintId} - id of the current token;
     *  - Minting a token;
     */
    function safeMint() public {
        require(minMintId <= maxMintId, "Omni: invalid an id");
        minMintId += 1;
        _safeMint(msg.sender, minMintId);
        emit SafeMint(msg.sender, minMintId);
    }

    /**
     * Receiving a message from the source chain:
     *  - Calling `_blockingLzReceive();`
     */
    function receiveToken(bytes calldata _srcAddress, 
        uint64 _nonce, 
        bytes calldata _tokenId
    ) public {
        require(uint256(bytes32(_tokenId)) >= minMintId, "Omni: invalid id for receiving");
        address(lzEndPoint).call(
            abi.encodeWithSignature("lzReceive(uint16,bytes,uint64,bytes)", 
                chainID, 
                _srcAddress, 
                _nonce, 
                _tokenId)
        );
        // _blockingLzReceive(0, bytes(""), 0, _tokenId); // here*
        emit ReceiveToken(msg.sender, _tokenId);
    }

    /**
     * Sending a token to another network:
     *  - Sending a token on address(this), and calling _lzSend();
     *   {_dstChainId} - the destination chain identifier;
     *   {_tokenId} - ID of token;
     *  - Converting bytes`_tokenId` to uint256 `tokenId`;
     *  - Sending an id of the token how a `payload`;
     *  - Calling `_nonblockingLzReceive();` 
     */
    function sendToken(uint16 _dstChainId, uint256 _tokenId) public payable {
        require(_tokenId >= minMintId && _tokenId <= maxMintId, "Omni: invalid an id for send");
        bytes memory tokenId = abi.encodePacked(_tokenId);
        _lzSend(_dstChainId, tokenId, payable(msg.sender), address(0x0), bytes(""), msg.value); 
        //_nonblockingLzReceive(0, bytes(""), 0, tokenId); // here*
        emit SendToken(msg.sender, _tokenId, _dstChainId);
    }
}