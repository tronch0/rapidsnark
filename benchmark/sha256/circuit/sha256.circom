pragma circom 2.0.3;

include "sha256_bytes.circom";

template Main(N) {
    signal input in[N];
    signal input hash[32];
    signal output out[32];

    component sha256 = Sha256Bytes(N);
    sha256.in <== in;
    out <== sha256.out;

    for (var i = 0; i < 32; i++) {
        out[i] === hash[i];
    }

    log("start ================");
    for (var i = 0; i < 32; i++) {
        log(out[i]);
    }
    log("finish ================");
}

// render this file before compilation
component main = Main(256);

