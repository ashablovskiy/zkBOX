// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.13;

import "./NFT.sol";
import "./ERC20.sol";
import "./MerkleTree.sol";

import "./depositVerify.sol";
import "./mintVerify.sol";
import "./assertVerify.sol";
import "./redeemVerify.sol";


contract Box {

    BoxedNFT public certificate;
    KhaosAsset public token;
    MerkleTree public merkleTree;
    DepositVerifier public dv;
    MintVerifier public mv;
    AssertVerifier public av;
    RedeemVerifier public rv;


    uint public totalAssets; // total assets deposited to box

    mapping(uint => uint)public commitments; // commitment-> amount deposited 
    mapping(uint => bool)public nullifier; // nullifier -> true if NFT is minted 

    event Deposited(uint commitment, uint Amount, address From);
    event Minted(uint Nullifier, address To);
    event AssertBalance(uint Nullifier, uint Minimum_Balance_Proved);
    event Redeem(uint, uint);

    constructor(address _NFT, address _asset, address _dv, address _mv, address _av, address _rv, address _merkleTree, address _hasher) {
        
        certificate = BoxedNFT(_NFT);
        token = KhaosAsset(_asset);
        merkleTree = MerkleTree(_merkleTree);
        dv = DepositVerifier(_dv);
        mv = MintVerifier(_mv);
        av = AssertVerifier(_av);
        rv = RedeemVerifier(_rv);
    }
    
    /**
    @param input[0] Commitment = MiMC Hash(Amount, SecretKey)
    @param input[1] Amount to be depostied
    */
    function deposit(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint[2] memory input)public returns(bool) {
            
        require(dv.verifyProof(a, b, c, input), "Proof is not valid");
        require(input[1]>0, "Assets shall be gretear then zero");
        require(commitments[input[0]]==0, "Commitment already exists");

        token.transferFrom(msg.sender, address(this), input[1]); //transfer ERC20 tokens to contract
        commitments[input[0]] = input[1]; // update Commitment -> Balance
        totalAssets += input[1]; // update Total Assets deposited

        emit Deposited(input[0], input[1], msg.sender);
        return true;
    }
    /**
    @param input[0] Nullifier = MiMC Hash(Amount, SecretKey, 1)
    */
    function mintCertificate(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint[1] memory input)public returns(bool) {
        
        require(mv.verifyProof(a, b, c, input), "Proof is not valid");
        require(!nullifier[input[0]], "Nullifier was already used");

        certificate.safeMint(msg.sender, input[0]); // Mint NFT
        nullifier[input[0]] = true; // Set Nullifier -> True to avoid it repeated usage

        emit Minted(input[0], msg.sender);
        return true;
    }
    
    /**
    @param input[0] Minimum amount of assets that supposed to be proofed
    @param input[1] Nullifier
    */
    function proofMinBalance(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint[2] memory input)public returns(bool) {

        require(av.verifyProof(a, b, c, input), "Not proven");
        require(nullifier[input[1]], "Nullifier was not used before");

        emit AssertBalance(input[1], input[0]);
        return true;
    }

    /**
    @param input[0] Nullifier
    @param input[1] Commitment
    @param input[2] Amount of assets
    */
    function redeem(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint[3] memory input) public returns(bool) {

        require(rv.verifyProof(a, b, c, input), "Proof is not valid");
        require(nullifier[input[0]], "Nullifier was not used before");
        require(commitments[input[1]]>0, "No assets to withdraw");
        require(certificate.nullifiersAssigned(input[0])==0, "Certificate for nullifier is not minted");
        require(certificate.ownerOf(certificate.tokenIdAssigned(input[0])) == msg.sender, "Only the owner of NFT can burn it");

        totalAssets -= input[2]; // reduce total assets variable
        commitments[input[1]]=0; // reset commitment balance to 0
        
        token.transfer(msg.sender, input[2]); // transfer balance to redeemer
 
        certificate.burn(certificate.tokenIdAssigned(input[0])); // burn NFT: To get TokenId tokenIdAssigned mapping is used

        emit Redeem(input[1], input[0]);

        return true;
    }
function getTotalAssets() external view returns(uint) {
    return(totalAssets);
}

}
