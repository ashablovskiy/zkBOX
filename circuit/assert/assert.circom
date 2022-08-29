pragma circom 2.0.6;

include "./mimcsponge.circom";

template assesDeposit() {
    signal  input treshold;
    signal  input secret;
    signal  input amount;
    signal  input nullifier;

    //CHECK IF SECRET KEY AND AMOUNT INDICATED CORRECTLY (so newly generated Nullifier equals Nullifier on input signal)
    component mimc = MiMCSponge(3, 220, 1);
    mimc.ins[0] <== amount;
    mimc.ins[1] <== secret;
    mimc.ins[2] <== 2;
    mimc.k <== 0;
    var nullifierGenerated = mimc.outs[0];

    assert(nullifierGenerated == nullifier && amount >= treshold);
    
}

component main { public [treshold, nullifier] } = assesDeposit();
