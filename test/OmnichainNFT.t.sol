// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/OmnichainNFT.sol";

contract TestOmnichainNFT is Test{
	OmnichainNFT public omniETH;
    OmnichainNFT public omniFTM;
    OmnichainNFT public _omniETH;

    /*OmniCounter public ETH;
    OmniCounter public FTM;*/

    /**
     * {goerliFork/fantomFork} - identifiers of the forks;
     * {RPC_URL_GOERLI} - RPC of the 'goerli' testnet;
     * {RPC_URL_FTM} - RPC of the 'fantom' testnet;
     * {owner/alice} - addresses for testing;
     */
    uint256 goerliFork;
    uint256 fantomFork;
    uint16 goerliID = 10121;
    uint16 fantomID = 10112;
    uint256 gasETH = 61174;
    uint256 gasFTM = gasETH * 2;  
    string RPC_URL_GOERLI = "https://goerli.infura.io/v3/";
    string RPC_URL_FTM = "https://fantom-testnet.blastapi.io/";
	address owner = makeAddr("owner");
	address alice = makeAddr("alice");
    address endPointETH = 0xbfD2135BFfbb0B5378b56643c2Df8a87552Bfa23;
    address endPointFTM = 0x7dcAD72640F835B0FA36EFD3D6d3ec902C7E5acf;

    // Events:
    event ReceiveToken(address user, bytes id);
    event SendToken(address user, uint256 id, uint256 chain);

	// How beforeEach();
    function setUp() public {
        // Create two different forks during setup
        goerliFork = vm.createFork(RPC_URL_GOERLI);
        fantomFork = vm.createFork(RPC_URL_FTM);

        /**
         * Connecting to 'FTM testnet';
         * Deploy a  contract; 
         */
        vm.selectFork(fantomFork);
        hoax(owner, 1000 ether);
        omniFTM = new OmnichainNFT(10, 20, gasETH, endPointFTM, fantomID);

        /**
         * Connecting to 'ETH testnet';
         * Deploy a  contract; 
         */
        vm.selectFork(goerliFork);
        hoax(owner, 1000 ether);
        omniETH = new OmnichainNFT(0, 10, gasFTM, endPointETH, goerliID);

        /**
         * Connecting to 'FTM testnet';
         * Setting the remote address for 'Omni NFT' in 'FTM testnet';
         * Print: `counter` (0);
         */
        vm.selectFork(fantomFork);
        hoax(owner, 1000 ether);
        bytes memory pathETH = abi.encodePacked(address(omniETH));
        omniFTM.setTrustedRemoteAddress(10121, pathETH); //goerliID = 10121;

        /**
         * Connecting to 'ETH testnet';
         * Setting the remote address for 'OmniCounter' in 'ETH testnet';
         * Print: `counter` (0); 
         */
        vm.selectFork(goerliFork);
        hoax(owner, 1000 ether);
        bytes memory pathFTM = abi.encodePacked(address(omniFTM));
        omniETH.setTrustedRemoteAddress(10112, pathFTM); //fantomID = 10112;
    }

    /**
     * Minting the token
     */
    function testMint() public {
        vm.selectFork(goerliFork);
        hoax(owner, 1000 ether);
        omniETH.safeMint();
        
        assertEq(omniETH.minMintId(), 1);
    }

    /**
    * Calling 'sendToken();'
    */
    function testSendToken() public {
        /**
         * Connecting to 'ETH testnet';
         * Mint a token;
         * Calling the `sendToken();` function for send a message;
         */
        vm.selectFork(goerliFork);
        hoax(owner, 1000 ether);
        omniETH.safeMint();

        // Reconnection to ETH testnet;
        vm.selectFork(goerliFork);
        hoax(owner);
        vm.expectEmit(true, false, false, false);
        emit SendToken(owner, 1, 10112);
        omniETH.sendToken{value: 1 ether}(10112, 1);
    }

    /**
     * Calling 'receiveToken();'
     */
    function testReceiveToken() public {
        /**
         * Connecting to 'ETH testnet';
         * Calling the `receiveToken();` function for receive a message;
         */
        vm.selectFork(goerliFork);
        bytes memory path = abi.encodePacked(address(omniFTM));
        vm.expectEmit(true, false, false, false);
        emit ReceiveToken(owner, "1");
        omniETH.receiveToken(path, 1, bytes("1"));
    }

    /**
     * Calling 'safeMint(); for revert'
     */
    /*function testRevertMint() public {
        vm.selectFork(goerliFork);
        hoax(owner);
        _omniETH = new OmnichainNFT(0, 1, gasFTM, endPointETH, goerliID);
        _omniETH.safeMint();
        vm.expectRevert(bytes("Omni: invalid an id"));
        _omniETH.safeMint();
    }*/

    /**
     * Calling 'sendToken(); for revert'
     */
    function testRevertSendToken() public {
        /**
         * Connecting to 'ETH testnet';
         * Mint a token;
         * Calling the `sendToken();` function for send a message and expect the revert;
         */
        vm.selectFork(goerliFork);
        hoax(owner, 1000 ether);
        omniETH.safeMint();

        // Reconnection to ETH testnet;
        vm.selectFork(goerliFork);
        hoax(owner);
        vm.expectRevert(bytes("Omni: invalid an id for send"));
        omniETH.sendToken{value: 1 ether}(10112, 20);
    }

    /**
     * Calling 'receiveToken(); for revert'
     */
    //function testRevertReceiveToken() public {
        /**
         * Connecting to 'ETH testnet';
         * Calling the `receiveToken();` function for receive a message and expect the revert;
         */
        /*vm.selectFork(goerliFork);
        //omniETH.safeMint();
        bytes memory path = abi.encodePacked(address(omniFTM));
        vm.expectRevert(bytes("Omni: invalid id for receiving"));
        omniETH.receiveToken(path, 1, bytes("0"));*/
    //}
}