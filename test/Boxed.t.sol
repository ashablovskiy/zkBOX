// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/Box.sol";
import "../src/NFT.sol";
import "../src/ERC20.sol";

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

    DepositVerifier dv;
    MintVerifier mv;
    AssertVerifier av;
    RedeemVerifier rv;

    function setUp() public {

        certificate = new BoxedNFT();
        asset = new KhaosAsset();

        dv = new DepositVerifier();
        mv = new MintVerifier();
        av = new AssertVerifier();
        rv = new RedeemVerifier();

        box = new Box(address(certificate),address(asset), address(dv), address(mv), address(av), address(rv));

        asset.mint(Alice, 200);
        asset.mint(RandomUser, 500);
    }


      function testWorkflow() public {

        // WORKFLOW: DEPOSIT -> MINT -> ASSERT ASSET TRESHOLD

       ///////////////////////DEPOSIT////////////////////
       
        vm.startPrank(Alice); //DEPOSIT ALICE
        asset.approve(address(box), 200);
       
       //PROOF GENERATED FOR {"amount": "10","secretKey": "1999"} 

        uint[2] memory a01 = [uint(0x0d386fb7621060a4a9e3a73ce3db1fc2b01d3c53b66d1afd88e118dfdb43231a), uint(0x200be9fe2680de039bf4583521479dcfcacf0d95a26e9997e27ac488edf61523)];
        uint[2][2] memory b01 = [[uint(0x2cef38a20302d3a2eb3c74d79c2723093f6e14d56dba091afd5601991f7388dc), uint(0x101fb93a7df21e83016e3a8c7f350676f7dd73b4d4c00ed04ac6bae5045aa620)],[uint(0x0631705028a27a3c32764c1bdb9636548685c184ee9e5ba470f17811078e86b9), uint(0x1cfaeeb379156910b0d1f446865a250a0afe4dfff155108cf375bbeacea10ee0)]];
        uint[2] memory c01 = [uint(0x14b1da3f6870a8c4a179ad8c5cef1503e71ea9e8dccdd8c13961fbc27b4ccaed), uint(0x049e47711d2dd887442c407ffd5666309e325de0b9bd8daf320d7793e514b224)];
        uint256[2] memory input01 = [uint(0x17bb043c01d34e7d8bb7369d8df719ed3132a5bd7cbc543a1a06b43d70ca8d8f),10];

        box.deposit(a01, b01, c01, input01);
       // assertEq(box.totalAssets, 10);
        vm.stopPrank();

        // vm.startPrank(RandomUser); //DEPOSIT BY RandomUser
        // asset.approve(address(vault), 200);

        // uint[2] memory a02 = 
        // uint[2][2] memory b02 = 
        // uint[2] memory c02 = 
        // uint256[2] memory input02 = 

        // vault.deposit(a02, b02, c02, input02);
        // vm.stopPrank();
        
        ////////////////MINT///////////////////////////////////////

        vm.startPrank(Bob);

        //PROOF GENERATED FOR  {"amount": "10", "secretKey": "1999"}
        uint[2] memory a1 = [uint(0x1ae14c1721d321207957f149a681fd78521938c85ac6076f40db742bde4cea71), uint(0x0befbf983dc7ae1c60e024ee021e68521c60ce775dc54973a2d8d8dc50093158)];
        uint[2][2] memory b1 = [[uint(0x120f34c93a580d905409cc8d065351a2e353540a9cd87dbad99302a03b1d9287), uint(0x02d780066c815f4853fc6da8627fe67ad6b7d129d805b5e6f934cdb1d40a56cf)],[uint(0x2f02530244b89df44384ce33b36501855216ffb2466ea8e6e7cb5c217767a88c), uint(0x1ffb03c5da57ce61c66ef333281350d919740bd0e7db048479e931bfbc8d2854)]];
        uint[2] memory c1 = [uint(0x0422768cd48d1717b37912d2a398441e990266eb45177d439ffb0a8f205ac0ec), uint(0x053e0cca312ab5a21ea4c706a7d54313e653be129cd00dbe43aa4dbbfd786d51)];
        uint[1] memory input1 = [uint(0x1d396171343daa988ac34690412d7f9f03edbf1348c8035ed525e2638fccbaea)];



        box.mintCertificate(a1, b1, c1, input1);
        console.log("OWNER", certificate.getTokenId(0));

        ////////////PROOF MINIMUM BALANCE///////////////////////////////

        //PROOF GENERATED FOR {"treshold": "4","secret": "1999","amount": "10", "nullifier": "13218455412978312490575890323879899493927815588697461542761906007863636835050"}
        uint[2] memory a21 = [uint(0x28284674fe3b36fd30357a325a042927d9371da57d2dfd89867662b92c567ab6), uint(0x10f6fedba94194c59c9ffd67d7334c339a496c0405ebfa5cca73fcaa3fcf3653)];
        uint[2][2] memory b21 = [[uint(0x127af98e7d1b834902e438e69c27ef760f45a6a00714fd4137146be8add12dcb), uint(0x2e35fb8a87b11679c14cef22a6860173741665de1b3495fc7e6c7c194c6728a0)],[uint(0x28182f2c417f027e4f9fd56a156596d2a29a13449724ed20c3d65c021cb62189), uint(0x06ff4de899e9408014fd0371c1c1284eb308a230e1492d0d64c99b557b851857)]];
        uint[2] memory c21 = [uint(0x216668b704e4dde2f04b78cbdc383eb382a1e839846ec21c47c3d3932b6a3020), uint(0x2424fb88a16ec9b259032b2f706e9413fdd813ac90a8500b539a2edea2e2e51a)];
        uint[2] memory input21 = [4, uint(0x1d396171343daa988ac34690412d7f9f03edbf1348c8035ed525e2638fccbaea)];

        //PROOF GENERATED FOR {"treshold": "8","secret": "1999","amount": "10", "nullifier": "13218455412978312490575890323879899493927815588697461542761906007863636835050"}
        uint[2] memory a22 = [uint(0x156c98a249c4da7646e639d626925e0439dc49bfba1c78736fe47f13b394ed1e), uint(0x1444a907b296b197ec3e8e92bc4af6f1f44803b64e04dce0aa536547efd01f4a)];
        uint[2][2] memory b22 = [[uint(0x1e1bbc0a4b8015fc347b0a404865e9ef4314228ac40dc309ced6839e33b45009), uint(0x141be18508b22596c76a3dfada7573e111214b2523726ddbfce8cf8f658fd11e)],[uint(0x082ff699fd58150668b21c0b005059560149148311ff66dccfdfe2db3f38723a), uint(0x219827ede98767ed384131ae36f083d7e33efe2599d1ce99bae980a51d74d661)]];
        uint[2] memory c22 = [uint(0x293ab8a3a26841b334020833c16a7959bf263e23f6724a3bf68eb97b4207d5d5), uint(0x284ad28fabb7da5a8444a280f85230d34b26ab931d357650aeef64e639889a96)];
        uint[2] memory input22 = [8, (0x1d396171343daa988ac34690412d7f9f03edbf1348c8035ed525e2638fccbaea)];
        
        box.proofMinBalance(a21, b21, c21, input21); // TEST PROOF FOR MIN_BALANCE = 4
        box.proofMinBalance(a22, b22, c22, input22); // TEST PROOF FOR MIN_BALANCE = 8

        ////////////REDEEM ASSETS///////////////////////////////

        //PROOF GENERATED FOR {"secret": "1999","amount": "10"}
        uint[2] memory a31 = [uint(0x1440808a6527a70cdf60cc81b3080eb3426e825ff92372fdd1992440cace6e00), uint(0x063844212dd34f8be7c74eb5daacb927c5c0e98778b1df6d15e05fa41ef532a9)];
        uint[2][2] memory b31 = [[uint(0x2236df31dfe04d0b024d97d4bb33bbcca1a85d43ffc63b8e6783959bfdd4e88d), uint(0x07c9d625ddf42e658310503741c3c84f8ba8bcbcb86ccab245bd7b595d0334db)],[uint(0x0f52528b5990c31782b03c3d931648d6a603ce465912025b0bfc64c413e97bcd), uint(0x1ff4f855a8a9b83e90121be4807fec1ddeff080f0ae9bcd772d0708f83b10de3)]];
        uint[2] memory c31 = [uint(0x07fe36a725e19025e0a5d6cf1c68ad2cb4fef5f3ce9a74142f859ff19f2e711d), uint(0x2595f817bc816f1e4854e78b1f59a98d2d8b71a9d93cf9c2b3dbfee8a3179f4e)];
        uint[3] memory input31 = [uint(0x1d396171343daa988ac34690412d7f9f03edbf1348c8035ed525e2638fccbaea), uint(0x17bb043c01d34e7d8bb7369d8df719ed3132a5bd7cbc543a1a06b43d70ca8d8f), 10];

       box.redeem(a31, b31, c31, input31);

        vm.stopPrank();

        //FUNCTIONS TO ADD: (1) PROOF THAT YOU HAVE SecretKey FOR PARTICULAR NFT

    }
}
