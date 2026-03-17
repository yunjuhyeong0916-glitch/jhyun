`timescale 1ns/1ps

module gpio_thr_unpack_sync (
    input  wire        clk,
    input  wire        rstn,

    // AXI GPIO #0 (dual channel)
    input  wire [31:0] gpio_thr0_ch1,
    input  wire [31:0] gpio_thr0_ch2,

    // AXI GPIO #1 (dual channel)
    input  wire [31:0] gpio_thr1_ch1,
    input  wire [31:0] gpio_thr1_ch2,

    output reg  signed [7:0] cfg_thr_nrz,
    output reg  signed [7:0] cfg_thr4_0,
    output reg  signed [7:0] cfg_thr4_1,
    output reg  signed [7:0] cfg_thr4_2,
    output reg  signed [7:0] cfg_thr8_0,
    output reg  signed [7:0] cfg_thr8_1,
    output reg  signed [7:0] cfg_thr8_2,
    output reg  signed [7:0] cfg_thr8_3,
    output reg  signed [7:0] cfg_thr8_4,
    output reg  signed [7:0] cfg_thr8_5,
    output reg  signed [7:0] cfg_thr8_6,
    output reg                cfg_thr_en
);

    reg [63:0] gpio0_meta, gpio0_sync;
    reg [63:0] gpio1_meta, gpio1_sync;
    reg        update_tgl_d;

    wire update_tgl;
    wire apply_cfg;

    assign update_tgl = gpio1_sync[25];
    assign apply_cfg  = update_tgl ^ update_tgl_d;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            gpio0_meta   <= 64'd0;
            gpio0_sync   <= 64'd0;
            gpio1_meta   <= 64'd0;
            gpio1_sync   <= 64'd0;
            update_tgl_d <= 1'b0;

            // default = 기존 embedded threshold 값과 동일
            cfg_thr_nrz  <=  8'sd0;

            cfg_thr4_0   <= -8'sd85;
            cfg_thr4_1   <=  8'sd0;
            cfg_thr4_2   <=  8'sd85;

            cfg_thr8_0   <= -8'sd108;
            cfg_thr8_1   <= -8'sd72;
            cfg_thr8_2   <= -8'sd36;
            cfg_thr8_3   <=  8'sd0;
            cfg_thr8_4   <=  8'sd36;
            cfg_thr8_5   <=  8'sd72;
            cfg_thr8_6   <=  8'sd108;

            cfg_thr_en   <= 1'b0;
        end else begin
            // 2FF sync for GPIO buses
            gpio0_meta <= {gpio_thr0_ch2, gpio_thr0_ch1};
            gpio0_sync <= gpio0_meta;

            gpio1_meta <= {gpio_thr1_ch2, gpio_thr1_ch1};
            gpio1_sync <= gpio1_meta;

            update_tgl_d <= update_tgl;

            // Apply only when SW toggles update bit
            if (apply_cfg) begin
                // GPIO0 CH1
                cfg_thr_nrz <= gpio0_sync[7:0];
                cfg_thr4_0  <= gpio0_sync[15:8];
                cfg_thr4_1  <= gpio0_sync[23:16];
                cfg_thr4_2  <= gpio0_sync[31:24];

                // GPIO0 CH2
                cfg_thr8_0  <= gpio0_sync[39:32];
                cfg_thr8_1  <= gpio0_sync[47:40];
                cfg_thr8_2  <= gpio0_sync[55:48];
                cfg_thr8_3  <= gpio0_sync[63:56];

                // GPIO1 CH1
                cfg_thr8_4  <= gpio1_sync[7:0];
                cfg_thr8_5  <= gpio1_sync[15:8];
                cfg_thr8_6  <= gpio1_sync[23:16];
                cfg_thr_en  <= gpio1_sync[24];
            end
        end
    end

endmodule
