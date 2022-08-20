pragma circom 2.0.6;

include "./mimcsponge.circom";

template assesDeposit() {
    signal  input secret;
    signal  input amount;
    signal  output nullifier;
    signal  output keyHash;

    component mimcN = MiMCSponge(3, 220, 1);
    mimcN.ins[0] <== secret;
    mimcN.ins[1] <== amount;
    mimcN.ins[2] <== 1;
    mimcN.k <== 0;
    nullifier <== mimcN.outs[0];

    component mimcH = MiMCSponge(2, 220, 1);
    mimcH.ins[0] <== secret;
    mimcH.ins[1] <== amount;
    mimcH.k <== 0;
    keyHash <== mimcH.outs[0];
    
}

component main { public [amount] } = assesDeposit();

