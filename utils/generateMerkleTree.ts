import { MerkleTree, MiMCSponge } from "./merkleTree";
const fs = require('fs');

const int = [1,2,3,4];
const lvl = 4;

const ext = fs.readFileSync("./inp.txt").toString().trim().split(",").map(Number);

console.log("FROM INPUT:",int);
console.log("FROM FILE:",ext);

const leaves = int.map((e) => e.toString());
const batchTree = new MerkleTree(lvl, leaves);

const tree = new MerkleTree(lvl);
leaves.forEach((leaf) => {
  tree.insert(leaf);
});

console.log(tree.proof(leaves.length-1)); //PROOF FOR THE LAST LEAF ONLY 

// DISPALY ALL POSSIBLE PROOFS FOR TREE
// for (let i = 0; i < leaves.length; i++) {
//   //console.log(batchTree.proof(i));
//   console.log(tree.proof(i));
// };


fs.writeFile ("merkleProof.txt", JSON.stringify(tree.proof(leaves.length-1)), function(err: any) {
  if (err) throw err;
  console.log('complete');
  }
);
