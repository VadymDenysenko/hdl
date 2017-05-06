// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2017 (c) Analog Devices, Inc. All rights reserved.
//
// Each core or library found in this collection may have its own licensing terms. 
// The user should keep this in in mind while exploring these cores. 
//
// Redistribution and use in source and binary forms,
// with or without modification of this file, are permitted under the terms of either
//  (at the option of the user):
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory, or at:
// https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html
//
// OR
//
//   2.  An ADI specific BSD license as noted in the top level directory, or on-line at:
// https://github.com/analogdevicesinc/hdl/blob/dev/LICENSE
//
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

module axi_ad9144 #(

  parameter   ID = 0,
  parameter   DEVICE_TYPE = 0,
  parameter   QUAD_OR_DUAL_N = 1,
  parameter   DAC_DATAPATH_DISABLE = 0) (

  // jesd interface
  // tx_clk is (line-rate/40)

  input                   tx_clk,
  output                  tx_valid,
  output      [(128*QUAD_OR_DUAL_N)+127:0]  tx_data,
  input                   tx_ready,

  // dma interface

  output                  dac_clk,
  output                  dac_valid_0,
  output                  dac_enable_0,
  input       [63:0]      dac_ddata_0,
  output                  dac_valid_1,
  output                  dac_enable_1,
  input       [63:0]      dac_ddata_1,
  output                  dac_valid_2,
  output                  dac_enable_2,
  input       [63:0]      dac_ddata_2,
  output                  dac_valid_3,
  output                  dac_enable_3,
  input       [63:0]      dac_ddata_3,
  input                   dac_dunf,

  // axi interface

  input                   s_axi_aclk,
  input                   s_axi_aresetn,
  input                   s_axi_awvalid,
  input       [ 15:0]     s_axi_awaddr,
  input       [ 2:0]      s_axi_awprot,
  output                  s_axi_awready,
  input                   s_axi_wvalid,
  input       [ 31:0]     s_axi_wdata,
  input       [ 3:0]      s_axi_wstrb,
  output                  s_axi_wready,
  output                  s_axi_bvalid,
  output      [ 1:0]      s_axi_bresp,
  input                   s_axi_bready,
  input                   s_axi_arvalid,
  input       [ 15:0]     s_axi_araddr,
  input       [ 2:0]      s_axi_arprot,
  output                  s_axi_arready,
  output                  s_axi_rvalid,
  output      [ 31:0]     s_axi_rdata,
  output      [ 1:0]      s_axi_rresp,
  input                   s_axi_rready);

  localparam NUM_CHANNELS = QUAD_OR_DUAL_N ? 4 : 2;

  // internal signals

  wire [NUM_CHANNELS-1:0] dac_valid_s;
  wire [NUM_CHANNELS-1:0] dac_enable_s;
  wire [NUM_CHANNELS*64-1:0] dac_ddata_s;

  // dual/quad cores

  assign dac_clk = tx_clk;

  assign dac_valid_0 = dac_valid_s[0];
  assign dac_valid_1 = dac_valid_s[1];
  assign dac_enable_0 = dac_enable_s[0];
  assign dac_enable_1 = dac_enable_s[1];
  assign dac_ddata_s[63:0] = dac_ddata_0;
  assign dac_ddata_s[127:64] = dac_ddata_1;

  generate
  if (QUAD_OR_DUAL_N == 1) begin
    assign dac_valid_2 = dac_valid_s[2];
    assign dac_valid_3 = dac_valid_s[3];
    assign dac_enable_2 = dac_enable_s[2];
    assign dac_enable_3 = dac_enable_s[3];
    assign dac_ddata_s[191:128] = dac_ddata_2;
    assign dac_ddata_s[255:192] = dac_ddata_3;
  end else begin
    assign dac_valid_2 = 1'b0;
    assign dac_valid_3 = 1'b0;
    assign dac_enable_2 = 1'b0;
    assign dac_enable_3 = 1'b0;
  end
  endgenerate

  axi_dac_jesd204 #(
    .ID(ID),
    .DEVICE_TYPE(DEVICE_TYPE),
    .NUM_LANES(NUM_CHANNELS * 2),
    .NUM_CHANNELS(NUM_CHANNELS),
    .DAC_DATAPATH_DISABLE(DAC_DATAPATH_DISABLE)
  ) i_dac_jesd204 (
    .tx_clk(tx_clk),
    .tx_valid(tx_valid),
    .tx_data(tx_data),
    .tx_ready(tx_ready),

    .dac_valid(dac_valid_s),
    .dac_enable(dac_enable_s),
    .dac_ddata(dac_ddata_s),
    .dac_dunf(dac_dunf),

    .s_axi_aclk(s_axi_aclk),
    .s_axi_aresetn(s_axi_aresetn),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awready(s_axi_awready),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(s_axi_wstrb),
    .s_axi_wready(s_axi_wready),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bresp(s_axi_bresp),
    .s_axi_bready(s_axi_bready),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arready(s_axi_arready),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_rready(s_axi_rready)
  );

endmodule
