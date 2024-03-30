// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
    parameter BITS = 32,
    parameter DELAYS=10,
    parameter pADDR_WIDTH = 12,
    parameter pDATA_WIDTH = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output reg wbs_ack_o,
    output reg [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);
    wire clk;
    wire rst, rst_n;

    wire [`MPRJ_IO_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-1:0] io_out;
    wire [`MPRJ_IO_PADS-1:0] io_oeb;

    wire valid;

    wire sdram_cle;
    wire sdram_cs;
    wire sdram_cas;
    wire sdram_ras;
    wire sdram_we;
    wire sdram_dqm;
    wire [1:0] sdram_ba;
    wire [12:0] sdram_a;
    wire [31:0] d2c_data;
    wire [31:0] c2d_data;
    wire [3:0]  bram_mask;

    wire [22:0] ctrl_addr;
    wire ctrl_busy;
    wire ctrl_in_valid, ctrl_out_valid;

    reg ctrl_in_valid_q;

    // WB responding signals
    wire        wbs_ack_o_fir;
    wire [31:0] wbs_dat_o_fir;
    wire        wbs_ack_o_sdr;
    wire [31:0] wbs_dat_o_sdr;
    // fir
    // AXI stream
    wire ss_tvalid; 
    wire [31:0] ss_tdata; 
    wire ss_tlast; 
    wire ss_tready; 

    wire sm_tready; 
    wire sm_tvalid; 
    wire [31:0] sm_tdata; 
    wire sm_tlast;
    wire [3:0]               tap_WE;
    wire                     tap_EN;
    wire [(pDATA_WIDTH-1):0] tap_Di;
    wire [(pADDR_WIDTH-1):0] tap_A;
    wire [(pDATA_WIDTH-1):0] tap_Do;

    // bram for data RAM
    wire [3:0]               data_WE;
    wire                     data_EN;
    wire [(pDATA_WIDTH-1):0] data_Di;
    wire [(pADDR_WIDTH-1):0] data_A;
    wire [(pDATA_WIDTH-1):0] data_Do;

    // AXI LITE
    wire awready;
    wire wready;
    wire awvalid;
    wire [11:0] awaddr;
    wire wvalid;
    wire [31:0] wdata;

    wire arready;
    wire rready;
    wire arvalid;
    wire [11:0] araddr;
    wire rvalid;
    wire [31:0] rdata;
    
    // WB MI A
    
    assign valid = wbs_stb_i && wbs_cyc_i && (wbs_adr_i[31:24] == 'h38);
    assign ctrl_in_valid = wbs_we_i ? valid : ~ctrl_in_valid_q && valid;
    assign wbs_ack_o_sdr = (wbs_we_i) ? ~ctrl_busy && valid : ctrl_out_valid; 
    assign bram_mask = wbs_sel_i & {4{wbs_we_i}};
    assign ctrl_addr = wbs_adr_i[22:0];

    always@(*) begin
        wbs_ack_o = 0;
        wbs_dat_o = 0;
        if(wbs_cyc_i && wbs_stb_i) begin
            if(wbs_adr_i[31:24] == 'h31) begin
                wbs_ack_o = wbs_ack_o_fir;
                wbs_dat_o = wbs_dat_o_fir;
            end
            else if(wbs_adr_i[31:24] == 'h38) begin
                wbs_ack_o = wbs_ack_o_sdr;
                wbs_dat_o = wbs_dat_o_sdr;
            end
        end
    end

    // IO
    assign io_out = d2c_data;
    assign io_oeb = {(`MPRJ_IO_PADS-1){rst}};

    // IRQ
    assign irq = 3'b000;	// Unused

    // LA
    assign la_data_out = {{(127-BITS){1'b0}}, d2c_data};
    // Assuming LA probes [65:64] are for controlling the count clk & reset  
    assign clk = (~la_oenb[64]) ? la_data_in[64]: wb_clk_i;
    assign rst = (~la_oenb[65]) ? la_data_in[65]: wb_rst_i;
    assign rst_n = ~rst;

    always @(posedge clk) begin
        if (rst) begin
            ctrl_in_valid_q <= 1'b0;
        end
        else begin
            if (~wbs_we_i && valid && ~ctrl_busy && ctrl_in_valid_q == 1'b0)
                ctrl_in_valid_q <= 1'b1;
            else if (ctrl_out_valid)
                ctrl_in_valid_q <= 1'b0;
        end
    end

    sdram_controller user_sdram_controller (
        .clk(clk),
        .rst(rst),
        
        .sdram_cle(sdram_cle),
        .sdram_cs(sdram_cs),
        .sdram_cas(sdram_cas),
        .sdram_ras(sdram_ras),
        .sdram_we(sdram_we),
        .sdram_dqm(sdram_dqm),
        .sdram_ba(sdram_ba),
        .sdram_a(sdram_a),
        .sdram_dqi(d2c_data),
        .sdram_dqo(c2d_data),

        .user_addr(ctrl_addr),
        .rw(wbs_we_i),
        .data_in(wbs_dat_i),
        .data_out(wbs_dat_o_sdr),
        .busy(ctrl_busy),
        .in_valid(ctrl_in_valid),
        .out_valid(ctrl_out_valid)
    );

    sdr user_bram (
        .Rst_n(rst_n),
        .Clk(clk),
        .Cke(sdram_cle),
        .Cs_n(sdram_cs),
        .Ras_n(sdram_ras),
        .Cas_n(sdram_cas),
        .We_n(sdram_we),
        .Addr(sdram_a),
        .Ba(sdram_ba),
        .Dqm(bram_mask),
        .Dqi(c2d_data),
        .Dqo(d2c_data)
    );

/*--------------------------------------*/
/* User project is instantiated  here   */
/*--------------------------------------*/

WBToAXI wbtoaxi_u (
    // WB
    .wb_clk_i(wb_clk_i),
    .wb_rst_i(wb_rst_i),
    .wbs_stb_i(wbs_stb_i),
    .wbs_cyc_i(wbs_cyc_i),
    .wbs_we_i(wbs_we_i),
    .wbs_sel_i(wbs_sel_i),
    .wbs_dat_i(wbs_dat_i),
    .wbs_adr_i(wbs_adr_i),
    .wbs_ack_o(wbs_ack_o_fir),
    .wbs_dat_o(wbs_dat_o_fir),

    // AXI LITE
    .awready(awready),
    .wready(wready),
    .awvalid(awvalid),
    .awaddr(awaddr),
    .wvalid(wvalid),
    .wdata(wdata),

    .arready(arready),
    .rready(rready),
    .arvalid(arvalid),
    .araddr(araddr),
    .rvalid(rvalid),
    .rdata(rdata),

    .ss_tvalid(ss_tvalid), 
    .ss_tdata(ss_tdata), 
    .ss_tlast(ss_tlast), 
    .ss_tready(ss_tready), 

    .sm_tready(sm_tready), 
    .sm_tvalid(sm_tvalid), 
    .sm_tdata(sm_tdata), 
    .sm_tlast(sm_tlast)
);

fir fir_1(
    // AXI LITE
    .awready(awready),
    .wready(wready),
    .awvalid(awvalid),
    .awaddr(awaddr),
    .wvalid(wvalid),
    .wdata(wdata),

    .arready(arready),
    .rready(rready),
    .arvalid(arvalid),
    .araddr(araddr),
    .rvalid(rvalid),
    .rdata(rdata),
    
    // AXI stream
    .ss_tvalid(ss_tvalid), 
    .ss_tdata(ss_tdata), 
    .ss_tlast(ss_tlast), 
    .ss_tready(ss_tready), 

    .sm_tready(sm_tready), 
    .sm_tvalid(sm_tvalid), 
    .sm_tdata(sm_tdata), 
    .sm_tlast(sm_tlast), 

    // bram for tap RAM
    .tap_WE(tap_WE),
    .tap_EN(tap_EN),
    .tap_Di(tap_Di),
    .tap_A(tap_A),
    .tap_Do(tap_Do),

    // bram for data RAM
    .data_WE(data_WE),
    .data_EN(data_EN),
    .data_Di(data_Di),
    .data_A(data_A),
    .data_Do(data_Do),

    .axis_clk(wb_clk_i),
    .axis_rst_n(!wb_rst_i)
);
	

bram11 data_ram (
    .clk(wb_clk_i),
    .we(data_WE[0]),
    .re(data_EN),
    .waddr(data_A),
    .raddr(data_A),
    .wdi(data_Di),
    .rdo(data_Do)
);

bram11 tap_ram (
    .clk(wb_clk_i),
    .we(tap_WE[0]),
    .re(tap_EN),
    .waddr(tap_A),
    .raddr(tap_A),
    .wdi(tap_Di),
    .rdo(tap_Do)
);
// uart uart (
// `ifdef USE_POWER_PINS
	// .vccd1(vccd1),	
	// .vssd1(vssd1),	
// `endif
    // .wb_clk_i(wb_clk_i),
    // .wb_rst_i(wb_rst_i),



    // .wbs_stb_i(wbs_stb_i),
    // .wbs_cyc_i(wbs_cyc_i),
    // .wbs_we_i(wbs_we_i),
    // .wbs_sel_i(wbs_sel_i),
    // .wbs_dat_i(wbs_dat_i),
    // .wbs_adr_i(wbs_adr_i),
    // .wbs_ack_o(wbs_ack_o),
    // .wbs_dat_o(wbs_dat_o),


    // .io_in  (io_in      ),
    // .io_out (io_out     ),
    // .io_oeb (io_oeb     ),

    // .user_irq (irq)
// );
endmodule


module WBToAXI(
    // WB
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output reg [31:0] wbs_dat_o,

    // AXI LITE
    input awready,
    input wready,
    output reg awvalid,
    output reg [11:0] awaddr,
    output reg wvalid,
    output reg [31:0] wdata,

    input arready,
    output reg rready,
    output reg arvalid,
    output reg [11:0] araddr,
    input rvalid,
    input [31:0] rdata,

    // AXI stream
    output reg ss_tvalid, 
    output reg [31:0] ss_tdata, 
    output reg ss_tlast, 
    input ss_tready, 

    output reg sm_tready, 
    input sm_tvalid, 
    input [31:0] sm_tdata, 
    input sm_tlast 
);

reg wbs_ack_o;
wire fir_valid;
wire fir_axil;
reg aw_handshaked;
reg w_handshaked;
reg ar_handshaked;

assign fir_valid = (wbs_stb_i == 1 && wbs_cyc_i == 1 && wbs_adr_i[31:24] == 'h31);
assign fir_axil = wbs_adr_i[7] == 0;

always@(posedge wb_clk_i or posedge wb_rst_i)begin
    if(wb_rst_i)begin
        aw_handshaked   <= 0;
        w_handshaked    <= 0;
        ar_handshaked   <= 0;
    end
    else begin
        if(wbs_ack_o)               aw_handshaked <= 0;
        else if(awvalid && awready) aw_handshaked <= 1;
        else                        aw_handshaked <= aw_handshaked;

        if(wbs_ack_o)               w_handshaked <= 0;
        else if(wvalid && wready)   w_handshaked <= 1;
        else                        w_handshaked <= w_handshaked;

        if(wbs_ack_o)               ar_handshaked <= 0;
        else if(arvalid && arready) ar_handshaked <= 1;
        else                        ar_handshaked <= ar_handshaked;
    end
end

// AXI LITE write
    // input awready,
    // input wready,
    // output awvalid,
    // output [11:0] awaddr,
    // output wvalid,
    // output [31:0] wdata,

always@(*) begin
    if(fir_valid && fir_axil) begin
        // awvalid
        awvalid = (wbs_we_i && !aw_handshaked);
        // wvalid
        wvalid = (wbs_we_i && !w_handshaked);
        // awaddr
        awaddr = wbs_adr_i[11:0];
        // wdata
        wdata = wbs_dat_i;

    end else begin
        awvalid = 0;
        awaddr  = 0;
        wvalid  = 0;
        wdata   = 0;
    end
end

// AXI LITE read
    // input arready,
    // output rready,
    // output arvalid,
    // output [11:0] araddr,
    // input rvalid,
    // input [31:0] rdata,

always@(*) begin
    if(fir_valid && fir_axil) begin
        // rready
        rready = (!wbs_we_i);
        // arvalid
        arvalid = (!wbs_we_i && !ar_handshaked);
        // araddr
        araddr = wbs_adr_i[11:0];

    end else begin
        rready  = 0;
        arvalid = 0;
        araddr  = 0;
    end
end

// AXI stream ss
    // output ss_tvalid, 
    // output [31:0] ss_tdata, 
    // output ss_tlast, 
    // input ss_tready, 

always@(*) begin
    if(fir_valid && !fir_axil && wbs_adr_i[7:0] == 'h80) begin
        // ss_tvalid
        ss_tvalid = wbs_we_i;

        // ss_tdata
        ss_tdata = wbs_dat_i;

        // ss_tlast
        ss_tlast = 1;

    end else begin
        ss_tvalid   = 0;
        ss_tdata    = 0;
        ss_tlast    = 0;
    end
end

// AXI stream sm 
    // output sm_tready, 
    // input sm_tvalid, 
    // input [31:0] sm_tdata, 
    // input sm_tlast, 

always@(*) begin
    if(fir_valid && !fir_axil && wbs_adr_i[7:0] == 'h84) begin
        // sm_tready
        sm_tready = 1;

    end else begin
        sm_tready = 0;
    end
end

// ack to wb and wbs_dat_o
always@(*) begin
    wbs_dat_o = 0;

    if(fir_valid && fir_axil)
        wbs_dat_o = rdata;
    else if(fir_valid && !fir_axil && wbs_adr_i[7:0] == 'h84)
        wbs_dat_o = sm_tdata;

    wbs_ack_o = ((w_handshaked == 1 && aw_handshaked == 1) 
              || (rready == 1 && rvalid == 1) 
              || (ss_tvalid == 1 && ss_tready == 1) 
              || (sm_tready == 1 && sm_tvalid == 1));
    // wbs_ack_o = ((w_handshaked == 1 && aw_handshaked == 1) 
    //           || (rready == 1 && rvalid == 1));
end


endmodule

module fir 
#(  parameter pADDR_WIDTH = 12,
    parameter pDATA_WIDTH = 32,
    parameter Tape_Num    = 11,
    parameter FIFO_width = 4
)
(
    output  wire                     awready,
    output  wire                     wready,
    input   wire                     awvalid,
    input   wire [(pADDR_WIDTH-1):0] awaddr,
    input   wire                     wvalid,
    input   wire [(pDATA_WIDTH-1):0] wdata,
    output  wire                     arready,
    input   wire                     rready,
    input   wire                     arvalid,
    input   wire [(pADDR_WIDTH-1):0] araddr,
    output  wire                     rvalid,
    output  reg [(pDATA_WIDTH-1):0] rdata,    
    input   wire                     ss_tvalid, 
    input   wire [(pDATA_WIDTH-1):0] ss_tdata, 
    input   wire                     ss_tlast, 
    output  reg                     ss_tready, 
    input   wire                     sm_tready, 
    output  reg                     sm_tvalid, 
    output  wire [(pDATA_WIDTH-1):0] sm_tdata, 
    output  reg                     sm_tlast, 
    
    // bram for tap RAM
    output  wire [3:0]               tap_WE,
    output  wire                     tap_EN,
    output  wire [(pDATA_WIDTH-1):0] tap_Di,
    output  reg [(pADDR_WIDTH-1):0] tap_A,
    input   wire [(pDATA_WIDTH-1):0] tap_Do,

    // bram for data RAM
    output  wire [3:0]               data_WE,
    output  wire                     data_EN,
    output  wire [(pDATA_WIDTH-1):0] data_Di,
    output  wire [(pADDR_WIDTH-1):0] data_A,
    input   wire [(pDATA_WIDTH-1):0] data_Do,

    input   wire                     axis_clk,
    input   wire                     axis_rst_n
);


    // write your code here!
    parameter IDLE = 2'b00, WAIT_FOR_DATA = 2'b01, COMPUTE = 2'b10,  RESET = 2'b11;
    reg [1:0] current_state, next_state;

    reg [(pDATA_WIDTH-1):0] configuration;
    reg [(pDATA_WIDTH-1):0] data_length;

    reg [(pADDR_WIDTH-1):0] axilite_write_addr;
    reg [(pDATA_WIDTH-1):0] axilite_write_data;
    reg axilite_wdata_received;
    reg axilite_waddr_received;
    reg axilite_write_en;

    //reg [(pADDR_WIDTH-1):0] axilite_reg_raddr;
    reg [(pDATA_WIDTH-1):0] axilite_read_reg;
    reg axilite_out_valid;
    reg wait_tapram_data;
    reg axilite_raddr_received;
    reg [(pADDR_WIDTH-1):0] axilite_read_addr;
    reg read_data_length;
    reg read_configuration;
    
    reg first_data;
    reg [5:0] shift_counter;
    wire data_write_en;
    reg [3:0] data_read_stage;
    reg computing, outputing;
    reg last_data;
    reg signed [(pDATA_WIDTH-1):0] data_received;
    reg [9:0] data_counter;

    reg signed [(pDATA_WIDTH-1):0] accumulated_result;
    wire signed [(pDATA_WIDTH-1):0] mult_result;
    reg signed [(pDATA_WIDTH-1):0] mult1;
    wire signed [(pDATA_WIDTH-1):0] mult2;
    reg signed [(pDATA_WIDTH-1):0] current_data;

    reg signed [(pDATA_WIDTH-1):0] In_FIFO[(FIFO_width**2-1):0], Out_FIFO[(FIFO_width**2-1):0];
    reg [(FIFO_width):0] In_FIFO_read_index, In_FIFO_write_index, Out_FIFO_read_index, Out_FIFO_write_index;
    wire In_FIFO_empty, In_FIFO_full, Out_FIFO_empty, Out_FIFO_full;

    always@(*)begin
        case(current_state)
        IDLE:begin
            if(configuration[0] == 1) next_state = WAIT_FOR_DATA;
            else next_state = IDLE;
        end
        WAIT_FOR_DATA:begin
            if(ss_tvalid) next_state = COMPUTE;
            else next_state = WAIT_FOR_DATA;
        end
        COMPUTE:begin
            if(sm_tlast && sm_tready && sm_tvalid) next_state = IDLE;
            else next_state = COMPUTE;
        end
        default:begin
            next_state = IDLE;
        end
        endcase
    end

    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            current_state <= IDLE;
        end
        else begin
            current_state <= next_state;
        end
    end

    //-------------------------------------tap sram----------------------------------------------------
    assign tap_EN = 1;

    // axi lite write
    assign awready = !axilite_waddr_received;
    assign wready = !axilite_wdata_received;
    assign tap_WE = {4{axilite_write_en && axilite_write_addr != 12'h00 && axilite_write_addr != 12'h10}};
    assign tap_Di = axilite_write_data;

    always@(*)begin
        axilite_write_en = (axilite_waddr_received && axilite_wdata_received);
    end

    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            axilite_write_addr <= 0;
        end
        else begin
            if(awvalid && awready) axilite_write_addr <= awaddr;
            else axilite_write_addr <= axilite_write_addr;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            axilite_write_data <= 0;
        end
        else begin
            if(wvalid && wready) axilite_write_data <= wdata;
            else axilite_write_data <= axilite_write_data;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            axilite_waddr_received <= 0;
        end
        else begin
            if(awvalid && awready) axilite_waddr_received <= 1;
            else if(axilite_write_en) axilite_waddr_received <= 0;
            else axilite_waddr_received <= axilite_waddr_received;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            axilite_wdata_received <= 0;
        end
        else begin
            if(wvalid && wready) axilite_wdata_received <= 1;
            else if(axilite_write_en) axilite_wdata_received <= 0;
            else axilite_wdata_received <= axilite_wdata_received;
        end
    end

    // axi lite read
    assign arready = !rvalid && !axilite_write_en;
    assign rvalid = axilite_out_valid;

    always@(*)begin
        if(read_configuration) rdata = {configuration[31:5],ss_tready,configuration[3:0]};
        else if(read_data_length) rdata = data_length;
        else rdata = axilite_read_reg;
    end

    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            axilite_raddr_received <= 0;
        end
        else begin
            if(arvalid && arready) axilite_raddr_received <= 1;
            //else if(rvalid && rready) axilite_raddr_received <= 0;
            else axilite_raddr_received <= 0;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            axilite_read_addr <= 0;
        end
        else begin
            if(arvalid && arready) axilite_read_addr <= araddr;
            else axilite_read_addr <= axilite_read_addr;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            read_data_length <= 0;
        end
        else begin
            if(arvalid && arready && araddr == 12'h10) read_data_length <= 1;
            else if(rvalid && rready) read_data_length <= 0;
            else read_data_length <= read_data_length;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            read_configuration <= 0;
        end
        else begin 
            if(arvalid && arready && araddr == 12'h00) read_configuration <= 1;
            else if(rvalid && rready) read_configuration <= 0;
            else read_configuration <= read_configuration;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            wait_tapram_data <= 0;
        end
        else begin
            if(axilite_raddr_received) wait_tapram_data <= 1;
            else wait_tapram_data <= 0;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            axilite_read_reg <= 0;
        end
        else begin 
            if(wait_tapram_data) axilite_read_reg <= tap_Do;
            else axilite_read_reg <= axilite_read_reg;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            axilite_out_valid <= 0;
        end
        else begin
            if(rvalid && rready) axilite_out_valid <= 0;
            else if(wait_tapram_data) axilite_out_valid <= 1;
            else axilite_out_valid <= axilite_out_valid;
        end
    end

    // axi lite address control

    always@(*)begin
        if(axilite_raddr_received && (axilite_read_addr != 12'h00 && axilite_read_addr != 12'h10)) tap_A = axilite_read_addr-12'h40;
        else if(axilite_write_en) tap_A = axilite_write_addr - 12'h40;
        else tap_A = computing ? data_read_stage*4 : 0;
    end

    // configuration and data length storage
    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            configuration <= 32'h0000_0004;
        end
        else begin 
            if(axilite_write_en && axilite_write_addr == 12'h00) configuration <= axilite_write_data;
            else if(ss_tvalid && current_state == WAIT_FOR_DATA) configuration <= configuration & 32'hFFFF_FFFE;
            else if(data_read_stage == 0) configuration <= configuration | 32'h0000_0020;
            else if(sm_tready && sm_tvalid && sm_tlast) configuration <= 32'h0000_0006;
            else if(rready && rvalid && read_configuration) configuration <= configuration & 32'hFFFF_FFDD;
            else configuration <= configuration;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            data_length <= 0;
        end
        else begin
            if(axilite_write_en && axilite_write_addr == 12'h10) data_length <= axilite_write_data;
            else data_length <= data_length;
        end
    end

    //------------------------------------COMPUTE state logic-----------------------------------------------------------
    // data sram control
    assign data_EN = (current_state == COMPUTE);
    assign data_write_en = (data_read_stage == 0 || first_data);
    assign data_WE = {4{data_write_en}};
    assign data_A = (computing) ? ((shift_counter==0) ? 'd40 : shift_counter - 4) : shift_counter;
    //assign mult1 = (shift_counter == 0) ? data_received : (first_data) ? 0 : data_Do;
    assign mult2 = tap_Do;
    assign data_Di = first_data ? ((data_read_stage == 0) ? data_received : 0) : data_received;
    assign mult_result = mult1 * mult2;
    assign sm_tdata = Out_FIFO[Out_FIFO_read_index[(FIFO_width-1):0]];

    assign In_FIFO_empty = (In_FIFO_read_index == In_FIFO_write_index);
    assign In_FIFO_full = (In_FIFO_read_index[(FIFO_width-1):0] == In_FIFO_write_index[(FIFO_width-1):0]) && (In_FIFO_read_index[(FIFO_width)] != In_FIFO_write_index[(FIFO_width)]);

    assign Out_FIFO_empty = (Out_FIFO_read_index == Out_FIFO_write_index);
    assign Out_FIFO_full = (Out_FIFO_read_index[(FIFO_width-1):0] == Out_FIFO_write_index[(FIFO_width-1):0]) && (Out_FIFO_read_index[(FIFO_width)] != Out_FIFO_write_index[(FIFO_width)]);

    genvar i, j;
    generate
        for(i = 0;i<FIFO_width**2;i=i+1)begin
            always@(posedge axis_clk or negedge axis_rst_n)begin
                if(!axis_rst_n)begin
                    In_FIFO[i] <= 0;
                    Out_FIFO[i] <= 0;
                end
                else begin
                    if(In_FIFO_write_index[(FIFO_width-1):0] == i)begin
                        if(ss_tready && ss_tvalid) In_FIFO[i] <= ss_tdata;
                        else In_FIFO[i] <= In_FIFO[i];
                    end
                    else begin
                        In_FIFO[i] <= In_FIFO[i];
                    end

                    if(Out_FIFO_write_index[(FIFO_width-1):0] == i)begin
                        if(outputing && !Out_FIFO_full) Out_FIFO[i] <= accumulated_result;
                        else Out_FIFO[i] <= Out_FIFO[i];
                    end
                    else begin
                        Out_FIFO[i] <= Out_FIFO[i];
                    end
                end
            end
        end
    endgenerate

    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            In_FIFO_read_index <= 0;
            In_FIFO_write_index <= 0;
            Out_FIFO_read_index <= 0;
            Out_FIFO_write_index <= 0;
        end
        else begin
            if(ss_tready && ss_tvalid) In_FIFO_write_index <= In_FIFO_write_index + 1;
            if(!computing && !outputing && !In_FIFO_empty) In_FIFO_read_index <= In_FIFO_read_index + 1;
            if(outputing && !Out_FIFO_full) Out_FIFO_write_index <= Out_FIFO_write_index + 1;
            if(sm_tready && sm_tvalid) Out_FIFO_read_index <= Out_FIFO_read_index + 1;
        end
    end

    always@(*)begin
        if(data_read_stage == 10)begin
            if(data_counter >= data_length) mult1 = 0;
            else mult1 = data_received;
        end
        else begin
            if(first_data) mult1 = 0;
            else mult1 = data_Do;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            data_counter <= 0;
        end
        else begin
            if(next_state == IDLE) data_counter <= 0;
            else if(sm_tready && sm_tvalid) data_counter <= data_counter + 1;
            else data_counter <= data_counter;
        end
    end
    
    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            data_received <= 0;
        end
        else begin
            if(!computing && !outputing && !In_FIFO_empty) data_received <= In_FIFO[In_FIFO_read_index[(FIFO_width-1):0]];
            else data_received <= data_received;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            computing <= 0;
        end
        else begin
            if(!computing && !outputing && !In_FIFO_empty) computing <= 1;
            else if(data_read_stage == 0) computing <= 0;
            //else if(sm_tready && sm_tvalid && (data_counter >= data_length - 1) && !sm_tlast) computing <= 1;
            else computing <= computing;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            outputing <= 0;
        end
        else begin
            if(data_read_stage == 0) outputing <= 1;
            else if(!Out_FIFO_full) outputing <= 0;
            else outputing <= outputing;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            data_read_stage <= 10;
        end
        else begin
            if(current_state ==COMPUTE)begin
                if(outputing && !Out_FIFO_full) data_read_stage <= 10;
                else if(computing) begin
                    if(data_read_stage == 0) data_read_stage <= 10;
                    else data_read_stage <= data_read_stage - 1;
                end
                else data_read_stage <= data_read_stage;
            end
            else begin
                data_read_stage <= data_read_stage;
            end
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            first_data <= 0;
        end
        else begin
            if(current_state == WAIT_FOR_DATA && next_state == COMPUTE) first_data <= 1;
            else if(data_read_stage == 0) first_data <= 0;
            else first_data <= first_data;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            shift_counter <= 40;
        end
        else begin
            if(next_state == IDLE) shift_counter <= 40;
            else if(computing || (outputing && !Out_FIFO_full)) begin
                if(shift_counter == 0) shift_counter <= 40;
                else shift_counter <= shift_counter - 4;
            end
            else shift_counter <= shift_counter;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            accumulated_result <= 0;
        end
        else begin
            if(outputing && !Out_FIFO_full) accumulated_result <= 0;
            else if(computing) accumulated_result <= accumulated_result + mult_result;
            else accumulated_result <= accumulated_result;
        end
    end


    // ss control
    always@(*)begin
        ss_tready = !In_FIFO_full;
    end

    // sm control
    always@(*)begin
        sm_tvalid = !Out_FIFO_empty;
    end

    always@(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)begin
            sm_tlast <= 0;
        end
        else begin
            if(sm_tvalid && sm_tready) sm_tlast <= 0;
            else sm_tlast <= (data_counter == data_length - 1);
        end
    end
endmodule


/*

module fir 
#(  parameter pADDR_WIDTH = 12,
    parameter pDATA_WIDTH = 32,
    parameter Tape_Num    = 11
)
(
	// AXI-Lite write channel
    output  wire                     awready,
    output  wire                     wready,
    input   wire                     awvalid,
    input   wire [(pADDR_WIDTH-1):0] awaddr,
    input   wire                     wvalid,
    input   wire [(pDATA_WIDTH-1):0] wdata,
    
	// AXI-Lite read channel
    output  wire                     arready,
    input   wire                     rready,
    input   wire                     arvalid,
    input   wire [(pADDR_WIDTH-1):0] araddr,
    output  wire                     rvalid,
    output  reg  [(pDATA_WIDTH-1):0] rdata,    
	
    input   wire                     ss_tvalid, 
    input   wire [(pDATA_WIDTH-1):0] ss_tdata, 
    input   wire                     ss_tlast, 
    output  reg                      ss_tready, 
	
    input   wire                     sm_tready, 
    output  reg                      sm_tvalid, 
    output  wire [(pDATA_WIDTH-1):0] sm_tdata, 
    output  reg                      sm_tlast, 
    
    // bram for tap RAM
    output  wire [3:0]               tap_WE,
    output  wire                     tap_EN,
    output  wire [(pDATA_WIDTH-1):0] tap_Di,
    output  reg  [(pADDR_WIDTH-1):0] tap_A,
    input   wire [(pDATA_WIDTH-1):0] tap_Do,

    // bram for data RAM
    output  wire [3:0]               data_WE,
    output  wire                     data_EN,
    output  wire [(pDATA_WIDTH-1):0] data_Di,
    output  wire [(pADDR_WIDTH-1):0] data_A,
    input   wire [(pDATA_WIDTH-1):0] data_Do,
	
	// system signals
    input   wire                     axis_clk,
    input   wire                     axis_rst_n
);


    // write your code here!
    parameter   IDLE            = 2'b00, 
                WAIT_FOR_DATA   = 2'b01, 
                COMPUTE         = 2'b10,  
                RESET           = 2'b11;

    reg [1:0] current_state, next_state;

    reg [(pDATA_WIDTH-1):0] configuration;
    reg [(pDATA_WIDTH-1):0] data_length;

    reg [(pADDR_WIDTH-1):0] axilite_write_addr;
    reg [(pDATA_WIDTH-1):0] axilite_write_data;
    reg axilite_wdata_received;
    reg axilite_waddr_received;
    reg axilite_write_en;

    //reg [(pADDR_WIDTH-1):0] axilite_reg_raddr;
    reg [(pDATA_WIDTH-1):0] axilite_read_reg;
    reg axilite_out_valid;
    reg wait_tapram_data;
    reg axilite_raddr_received;
    reg [(pADDR_WIDTH-1):0] axilite_read_addr;
    reg read_data_length;
    reg read_configuration;
    
    reg first_data;
    reg [5:0] shift_counter;
    wire data_write_en;
    reg [3:0] data_read_stage;
    reg computing, outputing;
    reg last_data;
    reg signed [(pDATA_WIDTH-1):0] data_received;
    reg [9:0] data_counter;

    reg signed [(pDATA_WIDTH-1):0] accumulated_result;
    wire signed [(pDATA_WIDTH-1):0] mult_result;
    reg signed [(pDATA_WIDTH-1):0] mult1;
    wire signed [(pDATA_WIDTH-1):0] mult2;
    reg signed [(pDATA_WIDTH-1):0] current_data;

    always@(*) begin
        case(current_state)
            IDLE: begin
                if(configuration[0] == 1)   next_state = WAIT_FOR_DATA;
                else                        next_state = IDLE;
            end
            WAIT_FOR_DATA: begin
                if(ss_tvalid)   next_state = COMPUTE;
                else            next_state = WAIT_FOR_DATA;
            end
            COMPUTE: begin
                if(sm_tlast && sm_tready && sm_tvalid)  next_state = IDLE;
                else                                    next_state = COMPUTE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) current_state <= IDLE;
        else            current_state <= next_state;
    end

    //-------------------------------------tap sram----------------------------------------------------
    assign tap_EN = 1;

    // axi lite write
    assign awready = !axilite_waddr_received;
    assign wready = !axilite_wdata_received;
    assign tap_WE = {4{axilite_write_en && axilite_write_addr != 12'h00 && axilite_write_addr != 12'h10}};
    assign tap_Di = axilite_write_data;

    always@(*) begin
        axilite_write_en = (axilite_waddr_received && axilite_wdata_received);
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            axilite_write_addr <= 0;
        end
        else begin
            if(awvalid && awready)  axilite_write_addr <= awaddr;
            else                    axilite_write_addr <= axilite_write_addr;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            axilite_write_data <= 0;
        end
        else begin
            if(wvalid && wready) axilite_write_data <= wdata;
            else axilite_write_data <= axilite_write_data;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            axilite_waddr_received <= 0;
        end
        else begin
            if(awvalid && awready)      axilite_waddr_received <= 1;
            else if(axilite_write_en)   axilite_waddr_received <= 0;
            else                        axilite_waddr_received <= axilite_waddr_received;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            axilite_wdata_received <= 0;
        end
        else begin
            if(wvalid && wready)        axilite_wdata_received <= 1;
            else if(axilite_write_en)   axilite_wdata_received <= 0;
            else                        axilite_wdata_received <= axilite_wdata_received;
        end
    end

    // axi lite read
    assign arready = !rvalid && !axilite_write_en;
    assign rvalid = axilite_out_valid;

    always@(*) begin
        if(read_configuration)      rdata = {configuration[31:5], ss_tready, configuration[3:0]};
        else if(read_data_length)   rdata = data_length;
        else                        rdata = axilite_read_reg;
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            axilite_raddr_received <= 0;
        end
        else begin
            if(arvalid && arready)  axilite_raddr_received <= 1;
            else                    axilite_raddr_received <= 0;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            axilite_read_addr <= 0;
        end
        else begin
            if(arvalid && arready)  axilite_read_addr <= araddr;
            else                    axilite_read_addr <= axilite_read_addr;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            read_data_length <= 0;
        end
        else begin
            if(arvalid && arready && araddr == 12'h10)  read_data_length <= 1;
            else if(rvalid && rready)                   read_data_length <= 0;
            else                                        read_data_length <= read_data_length;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            read_configuration <= 0;
        end
        else begin 
            if(arvalid && arready && araddr == 12'h00)  read_configuration <= 1;
            else if(rvalid && rready)                   read_configuration <= 0;
            else                                        read_configuration <= read_configuration;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            wait_tapram_data <= 0;
        end
        else begin
            if(axilite_raddr_received)  wait_tapram_data <= 1;
            else                        wait_tapram_data <= 0;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            axilite_read_reg <= 0;
        end
        else begin 
            if(wait_tapram_data)    axilite_read_reg <= tap_Do;
            else                    axilite_read_reg <= axilite_read_reg;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            axilite_out_valid <= 0;
        end
        else begin
            if(rvalid && rready)        axilite_out_valid <= 0;
            else if(wait_tapram_data)   axilite_out_valid <= 1;
            else                        axilite_out_valid <= axilite_out_valid;
        end
    end

    // axi lite address control
    always@(*) begin
        if(axilite_raddr_received && (axilite_read_addr != 12'h00 && axilite_read_addr != 12'h10)) 
                                    tap_A = axilite_read_addr - 12'h40;
        else if(axilite_write_en)   tap_A = axilite_write_addr - 12'h40;
        else                        tap_A = computing ? data_read_stage * 4 : 0;
    end

    reg sm_done;
    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) sm_done <= 0;
        else begin
            if(configuration[0] == 1)                   sm_done <= 0;
            else if(sm_tready && sm_tvalid && sm_tlast) sm_done <= 1;
            else                                        sm_done <= sm_done;
        end
    end

    // configuration and data length storage
    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            configuration <= 32'h0000_0004;
        end
        else begin 
            if(axilite_write_en && axilite_write_addr == 12'h00)    configuration <= axilite_write_data;
            else if(ss_tvalid && current_state == WAIT_FOR_DATA)    configuration <= configuration & 32'hFFFF_FFFE;
            else if(data_read_stage == 0)                           configuration <= configuration | 32'h0000_0020;
            else if(sm_done)                                        configuration <= 32'h0000_0006;
            else if(rready && rvalid && read_configuration)         configuration <= configuration & 32'hFFFF_FFDD;
            else                                                    configuration <= configuration;
        end
    end

	// axilite get datalength
    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            data_length <= 0;
        end
        else begin
            if(axilite_write_en && axilite_write_addr == 12'h10)    data_length <= axilite_write_data;
            else                                                    data_length <= data_length;
        end
    end

    //------------------------------------COMPUTE state logic-----------------------------------------------------------
    // data sram control
    assign data_EN = (current_state == COMPUTE);
    assign data_write_en = (data_read_stage == 0 || first_data);
    assign data_WE = {4{data_write_en}};
    assign data_A = (computing) ? ((shift_counter==0) ? 'd40 : shift_counter - 4) : shift_counter;
    assign mult2 = tap_Do;
    assign data_Di = first_data ? ((data_read_stage == 0) ? data_received : 0) : data_received;
    assign mult_result = mult1 * mult2;
    assign sm_tdata = accumulated_result;

    always@(*) begin
        if(data_read_stage == 10) begin
            if(data_counter >= data_length) mult1 = 0;
            else                            mult1 = data_received;
        end
        else begin
            if(first_data)  mult1 = 0;
            else            mult1 = data_Do;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            data_counter <= 0;
        end
        else begin
            if(next_state == IDLE)          data_counter <= 0;
            else if(sm_tready && sm_tvalid) data_counter <= data_counter + 1;
            else                            data_counter <= data_counter;
        end
    end
    
    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            data_received <= 0;
        end
        else begin
            if(ss_tready && ss_tvalid)  data_received <= ss_tdata;
            else                        data_received <= data_received;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            last_data <= 0;
        end
        else begin
            if(next_state == IDLE)          last_data <= 0;
            else if(ss_tready && ss_tvalid) last_data <= ss_tlast;
            else                            last_data <= last_data;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            computing <= 0;
        end
        else begin
            if(ss_tready && ss_tvalid)      computing <= 1;
            else if(data_read_stage == 0)   computing <= 0;
            else                            computing <= computing;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            outputing <= 0;
        end
        else begin
            if(data_read_stage == 0)        outputing <= 1;
            else if(sm_tready && sm_tvalid) outputing <= 0;
            else                            outputing <= outputing;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            data_read_stage <= 10;
        end
        else begin
            if(current_state ==COMPUTE) begin
                if(sm_tready && sm_tvalid)      data_read_stage <= 10;
                else if(computing) begin
                    if(data_read_stage == 0)    data_read_stage <= 10;
                    else                        data_read_stage <= data_read_stage - 1;
                end
                else                            data_read_stage <= data_read_stage;
            end
            else                                data_read_stage <= data_read_stage;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            current_data <= 0;
        end
        else begin
            if(data_read_stage == 1)    current_data <= data_Do;
            else                        current_data <= current_data;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            first_data <= 0;
        end
        else begin
            if(current_state == WAIT_FOR_DATA && next_state == COMPUTE) first_data <= 1;
            else if(data_read_stage == 0)                               first_data <= 0;
            else                                                        first_data <= first_data;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            shift_counter <= 40;
        end
        else begin
            if(next_state == IDLE)      shift_counter <= 40;
            else if(computing || (sm_tready && sm_tvalid)) begin
                if(shift_counter == 0)  shift_counter <= 40;
                else                    shift_counter <= shift_counter - 4;
            end
            else                        shift_counter <= shift_counter;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            accumulated_result <= 0;
        end
        else begin
            if(sm_tready && sm_tvalid)  accumulated_result <= 0;
            else if(computing)          accumulated_result <= accumulated_result + mult_result;
            else                        accumulated_result <= accumulated_result;
        end
    end


    // ss control
    always@(*) begin
        ss_tready = (!computing && !outputing && current_state == COMPUTE);
    end

    // sm control
    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            sm_tvalid <= 0;
        end
        else begin
            if(sm_tready && sm_tvalid)      sm_tvalid <= 0;
            else if(data_read_stage == 0)   sm_tvalid <= 1;
            else                            sm_tvalid <= sm_tvalid;
        end
    end

    always@(posedge axis_clk or negedge axis_rst_n) begin
        if(!axis_rst_n) begin
            sm_tlast <= 0;
        end
        else begin
            if(sm_tvalid && sm_tready)      sm_tlast <= 0;
            else if(data_read_stage == 0)   sm_tlast <= (data_counter == data_length - 1);
            else                            sm_tlast <= sm_tlast;
        end
    end

endmodule
*/

module bram11 (clk, we, re, waddr, raddr, wdi, rdo);
    // `define RAMinitFile "./init.dat"
    parameter ADDR_WIDTH = 12;
    parameter SIZE = 11;
    parameter BIT_WIDTH = 32;
    input                          clk;
    input                          we, re;
    input [ADDR_WIDTH-1:0]         waddr, raddr;
    input [BIT_WIDTH-1:0]          wdi;
    output reg [BIT_WIDTH-1:0]     rdo;
    reg [BIT_WIDTH-1:0] RAM [SIZE-1:0];
    // initial $readmemh(`RAMinitFile, RAM);
    
    always @(posedge clk)begin
        if(re) rdo <= RAM[raddr>>2];
    end
    
    always @(posedge clk)begin
        if(we) RAM[waddr>>2] <= wdi;
    end
    
endmodule

`default_nettype wire
