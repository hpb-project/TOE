`timescale 1ns / 1ps
import toe_top_define::*;
module tcp_rx #(
    parameter    PDWID        = 128       ,       
    parameter    PDSZ         = 4         ,       
    parameter    REQ_WID      = 12        ,       
    parameter    REQ_SZ       = 1         ,       
    parameter    RSLT_WID     = 256       ,       
    parameter    RSLT_SZ      = 2         ,       
    parameter    TAB_AWID     = 8         ,       
    parameter    TAB_DWID     = 128       ,       
    parameter    UPDATE_WID   = 256       ,       
    parameter    UPDATE_SZ    = 2         ,       
    parameter    DBG_WID      = 32                
) (
    input   wire                        clk               , 
    input   wire                        rst               , 
    input   wire                        fptr_fifo_naempty , 
    input   wire                        out_pkt_rdy       , 
    input   wire [1-1:0]                in_pd_vld         , 
    output  wire [1-1:0]                in_pd_rdy         , 
    input   wire [PDWID-1:0]            in_pd_dat         , 
    output   wire [1-1:0]               out_pd_vld        , 
    input    wire [1-1:0]               out_pd_rdy        , 
    input    wire [6-1:0]               ec_msg_fifo_cnt_used , 
    input    wire [1-1:0]               out_pmem_rdy      , 
    output   wire [PDWID-1:0]           out_pd_dat        , 
    output  wire    [1-1:0]             out_ack_vld       , 
    input   wire    [1-1:0]             out_ack_rdy       , 
    output  S_TX_BD                     out_ack_dat       , 
    output  wire [1-1:0]                tab_rreq_fifo_wen     ,       
    input   wire [1-1:0]                tab_rreq_fifo_nafull  ,       
    output  wire [TAB_AWID-1:0]         tab_rreq_fifo_wdata   ,       
    input   wire [1-1:0]                tab_rdat_fifo_wen     ,   
    output  wire [1-1:0]                tab_rdat_fifo_nafull  ,   
    input   wire [TAB_DWID-1:0]         tab_rdat_fifo_wdata   ,   
    output   wire [1-1:0]               tab_wr_fifo_wen     ,   
    input    wire [1-1:0]               tab_wr_fifo_nafull  ,   
    output   wire [TAB_AWID-1:0]        tab_wr_fifo_wdata   ,   
    output   wire [1-1:0]               tab_wdat_fifo_wen     ,   
    input    wire [1-1:0]               tab_wdat_fifo_nafull  ,   
    output   wire [TAB_DWID-1:0]        tab_wdat_fifo_wdata   ,   
    input   wire [31:0]       gbl_sec_cnt     ,           
    input   wire [31:0]       cfg_toe_mode    ,           
    input   wire [47:0]       cfg_sys_mac0     ,           
    input   wire [47:0]       cfg_sys_mac1     ,           
    input   wire [31:0]       cfg_sys_ip0     ,           
    input   wire [31:0]       cfg_sys_ip1     ,           
    input   wire [15:0]       cfg_toe_port0     ,           
    input   wire [15:0]       cfg_toe_port1     ,           
    input   wire [31:0]       cfg_tcp_age_time   ,           
    input   wire [31:0]       cfg_moe_bd_th     ,           
    input   S_MOE_RX_FIFO_ST  moe_rx_fifo_st     ,
    if_tcp_toe_reg.sink  u_if_tcp_toe_reg ,
    if_dbg_reg_toe       u_if_dbg_reg_toe ,
    output  wire [32*2-1:0]    tcp_rx_tab_act_dbg_sig1    ,  
    output  wire [DBG_WID-1:0]    tcp_rx_tab_act_dbg_sig    ,  
    output  wire [DBG_WID-1:0]    dbg_sig              
);
localparam TAB_INFO_WID = 16;
localparam CP_INFO_WID  = 32;
localparam LOOP_FIFO_AWID = 8;
wire [1-1:0]         loop_pd_vld    ;           
wire [1-1:0]         loop_pd_rdy    ;           
wire [PDWID-1:0]     loop_pd_dat    ;           
wire [LOOP_FIFO_AWID :0]     loop_fifo_cnt_free    ;           
wire [1-1:0]         mux_pd_vld    ;           
wire [1-1:0]         mux_pd_rdy    ;           
wire [PDWID-1:0]     mux_pd_dat    ;           
wire [32-1:0]       dbg_tcp_rx_cpkt_mux_cnt    ; 

cpkt_fifo_mux #(
    .CELL_WID              ( 128 )       ,   
    .CELL_SZ               ( 4   )       ,   
    .CELL_GAP              ( 6   )       ,   
    .FIFO1_AWID            ( 9   )       ,   
    .FIFO2_AWID            ( LOOP_FIFO_AWID   )       ,   
    .FIFO1_AFULL_TH        ( 64   )       ,   
    .FIFO2_AFULL_TH        ( 64   )       ,   
    .DBG_WID               ( 32  )           
) u_tcp_rx_cpkt_mux (
   .clk                ( clk                ),
   .rst                ( rst                ),
   .clr_cnt    ( u_if_tcp_toe_reg.cfg_clr_cnt ),
   .fst_in_vld            ( in_pd_vld          ),
   .fst_in_dat            ( in_pd_dat          ),
   .fst_in_rdy            ( in_pd_rdy          ),
   .snd_in_vld            ( loop_pd_vld        ),
   .snd_in_dat            ( loop_pd_dat        ),
   .snd_in_rdy            ( loop_pd_rdy        ),
   .snd_in_fifo_cnt_free  ( loop_fifo_cnt_free ),
   .out_vld            ( mux_pd_vld         ),
   .out_data           ( mux_pd_dat         ),
   .out_rdy            ( mux_pd_rdy         ),
   .dbg_sig            ( dbg_tcp_rx_cpkt_mux_cnt  )
   );
wire [1-1:0]         mix_pd_vld    ;           
wire [1-1:0]         mix_pd_rdy    ;           
wire [PDWID-1:0]     mix_pd_dat    ;           
tcp_rx_tcpkt_mix #(
  .PDWID      ( PDWID      ),
  .PDSZ        ( PDSZ      )
)u_tcp_rx_tcpkt_mix(
  .clk         ( clk            ), 
  .rst        ( rst            ),
  .u_if_tcp_toe_reg    (u_if_tcp_toe_reg   ),
  .in_pd_vld    ( mux_pd_vld    ),
  .in_pd_rdy    ( mux_pd_rdy    ),
  .in_pd_dat    ( mux_pd_dat    ),
  .out_pd_vld    ( mix_pd_vld  ),
  .out_pd_rdy    ( mix_pd_rdy  ),
  .out_pd_dat    ( mix_pd_dat  ),
  .dbg_sig      (             ) 
);
wire [1-1:0]         pre_pd_vld    ;           
wire [1-1:0]         pre_pd_rdy    ;           
wire [PDWID-1:0]     pre_pd_dat    ;           
wire                flag_toe_exit  ;
assign flag_toe_exit = out_pd_vld;
tcp_rx_tab_pre_req #(
  .PDWID      ( PDWID      ),
  .PDSZ      ( PDSZ      )
)u_tcp_rx_tab_pre_req(
  .clk         ( clk            ), 
  .rst        ( rst            ),
  .flag_toe_exit    ( flag_toe_exit    ),
  .u_if_tcp_toe_reg    (u_if_tcp_toe_reg   ),
  .u_if_dbg_reg_toe    (u_if_dbg_reg_toe   ),
  .in_pd_vld    ( mix_pd_vld    ),
  .in_pd_rdy    ( mix_pd_rdy    ),
  .in_pd_dat    ( mix_pd_dat    ),
  .out_pd_vld    ( pre_pd_vld  ),
  .out_pd_rdy    ( pre_pd_rdy  ),
  .out_pd_dat    ( pre_pd_dat  ),
  .dbg_sig      (             ) 
);
wire        tab_msg_fifo_wen  ;
wire  [TAB_INFO_WID-1:0]  tab_msg_fifo_wdata  ;
wire        tab_msg_fifo_nafull  ;
wire        tab_msg_fifo_rd  ;
wire  [TAB_INFO_WID-1:0]  tab_msg_fifo_rdata  ;
wire        tab_msg_fifo_nempty  ;
wire        tab_msg_fifo_naempty  ;
wire        sync_msg_vld   ;
wire  [TAB_INFO_WID-1:0]  sync_msg_dat   ;
wire        sync_msg_rdy  ;
wire        pd_fifo_wen  ;
wire  [PDWID-1:0]    pd_fifo_wdata  ;
wire        pd_fifo_nafull  ;
wire        pd_fifo_rd  ;
wire  [PDWID-1:0]    pd_fifo_rdata  ;
wire        pd_fifo_nempty  ;
wire        pd_fifo_naempty  ;
wire        sync_pd_vld   ;
wire  [PDWID-1:0]    sync_pd_dat   ;
wire        sync_pd_rdy  ;
tcp_rx_tab_req #(
  .PDWID      ( PDWID      ),
  .TAB_AWID    ( TAB_AWID    ),
  .TAB_INFO_WID    ( TAB_INFO_WID     ) 
)u_tcp_rx_tab_req(
  .clk         ( clk            ), 
  .rst        ( rst            ),
  .in_pd_vld    ( pre_pd_vld    ),
  .in_pd_rdy    ( pre_pd_rdy    ),
  .in_pd_dat    ( pre_pd_dat    ),
  .tab_rreq_fifo_wen  ( tab_rreq_fifo_wen  ),
  .tab_rreq_fifo_wdata  ( tab_rreq_fifo_wdata  ),
  .tab_rreq_fifo_nafull  ( tab_rreq_fifo_nafull  ),
  .tab_msg_fifo_wen  ( tab_msg_fifo_wen  ),
  .tab_msg_fifo_wdata  ( tab_msg_fifo_wdata  ),
  .tab_msg_fifo_nafull  ( tab_msg_fifo_nafull  ),
  .pd_fifo_wen    ( pd_fifo_wen    ),
  .pd_fifo_wdata    ( pd_fifo_wdata    ),
  .pd_fifo_nafull    ( pd_fifo_nafull  ), 
  .dbg_sig    (       ) 
);
wire        rslt_fifo_rd    ;
wire  [TAB_DWID-1:0]    rslt_fifo_rdata    ;
wire        rslt_fifo_nempty    ;
wire        rslt_fifo_naempty  ;
wire        sync_rslt_vld  ;
wire  [TAB_DWID-1:0]    sync_rslt_dat  ;
wire        sync_rslt_rdy    ;
bfifo #(
    .RAM_STYLE              ( "block"                   ),              
    .DWID                   ( TAB_DWID                  ),
    .AWID                   ( 6                         ),
    .AFULL_TH               ( 8                         ),
    .AEMPTY_TH              ( 8                         ),
    .DBG_WID                ( 32                        )
) u_tab_rslt_fifo (
    .clk                    ( clk                       ),              
    .rst                    ( rst                       ),              
    .wen                    ( tab_rdat_fifo_wen         ),              
    .wdata                  ( tab_rdat_fifo_wdata       ),              
    .nfull                  (              ),              
    .nafull                 ( tab_rdat_fifo_nafull      ),              
    .woverflow              (                           ),              
    .cnt_free               (                           ),              
    .ren                    ( rslt_fifo_rd             ),              
    .rdata                  ( rslt_fifo_rdata           ),              
    .nempty                 ( rslt_fifo_nempty          ),              
    .naempty                ( rslt_fifo_naempty         ),              
    .roverflow              (                           ),              
    .cnt_used               (                           ),              
    .dbg_sig                (                           )               
);
bfifo #(
    .RAM_STYLE              ( "distributed"             ),              
    .DWID                   ( TAB_INFO_WID              ),
    .AWID                   ( 5                         ),
    .AFULL_TH               ( 8                         ),
    .AEMPTY_TH              ( 8                         ),
    .DBG_WID                ( 32                        )
) u_msg_fifo (
    .clk                    ( clk                       ),              
    .rst                    ( rst                       ),              
    .wen                    ( tab_msg_fifo_wen             ),              
    .wdata                  ( tab_msg_fifo_wdata           ),              
    .nfull                  ( tab_msg_fifo_nfull           ),              
    .nafull                 ( tab_msg_fifo_nafull          ),              
    .woverflow              (                           ),              
    .cnt_free               (                           ),              
    .ren                    ( tab_msg_fifo_rd             ),              
    .rdata                  ( tab_msg_fifo_rdata           ),              
    .nempty                 ( tab_msg_fifo_nempty          ),              
    .naempty                ( tab_msg_fifo_naempty         ),              
    .roverflow              (                           ),              
    .cnt_used               (                           ),              
    .dbg_sig                (                           )               
);

bfifo #(
    .RAM_STYLE              ( "block"                   ),              
    .DWID                   ( PDWID                     ),
    .AWID                   ( 6                         ),
    .AFULL_TH               ( 8                         ),
    .AEMPTY_TH              ( 8                         ),
    .DBG_WID                ( 32                        )
) u_pd_fifo (
    .clk                    ( clk                       ),              
    .rst                    ( rst                       ),              
    .wen                    ( pd_fifo_wen               ),              
    .wdata                  ( pd_fifo_wdata             ),              
    .nfull                  (                  ),              
    .nafull                 ( pd_fifo_nafull            ),              
    .woverflow              (                           ),              
    .cnt_free               (                           ),              
    .ren                    ( pd_fifo_rd               ),              
    .rdata                  ( pd_fifo_rdata             ),              
    .nempty                 ( pd_fifo_nempty            ),              
    .naempty                ( pd_fifo_naempty           ),              
    .roverflow              (                           ),              
    .cnt_used               (                           ),              
    .dbg_sig                (                           )               
);


sync_table_fifo #(
    .CELL_CHN_NUM   ( 2                    ) ,
    .INFO_WID       ( 16                   ) ,
    .CDWID          ( {16'd128, 16'd128 }  ) ,
    .CELLSZ         ( {16'd2  , 16'd4   }  ) ,
    .MAX_CELLSZ     ( 4                    ) ,
    .GAP_NUM        ( 6                    ) ,
    .CDWID_SUM      ( 256                  )  
) u_sync_table_tcp_rx(
    .clk               ( clk                                 ) ,
    .rst               ( rst                                 ) ,
    .in_msg_nempty    ( tab_msg_fifo_nempty                ) ,
    .in_msg_rd        ( tab_msg_fifo_rd                   ) ,
    .in_msg_rdata     ( tab_msg_fifo_rdata                 ) ,
    .in_cpkt_nempty   ( {rslt_fifo_nempty, pd_fifo_nempty } ) ,
    .in_cpkt_rd       ( {rslt_fifo_rd,    pd_fifo_rd    } ) ,
    .in_cpkt_rdata    ( {rslt_fifo_rdata,  pd_fifo_rdata  } ) ,
    .out_msg_vld      ( sync_msg_vld                       ) ,     
    .out_msg_rdy      ( sync_msg_rdy                       ) ,
    .out_msg_dat      ( sync_msg_dat                       ) ,
    .out_cpkt_vld      ( {sync_rslt_vld,  sync_pd_vld  }     ) ,
    .out_cpkt_rdy      ( {sync_rslt_rdy,  sync_pd_rdy  }     ) ,
    .out_cpkt_dat      ( {sync_rslt_dat,  sync_pd_dat  }     ) ,
    .dbg_sig           (                                     )  
);


wire [31:0] tcp_rx_act_dbg_sig;


tcp_rx_table_act #(
  .PDWID        ( PDWID         ), 
  .PDSZ         ( PDSZ          ),
  .REQ_WID      ( REQ_WID       ),
  .REQ_SZ       ( REQ_SZ        ),
  .RSLT_SZ      ( RSLT_SZ       ),
  .UPDATE_WID   ( UPDATE_WID    ),
  .UPDATE_SZ    ( UPDATE_SZ     ),
  .TAB_INFO_WID ( TAB_INFO_WID  ),
  .TAB_AWID     ( TAB_AWID      ),
  .TAB_DWID     ( TAB_DWID      ),
  .LOOP_FIFO_AWID( LOOP_FIFO_AWID   )       ,   
  .DBG_WID      ( DBG_WID       )
) u_tcp_rx_tab_act ( 
  .clk                   ( clk                 ),
  .rst                   ( rst                 ),
  .out_pkt_rdy           ( out_pkt_rdy         ), 
  .fptr_fifo_naempty     ( fptr_fifo_naempty   ),
  .sync_msg_vld          ( sync_msg_vld       ),
  .sync_msg_rdy          ( sync_msg_rdy       ),
  .sync_msg_dat          ( sync_msg_dat       ),
  .sync_rslt_vld         ( sync_rslt_vld       ),
  .sync_rslt_rdy         ( sync_rslt_rdy       ),
  .sync_rslt_dat         ( sync_rslt_dat       ),
  .sync_pd_vld           ( sync_pd_vld         ),
  .sync_pd_rdy           ( sync_pd_rdy         ),
  .sync_pd_dat           ( sync_pd_dat         ),
  .out_pd_vld            ( out_pd_vld          ),
  .out_pd_rdy            ( out_pd_rdy          ),
  .ec_msg_fifo_cnt_used  ( ec_msg_fifo_cnt_used), 
  .out_pmem_rdy          ( out_pmem_rdy        ),
  .out_pd_dat            ( out_pd_dat          ),
  .out_ack_vld           ( out_ack_vld         ),
  .out_ack_rdy           ( out_ack_rdy         ),
  .out_ack_dat           ( out_ack_dat         ),
  .loop_pd_vld           ( loop_pd_vld         ),
  .loop_pd_rdy           ( loop_pd_rdy         ),
  .loop_pd_dat           ( loop_pd_dat         ),
  .loop_fifo_cnt_free    ( loop_fifo_cnt_free  ),
  .tab_wr_fifo_wen     ( tab_wr_fifo_wen   ),
  .tab_wr_fifo_nafull  ( tab_wr_fifo_nafull),
  .tab_wr_fifo_wdata   ( tab_wr_fifo_wdata ),
  .tab_wdat_fifo_wen     ( tab_wdat_fifo_wen   ),
  .tab_wdat_fifo_nafull  ( tab_wdat_fifo_nafull),
  .tab_wdat_fifo_wdata   ( tab_wdat_fifo_wdata ),
  .gbl_sec_cnt           ( gbl_sec_cnt         ),
  .cfg_sys_mac0          ( cfg_sys_mac0        ),
  .cfg_sys_mac1          ( cfg_sys_mac1        ),
  .cfg_sys_ip0           ( cfg_sys_ip0         ),
  .cfg_sys_ip1           ( cfg_sys_ip1         ),
  .cfg_toe_port0         ( cfg_toe_port0       ),
  .cfg_toe_port1         ( cfg_toe_port1       ),
  .cfg_tcp_age_time      ( cfg_tcp_age_time    ),
  .cfg_moe_bd_th         ( cfg_moe_bd_th       ),
  .moe_rx_fifo_st        ( moe_rx_fifo_st      ),
  .u_if_tcp_toe_reg      ( u_if_tcp_toe_reg    ),
  .u_if_dbg_reg_toe      ( u_if_dbg_reg_toe    ),
  .dbg_sig1              ( tcp_rx_tab_act_dbg_sig1 ),
  .dbg_sig               ( tcp_rx_tab_act_dbg_sig  )
);
assign dbg_sig = 32'h0;
assign u_if_dbg_reg_toe.tcp_rx_fifo_nafull = { 23'h0, tab_wdat_fifo_nafull, tab_wr_fifo_nafull, sync_msg_rdy, out_pkt_rdy, out_pmem_rdy, in_pd_rdy, loop_pd_rdy, mux_pd_rdy, mix_pd_rdy, pre_pd_rdy, tab_rreq_fifo_nafull, tab_msg_fifo_nafull, pd_fifo_nafull, out_pd_rdy };
endmodule
