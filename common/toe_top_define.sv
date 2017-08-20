
`timescale 1ns / 1ps
package toe_top_define;

typedef struct packed {
        logic           [15:0]      fifo_used_cnt       ;
        logic           [15:0]      free_msg_id_cnt     ;
        logic           [15:0]      free_rcv_msg_id_cnt ;
} S_MOE_RX_FIFO_ST;


//typedef struct packed {
//        E_BD_TYP        bd_typ      ;
//        E_BD_ST         bd_st       ;
//        logic [12-1:0]  msg_id      ;
//        U_BUF_ID_TOS    buf_id_tos  ;  //buf id or msg tos
//        U_BUF_SEQ_NUM   buf_seq_num ;  //buf num or buf seqn
//        logic [16-1:0]  dat_crc     ;
//        logic [16-1:0]  fid         ;
//        logic [32-1:0]  trans_id    ;
//        logic [08-1:0]  cur_tray_id ;
//        logic [08-1:0]  bak_tray_id ;
//} S_RX_BD;
//parameter RX_BD_WID = $bits(S_RX_BD);   //136b
//
//typedef enum logic [3:0] 
//{ 
//        //VAL_MSG_RX_ST_OK    ,
//        VAL_MSG_RX_ST_DONE       , 
//        VAL_MSG_RX_ST_MSG_RETRY  ,
//        VAL_MSG_RX_ST_WBD_RETRY  ,
//        VAL_MSG_RX_ST_DMA_RETRY  ,
//        VAL_MSG_RX_ST_WAIT       , 
//        VAL_MSG_RX_ST_DROP       , 
//        VAL_MSG_RX_ST_MAGIC_ERR  ,//magic number is error
//        VAL_MSG_RX_ST_DAT_LEN_ERR,//data_length is illegal
//        VAL_MSG_RX_ST_MSG_TYP_ERR,//data_length is illegal
//        VAL_MSG_RX_ST_WR_LEN_ERR ,//write data_legth is 0
//        VAL_MSG_RX_ST_RD_NLBA_ERR,//read nlba is 0 or read nlba > cfg
//        VAL_MSG_RX_ST_TRIM_ERR   ,
//        VAL_MSG_RX_ST_TIMEOUT
//} E_MSG_RX_ST ;   //the status for the message received
//
//
////old define
//parameter DATE_VER        = 32'h2015_0323;
//parameter LOGIC_VER       = 32'h0001_2000;
//

endpackage : toe_top_define






