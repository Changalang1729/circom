include "CompConstant.circom";
include "Num2Bits.circom";
include "BinSum.circom";


template LessThan(n) {
    signal input in[2];
    signal output out;

    component num2Bits0;
    component num2Bits1;

    component adder;

    adder = BinSum(n, 2);

    num2Bits0 = Num2Bits(n);
    num2Bits1 = Num2BitsNeg(n);

    in[0] ==> num2Bits0.in;
    in[1] ==> num2Bits1.in;

    var i;
    for (i=0;i<n;i++) {
        num2Bits0.out[i] ==> adder.in[0][i];
        num2Bits1.out[i] ==> adder.in[1][i];
    }

    adder.out[n-1] ==> out;
}


template RangeProof(bits, max_abs_value) {
    signal input in; 
 
    component lowerBound = LessThan(bits);
    component upperBound = LessThan(bits);
 
    lowerBound.in[0] <== max_abs_value + in; 
    lowerBound.in[1] <== 0;
    lowerBound.out === 0
 
    upperBound.in[0] <== 2 * max_abs_value;
    upperBound.in[1] <== max_abs_value + in; 
    upperBound.out === 0
}

// input: n field elements, whose abs are claimed to be less than max_abs_value
// output: none
template MultiRangeProof(n, bits, max_abs_value) {
    signal input in[n];
    component rangeProofs[n];
 
    for (var i = 0; i < n; i++) {
        rangeProofs[i] = RangeProof(bits, max_abs_value);
        rangeProofs[i].in <== in[i];
    }
}


template Sign() {
    signal input in[254];
    signal output sign;

    component comp = CompConstant(10944121435919637611123202872628637544274182200208017171849102093287904247808);

    var i;

    for (i=0; i<254; i++) {
        comp.in[i] <== in[i];
    }

    sign <== comp.out;
}
 
// input: any field elements
// output: 1 if field element is in (p/2, p-1], 0 otherwise
template IsNegative() {
    signal input in;
    signal output out;
 
    component num2Bits = Num2Bits(254);
    num2Bits.in <== in;
    component sign = Sign();
 
    for (var i = 0; i < 254; i++) {
        sign.in[i] <== num2Bits.out[i];
    }
 
    out <== sign.sign;
}
