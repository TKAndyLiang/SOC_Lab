// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
// Date        : Tue Nov 21 02:40:21 2023
// Host        : ubuntu2004 running 64-bit Ubuntu 20.04.4 LTS
// Command     : write_verilog -force -mode funcsim
//               /home/ubuntu/labi/vvd_caravel_fpga_gcd/vvd_caravel_fpga_gcd.gen/sources_1/bd/design_1/ip/design_1_blk_mem_gen_0_0/design_1_blk_mem_gen_0_0_sim_netlist.v
// Design      : design_1_blk_mem_gen_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "design_1_blk_mem_gen_0_0,blk_mem_gen_v8_4_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_5,Vivado 2022.1" *) 
(* NotValidForBitStream *)
module design_1_blk_mem_gen_0_0
   (clka,
    rsta,
    ena,
    wea,
    addra,
    dina,
    douta,
    clkb,
    rstb,
    enb,
    web,
    addrb,
    dinb,
    doutb,
    rsta_busy,
    rstb_busy);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE BRAM_CTRL, READ_WRITE_MODE READ_WRITE, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA RST" *) input rsta;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [3:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [31:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [31:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [31:0]douta;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE BRAM_CTRL, READ_WRITE_MODE READ_WRITE, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB RST" *) input rstb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB WE" *) input [3:0]web;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [31:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DIN" *) input [31:0]dinb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [31:0]doutb;
  output rsta_busy;
  output rstb_busy;

  wire [31:0]addra;
  wire [31:0]addrb;
  wire clka;
  wire clkb;
  wire [31:0]dina;
  wire [31:0]dinb;
  wire [31:0]douta;
  wire [31:0]doutb;
  wire ena;
  wire enb;
  wire rsta;
  wire rsta_busy;
  wire rstb;
  wire rstb_busy;
  wire [3:0]wea;
  wire [3:0]web;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [31:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [31:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [31:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "32" *) 
  (* C_ADDRB_WIDTH = "32" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "8" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "2" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "1" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "1" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     10.7492 mW" *) 
  (* C_FAMILY = "zynq" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "1" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "1" *) 
  (* C_HAS_RSTB = "1" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "NONE" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "2" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "2048" *) 
  (* C_READ_DEPTH_B = "2048" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "32" *) 
  (* C_READ_WIDTH_B = "32" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "1" *) 
  (* C_USE_BYTE_WEA = "1" *) 
  (* C_USE_BYTE_WEB = "1" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "4" *) 
  (* C_WEB_WIDTH = "4" *) 
  (* C_WRITE_DEPTH_A = "2048" *) 
  (* C_WRITE_DEPTH_B = "2048" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "32" *) 
  (* C_WRITE_WIDTH_B = "32" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  design_1_blk_mem_gen_0_0_blk_mem_gen_v8_4_5 U0
       (.addra({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,addra[12:2],1'b0,1'b0}),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,addrb[12:2],1'b0,1'b0}),
        .clka(clka),
        .clkb(clkb),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb(dinb),
        .douta(douta),
        .doutb(doutb),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(enb),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[31:0]),
        .regcea(1'b0),
        .regceb(1'b0),
        .rsta(rsta),
        .rsta_busy(rsta_busy),
        .rstb(rstb),
        .rstb_busy(rstb_busy),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[31:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[31:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
        .web(web));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2022.1"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
RgPKnWr9n0dGgttm3akiFhAlfB96usOQYxnEmPhGyTGg1AbizYAjGPWLXBWl50n/d0IA71ci4aJB
wt6mtfyNADm3ZReK7D3mKu037BOgxryoEwwf1kiC6q/PllxsdAgEMfQrfHJ3E2AzSpdYjoxVYito
y0JW6CUDcWvWa4WV0EA=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
M0l6KpOGH3jL8eRt3NCD7e2USYnkg5H9GAnE1PKmnjiouFN3Y8kjWA2PZDAQLm9UW+TsC1HeVlzO
WjNCHkjR/6ubCsIcWfpPZWdIuAenlsyq8Y9l6b8vMj8JSbDEOiFF/GHSbKsn22MJdDJKEhHFK6GV
s8gR2vywRFwG69gIRE4qGhVB+WIg8GJrDpDMYH6lCjMkTrjXuKDUcNlJN3NPLuhJ7tsditwf1pr5
moJRmGpJnip/rGm0g4o4A6ev4CtePjoao8C1wFtzHkERX9oenhh7cGjDMejU5IrLv8NxFnLj1FpB
9MuF1beTU20NI5oAn6zLiLiOtXjf0ghU3AN4DA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
hAsrUfp6Qgjm8yBjNYTEtQmVQmMxzL8TE/3oiQSxSI3+yEkXAbQCXkT9mo+LCdv+fGECOB0istHd
eLtbsiYbxjxNxYkXiUrRE5O+aSxynIray+uF9DJigTEUZu8JJXUbzxK4DDUu1Lm9tpGps4+Prz1m
0gkj13RT/Y/418s2VTw=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
BP/54Wm/GJmb1jy0bxWJJX4aiKyiWPVh4X3VL30BQrmX4PlEsNKzBJH3Qu8IIYERfnFP0ifAgboa
vypMQ5Ed0BrMePGkWIgT6I8hxJCMFpHdkSK7m1giSKyZzFfTOrVqoNFXE+qdzLfY1J5hBWCvouYo
jllavK4N3gF9FLScH2AUWYVMcVth2QPaTAU2NLnAUNH8kgtBjBfc8/KbPPTznD1QNVqvFstzcbTA
hGQ1ETVPvINQ0KqxxAG5PRhtQD4+pC+hr/Tvk+RSvGyBOfy9zE86OXkJiYs9dSFhNiMFmCPL9DBO
se4OxNNC0/7aBtb1mkSEA9YFDYEb9jS7Jasy2A==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
SnzT9DVH3xlEN8nrr2YrlvTO5qj7L22d7WaBcuKyTaiHoIwwFHrC4HQbfs0TAwkdWcOgmJoATPSF
F6qm0KiddbrlERF3MfKUldeGBJtqLdX+zGw7+3JD7S+HB9dIMOFOHy+IiCZp1/Pz8epKpi238cel
rcVoJQKz406wmXDvOo8KsT+XhRLs9BVCrBErPGGXKYDk6NXAp0duOgQE9DbslzMU83M/kUC7uERV
tQW02240peKQFp2elEZC7Tetvgp0TaFTtJiKN45REi8GQUCKGa85JjNIk1qb/+k95TIIP1xrHirc
6iX7qbwnPetv8TVu2NjkZ0WDEK5RXdOXcxBwHA==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2021_07", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
erkR82V0jX8ytva+9MzEs0c75Z7j7TsgxWRLNAUfbbU28i+U9YzuZlSfYU75M0f9jx1gvxtBrfKv
cNHVdkR+i5zfHDZsDwfMEEBhs8wzDCKqe+eex6BBEvlIOesCPXrr2RozQgaQ1PBh/os2Arfu+873
BjsVxFJkbhpzIqlddOo/XZV9Yi+eih7A7pXXEBR6IL7Poo4Ka49MiVQU0xJrDTm+ddOuMPDRRD7g
dsxS/uzdcBcO2myV6g/7YH/C2Ce9s6+UywJN/0JeXSqwA7bsBqqnfFicVAT0lckLopMLiuzK7dsN
EwhFeqoetciFrDIj9+o0xDMWBZhgNP1u68vURA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
R+BI65BKLT0I9hEtsxGnDyM5XY9gzULeTPOSDXvd3KWOzZJAx6C0xlbyZcFZhAEG/QIK2yd0wAi6
IUWxyF/sx3HsqKjhVi5KxnpuXDBOZVoj811O7JukedFVmDW7OHGtBkuiJ5X5irw7mfsEKRQmF/1i
V6lj9HYHZEjxtDeZjACsLY4y1QxWalSKT4HIMOHznBLL8dLbGMlS+ZmFuFn0gcwZavVl7gTkTtkf
W0gn01A9ru7NKsf+iLX0kj4dgItPu9N2g02M1vWQ9UUQEVvfV7lUc7GY1suibrD8aEkhH9S7lZ7n
bFsT4qxyvzg8ML6v4g4v7N6VuyhEtgFgNd725Q==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
jNUVKiwH68vHsU54idgvKwaVJcoxTUuxfgrQpbpmM/IpesWA3wHsGzYClwAxkKzw3KRnFyQqTWcZ
yj1EQ2CMBxlJ0kyNbZW8OK8pXzeigToZ0U6Aq3Gy+j7wBbhe83wE1Ygn82sK8dHTEulvaRLn/c5r
ispy1s7jMKIvYNzoUuZrgyBQyfaYmdqUia8XlQjFd+VwzhTXKwzvmaqHWyaHjfBKeCooO7+oUxMG
OJg83W54EVe9ronFQ8Wr9EOL8ia7qelCAgyQe/bC0HHCoMAm8apI7sX23iMR/wMiPP5V2bQzycy+
rBX/+SWkqSeIE1FLm+muFPvrE7iLwJaW8d1fzdFFjAZ5aIXArbWNfwbK8S0TczXc9lEzmpb69rwA
UJIrs4alo81qGQ32UFhjuMQjX75O9Od1HWHDj5PFaT/Ja5Ly+bK8Cc3gfO6dCE81m7d+B2JBZ/Hl
tBA19QuOAYwT2EIPOdpaVtCULb33cWODWu3qQFhZMmDzKTb3kwpcr0LL

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
MnzcA2swaxH1LRacKDou0ZmiiMRETbWIdHgeBgyQz7ILronsXLoB/C20WuFNGEVSiL2/51EZ6MXZ
vMHI8fFcMQCJcuTBDBibUMKv6bXI9s8fTbtrBZppbF/R1icG5JYhqmX4aRnv4W/dxJRjI2L35nLN
Y48E9OfgfkD1sr+IRwx8WEKFmUhuk8dLe0VOK7ywe3XEcneYvrz+HhPj16bGmNfMwNnDgZ3gKKZD
hRnys+jzvAX3HyISrErWXhMKrhWMxXeTNFJCqNQ0LWAVHQYwyKnF5xVpyXSuGNSIrva+QXqOrZBG
3VNLirNVtMRiKLfwZeMaqvswkqBDAa53utlAAA==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
d0xXkKtsKM8GvXhDZr16p1+oE3uBtD04BJ76eGGIEj/CFECfHVy9qsJ43oSKjas0+AJr4GFFnVb6
X7gJV6MmX/OboC9ier5joUCGz0mxVzkRZK9a+LPEDcg0K6+cLE36kr+FfxW9Uk2816EHBCMCf5mK
A4eAhSmAb5Nq74F/q0quiG416npbny7faiQ+xmPDfYYiM3UuMKaD4iE8ODlz1w5xThPllWESf3LZ
NTkw6fozyTqZ47vvE21O3dgIGAY1v+C6BwlCK24VwPJa1xs9csY+qTk31j5jjAc1ExlB6QF7t9UH
lk70qdNPWxT87OH7kFT8UvPO1D6BTC3/WkDZfA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
LYhdzKTvo93uJrAaiP5OfCDuOnu2BSvPnxlv6I7h2n1+xHtj34LNNKzWEgOg9dUV9cYDaHYUjjEt
DKdWcz6mZ61d5qyxAhpv67fc90v7JVgtOAcT94/Yb+AuLxXFcGA6Gic7uoJtUgz6JmTnb22Dxdjc
KuIewDj4IOTfP8XGXKTaF+cNp0CFrQgTAcVSQFyLFxr0I/9h3S+GZLecA7ntEeHEOfCJzPvy0ddi
7MCdQWECLb+fXC0IAn8V95TumcpINiRAX1BHi9IGJ4QoMrb3jOCrPkFhDMTJj2aiImUWdi/l/0QE
d7wcXlgIEYVeoKYUOJ4mqy+zZPUbLNeOPADUDQ==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 59888)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
