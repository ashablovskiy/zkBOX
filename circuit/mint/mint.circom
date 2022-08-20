pragma circom 2.0.6;

include "./mimcsponge.circom";

template mint() {
    signal  input  amount;
    signal  input  secretKey;
    signal  output nullifier;

    //check if secret is correct (hashes are qual)
    // Currently disabled

    // component mimc1 = MiMCSponge(1, 220, 1);
    // mimc1.ins[0] <== secretKey;
    // mimc1.k <== 0;
    // var out = mimc1.outs[0];
    // assert(out == keyHash); 

    // calculate Nullifier -> Hash(secretKey,1)
    component mimc2 = MiMCSponge(3, 220, 1);
    mimc2.ins[0] <== secretKey;
    mimc2.ins[1] <== amount;
    mimc2.ins[2] <== 1;
    mimc2.k <== 0;
    nullifier <== mimc2.outs[0];
}

component main = mint();
//component main { public [keyHash] } = mint();

//PROBLEM TO SOLVE: keyHash to be private so no one can link keyHash to Nullifier