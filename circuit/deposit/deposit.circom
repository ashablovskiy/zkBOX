pragma circom 2.0.6;

include "./mimcsponge.circom";

template hashDeposit() {
    signal input amount;
    signal input secretKey;
    signal output keyHash;

    component mimc = MiMCSponge(2, 220, 1);
    mimc.ins[0] <== secretKey;
    mimc.ins[1] <== amount;

    mimc.k <== 0;

    keyHash <== mimc.outs[0];
}

component main {public[amount]}  = hashDeposit();