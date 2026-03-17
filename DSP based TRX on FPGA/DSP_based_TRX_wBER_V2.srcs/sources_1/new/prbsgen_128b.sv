`timescale 1ns/1ps
module prbsgen_128b (
    input  logic         rstb,
    input  logic         i_clk,

    input  logic [1:0]   sel_prbs,
    input  logic         ext_ptrn_en,
    input  logic [127:0] ext_ptrn,

    output logic [127:0] dout
);

    // ------------------------------------------------------------
    // LFSR state
    // ------------------------------------------------------------
    logic [30:0] state_q, state_d;
    logic [30:0] s;
    logic [127:0] prbs128;

    // ------------------------------------------------------------
    // Feedback logic (same as 64b)
    // ------------------------------------------------------------
    function automatic logic fb_left (
        input logic [30:0] st,
        input logic [1:0]  mode
    );
        case (mode)
            2'b00: fb_left = st[6]  ^ st[5];   // PRBS7
            2'b01: fb_left = st[14] ^ st[13]; // PRBS15
            2'b10: fb_left = st[22] ^ st[17]; // PRBS23
            default: fb_left = st[30] ^ st[27]; // PRBS31
        endcase
    endfunction

    function automatic logic [30:0] step_left (
        input logic [30:0] st,
        input logic [1:0]  mode
    );
        logic fb;
        begin
            fb = fb_left(st, mode);
            case (mode)
                2'b00: step_left = {24'b0, st[5:0],  fb};
                2'b01: step_left = {16'b0, st[13:0], fb};
                2'b10: step_left = {8'b0,  st[21:0], fb};
                default: step_left = {st[29:0], fb};
            endcase
        end
    endfunction

    function automatic logic out_msb (
        input logic [30:0] st,
        input logic [1:0]  mode
    );
        case (mode)
            2'b00: out_msb = st[6];
            2'b01: out_msb = st[14];
            2'b10: out_msb = st[22];
            default: out_msb = st[30];
        endcase
    endfunction

    // ------------------------------------------------------------
    // 128-bit unrolled PRBS generation
    // ------------------------------------------------------------
    always_comb begin
        s        = state_q;
        prbs128 = '0;
        dout     = '0;
        state_d  = state_q;

        if (ext_ptrn_en) begin
            dout    = ext_ptrn;
            state_d = state_q;
        end else begin
            for (int i = 0; i < 128; i++) begin
                prbs128[i] = out_msb(s, sel_prbs);
                s          = step_left(s, sel_prbs);
            end
            dout    = prbs128;
            state_d = s;
        end
    end

    // ------------------------------------------------------------
    // Seed logic (unchanged)
    // ------------------------------------------------------------
    logic [30:0] seed_val;
    logic        seed_load;

    always_comb begin
        case (sel_prbs)
            2'b00: seed_val = 31'h0000_007F;
            2'b01: seed_val = 31'h0000_7FFF;
            2'b10: seed_val = 31'h007F_FFFF;
            default: seed_val = 31'h7FFF_FFFF;
        endcase
    end

    always_ff @(posedge i_clk or negedge rstb) begin
        if (!rstb) begin
            state_q   <= '0;
            seed_load <= 1'b1;
        end else begin
            if (seed_load) begin
                state_q   <= seed_val;
                seed_load <= 1'b0;
            end else begin
                state_q   <= state_d;
            end
        end
    end

endmodule