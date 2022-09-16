import * as fcl from "@onflow/fcl"

export function generator(seed) {
    this.seed = seed;
    this.g = () => {
        this.seed = lcg(BigInt(4294967296), BigInt(1664525), BigInt(1013904223), this.seed);
        return this.seed
    }
    this.g();
    this.g();
    this.g();
    this.range = (min,max) => {
        this.g()
        return Number(BigInt(min) + (this.seed % BigInt(max-min+1)))
    }
    this.pick = (options, weights) => {
        var weightRanges = [];
        var totalWeight = 0;
        weights.forEach((weight) => {
            totalWeight = totalWeight + weight;
            weightRanges.push(totalWeight);
        });
        let p = this.g() % BigInt(totalWeight);
        var lastWeight = 0;
        for (let i = 0; i < weightRanges.length; i++) {
            if (p >= lastWeight && p < weightRanges[i]) {
                return options[i];
            }
            lastWeight = weights[i];
        }
    }
    this.bool = () => {
        return this.g() % BigInt(2) === 0 ? true : false
    }
}


export async function calc(blockHeight, uuid) {
    console.log("calculating seed for", {blockHeight,uuid})
    const blockHash = await fcl.send([fcl.getBlock(), fcl.atBlockHeight(blockHeight)]).then(fcl.decode);
    const h = await sha256(uuid)
    const hashBytes = fromHexString(blockHash.id.toString())
    const saltBytes = fromHexString(h)
    var seed = BigInt(0)
    for (let i = 0; i < hashBytes.length; i++) {
        const byte = hashBytes[i] ^ saltBytes[i];
        seed = seed << BigInt(2)
        seed += BigInt(parseInt(byte, 16));
    } 
    console.log(seed)
    return (seed)
}

const fromHexString = (hexString) =>
  Uint8Array.from(hexString.match(/.{1,2}/g).map((byte) => parseInt(byte, 16)));

async function sha256(str) {
    const buf = await crypto.subtle.digest("SHA-256", new TextEncoder("utf-8").encode(str));
    return Array.prototype.map.call(new Uint8Array(buf), x=>(('00'+x.toString(16)).slice(-2))).join('');
}
  
function lcg(modulus, a, c, s) {
    return (a * s + c) % modulus;
}
