pragma circom 2.0.6;

include "./mimcsponge.circom";

template assesDeposit() {
    signal  input treshold;
    signal  input secret;
    signal  input amount;
    signal  input nullifier;

    //CHECK IF SECRET KEY AND AMOUNT INDICATED CORRECTLY (so newly generated Nullifier equals Nullifier on input signal)
    component mimc2 = MiMCSponge(3, 220, 1);
    mimc2.ins[0] <== secret;
    mimc2.ins[1] <== amount;
    mimc2.ins[2] <== 1;
    mimc2.k <== 0;
    var nullifierGenerated = mimc2.outs[0];

    assert(nullifierGenerated == nullifier && amount >= treshold);
    
}

component main { public [treshold, nullifier] } = assesDeposit();
