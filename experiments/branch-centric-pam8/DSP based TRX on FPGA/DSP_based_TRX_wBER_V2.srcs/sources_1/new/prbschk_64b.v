`timescale 1ns/1ps
module prbschk_64b #(
    parameter integer BITCNT_W  = 48,
    parameter integer ERRCNT_W  = 48
) (
    input              rstb,
    input              i_clk,

    input      [1:0]   sel_prbs,
    input              ext_ptrn_en,
    input      [63:0]  ext_ptrn,

    input              state_in_en,
    input      [30:0]  state_in,
    output     [30:0]  state_out,

    input      [63:0]  din,

    output     [63:0]  exp,
    output     [63:0]  err_bits,
    output reg [6:0]   err_popcnt,

    output reg [BITCNT_W-1:0] bit_cnt,
    output reg [ERRCNT_W-1:0] err_cnt
);

    // ------------------------------------------------------------------------
    // Internal state (same concept as generator)
    // ------------------------------------------------------------------------
    reg  [30:0] state_q;
    reg  [30:0] state_d;
    reg  [30:0] s;
    reg  [63:0] exp64;
    reg  [30:0] state_base;

    // ------------------------------------------------------------------------
    // mode-change tracking (same as generator)
    // ------------------------------------------------------------------------
    reg  [1:0] sel_prbs_q;
    wire       sel_changed;

    always @(posedge i_clk or negedge rstb) begin
        if (!rstb) sel_prbs_q <= 2'b11;  // PRBS31 default
        else       sel_prbs_q <= sel_prbs;
    end
    assign sel_changed = (sel_prbs_q != sel_prbs);

    // ------------------------------------------------------------------------
    // Functions (must match generator)
    // ------------------------------------------------------------------------
    function fb_left;
        input [30:0] st;
        input [1:0]  mode;
        begin
            case (mode)
                2'b00: fb_left = st[6]  ^ st[5];     // PRBS7
                2'b01: fb_left = st[14] ^ st[13];    // PRBS15
                2'b10: fb_left = st[22] ^ st[17];    // PRBS23
                default: fb_left = st[30] ^ st[27];  // PRBS31
            endcase
        end
    endfunction

    function [30:0] step_left;
        input [30:0] st;
        input [1:0]  mode;
        reg fb;
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

    function out_msb;
        input [30:0] st;
        input [1:0]  mode;
        begin
            case (mode)
                2'b00: out_msb = st[6];
                2'b01: out_msb = st[14];
                2'b10: out_msb = st[22];
                default: out_msb = st[30];
            endcase
        end
    endfunction

    function [30:0] seed_of;
        input [1:0] mode;
        begin
            case (mode)
                2'b00: seed_of = 31'h0000_007F;
                2'b01: seed_of = 31'h0000_7FFF;
                2'b10: seed_of = 31'h007F_FFFF;
                default: seed_of = 31'h7FFF_FFFF;
            endcase
        end
    endfunction

    function [6:0] popcount64;
        input [63:0] x;
        integer i;
        integer c;
        begin
            c = 0;
            for (i = 0; i < 64; i = i + 1)
                c = c + x[i];
            popcount64 = c[6:0];
        end
    endfunction

    // ------------------------------------------------------------------------
    // Expected generation (same "state_in_en 즉시 base 사용" policy)
    // ------------------------------------------------------------------------
    integer k;
    always @(*) begin
        state_base = (state_in_en) ? state_in : state_q;

        s       = state_base;
        exp64   = 64'b0;
        state_d = state_base;

        if (ext_ptrn_en) begin
            exp64   = ext_ptrn;
            state_d = state_base; // hold
        end else begin
            for (k = 0; k < 64; k = k + 1) begin
                exp64[k] = out_msb(s, sel_prbs);
                s        = step_left(s, sel_prbs);
            end
            state_d = s;
        end
    end

    assign exp       = exp64;
    assign state_out = state_d;

    // ------------------------------------------------------------------------
    // State register update (THIS is the key: sel_changed => seed_of(sel_prbs))
    // ------------------------------------------------------------------------
    always @(posedge i_clk or negedge rstb) begin
        if (!rstb) begin
            state_q <= 31'h7FFF_FFFF; // same default as generator
        end else if (state_in_en) begin
            state_q <= state_in;      // manual load
        end else if (sel_changed) begin
            state_q <= seed_of(sel_prbs); // auto seed on mode change
        end else begin
            state_q <= state_d;       // advance
        end
    end

    // ------------------------------------------------------------------------
    // Error / counters
    // ------------------------------------------------------------------------
    assign err_bits = din ^ exp64;

    always @(*) begin
        err_popcnt = popcount64(err_bits);
    end

    always @(posedge i_clk or negedge rstb) begin
        if (!rstb) begin
            bit_cnt <= {BITCNT_W{1'b0}};
            err_cnt <= {ERRCNT_W{1'b0}};
        end else begin
            bit_cnt <= bit_cnt + {{(BITCNT_W-7){1'b0}}, 7'd64};
            err_cnt <= err_cnt + {{(ERRCNT_W-7){1'b0}}, err_popcnt};
        end
    end

endmodule