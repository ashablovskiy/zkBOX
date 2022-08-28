pragma circom 2.0.6;

include "./mimcsponge.circom";

template Deposit() {
    signal input amount;
    signal input secretKey;
    signal output commitment;

    component mimc = MiMCSponge(3, 220, 1);
    mimc.ins[0] <== amount;
    mimc.ins[1] <== secretKey;
    mimc.ins[2] <== 1;

    mimc.k <== 0;

    commitment <== mimc.outs[0];
}

component main {public[amount]}  = Deposit();