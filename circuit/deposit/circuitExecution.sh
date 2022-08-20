#!/bin/bash

# Variable to store the name of the circuit
CIRCUIT=deposit

# Variable to store the number of the ptau file
PTAU=14

# In case there is a circuit name as an input
if [ "$1" ]; then
    CIRCUIT=$1
fi

# In case there is a ptau file number as an input
if [ "$2" ]; then
    CIRCUIT=$2
fi

# Compile the circuit
circom ${CIRCUIT}.circom --r1cs --wasm --sym --c

# Generate the witness.wtns
node ${CIRCUIT}_js/generate_witness.js ${CIRCUIT}_js/${CIRCUIT}.wasm ${CIRCUIT}_input.json ${CIRCUIT}_js/witness.wtns

# Trusted setup phase 1 (The powers of tau, which is independent of the circuit)
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v

# Generate a .zkey file that will contain the proving and verification keys together with all phase 2 contributions
snarkjs groth16 setup ${CIRCUIT}.r1cs pot12_final.ptau ${CIRCUIT}_0000.zkey

# Contribute to the phase 2 of the ceremony (circuit dependent)
snarkjs zkey contribute ${CIRCUIT}_0000.zkey ${CIRCUIT}_0001.zkey --name="1st Contributor Name" -v

# Export the verification key
snarkjs zkey export verificationkey ${CIRCUIT}_0001.zkey verification_key.json

# Generate a zk-proof associated to the circuit and the witness. This generates proof.json and public.json
snarkjs groth16 prove ${CIRCUIT}_0001.zkey ${CIRCUIT}_js/witness.wtns proof.json public.json

# Verify the proof
snarkjs groth16 verify verification_key.json public.json proof.json

# Generate a Solidity verifier that allows verifying proofs on Ethereum blockchain
snarkjs zkey export solidityverifier ${CIRCUIT}_0001.zkey ${CIRCUIT}Verifier.sol

# Update the solidity version and name in the Solidity verifier
sed -i '' 's/0.6.11/0.8.13/' ${CIRCUIT}Verifier.sol
#sed -i '' 's/contract Verifier/contract ${CIRCUIT}Verifier/' ${CIRCUIT}Verifier.sol

# Generate and print parameters of call
snarkjs generatecall | tee ${CIRCUIT}_parameters.txt
