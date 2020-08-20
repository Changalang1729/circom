include "dependency.circom";

template Modulo(divisor_bits) {
    signal input dividend; // -8
    signal input divisor; // 5
    signal output remainder; // 2
    signal output quotient; // -2
 
    component is_neg = IsNegative();
    is_neg.in <== dividend;
 
    signal output is_dividend_negative;
    is_dividend_negative <== is_neg.out;
 
    signal output dividend_adjustment;
    dividend_adjustment <== 1 + is_dividend_negative * -2; // 1 or -1
 
    signal output abs_dividend;
    abs_dividend <== dividend * dividend_adjustment; // 8
 
    signal output raw_remainder;
    raw_remainder <-- abs_dividend % divisor;
 
    signal output neg_remainder;
    neg_remainder <-- divisor - raw_remainder;
 
    if (is_dividend_negative == 1 && raw_remainder != 0) {
        remainder <-- neg_remainder;
    } else {
        remainder <-- raw_remainder;
    }
 
    quotient <-- (dividend - remainder) / divisor; // (-8 - 2) / 5 = -2.
 
    dividend === divisor * quotient + remainder; // -8 = 5 * -2 + 2.
 
   // var 	SQRT_P = 85070591730234615865843651857942052864;
   // var SQRT_P = 16;
    component rp = MultiRangeProof(3, 128, SQRT_P);
    rp.in[0] <== divisor;
    rp.in[1] <== quotient;
    rp.in[2] <== dividend;
 
    // check that 0 <= remainder < divisor
    component remainderUpper = LessThan(divisor_bits);
    remainderUpper.in[0] <== remainder;
    remainderUpper.in[1] <== divisor;
    remainderUpper.out === 1;
}

component main = Modulo(8); 
