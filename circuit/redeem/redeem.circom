pragma circom 2.0.6;

include "./mimcsponge.circom";

template Redeem() {
    signal  input secretKey;
    signal  input amount;
    signal  output nullifier;
    signal  output commitment;

    component mimcN = MiMCSponge(3, 220, 1);
    mimcN.ins[0] <== amount;
    mimcN.ins[1] <== secretKey;
    mimcN.ins[2] <== 2;
    mimcN.k <== 0;
    nullifier <== mimcN.outs[0];

    component mimcC = MiMCSponge(3, 220, 1);
    mimcC.ins[0] <== amount;
    mimcC.ins[1] <== secretKey;
    mimcC.ins[2] <== 1;
    mimcC.k <== 0;
    commitment <== mimcC.outs[0];
    
}
component main { public [amount] } = Redeem();

