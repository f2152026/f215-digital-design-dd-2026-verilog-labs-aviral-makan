// cla4_dataflow.v
// The same 4-bit CLA as cla4.v, rewritten using dataflow modeling
// (continuous `assign` statements) instead of gate primitives. Compare
// the line count and readability of this file to cla4.v.
//
// TODO: add a delay to every assign statement (e.g. assign #(2) ...) --
// same default-delay expectation as everywhere else from Task 2 onward.
//   assign #(2) p = a ^ b;
//   assign #(2) g = a & b;
//   assign #(2) c1   = g[0] | (p[0] & cin);
//   assign #(2) c2   = g[1] | (p[1] & g[0]) | (p[1] & p[0] & cin);
//   assign #(2) c3   = ... (same pattern, one more term)
//   assign #(2) cout = ... (same pattern, one more term)
//   assign #(2) sum  = p ^ {c3, c2, c1, cin};

module cla4_dataflow(
  input  [3:0] a,
  input  [3:0] b,
  input        cin,
  output [3:0] sum,
  output       cout
);

  wire [3:0] p, g;
  wire c1, c2, c3;

  wire t10;
  wire t20, t21;
  wire t30, t31, t32;
  wire t40, t41, t42, t43;

  assign #(2,3) p = a ^ b;
  assign #(2,3) g = a & b;

  assign #(2,3) t10 = p[0] & cin;
  assign #(2,3) c1  = g[0] | t10;

  assign #(2,3) t20 = p[1] & g[0];
  assign #(2,3) t21 = p[1] & p[0] & cin;
  assign #(2,3) c2  = g[1] | t20 | t21;

  assign #(2,3) t30 = p[2] & g[1];
  assign #(2,3) t31 = p[2] & p[1] & g[0];
  assign #(2,3) t32 = p[2] & p[1] & p[0] & cin;
  assign #(2,3) c3  = g[2] | t30 | t31 | t32;

  assign #(2,3) t40 = p[3] & g[2];
  assign #(2,3) t41 = p[3] & p[2] & g[1];
  assign #(2,3) t42 = p[3] & p[2] & p[1] & g[0];
  assign #(2,3) t43 = p[3] & p[2] & p[1] & p[0] & cin;
  assign #(2,3) cout = g[3] | t40 | t41 | t42 | t43;

  assign #(2,3) sum = p ^ {c3, c2, c1, cin};

endmodule