// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8 .13;

import "./NFT.sol";
import "./ERC20.sol";
import "./depositVerify.sol";
import "./mintVerify.sol";
import "./assertVerify.sol";
import "./redeemVerify.sol";


contract Box {

    BoxedNFT public certificate;
    KhaosAsset public token;
    DepositVerifier public dv;
    MintVerifier public mv;
    AssertVerifier public av;
    RedeemVerifier public rv;


    uint public assets; // total assets deposited to box

    mapping(uint => uint)public KeyHashes; // MiMC Hash(SecretKey) -> balance deposited
    mapping(uint => bool)public nullifier; // uint - MiMC Hash(SecretKey,1) -> true if NFT is minted by SecretKey owner

    event Deposited(uint KeyHash, uint Amount, address From);
    event Minted(uint Nullifier, address To);
    event AssertBalance(uint Nullifier, uint Minimum_Balance_Proved);
    event RedeemCertificate(uint, uint);

    constructor(address _NFT, address _asset, address _dv, address _mv, address _av, address _rv) {
        certificate = BoxedNFT(_NFT);
        token = KhaosAsset(_asset);
        dv = DepositVerifier(_dv);
        mv = MintVerifier(_mv);
        av = AssertVerifier(_av);
        rv = RedeemVerifier(_rv);
    }
    function deposit(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint[2] memory input)public returns(bool) {
        require(dv.verifyProof(a, b, c, input), "Proof is not valid");
        token.transferFrom(msg.sender, address(this), input[1]);
        uint hash = input[0];
        KeyHashes[hash] = input[1]; // update balance
        assets += input[1];
        emit Deposited(hash, input[1], msg.sender);
        return true;
    }

    function mintCertificate(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint[1] memory input)public returns(bool) {
        require(mv.verifyProof(a, b, c, input), "Proof is not valid");
        certificate.safeMint(msg.sender, input[0]);
        nullifier[input[0]] = true;
        emit Minted(input[0], msg.sender);
        return true;
    }

    function proofMinBalance(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint[2] memory input)public returns(bool) {

        require(av.verifyProof(a, b, c, input), "Not proven");
        require(nullifier[input[1]], "No NFT with such nullifier");
        emit AssertBalance(input[1], input[0]);
        return true;
    }

    function redeem(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint[3] memory input) public returns(bool) {

        require(rv.verifyProof(a, b, c, input), "Proof is not valid");
        require(KeyHashes[input[1]]==0, "Nothing to redeem");
        require(certificate.nullifiersAssigned(input[0])==0, "NFT for subject nullifier is not minted");

        assets -= input[2]; // reduce total assets variable
        delete KeyHashes[input[1]]; // delete relevant keyHash record in mapping
        delete nullifier[input[0]]; // delete relevant nullifier record in mapping
        
        certificate.burn(certificate.tokenIdAssigned(input[0])); // burn NFT. to get TokenId tokenIdAssigned mapping is used
        
        token.transferFrom(address(this), msg.sender, input[2]); // transfer balance to redeemer

        emit RedeemCertificate(input[1], input[0]);

        return true;
    }

}
