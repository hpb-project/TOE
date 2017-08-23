`timescale 1ns / 1ps
import nic_top_define::*;

module ec_gen #(
    parameter    DIRECTION    = "RX"      ,  
    parameter    PDWID        = 128       ,  
    parameter    PDSZ         = 4           ,  
    parameter    DWID         = 256       ,  
    parameter    ECMWID       = 88           ,  
    parameter    REQ_WID      = 38            
) (
    input  wire          clk        ,
    input   wire          rst        ,
    input   wire [1-1:0]         total_pd_vld    ,           
    output   wire [1-1:0]         total_pd_rdy    ,           
    output   wire [1-1:0]         in_pmem_rdy    ,           
    input   wire [PDWID*PDSZ-1:0]       total_pd_dat    ,           
    output  wire [1-1:0]                pkt_req_fifo_wen   ,      
    input   wire [1-1:0]                pkt_req_fifo_nafull ,       
    output  wire [REQ_WID-1:0]          pkt_req_fifo_wdata   ,       
    output   wire [1-1:0]       ec_msg_fifo_wen   ,           
    input   wire [1-1:0]       ec_msg_fifo_nafull  ,           
    output   wire [ECMWID-1:0]     ec_msg_fifo_wdata   ,           
    output   wire [1-1:0]       ec_dat_fifo_wen   ,           
    input   wire [1-1:0]       ec_dat_fifo_nafull   ,           
    output   reg  [DWID-1:0]     ec_dat_fifo_wdata   ,            
    input   wire [47:0]       cfg_sys_mac0       ,           
    input   wire [47:0]       cfg_sys_mac1       ,           
    input   wire [31:0]       dbg_sig0                   
);
localparam VAL_EC_CMD_RM_HDR    = 1;
localparam VAL_EC_CMD_ADD_HDR   = 2;
localparam VAL_EC_CMD_TT   = 3; 
localparam VAL_EC_CMD_NEW_PKT   = 0;
localparam VAL_EC_CMD_DROP_PKT  = 4;
`include "common_define_value.v"
wire [47:00]     eth_dmac;
wire [47:00]     eth_smac;
wire [15:00]     eth_typ ;
wire [112-1:00]   eth_hdr ;
wire [63:0]             toe_hdr;
`include "pkt_des_unpack.v"
wire   [0:0]  flag_rls; 
wire   [0:0]  flag_drop; 
wire   [0:0]  flag_nxt; 
wire   [0:0]  flag_sop; 
wire   [0:0]  flag_eop; 
assign   flag_rls = pd_rls_flag; 
assign   flag_drop = (pd_fwd==VAL_FWD_DROP) ? 1'b1 : 1'b0; 
assign   flag_nxt = 1'b0;
assign   flag_sop = 1'b1; 
assign   flag_eop = 1'b1; 
assign pkt_req_fifo_wdata = { flag_drop[0], pd_chn_id[2:0], pd_pptr[11:0], pd_plen[15:0], pd_credit[1:0], flag_rls[0], flag_nxt[0], flag_sop[0], flag_eop[0]};
assign pkt_req_fifo_wen   = (pd_fwd==VAL_FWD_DROP&&flag_rls==1'b0) ? 1'b0 : flag_step[2];
reg [3:0]   ec_cmd      ;
reg [15:0]   out_pkt_len    ;  
reg [7:0]   ec_hdr_len    ;  
reg [15:000]    pkt_fid     ;
generate 
if( DIRECTION=="RX" )begin
  always @ ( * ) begin
    if( pd_fwd==VAL_FWD_MAC ) begin
      ec_cmd = VAL_EC_CMD_TT;
      out_pkt_len = pd_plen;   
      ec_hdr_len  = 0;
      ec_dat_fifo_wdata = { toe_hdr[63:0], 192'h0 };  
      pkt_fid = 0;
      pkt_fid[3:0] = pd_chn_id;
    end
    else if( pd_fwd==VAL_FWD_APP ) begin
      ec_cmd = VAL_EC_CMD_RM_HDR;
      out_pkt_len = pd_plen - pd_hdr_len - pd_tail_len;
      ec_hdr_len  = 54;
      ec_dat_fifo_wdata = { toe_hdr[63:0], 192'h0 }; 
      pkt_fid = {pd_chn_id[1:0],pd_tcp_fid[13:0]};
    end
    else if( pd_fwd==VAL_FWD_TOE ) begin
      ec_cmd = VAL_EC_CMD_ADD_HDR;
      out_pkt_len = 64;
      ec_hdr_len  = 8;
      ec_dat_fifo_wdata = { toe_hdr[63:0], 192'h0 };
      pkt_fid = 8;
    end
    else begin
      ec_cmd = VAL_EC_CMD_DROP_PKT;
      out_pkt_len = pd_plen;
      ec_hdr_len  = 0;
      ec_dat_fifo_wdata = { toe_hdr[63:0], 192'h0 };
      pkt_fid = {pd_chn_id[1:0],pd_tcp_fid[13:0]};
    end
  end
end
else begin 
  always @ ( * ) begin
    if( pd_fwd==VAL_FWD_MAC ) begin
      ec_cmd = VAL_EC_CMD_TT;
      out_pkt_len = pd_plen;   
      ec_hdr_len  = 0;
      if(flag_step[1]==1'b1) begin
        ec_dat_fifo_wdata = { eth_hdr[111:0], total_pd_dat[128*2 +: (128+16) ]} ;
      end
      else begin
        ec_dat_fifo_wdata = { total_pd_dat[128*0 +: 256 ] };
      end
      pkt_fid = pd_tcp_fid;
    end
    else if( pd_fwd==VAL_FWD_APP ) begin
      ec_cmd = VAL_EC_CMD_ADD_HDR;
      out_pkt_len = pd_plen + 54;
      ec_hdr_len  = 54;
      if(flag_step[1]==1'b1) begin
        ec_dat_fifo_wdata = { eth_hdr[111:0], total_pd_dat[128*2 +: (128+16) ]} ;
      end
      else begin
        ec_dat_fifo_wdata = { total_pd_dat[128*0 +: 256 ] };
      end
      pkt_fid = pd_tcp_fid;
    end
    else if( pd_fwd==VAL_FWD_TOE && (pd_ptyp==VAL_PTYP_CPU_INIT || pd_ptyp==VAL_PTYP_CPU_FREE) ) begin
      ec_cmd = VAL_EC_CMD_RM_HDR;
      out_pkt_len = pd_plen-8;   
      ec_hdr_len  = 8;
      if(flag_step[1]==1'b1) begin
        ec_dat_fifo_wdata = { eth_hdr[111:0], total_pd_dat[128*2 +: (128+16) ]} ;
      end
      else begin
        ec_dat_fifo_wdata = { total_pd_dat[128*0 +: 256 ] };
      end
      pkt_fid = pd_tcp_fid;
    end
    else if( pd_fwd==VAL_FWD_TOE && pd_ptyp==VAL_PTYP_PKT_SYNACK ) begin
      ec_cmd = VAL_EC_CMD_NEW_PKT;
      out_pkt_len = 62;
      ec_hdr_len  = 62;
      if(flag_step[1]==1'b1) begin
        ec_dat_fifo_wdata = { eth_hdr[111:0], total_pd_dat[128*2 +: (128+16) ]} ;
      end
      else begin
              ec_dat_fifo_wdata = (pd_tcp_opt==32'h2) ? { total_pd_dat[128*4-54*8+:54*8], 32'h020405b4, 32'h01030305, 16'h0 } : (pd_tcp_opt==32'h1) ? { total_pd_dat[128*4-54*8+:54*8], 32'h020405b4, 32'h01030301, 16'h0 } : { total_pd_dat[128*4-54*8+:54*8], 32'h020405b4, 32'h01010101, 16'h0 } ;
      end
      pkt_fid = pd_tcp_fid;
    end
    else if( pd_fwd==VAL_FWD_TOE && pd_ptyp==VAL_PTYP_PKT_FIN ) begin
      ec_cmd = VAL_EC_CMD_NEW_PKT;
      out_pkt_len = 54;
      ec_hdr_len  = 54;
      if(flag_step[1]==1'b1) begin
        ec_dat_fifo_wdata = { eth_hdr[111:0], total_pd_dat[128*2 +: (128+16) ]} ;
      end
      else begin
        ec_dat_fifo_wdata = { total_pd_dat[128*0 +: 256 ] };
      end
      pkt_fid = pd_tcp_fid;
    end
    else if( pd_fwd==VAL_FWD_TOE ) begin
      ec_cmd = VAL_EC_CMD_NEW_PKT;
      out_pkt_len = 54;
      ec_hdr_len  = 54;
      if(flag_step[1]==1'b1) begin
        ec_dat_fifo_wdata = { eth_hdr[111:0], total_pd_dat[128*2 +: (128+16) ]} ;
      end
      else begin
        ec_dat_fifo_wdata = { total_pd_dat[128*0 +: 256 ] };
      end
      pkt_fid = pd_tcp_fid;
    end
    else begin
      ec_cmd = VAL_EC_CMD_DROP_PKT;
      out_pkt_len = pd_plen;
      ec_hdr_len  = 54;
      if(flag_step[1]==1'b1) begin
        ec_dat_fifo_wdata = { eth_hdr[111:0], total_pd_dat[128*2 +: (128+16) ]} ;
      end
      else begin
        ec_dat_fifo_wdata = { total_pd_dat[128*0 +: 256 ] };
      end
      pkt_fid = pd_tcp_fid;
    end
  end
end
endgenerate
assign ec_msg_fifo_wdata = { ec_cmd[3:0], ec_hdr_len[7:0], pd_plen[15:0], pkt_fid[15:0], pd_tcp_seqn[31:0], pd_tail_len[7:0], pd_chn_id[3:0], pd_out_id[3:0] };
assign ec_msg_fifo_wen   = (pd_fwd==VAL_FWD_DROP) ? 1'b0 : flag_step[2];
assign eth_dmac = pd_smac;
assign eth_smac = (pd_tcp_fid[15:14]==2'h0)? cfg_sys_mac0 : cfg_sys_mac1;
assign eth_typ  = 16'h0800;
assign eth_hdr  = { eth_dmac, eth_smac, eth_typ };
assign toe_hdr = {pd_ptyp[7:0], pd_tcp_fid[15:0], out_pkt_len[15:0], 16'h0, 8'h0};
assign ec_dat_fifo_wen   = (pd_fwd==VAL_FWD_DROP) ? 1'b0 : (flag_step[2] | flag_step[1]);
assign total_pd_rdy = ec_msg_fifo_nafull & ec_dat_fifo_nafull;
assign in_pmem_rdy = pkt_req_fifo_nafull ;
endmodule
