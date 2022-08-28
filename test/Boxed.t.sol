// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/Box.sol";
import "../src/NFT.sol";
import "../src/ERC20.sol";
import "../src/MerkleTree.sol";
import "../src/HasherMiMC.sol";


import "../src/depositVerify.sol";
import "../src/mintVerify.sol";
import "../src/assertVerify.sol";
import "../src/redeemVerify.sol";


contract BoxTest is Test {
using stdStorage for StdStorage;

    address Alice = address(200);
    address Bob = address(300);
    address RandomUser = address(400);

    Box box;
    BoxedNFT certificate;
    KhaosAsset asset;
    MerkleTree merkleTree;
    MiMC hasherHelper;

    DepositVerifier dv;
    MintVerifier mv;
    AssertVerifier av;
    RedeemVerifier rv;

    function setUp() public {

        certificate = new BoxedNFT();
        asset = new KhaosAsset();
        hasherHelper = new MiMC();
        merkleTree = new MerkleTree(4, hasherHelper.sponge());


        dv = new DepositVerifier();
        mv = new MintVerifier();
        av = new AssertVerifier();
        rv = new RedeemVerifier();

        box = new Box(address(certificate),address(asset), address(dv), address(mv), address(av), address(rv), address(merkleTree));

        asset.mint(Alice, 20);
        asset.mint(RandomUser, 500);
    }

      function testWorkflow() public {

       ///////////////////////DEPOSIT/////////////////////////////////////////////////////////////////////////////

        vm.startPrank(Alice); 
        asset.approve(address(box), 100);
       
        /**
        PROOF GENERATED FOR:

        "amount": "20",
        "secretKey": "111111"
        */
        uint[2] memory a00 =  [uint(0x2156023f2721310f3d4dc44e7e69d972be8ec70b26af6fc17b58477499ac23c5), uint(0x0ebd15ff686b64cd2eb4012432e88dbea8bc12493aee5e8ab47c3b4cfa3aada9)];
        uint[2][2] memory b00 =  [[uint(0x0ecd33e589aa6d66664186175a1980edc880526554b69121b9b5720f030f1847), uint(0x1114b5b2b9188c55d7f6fcada49023ea194d23d665b23e67fc3f44da5eaa6ede)],[uint(0x241a3a41a7148dc902889176a157b9721dfd396dc5b5b29c58b05e328b869fec), uint(0x1ed89231f119a80d9ac3e5595fbacafc414a75c74389b5d511bad3da77d95c2a)]];
        uint[2] memory c00 =  [uint(0x00d36f41e46e164e0d5d97ba976639fdd7a690932e6a097505cf0845c8d0ca5e), uint(0x2534ced95958f25ea8f293d1c19f1410f3a9a3655584cd3fc1286e9a7095e2f9)];
        uint256[2] memory input00 =  [uint(0x02b073287ed1591f2ac2a5839c5bf60ca328660a7a949018564524cfa90e4aab),20];

        assertEq(asset.balanceOf(Alice),20); // Balance of Alice before deposit
        
        box.deposit(a00, b00, c00, input00);
        // console.log("commitment/leaf", input00[0]);
        // console.log("ROOT AFTER DEPOSIT");
        // console.logBytes32(merkleTree.getLastRoot());
        
        assertEq(box.totalAssets(), 20); //Check that total assets is equal to 10
        assertEq(asset.balanceOf(Alice), 0); // Balance of Alice after deposit

        vm.stopPrank();
        
        ////////////////MINT///////////////////////////////////////////////////////////////////////////

        vm.startPrank(Bob);

        /**
        PROOF GENERATED FOR:

        "secretKey": "111111",
        "amount": "20",
        "root": "0xeb9b74ac4a14e15eaec775955c536d6c224bbb2eb1a7bb32a43572d06124e35",
        "pathElements": [
        "0x2fe54c60d3acabf3343a35b6eba15db4821b340f76e741e2249685ed4899af6c",
        "0x256a6135777eee2fd26f54b8b7037a25439d5235caee224154186d2b8a52e31d",
        "0x1151949895e82ab19924de92c40a3d6f7bcb60d92b00504b8199613683f0c200",
        "0x20121ee811489ff8d61f09fb89e313f14959a0f28bb428a20dba6b0b068b3bdb"
        ],
        "pathIndices": [ 0, 0, 0, 0 ],
        "leaf": "0x02b073287ed1591f2ac2a5839c5bf60ca328660a7a949018564524cfa90e4aab"
         */
        uint[2] memory a1 =  [uint(0x00c586d6aafd987326b3699fbed65ee958fc3ab9c2cce2c6b9a8f271638928db), uint(0x2d2456ff93d76e0277cc0519be6a5c3f77aefc1cfc237e232041dd3afb86954c)];
        uint[2][2] memory b1 =  [[uint(0x1deb82d2fb9f4987c8afbea168a88f1fce2e92bf2b0c3a92f891ae2b9e694f3c), uint(0x1ed6b7cddc48bf8a7e7d50e0c24846600c66d1c6a1392e9eee83d9815f3b6d3f)], [uint(0x1b1f3488c0ef8f92fc2da24307567f076d791c1a4430e061ba21a922a01d03b2), uint(0x215aa92f35702f344304383dc140cd7dbbac4fef1816a9a9f8117ce56c03069d)]];
        uint[2] memory c1 = [uint(0x0355f6ef33e60a41bdea8f4aec81ccfe26a04bf47c39abb99723d38d74f7f9cf), uint(0x2981f0f6fb37f1f5f3c76b2bfdbb60dd6102394043ca806d13363983f4d08856)];
        uint[2] memory input1 = [uint(0x0b395deda5aa694a22a9a9aad7f8301bad7c8efeef80bc1f31d84a0e79456013), uint(0xeb9b74ac4a14e15eaec775955c536d6c224bbb2eb1a7bb32a43572d06124e35)];

        assertEq(certificate.balanceOf(Bob),0); // NFT Bob has before mint

        box.mintCertificate(a1, b1, c1, input1);

        assertEq(certificate.balanceOf(Bob),1); // to make sure that NFT is minted to Bob

        // ////////////PROOF MINIMUM BALANCE///////////////////////////////

        // //PROOF GENERATED FOR {"treshold": "4","secret": "1999","amount": "10", "nullifier": "13218455412978312490575890323879899493927815588697461542761906007863636835050"}
        // uint[2] memory a21 = [uint(0x28284674fe3b36fd30357a325a042927d9371da57d2dfd89867662b92c567ab6), uint(0x10f6fedba94194c59c9ffd67d7334c339a496c0405ebfa5cca73fcaa3fcf3653)];
        // uint[2][2] memory b21 = [[uint(0x127af98e7d1b834902e438e69c27ef760f45a6a00714fd4137146be8add12dcb), uint(0x2e35fb8a87b11679c14cef22a6860173741665de1b3495fc7e6c7c194c6728a0)],[uint(0x28182f2c417f027e4f9fd56a156596d2a29a13449724ed20c3d65c021cb62189), uint(0x06ff4de899e9408014fd0371c1c1284eb308a230e1492d0d64c99b557b851857)]];
        // uint[2] memory c21 = [uint(0x216668b704e4dde2f04b78cbdc383eb382a1e839846ec21c47c3d3932b6a3020), uint(0x2424fb88a16ec9b259032b2f706e9413fdd813ac90a8500b539a2edea2e2e51a)];
        // uint[2] memory input21 = [4, uint(0x1d396171343daa988ac34690412d7f9f03edbf1348c8035ed525e2638fccbaea)];

        // assertTrue(box.proofMinBalance(a21, b21, c21, input21)); // TEST PROOF FOR MIN_BALANCE = 4



        // ////////////REDEEM ASSETS///////////////////////////////

        // //PROOF GENERATED FOR {"secret": "1999","amount": "10"}
        // uint[2] memory a31 = [uint(0x1440808a6527a70cdf60cc81b3080eb3426e825ff92372fdd1992440cace6e00), uint(0x063844212dd34f8be7c74eb5daacb927c5c0e98778b1df6d15e05fa41ef532a9)];
        // uint[2][2] memory b31 = [[uint(0x2236df31dfe04d0b024d97d4bb33bbcca1a85d43ffc63b8e6783959bfdd4e88d), uint(0x07c9d625ddf42e658310503741c3c84f8ba8bcbcb86ccab245bd7b595d0334db)],[uint(0x0f52528b5990c31782b03c3d931648d6a603ce465912025b0bfc64c413e97bcd), uint(0x1ff4f855a8a9b83e90121be4807fec1ddeff080f0ae9bcd772d0708f83b10de3)]];
        // uint[2] memory c31 = [uint(0x07fe36a725e19025e0a5d6cf1c68ad2cb4fef5f3ce9a74142f859ff19f2e711d), uint(0x2595f817bc816f1e4854e78b1f59a98d2d8b71a9d93cf9c2b3dbfee8a3179f4e)];
        // uint[3] memory input31 = [uint(0x1d396171343daa988ac34690412d7f9f03edbf1348c8035ed525e2638fccbaea), uint(0x17bb043c01d34e7d8bb7369d8df719ed3132a5bd7cbc543a1a06b43d70ca8d8f), 10];
        
        // assertEq(asset.balanceOf(Bob),0); // Balance of Bob before redeem

        // box.redeem(a31, b31, c31, input31);
        
        // assertEq(certificate.balanceOf(Bob),0); // Number of certificates Bob have after redeem
        // assertEq(asset.balanceOf(Bob),10); // Balance of Bob after redeem
        // assertEq(box.totalAssets(), 15); //Check that total assets is equal to 0 
        
        // vm.expectRevert("No assets to withdraw"); //Let's try to redeem second time the same assets
        // box.redeem(a31, b31, c31, input31);

        vm.stopPrank();

    }

// function testMerkleTree() public {

// console.log("LEVELS", merkleTree.levels());
// console.log("ROOT BEFORE _insert:");
// console.logBytes32(merkleTree.getLastRoot());

// //bytes32 testCommitment = keccak256("SALT");

// uint realCommitmentHex =uint(0x2c8e0413f3359042704a547c9cc9e307ccd3ec64ac44ce4c6225b9244d9a9384);
// uint realCommitmentDec = 1;
// bytes32 realC = bytes32(realCommitmentDec);
// //0x17ebb78eec239b6d3ca5fb067a4c038e8ca993739a4c1db1fbe245c77bfb3750
// merkleTree._insert(realC);

// console.log("ROOT AFTER _insert:");
// console.logBytes32(merkleTree.getLastRoot());
// }

}