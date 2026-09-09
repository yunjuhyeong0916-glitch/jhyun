`timescale 1ns/1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: Control and Coefficient Interface
// Module Name: gpio_ctrl_unpack_sync
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Synchronizes and unpacks GPIO control words into TX/RX configuration fields.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module gpio_ctrl_unpack_sync (
    input  wire        clk,
    input  wire        rstn,
    input  wire [31:0] gpio_ctrl,

    output reg  [1:0]  sel_prbs,
    output reg  [1:0]  mode,
    output reg         tx_ffe_en,
    output reg         ext_ptrn_en,
    output reg  [1:0]  ch_sel,
    output reg         cfg_use_mlsd,
    output reg         rx_ffe_en,
    output reg  [2:0]  tx_train_mode
);

    // gpio_ctrl bit map
    // [1:0]   sel_prbs
    // [3:2]   mode
    // [4]     tx_ffe_en
    // [5]     ext_ptrn_en
    // [7:6]   ch_sel
    // [8]     cfg_use_mlsd
    // [9]     rx_ffe_en
    // [12:10] tx_train_mode
    //          0: normal PRBS/modulated TX
    //          1: constant PAM4 -3 level
    //          2: constant PAM4 -1 level
    //          3: constant PAM4 +1 level
    //          4: constant PAM4 +3 level
    //          5: alternating -3/+3 every symbol
    //          6: isolated +3 pulse every 256 symbols on -3 baseline
    //          7: 128-symbol step, -3 then +3
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            sel_prbs       <= 2'b00;
            mode           <= 2'b00;
            tx_ffe_en      <= 1'b0;
            ext_ptrn_en    <= 1'b0;
            ch_sel         <= 2'b00;
            cfg_use_mlsd   <= 1'b0;
            rx_ffe_en      <= 1'b0;
            tx_train_mode  <= 3'd0;
        end else begin
            sel_prbs       <= gpio_ctrl[1:0];
            mode           <= gpio_ctrl[3:2];
            tx_ffe_en      <= gpio_ctrl[4];
            ext_ptrn_en    <= gpio_ctrl[5];
            ch_sel         <= gpio_ctrl[7:6];
            cfg_use_mlsd   <= gpio_ctrl[8];
            rx_ffe_en      <= gpio_ctrl[9];
            tx_train_mode  <= gpio_ctrl[12:10];
        end
    end

endmodule
