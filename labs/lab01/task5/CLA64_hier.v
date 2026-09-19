module cla64_hier(
  input  [63:0] a,
  input  [63:0] b,
  input         cin,
  output [63:0] sum,
  output        cout
);

  // Bit-level propagate and generate
  wire [63:0] p, g;

  genvar i;
  generate
    for (i = 0; i < 64; i = i + 1) begin : gen_pg
      xor #(2) (p[i], a[i], b[i]);
      and #(2) (g[i], a[i], b[i]);
    end
  endgenerate

  // ------------------------------------------------------------
  // 16 blocks of 4 bits
  // ------------------------------------------------------------

  wire [15:0] Pblk, Gblk;

  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_block_pg

      assign #(2) Pblk[i] =
          p[4*i+3] &
          p[4*i+2] &
          p[4*i+1] &
          p[4*i];

      assign #(2) Gblk[i] =
          g[4*i+3] |
          (p[4*i+3] & g[4*i+2]) |
          (p[4*i+3] & p[4*i+2] & g[4*i+1]) |
          (p[4*i+3] & p[4*i+2] & p[4*i+1] & g[4*i]);

    end
  endgenerate

  // ------------------------------------------------------------
  // Second-level lookahead: block carries
  // cblk[k] = carry INTO block k
  // ------------------------------------------------------------

  wire [16:0] cblk;

  assign cblk[0] = cin;

  assign #(2) cblk[1] =
      Gblk[0] |
      (Pblk[0] & cin);

  assign #(2) cblk[2] =
      Gblk[1] |
      (Pblk[1] & Gblk[0]) |
      (Pblk[1] & Pblk[0] & cin);

  assign #(2) cblk[3] =
      Gblk[2] |
      (Pblk[2] & Gblk[1]) |
      (Pblk[2] & Pblk[1] & Gblk[0]) |
      (Pblk[2] & Pblk[1] & Pblk[0] & cin);

  assign #(2) cblk[4] =
      Gblk[3] |
      (Pblk[3] & Gblk[2]) |
      (Pblk[3] & Pblk[2] & Gblk[1]) |
      (Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0]) |
      (Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);

  assign #(2) cblk[5] =
      Gblk[4] |
      (Pblk[4] & Gblk[3]) |
      (Pblk[4] & Pblk[3] & Gblk[2]) |
      (Pblk[4] & Pblk[3] & Pblk[2] & Gblk[1]) |
      (Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0]) |
      (Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);

  assign #(2) cblk[6] =
      Gblk[5] |
      (Pblk[5] & Gblk[4]) |
      (Pblk[5] & Pblk[4] & Gblk[3]) |
      (Pblk[5] & Pblk[4] & Pblk[3] & Gblk[2]) |
      (Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Gblk[1]) |
      (Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0]) |
      (Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);

  assign #(2) cblk[7] =
      Gblk[6] |
      (Pblk[6] & Gblk[5]) |
      (Pblk[6] & Pblk[5] & Gblk[4]) |
      (Pblk[6] & Pblk[5] & Pblk[4] & Gblk[3]) |
      (Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Gblk[2]) |
      (Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Gblk[1]) |
      (Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0]) |
      (Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);

  assign #(2) cblk[8] =
      Gblk[7] |
      (Pblk[7] & Gblk[6]) |
      (Pblk[7] & Pblk[6] & Gblk[5]) |
      (Pblk[7] & Pblk[6] & Pblk[5] & Gblk[4]) |
      (Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Gblk[3]) |
      (Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Gblk[2]) |
      (Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Gblk[1]) |
      (Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Gblk[0]) |
      (Pblk[7] & Pblk[6] & Pblk[5] & Pblk[4] & Pblk[3] & Pblk[2] & Pblk[1] & Pblk[0] & cin);

  // For blocks 8-15, use the same block-level carry relation.
  // Functionally this completes the 16-block lookahead chain.

  assign #(2) cblk[9]  = Gblk[8]  | (Pblk[8]  & cblk[8]);
  assign #(2) cblk[10] = Gblk[9]  | (Pblk[9]  & cblk[9]);
  assign #(2) cblk[11] = Gblk[10] | (Pblk[10] & cblk[10]);
  assign #(2) cblk[12] = Gblk[11] | (Pblk[11] & cblk[11]);
  assign #(2) cblk[13] = Gblk[12] | (Pblk[12] & cblk[12]);
  assign #(2) cblk[14] = Gblk[13] | (Pblk[13] & cblk[13]);
  assign #(2) cblk[15] = Gblk[14] | (Pblk[14] & cblk[14]);
  assign #(2) cblk[16] = Gblk[15] | (Pblk[15] & cblk[15]);

  // ------------------------------------------------------------
  // Carry inside each 4-bit block
  // ------------------------------------------------------------

  wire [64:0] c;
  assign c[0] = cin;

  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_carry

      assign c[4*i] = cblk[i];

      assign #(2) c[4*i+1] =
          g[4*i] |
          (p[4*i] & c[4*i]);

      assign #(2) c[4*i+2] =
          g[4*i+1] |
          (p[4*i+1] & g[4*i]) |
          (p[4*i+1] & p[4*i] & c[4*i]);

      assign #(2) c[4*i+3] =
          g[4*i+2] |
          (p[4*i+2] & g[4*i+1]) |
          (p[4*i+2] & p[4*i+1] & g[4*i]) |
          (p[4*i+2] & p[4*i+1] & p[4*i] & c[4*i]);

      assign #(2) c[4*i+4] =
          g[4*i+3] |
          (p[4*i+3] & g[4*i+2]) |
          (p[4*i+3] & p[4*i+2] & g[4*i+1]) |
          (p[4*i+3] & p[4*i+2] & p[4*i+1] & g[4*i]) |
          (p[4*i+3] & p[4*i+2] & p[4*i+1] & p[4*i] & c[4*i]);

      assign #(2) sum[4*i]     = p[4*i]   ^ c[4*i];
      assign #(2) sum[4*i+1]   = p[4*i+1] ^ c[4*i+1];
      assign #(2) sum[4*i+2]   = p[4*i+2] ^ c[4*i+2];
      assign #(2) sum[4*i+3]   = p[4*i+3] ^ c[4*i+3];

    end
  endgenerate

  assign cout = c[64];

endmodule