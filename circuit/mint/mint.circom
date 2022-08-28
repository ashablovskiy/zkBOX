pragma circom 2.0.6;

include "./mimcsponge.circom";

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

// Verifies that:
// (1) Commitment (constructed from Amount and SecretKey) the same as privided Leaf
// (2) merkle proof is correct for given merkle root and a Leaf
// pathIndices input is an array of 0/1 selectors telling whether given pathElement is on the left or right side of merkle path

template Mint(levels) {
    signal  input   leaf;
    signal  input   root;
    signal  input   pathElements[levels];
    signal  input   pathIndices[levels];

    signal  input   amount;
    signal  input   secretKey;
    signal  output  nullifier;

    component mimcC = MiMCSponge(3, 220, 1);
    mimcC.ins[0] <== amount;
    mimcC.ins[1] <== secretKey;
    mimcC.ins[2] <== 1;
    mimcC.k <== 0;

    leaf === mimcC.outs[0]; //verifies that commitment == leaf
    
    component mimcN = MiMCSponge(3, 220, 1);
    mimcN.ins[0] <== amount;
    mimcN.ins[1] <== secretKey;
    mimcN.ins[2] <== 2;
    mimcN.k <== 0;
    nullifier <== mimcN.outs[0]; //constructs nullifier

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
    
    root === hashers[levels - 1].hash; //verifies that root generated with merkle proof for the leaf corresponds to provided as argument
}

component main{public[root]} = Mint(4); // Argument: width of tree (2^x)