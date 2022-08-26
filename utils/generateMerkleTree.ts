import { MerkleTree, MiMCSponge } from "./merkleTree";
const fs = require('fs');

//const int = [1,2,3,4];
const lvl = 2;

const ext = fs.readFileSync("./inp.txt").toString().trim().split(",").map(Number);

//console.log("FROM INPUT:",int);
console.log("FROM FILE:",ext);

const leaves = ext.map((e:number) => e.toString());
const batchTree = new MerkleTree(lvl, leaves);

const tree = new MerkleTree(lvl);
leaves.forEach((leaf:string) => {
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

/////////SEPARATE JSON ELEMENTS///////////
const obj = tree.proof(leaves.length-1);
const root = obj.root.toString();
const pE = obj.pathElements.toString().trim().split(",").map(Number);

function bnToHex(bn:any) {
  var base = 16;
  var hex = BigInt(bn).toString(base);
  if (hex.length % 2) {
    hex = '0' + hex;
  }
  return hex;
}

console.log("root:",bnToHex(root));
console.log("pE[1]:",bnToHex(pE[1])); //NOT CORRECT
// for (let i1 = 0; i1 < pE.length; i1++) {
// var pE_hex:any = bnToHex(pE[1]);
//   };

// console.log("pE_hex:",pE_hex);
