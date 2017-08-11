
import nic_top_define::*;
/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
interface if_tcp_cfg_reg;

logic          cfg_clr_cnt      ; 
logic          cfg_bak_en       ;  //S5 bakup enable
logic          cnt_clr          ; 
logic [31:0]   tray_status      ; 
logic [31:0]   cbus_wr_age      ; 
logic [31:0]   cbus_rd_age      ; 
logic [31:0]   addr_spr         ; 
logic [31:0]   tray_cbus_id     ; 
logic [31:0]   tray_cbus_addr   ; 
logic [31:0]   time_cfg         ; 
logic [31:0]   cfg_tray_ba      ; 
logic [31:0]   cfg_tray_buf_ba  ; 
logic [31:0]   cfg_tray_hdr_ba  ; 
logic [31:0]   cfg_tray_bd_ba   ; 
logic [31:0]   cfg_tray_bd_msk  ; 
logic [31:0]   cfg_tray_rbuf_ba ; 
logic [31:0]   cfg_rge_id       ; 
logic [31:0]   cfg_nic_id       ; 
logic [31:0]   cfg_nic_id_pos   ; 
logic [31:0]   global_tms_1s    ; 
logic [31:0]   global_tms_1ms   ; 
logic [31:0]   global_tms_1us   ; 
logic [01-1:0] arr_work_en      ;
logic [31:0]   us_time_cfg      ; 
logic [31:0]   aurora_st_arr    ; 
logic [31:0]   dbg_tray_send_age_st    ; 


modport sink( 
        input  cfg_clr_cnt      , 
        input  cfg_bak_en       ,  //S5 bakup enable
        input  cnt_clr          , 
        input  tray_status      , 
        input  cbus_wr_age      , 
        input  cbus_rd_age      , 
        input  addr_spr         , 
        input  tray_cbus_id     , 
        input  tray_cbus_addr   , 
        input  time_cfg         , 
        input  cfg_tray_ba      , 
        input  cfg_tray_buf_ba  , 
        input  cfg_tray_hdr_ba  , 
        input  cfg_tray_bd_ba   , 
        input  cfg_tray_bd_msk  , 
        input  cfg_tray_rbuf_ba , 
        input  cfg_rge_id       , 
        input  cfg_nic_id       , 
        input  cfg_nic_id_pos   , 
        input  global_tms_1s    , 
        input  global_tms_1ms   , 
        input  global_tms_1us   ,
        input  arr_work_en      , 
        input  aurora_st_arr    , 
        input  dbg_tray_send_age_st      , 
        input  us_time_cfg          
);
modport src ( 
        output cfg_clr_cnt      , 
        output cfg_bak_en       ,  //S5 bakup enable
        output cnt_clr          , 
        output tray_status      , 
        output cbus_wr_age      , 
        output cbus_rd_age      , 
        output addr_spr         , 
        output tray_cbus_id     , 
        output tray_cbus_addr   , 
        output time_cfg         , 
        output cfg_tray_ba      , 
        output cfg_tray_buf_ba  , 
        output cfg_tray_hdr_ba  , 
        output cfg_tray_bd_ba   , 
        output cfg_tray_bd_msk  , 
        output cfg_tray_rbuf_ba , 
        output cfg_rge_id       , 
        output cfg_nic_id       , 
        output cfg_nic_id_pos   , 
        output global_tms_1s    , 
        output global_tms_1ms   , 
        output global_tms_1us   , 
        output arr_work_en      , 
        output aurora_st_arr    , 
        output dbg_tray_send_age_st      , 
        output us_time_cfg        
);

endinterface : if_tcp_cfg_reg

interface if_dbg_reg_nic;

logic [31:00]  bd_dist_in_cnt ; 
logic [31:00]  dbg_cnt ; 

modport sink( 
        input bd_dist_in_cnt ,
        input dbg_cnt 
);
modport src ( 
        output bd_dist_in_cnt , 
        output dbg_cnt        
);

endinterface : if_dbg_reg_nic

/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
interface if_rx_bd;

logic          vld      ;
logic          rdy      ; 
S_RX_BD        rx_bd    ; 

modport sink( input vld, output rdy, input rx_bd );
modport src ( output vld, input rdy, output rx_bd );

endinterface : if_rx_bd

/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
interface if_tx_bd;

logic          vld      ;
logic          rdy      ; 
S_TX_BD        tx_bd    ; 

modport sink( input vld, output rdy, input tx_bd );
modport src ( output vld, input rdy, output tx_bd );

endinterface : if_tx_bd

interface if_car_bd;

logic            vld      ;
logic            rdy      ; 
S_CAR_BD         car_bd   ; 

modport sink( input  vld, output rdy, input  car_bd );
modport src ( output vld, input  rdy, output car_bd );

endinterface : if_car_bd

interface if_rsd_bd;

logic            vld      ;
logic            rdy      ; 
S_RSD_BD         rsd_bd   ; 

modport sink( input  vld, output rdy, input  rsd_bd );
modport src ( output vld, input  rdy, output rsd_bd );

endinterface : if_rsd_bd


/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
interface if_tray_bd;

logic          vld      ;
logic          rdy      ; 
S_TRAY_BD      tray_bd  ;

modport sink( 
    input vld ,
    output rdy ,
    input tray_bd  
    );

modport src ( 
    output vld  ,
    input rdy  ,
    output tray_bd 
    );

endinterface : if_tray_bd


/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
interface if_miss_bd;

logic          vld      ;
logic          rdy      ; 
S_TRAY_BD      miss_bd  ;

modport sink( input vld, output rdy, input miss_bd );
modport src ( output vld, input rdy, output miss_bd );

endinterface : if_miss_bd

/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
interface if_msg_rx_tbl;

logic                             ren              ;
logic  [MSG_RX_TBL_AWID-1:0]      raddr            ;
logic                             rvld             ;
S_MSG_RX_TBL                      now_msg_rx_entry ;

logic                             wen              ;
logic  [MSG_RX_TBL_AWID-1:0]      waddr            ;
S_MSG_RX_TBL                      new_msg_rx_entry ;

modport usr_rif( output ren, output raddr, input now_msg_rx_entry,  input rvld  );
modport usr_wif( output wen, output waddr, output new_msg_rx_entry  )            ;
modport tbl_rif( input ren,  input raddr,  output now_msg_rx_entry, output rvld );
modport tbl_wif( input wen,  input waddr,  input new_msg_rx_entry )              ;

endinterface : if_msg_rx_tbl

/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
interface if_msg_tx_tbl;

logic                             ren              ;
logic  [MSG_TX_TBL_AWID-1:0]      raddr            ;
logic                             rvld             ;
S_MSG_TX_TBL                      now_msg_tx_entry ;

logic                             wen              ;
logic  [MSG_TX_TBL_AWID-1:0]      waddr            ;
S_MSG_TX_TBL                      new_msg_tx_entry ;

modport usr_rif( output ren, output raddr, input now_msg_tx_entry,  input rvld  );
modport usr_wif( output wen, output waddr, output new_msg_tx_entry  );
modport tbl_rif( input ren,  input raddr,  output now_msg_tx_entry, output rvld );
modport tbl_wif( input wen,  input waddr,  input new_msg_tx_entry );

endinterface : if_msg_tx_tbl

/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
interface if_bd_dist_tbl;

logic                             ren              ;
logic  [BD_DIST_TBL_AWID-1:0]      raddr            ;
logic                             rvld             ;
S_BD_DIST_TBL                      now_bd_dist_entry ;

logic                             wen              ;
logic  [BD_DIST_TBL_AWID-1:0]      waddr            ;
S_BD_DIST_TBL                      new_bd_dist_entry ;

modport usr_rif( output ren, output raddr, input now_bd_dist_entry,  input rvld  );
modport usr_wif( output wen, output waddr, output new_bd_dist_entry  );
modport tbl_rif( input ren,  input raddr,  output now_bd_dist_entry, output rvld );
modport tbl_wif( input wen,  input waddr,  input new_bd_dist_entry );

endinterface : if_bd_dist_tbl


/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
interface if_bd_coll_tbl;

logic                             ren              ;
logic  [BD_COLL_TBL_AWID-1:0]      raddr            ;
logic                             rvld             ;
S_BD_COLL_TBL                      now_bd_coll_entry ;

logic                             wen              ;
logic  [BD_COLL_TBL_AWID-1:0]      waddr            ;
S_BD_COLL_TBL                      new_bd_coll_entry ;

modport usr_rif( output ren, output raddr, input now_bd_coll_entry,  input rvld  );
modport usr_wif( output wen, output waddr, output new_bd_coll_entry  );
modport tbl_rif( input ren,  input raddr,  output now_bd_coll_entry, output rvld );
modport tbl_wif( input wen,  input waddr,  input new_bd_coll_entry );

endinterface : if_bd_coll_tbl

/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
interface if_tray_wptr_tbl;

logic                             ren              ;
logic  [TRAY_WPTR_TBL_AWID-1:0]      raddr            ;
logic                             rvld             ;
S_TRAY_WPTR_TBL                      now_tray_wptr_entry ;

logic                             wen              ;
logic  [TRAY_WPTR_TBL_AWID-1:0]      waddr            ;
S_TRAY_WPTR_TBL                      new_tray_wptr_entry ;

modport usr_rif( output ren, output raddr, input now_tray_wptr_entry,  input rvld  );
modport usr_wif( output wen, output waddr, output new_tray_wptr_entry  );
modport tbl_rif( input ren,  input raddr,  output now_tray_wptr_entry, output rvld );
modport tbl_wif( input wen,  input waddr,  input new_tray_wptr_entry );

endinterface : if_tray_wptr_tbl


/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
interface if_tray_rptr_tbl;

logic                             ren              ;
logic  [TRAY_WPTR_TBL_AWID-1:0]      raddr            ;
logic                             rvld             ;
S_TRAY_RPTR_TBL                      now_tray_rptr_entry ;

logic                             wen              ;
logic  [TRAY_WPTR_TBL_AWID-1:0]      waddr            ;
S_TRAY_RPTR_TBL                      new_tray_rptr_entry ;

modport usr_rif( output ren, output raddr, input now_tray_rptr_entry,  input rvld  );
modport usr_wif( output wen, output waddr, output new_tray_rptr_entry  );
modport tbl_rif( input ren,  input raddr,  output now_tray_rptr_entry, output rvld );
modport tbl_wif( input wen,  input waddr,  input new_tray_rptr_entry );

endinterface : if_tray_rptr_tbl

/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
interface if_tray_map_tbl;

logic                             ren              ;
logic  [TRAY_MAP_TBL_AWID-1:0]      raddr            ;
logic                             rvld             ;
S_TRAY_MAP_TBL                      now_tray_map_entry ;

logic                             wen              ;
logic  [TRAY_MAP_TBL_AWID-1:0]      waddr            ;
S_TRAY_MAP_TBL                      new_tray_map_entry ;

modport usr_rif( output ren, output raddr, input now_tray_map_entry,  input rvld  );
modport usr_wif( output wen, output waddr, output new_tray_map_entry  );
modport tbl_rif( input ren,  input raddr,  output now_tray_map_entry, output rvld );
modport tbl_wif( input wen,  input waddr,  input new_tray_map_entry );

endinterface : if_tray_map_tbl

interface if_bdcar_carid_tbl;

logic                       raddr_wen   ;
logic [CAR_ID_TBL_AWID-1:0] raddr_wdata ;
logic                       raddr_nafull;

logic                       rdata_wen   ;
logic [CAR_ID_TBL_DWID-1:0] rdata_wdata ;
logic                       rdata_nafull;

logic                       waddr_wen   ;
logic [CAR_ID_TBL_AWID-1:0] waddr_wdata ;
logic                       waddr_nafull;

logic                       wdata_wen   ;
logic [CAR_ID_TBL_DWID-1:0] wdata_wdata ;
logic                       wdata_nafull;

modport usr_rif( output raddr_wen, output raddr_wdata, input  raddr_nafull,
                 input  rdata_wen, input  rdata_wdata, output rdata_nafull  );

modport usr_wif( output waddr_wen, output waddr_wdata, input  waddr_nafull,
                 output wdata_wen, output wdata_wdata, input  wdata_nafull  );

modport tbl_rif( input  raddr_wen, input  raddr_wdata, output raddr_nafull,
                 output rdata_wen, output rdata_wdata, input  rdata_nafull  );

modport tbl_wif( input  waddr_wen, input  waddr_wdata, output waddr_nafull,
                 input  wdata_wen, input  wdata_wdata, output wdata_nafull  );

endinterface : if_bdcar_carid_tbl

interface if_bdcar_token_tbl;

logic                          raddr_wen   ;
logic [CAR_TOKEN_TBL_AWID-1:0] raddr_wdata ;
logic                          raddr_nafull;

logic                          rdata_wen   ;
logic [CAR_TOKEN_TBL_DWID-1:0] rdata_wdata ;
logic                          rdata_nafull;

logic                          waddr_wen   ;
logic [CAR_TOKEN_TBL_AWID-1:0] waddr_wdata ;
logic                          waddr_nafull;

logic                          wdata_wen   ;
logic [CAR_TOKEN_TBL_DWID-1:0] wdata_wdata ;
logic                          wdata_nafull;

modport usr_if(  output raddr_wen, output raddr_wdata, input  raddr_nafull,
                 input  rdata_wen, input  rdata_wdata, output rdata_nafull,
                 output waddr_wen, output waddr_wdata, input  waddr_nafull,
                 output wdata_wen, output wdata_wdata, input  wdata_nafull  );

modport usr_rif( output raddr_wen, output raddr_wdata, input  raddr_nafull,
                 input  rdata_wen, input  rdata_wdata, output rdata_nafull  );

modport usr_wif( output waddr_wen, output waddr_wdata, input  waddr_nafull,
                 output wdata_wen, output wdata_wdata, input  wdata_nafull  );

modport tbl_rif( input  raddr_wen, input  raddr_wdata, output raddr_nafull,
                 output rdata_wen, output rdata_wdata, input  rdata_nafull  );

modport tbl_wif( input  waddr_wen, input  waddr_wdata, output waddr_nafull,
                 input  wdata_wen, input  wdata_wdata, output wdata_nafull  );

endinterface : if_bdcar_token_tbl

interface if_bdrsd_seq_tbl;

logic                          raddr_wen   ;
logic [RSD_SEQ_TBL_AWID-1:0]   raddr_wdata ;
logic                          raddr_nafull;

logic                          rdata_wen   ;
logic [256-1:0]                rdata_wdata ;
logic                          rdata_nafull;
S_RSD_SEQ_TBL                  rdata_wdata_exp ;

logic                          waddr_wen   ;
logic [RSD_SEQ_TBL_AWID-1:0]   waddr_wdata ;
logic                          waddr_nafull;

logic                          wdata_wen   ;
logic [256-1:0]                wdata_wdata ;
logic                          wdata_nafull;
S_RSD_SEQ_TBL                  wdata_wdata_exp ;

modport usr_if ( output raddr_wen, output raddr_wdata, input  raddr_nafull,
                 input  rdata_wen, input  rdata_wdata, output rdata_nafull, output rdata_wdata_exp,
                 output waddr_wen, output waddr_wdata, input  waddr_nafull,
                 output wdata_wen, output wdata_wdata, input  wdata_nafull, output wdata_wdata_exp);

modport usr_rif( output raddr_wen, output raddr_wdata, input  raddr_nafull,
                 input  rdata_wen, input  rdata_wdata, output rdata_nafull, output rdata_wdata_exp);

modport usr_wif( output waddr_wen, output waddr_wdata, input  waddr_nafull,
                 output wdata_wen, output wdata_wdata, input  wdata_nafull, output wdata_wdata_exp);

modport tbl_rif( input  raddr_wen, input  raddr_wdata, output raddr_nafull,
                 output rdata_wen, output rdata_wdata, input  rdata_nafull  );

modport tbl_wif( input  waddr_wen, input  waddr_wdata, output waddr_nafull,
                 input  wdata_wen, input  wdata_wdata, output wdata_nafull  );

endinterface : if_bdrsd_seq_tbl

/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
interface if_cbus;
parameter CBUS_AWID = 16;
parameter CBUS_DWID = 32;

//logic                             cbus_clk              ;
//logic                             cbus_rst              ;
logic                             cbus_req              ;
logic                             cbus_rw               ;
logic                             cbus_ack              ;
logic  [CBUS_AWID-1:0]            cbus_addr             ;
logic  [CBUS_DWID-1:0]            cbus_wdata            ;
logic  [CBUS_DWID-1:0]            cbus_rdata            ;

modport src( 
    output   cbus_req            ,
    output   cbus_rw             ,
    input    cbus_ack            ,
    output   cbus_addr           ,
    output   cbus_wdata          ,
    input    cbus_rdata           
);

modport sink( 
    input   cbus_req            ,
    input   cbus_rw             ,
    output  cbus_ack            ,
    input   cbus_addr           ,
    input   cbus_wdata          ,
    output  cbus_rdata           
);

endinterface : if_cbus



/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
interface if_dma_wif ;

logic                           vld      ;
logic                           rdy      ;
logic                           sop      ; 
logic                           eop      ; 
logic       [AXI_MTYWID-1:0]    mty      ; 
logic       [4-1:0]             fid      ; 
logic       [AXI_AWID-1:0]      waddr    ; 
logic       [AXI_DWID-1:0]      wdata    ; 

modport src( 
    output   vld   ,
    input    rdy   ,
    output   sop   ,
    output   eop   ,
    output   mty   ,
    output   fid   ,
    output   waddr ,
    output   wdata    
    );

modport sink( 
    input    vld   ,
    output   rdy   ,
    input    sop   ,
    input    eop   ,
    input    mty   ,
    input    fid   ,
    input    waddr ,
    input    wdata    
    );

endinterface : if_dma_wif

/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
interface if_rbd_fifo_rif ;
parameter FIFO_DWID = 12;
logic                      fifo_ren      ;
logic     [BDQBIT-1:0]     fifo_rqid     ;
logic     [BDQN-1:0]       fifo_nempty   ;
logic     [BDQN-1:0]       fifo_naempty  ;
logic     [FIFO_DWID-1:0]  fifo_rdata    ;
modport sink ( 
        output   fifo_ren      ,
        output   fifo_rqid     ,
        input    fifo_nempty   ,
        input    fifo_naempty  ,
        input    fifo_rdata     
);
endinterface : if_rbd_fifo_rif

interface if_rbd_fifo_wif ;
parameter FIFO_DWID = 12;
logic                     fifo_wen      ;
logic     [8-1:0]         fifo_wqid     ;
logic     [BDQN-1:0]      fifo_nfull    ;
logic     [BDQN-1:0]      fifo_nafull   ;
logic     [FIFO_DWID-1:0] fifo_wdata    ;
logic                     rdok          ;

modport src( 
        output   fifo_wen      , 
        output   fifo_wqid     , 
        output   fifo_wdata    ,
        output   rdok          , 
        input    fifo_nfull    , 
        input    fifo_nafull  
);
modport sink( 
        input    fifo_wen      , 
        input    fifo_wqid     , 
        input    fifo_wdata    ,
        input    rdok          ,
        output   fifo_nfull    , 
        output   fifo_nafull   
);
endinterface : if_rbd_fifo_wif

/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
interface if_wbd_fifo_rif ;
parameter FIFO_DWID = 12;
logic                      fifo_ren      ;
logic     [BDQBIT-1:0]     fifo_rqid     ;
logic                      sub           ;
logic     [BDQBIT-1:0]     sub_qid       ;
logic     [11:0]           sub_num       ; 
logic     [12*BDQN-1:0]    free_num      ; 
logic     [BDQN-1:0]       fifo_nempty   ;
logic     [BDQN-1:0]       fifo_naempty  ;
logic     [FIFO_DWID-1:0]  fifo_rdata    ;
modport sink ( 
        output   fifo_ren      ,
        output   fifo_rqid     ,
        output   sub           ,
        output   sub_qid       ,
        output   sub_num       ,
        input    free_num      ,
        input    fifo_nempty   ,
        input    fifo_naempty  ,
        input    fifo_rdata     
);
endinterface : if_wbd_fifo_rif

interface if_wbd_fifo_wif ;
parameter FIFO_DWID = 12;
logic                     fifo_wen      ;
logic     [BDQBIT-1:0]    fifo_wqid     ;
logic     [BDQN-1:0]      fifo_nfull   ;
logic     [BDQN-1:0]      fifo_nafull  ;
logic     [FIFO_DWID-1:0] fifo_wdata    ;
modport src( 
        output   fifo_wen      , 
        output   fifo_wqid     , 
        output   fifo_wdata    , 
        input    fifo_nfull    , 
        input    fifo_nafull     
);
modport sink( 
        input    fifo_wen      , 
        input    fifo_wqid     , 
        input    fifo_wdata    , 
        output   fifo_nfull    , 
        output   fifo_nafull     
);
endinterface : if_wbd_fifo_wif

/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
interface if_mid_fifo_rif ;
parameter FIFO_DWID = 12;
logic                      fifo_ren      ;
logic     [BDQBIT-1:0]     fifo_rqid     ;
logic     [BDQN-1:0]       fifo_nempty   ;
logic     [BDQN-1:0]       fifo_naempty  ;
logic     [FIFO_DWID-1:0]  fifo_rdata    ;
modport sink ( 
        output   fifo_ren      ,
        output   fifo_rqid     ,
        input    fifo_nempty   ,
        input    fifo_naempty  ,
        input    fifo_rdata     
);
endinterface : if_mid_fifo_rif

interface if_mid_fifo_wif ;
parameter FIFO_DWID = 12;
logic                     fifo_wen      ;
logic     [BDQBIT-1:0]    fifo_wqid     ;
logic     [BDQN-1:0]      fifo_nfull   ;
logic     [BDQN-1:0]      fifo_nafull  ;
logic     [FIFO_DWID-1:0] fifo_wdata    ;
modport src( 
        output   fifo_wen      , 
        output   fifo_wqid     , 
        output   fifo_wdata    , 
        input    fifo_nfull    , 
        input    fifo_nafull     
);
modport sink( 
        input    fifo_wen      , 
        input    fifo_wqid     , 
        input    fifo_wdata    , 
        output   fifo_nfull    , 
        output   fifo_nafull     
);
endinterface : if_mid_fifo_wif


/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
interface if_tcpr_tbl_rreq ;
logic                         wen      ;
logic     [TCPR_TBL_AWID-1:0] wdata    ;
logic                         nafull   ;
modport src ( 
        output   wen      ,
        output   wdata    ,
        input    nafull    
);
modport sink ( 
        input     wen      ,
        input     wdata    ,
        output    nafull    
);
endinterface : if_tcpr_tbl_rreq


interface if_tcpr_tbl_rdat ;
logic                         wen      ;
logic     [TCPR_TBL_DWID-1:0] wdata    ;
logic                         nafull   ;
modport src ( 
        output   wen      ,
        output   wdata    ,
        input    nafull    
);
modport sink ( 
        input     wen      ,
        input     wdata    ,
        output    nafull    
);
endinterface : if_tcpr_tbl_rdat



interface if_tcp_toe_reg;

logic [00:00]  cfg_clr_cnt           ;
logic [31:00]  cfg_toe_mode          ;

logic [00:00]  cfg_toe_mode_loop     ;
logic [00:00]  cfg_toe_mode_reorder  ;
logic [00:00]  cfg_toe_mode_ins_err  ;
logic [00:00]  cfg_toe_mode_sess_ne  ; //session_not_exist
logic [00:00]  cfg_toe_mode_dupack_en;
logic [00:00]  cfg_toe_mode_ins_err1 ;
logic [00:00]  cfg_toe_mode_ins_bp   ;
logic [00:00]  cfg_toe_mode_ins_bp1  ;
logic [00:00]  cfg_limit_rate_en     ;
logic [15:00]  cfg_toe_mode_cell_gap ;

logic [31:00]  cfg_sys_win           ;
logic [15:00]  cfg_write_bd_low_th   ;
logic [15:00]  cfg_read_bd_low_th    ;
logic [15:00]  cfg_msg_bd_low_th     ;
logic [15:00]  cfg_write_bd_high_th  ;
logic [15:00]  cfg_read_bd_high_th   ;
logic [15:00]  cfg_msg_bd_high_th    ;
logic [31:00]  cfg_dupack_mode       ;
logic [01:00]  cfg_ckserr_drop_en    ;//bit1 is tcp cks err drop en ,bit0 is ip cks err drop en

modport src ( output cfg_clr_cnt, cfg_toe_mode, 
        cfg_toe_mode_loop, 
        cfg_toe_mode_reorder,
        cfg_toe_mode_ins_err,
        cfg_toe_mode_sess_ne,
        cfg_toe_mode_dupack_en,
        cfg_toe_mode_ins_err1 , 
        cfg_toe_mode_ins_bp   , 
        cfg_toe_mode_ins_bp1   , 
        cfg_limit_rate_en     , 
        cfg_toe_mode_cell_gap ,
        cfg_msg_bd_low_th     ,
        cfg_msg_bd_high_th     ,
        cfg_dupack_mode     ,
        cfg_write_bd_low_th, cfg_read_bd_low_th, cfg_write_bd_high_th, cfg_read_bd_high_th , 
        cfg_ckserr_drop_en );

modport sink( input  cfg_clr_cnt, cfg_toe_mode, 
        cfg_toe_mode_loop, 
        cfg_toe_mode_reorder,
        cfg_toe_mode_ins_err,
        cfg_toe_mode_sess_ne,
        cfg_toe_mode_dupack_en,
        cfg_toe_mode_ins_err1 , 
        cfg_toe_mode_ins_bp   , 
        cfg_toe_mode_ins_bp1   , 
        cfg_limit_rate_en     , 
        cfg_toe_mode_cell_gap ,
        cfg_msg_bd_low_th     ,
        cfg_msg_bd_high_th     ,
        cfg_dupack_mode     ,
        cfg_write_bd_low_th, cfg_read_bd_low_th, cfg_write_bd_high_th, cfg_read_bd_high_th ,
        cfg_ckserr_drop_en );

endinterface : if_tcp_toe_reg



interface if_dbg_reg_toe;

logic [31:0]   rx_pktlen_ecnt    ;//bit31:16 is iplen err cnt ,bit15:0 is short err cnt
logic [31:0]   rx_cks_ecnt       ;//bit31:16 is tcpcks err cnt,bit15:0 is ipcks err cnt
logic [31:00]  tcpr_in_pd_cnt    ;
logic [31:00]  tcpr_pkt_drop_cnt ;
logic [31:00]  tcpr_pkt_bp_drop_cnt ;
logic [31:00]  tcpr_pkt_mac_cnt ;
logic [31:00]  tcpr_pkt_toe_cnt ;
logic [31:00]  tcpr_pkt_app_cnt ;
logic [31:00]  tcpr_in_syn_cnt   ;
logic [31:00]  tcpr_in_ack_cnt   ;
logic [31:00]  tcpr_in_fin_cnt   ;
logic [31:00]  tcpr_in_rep_fin_cnt ;
logic [31:00]  tcpr_in_rst_cnt   ;
logic [31:00]  tcpr_in_dat_cnt   ;
logic [31:00]  tcpr_tbl_new_cnt  ;
logic [31:00]  tcpr_tbl_del_cnt  ;
logic [31:00]  tcpr_dup_ack_cnt  ;
logic [31:00]  tcpr_bp_dup_ack_cnt  ;
logic [31:00]  tcpr_drop_dup_ack_cnt  ;
logic [31:00]  tcpr_seqn_err_cnt  ;
logic [31:00]  tcpr_reorder_cnt  ;
logic [31:00]  tcpr_out_order_drop_cnt;

logic [31:00]  tcpr_in_pd_cnt_fid0 ;
logic [31:00]  tcpr_in_pd_cnt_fid1 ;
logic [31:00]  tcpt_in_pd_cnt ;
logic [31:00]  tcpt_drop_pd_cnt ;
logic [31:00]  tcpt_mac_pd_cnt ;
logic [31:00]  tcpt_toe_pd_cnt ;
logic [31:00]  tcpt_app_pd_cnt ;
logic [31:00]  pmux_cell_nrdy_cnt   ;
logic [31:00]  fptr_fifo_aempty_cnt ;
logic [31:00]  toe_rx_fptr_fifo_cnt_used ;
logic [31:00]  toe_tx_fptr_fifo_cnt_used ;
logic [31:00]  tcpr_fifo_nafull ;

logic [31:00]  toe_rx_prepe_dbg   ;
logic [31:00]  toe_tx_prepe_dbg   ;
logic [31:00]  tcpr_out_syn_cnt   ;
logic [31:00]  tcpt_out_syn_cnt   ;
logic [31:00]  tcpt_out_fin_cnt   ;
logic [31:00]  tcpt_out_rst_cnt   ;
logic [31:00]  tcpt_loop_rst_cnt  ;
logic [31:00]  tcpr_syn2rst_cnt   ;


//modport src ( output dbg_write_bd_low_th, dbg_read_bd_low_th, dbg_write_bd_high_th, dbg_read_bd_high_th );
modport sink( 
  input  tcpr_out_syn_cnt   , 
  input  tcpt_out_syn_cnt   , 
  input  tcpt_out_fin_cnt   , 
  input  tcpt_out_rst_cnt   , 
  input  tcpt_loop_rst_cnt  , 
  input  tcpr_syn2rst_cnt   , 
  input  toe_rx_prepe_dbg   , 
  input  toe_tx_prepe_dbg   , 
  input  rx_pktlen_ecnt    ,//bit31:16 is iplen err cnt ,bit15:0 is short err cnt
  input  rx_cks_ecnt       ,//bit31:16 is tcpcks err cnt,bit15:0 is ipcks err cnt
  input  tcpr_in_pd_cnt   , 
  input  tcpr_pkt_drop_cnt, 
  input  tcpr_pkt_bp_drop_cnt , 
  input  tcpr_pkt_mac_cnt     , 
  input  tcpr_pkt_toe_cnt     , 
  input  tcpr_pkt_app_cnt     , 
  input  tcpr_in_syn_cnt      , 
  input  tcpr_in_ack_cnt      , 
  input  tcpr_in_fin_cnt      , 
  input  tcpr_in_rep_fin_cnt  , 
  input  tcpr_in_rst_cnt  , 
  input  tcpr_in_dat_cnt  , 
  input  tcpr_tbl_new_cnt , 
  input  tcpr_tbl_del_cnt ,
  input  tcpr_dup_ack_cnt ,
  input  tcpr_bp_dup_ack_cnt     ,
  input  tcpr_drop_dup_ack_cnt   ,
  input  tcpr_seqn_err_cnt       , 
  input  tcpr_reorder_cnt    ,
  input  tcpr_in_pd_cnt_fid0 ,
  input  tcpr_in_pd_cnt_fid1 , 
  input  tcpt_in_pd_cnt      ,
  input  tcpt_drop_pd_cnt    , 
  input  tcpt_mac_pd_cnt    , 
  input  tcpt_toe_pd_cnt    , 
  input  tcpt_app_pd_cnt      ,
  input  pmux_cell_nrdy_cnt   , 
  input  fptr_fifo_aempty_cnt  , 
  input  toe_rx_fptr_fifo_cnt_used ,
  input  toe_tx_fptr_fifo_cnt_used ,
  input  tcpr_out_order_drop_cnt   ,
  input  tcpr_fifo_nafull  
);

endinterface : if_dbg_reg_toe



