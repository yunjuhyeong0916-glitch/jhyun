`timescale 1ns/1ps
module prbsgen_64b (
    input  logic        rstb,
    input  logic        i_clk,

    input  logic [1:0]  sel_prbs,
    input  logic        ext_ptrn_en,
    input  logic [63:0] ext_ptrn,

    input  logic        state_in_en,
    input  logic [30:0] state_in,
    output logic [30:0] state_out,

    output logic [63:0] dout
);

    // ------------------------------------------------------------------------
    // State
    // ------------------------------------------------------------------------
    logic [30:0] state_q, state_d;
    logic [30:0] s;
    logic [63:0] prbs64;

    // ------------------------------------------------------------------------
    // Feedback functions
    // ------------------------------------------------------------------------
    function automatic logic fb_left (
        input logic [30:0] st,
        input logic [1:0]  mode
    );
        case (mode)
            2'b00: fb_left = st[6]  ^ st[5];    // PRBS7
            2'b01: fb_left = st[14] ^ st[13];  // PRBS15
            2'b10: fb_left = st[22] ^ st[17];  // PRBS23
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

    // ------------------------------------------------------------------------
    // Seed table
    // ------------------------------------------------------------------------
    function automatic logic [30:0] seed_of (
        input logic [1:0] mode
    );
        case (mode)
            2'b00: seed_of = 31'h0000_007F;
            2'b01: seed_of = 31'h0000_7FFF;
            2'b10: seed_of = 31'h007F_FFFF;
            default: seed_of = 31'h7FFF_FFFF;
        endcase
    endfunction

    // ------------------------------------------------------------------------
    // ★ 핵심 수정 포인트
    // - state_in_en = 1 이면 state_q가 아니라 state_in을
    //   "즉시" PRBS 생성의 시작 상태로 사용
    // ------------------------------------------------------------------------
    logic [30:0] state_base;

    always_comb begin
        state_base = state_in_en ? state_in : state_q;

        s        = state_base;
        prbs64  = '0;
        state_d = state_base;

        if (ext_ptrn_en) begin
            prbs64  = ext_ptrn;
            state_d = state_base;
        end else begin
            for (int i = 0; i < 64; i++) begin
                prbs64[i] = out_msb(s, sel_prbs);
                s         = step_left(s, sel_prbs);
            end
            state_d = s;
        end
    end

    assign dout      = prbs64;
    assign state_out = state_d;

    // ------------------------------------------------------------------------
    // PRBS mode change tracking (safe)
    // ------------------------------------------------------------------------
    logic [1:0] sel_prbs_q;
    logic       sel_changed;

    always_ff @(posedge i_clk or negedge rstb) begin
        if (!rstb) sel_prbs_q <= 2'b11; // PRBS31 default
        else       sel_prbs_q <= sel_prbs;
    end
    assign sel_changed = (sel_prbs_q != sel_prbs);

    // ------------------------------------------------------------------------
    // State register
    // ------------------------------------------------------------------------
    always_ff @(posedge i_clk or negedge rstb) begin
        if (!rstb) begin
            state_q <= 31'h7FFF_FFFF;
        end else if (state_in_en) begin
            state_q <= state_in;
        end else if (sel_changed) begin
            state_q <= seed_of(sel_prbs);
        end else begin
            state_q <= state_d;
        end
    end

endmodule