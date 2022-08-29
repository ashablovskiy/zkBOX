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

        vm.startPrank(Alice); 
        asset.approve(address(box), 100);
       
        /**
        DEPOSIT ASSETS

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
        
        vm.startPrank(Bob);

        /**
        MINT CERTIFICATE
        
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

        /** 
        PROOF MINIMUM BALANCE

        PROOF GENERATED FOR:
        
        "treshold": "12",
        "secret": "111111",
        "amount": "20",
        "nullifier": "5076799886472541078874867201030064582719343703460290082042269264860114411539"
        */
        uint[2] memory a21 = [uint(0x1f35e207a87e5c360cfd69b4c5f43f9eaaca18c9cb83387c9c45720c0e55f7f5), uint(0x08f18218988401364bed6c08826c71052c60fb755a000f84923349f971204456)];
        uint[2][2] memory b21 = [[uint(0x06253141d9e1d9463857bb8fd7caa9d43ad7c9381b2d0afbe3763fd7d0a3f22e), uint(0x0a56dd89ca551f5702e677b3aca5df3d1d727cbf2527994edb05e806100861e4)],[uint(0x0a8e70d2510e779121807db42a8d84d48560e796d95af7a4f4461515ad505491), uint(0x2c52ed16848fb5fd104139d9364392a47f4e17721f511bb15f542cc0489f258b)]];
        uint[2] memory c21 = [uint(0x01b4ea65c27decc2b394592aa107bf0b27db189fa43df5fb4e5fcd0b63cad316), uint(0x034f2a6db357fdea772bf09ec708395470d4ce9bee217b5ed8bcfda2470f18c1)];
        uint[2] memory input21 = [12,uint(0x0b395deda5aa694a22a9a9aad7f8301bad7c8efeef80bc1f31d84a0e79456013)];

        assertTrue(box.proofMinBalance(a21, b21, c21, input21)); 

        /**
        REDEEM ASSETS

        PROOF GENERATED FOR:

        "secret": "111111",
        "amount": "20"
        */
        uint[2] memory a31 = [uint(0x1dc8003f92b5e086dadf9af181d489cb4ccdaa72a482a2d9d7b893eafcde4ec4), uint(0x198241e540d72c9323ce2f539090b316bc9bd73e5c0365a2fa4b8aa365d4cf36)];
        uint[2][2] memory b31 = [[uint(0x08f1ef87b5eab3bfbef4aa042257fd1c4ece969bdce25cfaf4d6538a27ac443d), uint(0x2f6e5f8cf9163dc11bd6ba48b54cff28ffae7f691dbb385995f772e673b98af1)],[uint(0x00392cf5e29c5635d178435bf062773d75defce1cda2f67eed5f446fc6484af6), uint(0x23abad3bac53222d8d7fb93418e62b2316ad723ea701aba84c3ee4e4265f4c0c)]];
        uint[2] memory c31 = [uint(0x07397168e2e6542f8f25c72cfe0085ec529d2a77582f0973ebd774215fb11ff9), uint(0x1a14e566efb87fe4a502b66e509ff186d0a74445c082a8d43827d4dda3c1a46e)];
        uint[3] memory input31 = [uint(0x0b395deda5aa694a22a9a9aad7f8301bad7c8efeef80bc1f31d84a0e79456013),uint(0x02b073287ed1591f2ac2a5839c5bf60ca328660a7a949018564524cfa90e4aab),20];

        // assertEq(asset.balanceOf(Bob),0); // Balance of Bob before redeem

        box.redeem(a31, b31, c31, input31);
        
        assertEq(certificate.balanceOf(Bob),0); // Number of certificates Bob have after redeem
        assertEq(asset.balanceOf(Bob),20); // Balance of Bob after redeem
        assertEq(box.totalAssets(), 0); //Check that total assets is equal to 0 
        
        vm.expectRevert("No assets to withdraw"); //Let's try to redeem second time the same assets
        box.redeem(a31, b31, c31, input31);

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