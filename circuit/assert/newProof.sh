#!/bin/bash

# Variable to store the name of the circuit
CIRCUIT=deposit


# In case there is a circuit name as an input
if [ "$1" ]; then
    CIRCUIT=$1
fi


# Generate the witness.wtns
node ${CIRCUIT}_js/generate_witness.js ${CIRCUIT}_js/${CIRCUIT}.wasm ${CIRCUIT}_input.json ${CIRCUIT}_js/witness.wtns



# Generate a zk-proof associated to the circuit and the witness. This generates proof.json and public.json
snarkjs groth16 prove ${CIRCUIT}_0001.zkey ${CIRCUIT}_js/witness.wtns proof.json public.json

# Verify the proof
snarkjs groth16 verify verification_key.json public.json proof.json

# Generate and print parameters of call
snarkjs generatecall | tee ${CIRCUIT}_parameters_alt.txt

# Formating for Solidity input format
sed -i '' 's/\["/[uint(/g' ${CIRCUIT}_parameters_alt.txt
sed -i '' 's/"\]/)\]/g' ${CIRCUIT}_parameters_alt.txt
sed -i '' 's/, "/, uint(/g' ${CIRCUIT}_parameters_alt.txt
sed -i '' 's/\],/\];/g' ${CIRCUIT}_parameters_alt.txt
sed -i '' 's/",/),/g' ${CIRCUIT}_parameters_alt.txt

