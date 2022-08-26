pragma circom 2.0.0;

// Massively borrowed from tornado cash: https://github.com/tornadocash/tornado-core/tree/master/circuits
//include "./bitify.circom";
include "./mimcsponge.circom";
//include "circomlib/pedersen.circom";

// Computes MiMC([left, right])
template HashLeftRight() {
    signal input left;
    signal input right;
    signal output hash;

    component hasher = MiMCSponge(2, 220, 1);
    hasher.ins[0] <== left;
    hasher.ins[1] <== right;
    hasher.k <== 0;
    hash <== hasher.outs[0];
}

// if s == 0 returns [in[0], in[1]]
// if s == 1 returns [in[1], in[0]]
template DualMux() {
    signal input in[2];
    signal input s;
    signal output out[2];

    s * (1 - s) === 0;
    out[0] <== (in[1] - in[0])*s + in[0];
    out[1] <== (in[0] - in[1])*s + in[1];
}

// Verifies that merkle proof is correct for given merkle root and a leaf
// pathIndices input is an array of 0/1 selectors telling whether given pathElement is on the left or right side of merkle path
template MerkleTreeChecker(levels) {
    signal input leaf;
    signal input root;
    signal input pathElements[levels];
    signal input pathIndices[levels];
    signal output rootGenerated;
    // signal output lev1_0;
    // signal output lev1_1;
    // signal output hashLev1;
    // signal output lev2_0;
    // signal output lev2_1;
    // signal output hashLev2;

    component selectors[levels];
    component hashers[levels];

    for (var i = 0; i < levels; i++) {
        selectors[i] = DualMux();
        selectors[i].in[0] <== i == 0 ? leaf : hashers[i - 1].hash;
        selectors[i].in[1] <== pathElements[i];
        selectors[i].s <== pathIndices[i];

        hashers[i] = HashLeftRight();
        hashers[i].left <== selectors[i].out[0];
        hashers[i].right <== selectors[i].out[1];
    }
    // lev1_0 <== hashers[0].left;
    // lev1_1 <== hashers[0].right;
    // hashLev1 <== hashers[0].hash;
    // lev2_0 <== hashers[1].left;
    // lev2_1 <== hashers[1].right;
    // hashLev2 <== hashers[1].hash;

    rootGenerated <== hashers[levels - 1].hash;
    rootGenerated === root;
}




component main {public [leaf, root]} = MerkleTreeChecker(2); // This value  corresponds to width of tree (2^x)