
`timescale 1ns / 1ps
package nic_top_define;

//old define
parameter DATE_VER        = 32'h2015_0323;
parameter LOGIC_VER       = 32'h0001_2000;

parameter GLB_RD_LEN      = 16'd4096     ;

`ifdef NIC_MID
parameter GLB_KEY_TAB_AWID    = 9        ;
parameter GLB_KEY_TAB_DWID    = 128      ;
parameter GLB_ACT_TAB_AWID    = 9        ;
parameter GLB_ACT_TAB_DWID    = 128      ;
`else
parameter GLB_KEY_TAB_AWID    = 9        ; //12
parameter GLB_KEY_TAB_DWID    = 128      ;
parameter GLB_ACT_TAB_AWID    = 9        ;
parameter GLB_ACT_TAB_DWID    = 128      ;
`endif

`ifdef S5_SIMULATION
parameter NICN                = `RGE_NIC         ;
parameter TRAYN               = `TRAY_NUM        ;
`elsif TRAYN_EQU_15
parameter NICN                = 2                ;
parameter TRAYN               = 15               ;
`else
parameter NICN                = 2                ;
parameter TRAYN               = 4                ;
`endif

parameter PCS_REFCLK_NUM      = 1                ;
parameter BDQN                = 1                ;
parameter BDQBIT              = $clog2(BDQN)+1   ;

//for mqdma
parameter TAGW                = 8                ;
parameter TAG_NUM             = 2**TAGW          ;

//old define


parameter AXI_AWID      = 48  ;  
parameter AXI_DWID      = 256 ;  
parameter AXI_MTYWID    = 5   ;  
parameter TRAY_MEM_AWID = 32  ;  

parameter CBUS_AWID     = 16  ;
parameter CBUS_DWID     = 32  ;

//key parameter in BD structure
parameter MSG_ID_WID      = 12   ;  //msg_id key width  
parameter MSG_ID_NUM      = 1024 ;  //msg_id number
parameter MSG_ID_DBIT     = 10   ;  //msg_id fifo depth bit

parameter BUF_ID_WID      = 12   ;  //buf_id key width      
parameter BUF_ID_NUM      = 2048 ;  //buf_id number         
parameter BUF_ID_DBIT     = 11   ;  //buf_id fifo depth bit 
parameter BUF_ID_DEPTHBIT = BUF_ID_DBIT ;  

parameter MAX_CELL_GAP    = 8 ;  //the gap cycle between cells

parameter TCPR_TBL_AWID = 8   ; 
parameter TCPR_TBL_DWID = 128 ; 
parameter TCPR_TBL_DNUM = 2   ; 

/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
typedef enum logic [4:0] 
{ 
        //VAL_MSG_RX_ST_OK    ,
        VAL_MSG_RX_ST_DONE       , 
        VAL_MSG_RX_ST_MSG_RETRY  ,
        VAL_MSG_RX_ST_WBD_RETRY  ,
        VAL_MSG_RX_ST_DMA_RETRY0 ,
        VAL_MSG_RX_ST_DMA_RETRY1 ,
        VAL_MSG_RX_ST_DMA_RETRY2 ,
        VAL_MSG_RX_ST_DMA_RETRY3 ,
        VAL_MSG_RX_ST_DMA_RETRY4 ,
        VAL_MSG_RX_ST_DMA_RETRY5 ,
        VAL_MSG_RX_ST_DMA_RETRY6 ,
        VAL_MSG_RX_ST_DMA_RETRY7 ,
        VAL_MSG_RX_ST_TRAY_RETRY ,
        VAL_MSG_RX_ST_ARR_RETRY  ,
        VAL_MSG_RX_ST_AGE_RETRY  ,//TRAY SEND AGE
        VAL_MSG_RX_ST_WAIT       , 
        VAL_MSG_RX_ST_DROP       , 
        VAL_MSG_RX_ST_MAGIC_ERR  ,//magic number is error
        VAL_MSG_RX_ST_DAT_LEN_ERR,//data_length is illegal
        VAL_MSG_RX_ST_MSG_TYP_ERR,//data_length is illegal
        VAL_MSG_RX_ST_WR_LEN_ERR ,//write data_legth is 0
        VAL_MSG_RX_ST_RD_NLBA_ERR,//read nlba is 0 or read nlba > cfg
        VAL_MSG_RX_ST_TRIM_ERR   ,        
        VAL_MSG_RX_ST_TIMEOUT
} E_MSG_RX_ST ;   //the status for the message received

typedef enum logic [7:0]
{ 
        VAL_MSG_TYP_READ             =  8'd00 , 
        VAL_MSG_TYP_READ_REPLY       =  8'd01 , 
        VAL_MSG_TYP_WRITE            =  8'd02 , 
        VAL_MSG_TYP_WRITE_REPLY      =  8'd03 , 
        VAL_MSG_TYP_LOADW            =  8'd04 ,  //load write
        VAL_MSG_TYP_LOADW_REPLY      =  8'd05 ,  //load write reply
        VAL_MSG_TYP_FLUSHC           =  8'd06 ,  //flush complete
        VAL_MSG_TYP_FLUSHC_REPLY     =  8'd07 ,  //flush complete reply
        VAL_MSG_TYP_CACHED           =  8'd08 ,  //cache delete
        VAL_MSG_TYP_CACHED_REPLY     =  8'd09 ,  //cache delete reply
        VAL_MSG_TYP_KEEPA            =  8'd10 ,  //keep alive
        VAL_MSG_TYP_KEEPA_REPLY      =  8'd11 ,  //keep alive reply
        VAL_MSG_TYP_CACHEF           =  8'd12 ,  //cache find
        VAL_MSG_TYP_CACHEF_REPLY     =  8'd13 ,  //caceh find reply
        VAL_MSG_TYP_FLUSHR           =  8'd14 ,  //flush read
        VAL_MSG_TYP_FLUSHR_REPLY     =  8'd15 ,  //flush read reply
        VAL_MSG_TYP_LOADC            =  8'd20 ,  //load complete
        VAL_MSG_TYP_LOADC_REPLY      =  8'd21 ,  //load complete reply
        VAL_MSG_TYP_TRIM             =  8'd36 ,  //trim
        VAL_MSG_TYP_TRIM_REPLY       =  8'd37 ,  //trim reply
        VAL_MSG_TYP_FLUSH_REQ        =  8'd38 ,  //flush req
        VAL_MSG_TYP_FLUSH_REQ_REPLY  =  8'd39 ,   //flush req reply
        VAL_MSG_TYP_LOAD_REQ         =  8'd40 ,  //load req 
        VAL_MSG_TYP_LOAD_REQ_REPLY   =  8'd41    //load req reply
} E_MSG_TYP ;    //the value for type of message


typedef enum logic [7:0] 
{ 
        VAL_PTYP_RSV                = 8'h0                              ,  
        VAL_PTYP_MAC                = 8'h1                              ,  
        VAL_PTYP_PKT_MSG            = 8'hf                              ,  

        VAL_PTYP_CPU_INIT             = 8'h10                             ,  
        VAL_PTYP_CPU_FREE             = 8'h11                             ,  
        VAL_PTYP_PKT_SYN              = 8'h12                             ,   
        VAL_PTYP_PKT_FIN              = 8'h13                             ,   
        VAL_PTYP_PKT_SYNACK           = 8'h14                             ,   
        VAL_PTYP_PKT_ACK              = 8'h15                             ,   
        VAL_PTYP_PKT_FIRST_ACK        = 8'h16                             ,   
        VAL_PTYP_PKT_LAST_ACK         = 8'h17                             ,   
        VAL_PTYP_PKT_DUP_ACK          = 8'h18                             ,   
        VAL_PTYP_PKT_AGE_FIN          = 8'h19                             ,   
        VAL_PTYP_PKT_RST              = 8'h1a                             ,   
        VAL_PTYP_CPU_RST              = 8'h1b                             ,   
        VAL_PTYP_POL_RST              = 8'h1c                             ,   
        VAL_PTYP_RESND_RST            = 8'h1d                             ,   
        VAL_PTYP_PKT_OUT_ORDER        = 8'h1e                             ,
        VAL_PTYP_AGE_MID              = 8'h1f                             ,   
        VAL_PTYP_AGE_WBD              = 8'h20                             ,   
        VAL_PTYP_AGE_RBD              = 8'h21                             ,   
        VAL_PTYP_MOE_RST              = 8'h22                             ,   
        
        VAL_PTYP_DROP_MAC_ERR        = 8'h40                             ,  
        VAL_PTYP_DROP_IP_LEN_ERR      = 8'h41                             ,  
        VAL_PTYP_DROP_IPCKS_ERR      = 8'h42                             ,  
        VAL_PTYP_DROP_TCPCKS_ERR      = 8'h43                             ,  
        VAL_PTYP_DROP_SEQN_ERR        = 8'h44                             ,  
        VAL_PTYP_DROP_SYN_REPEAT     = 8'h45                             ,  
        VAL_PTYP_DROP_ACK            = 8'h46                             ,   
        VAL_PTYP_DROP_FIRST_ACK      = 8'h47                             ,   
        VAL_PTYP_DROP_LAST_ACK        = 8'h48                             ,   
        VAL_PTYP_DROP_CPU_LOOP       = 8'h49                             ,   
        VAL_PTYP_DROP_MOE_BP         = 8'h4a                             ,   
        VAL_PTYP_DROP_RST            = 8'h4b                             ,   
        VAL_PTYP_DROP_APP_BP          = 8'h4c                             ,   
        VAL_PTYP_DROP_INSERT_ERR     = 8'h4d                             ,   
        VAL_PTYP_DROP_DUP_ACK        = 8'h4e                             ,   
        VAL_PTYP_DROP_SESS_NOTEXIST  = 8'h4f                             ,   
        VAL_PTYP_DROP_SHORT_PKT      = 8'h50                             ,   
        VAL_PTYP_DROP_TOE_TX_ERR     = 8'h51                             ,   

        VAL_PTYP_READ                    = 8'h80                ,
        VAL_PTYP_READ_REPLY              = 8'h81                ,

        VAL_PTYP_WRITE                   = 8'h82                ,
        VAL_PTYP_WRITE_REPLY             = 8'h83                ,

        VAL_PTYP_LOAD_WRITE              = 8'h84                ,
        VAL_PTYP_LOAD_WRITE_REPLY        = 8'h85                ,

        VAL_PTYP_FLUSH_COMPLETE          = 8'h86                ,
        VAL_PTYP_FLUSH_COMPLETE_REPLY    = 8'h87                ,

        VAL_PTYP_CACHE_DELETE            = 8'h88                ,
        VAL_PTYP_CACHE_DELETE_REPLY      = 8'h89                ,

        VAL_PTYP_KEEP_ALIVE              = 8'h8a                ,
        VAL_PTYP_KEEP_ALIVE_REPLY        = 8'h8b                ,

        VAL_PTYP_CACHE_FIND              = 8'h8c                ,
        VAL_PTYP_CACHE_FIND_REPLY        = 8'h8d                ,

        VAL_PTYP_FLUSH_READ              = 8'h8e                ,
        VAL_PTYP_FLUSH_READ_REPLY        = 8'h8f                ,

        VAL_PTYP_RMAP_POL                = 8'h90                ,
        
        VAL_PTYP_CPU_DEL                 = 8'h9a                ,
        VAL_PTYP_CPU_DEL_REPLY           = 8'h9b                ,
        VAL_PTYP_USR_DEL                 = 8'h9c                , 
        VAL_PTYP_USR_DEL_REPLY           = 8'h9d                ,
        VAL_PTYP_CPU_POL                 = 8'h9e                ,


        VAL_PTYP_READ_HDR                = 8'hc0                ,
        VAL_PTYP_WRITE_HDR               = 8'hc1                ,
        VAL_PTYP_WRITE_BAK               = 8'hc2                ,
        VAL_PTYP_WRITE_BAK_HDR           = 8'hc3                ,
        VAL_PTYP_LOAD_WRITE_HDR          = 8'hc4                ,
        VAL_PTYP_FLUSH_READ_HDR          = 8'hc5                ,
        VAL_PTYP_LOADW_HDR               = 8'hc6                ,
        VAL_PTYP_LOADW_BAK_HDR           = 8'hc7                ,
        VAL_PTYP_LOADW_BAK               = 8'hc8                ,

        VAL_PTYP_WRITE_COMPLETE          = 8'h92                ,  
        VAL_PTYP_WRITE_COMPLETE_REPLY    = 8'h93                ,  

        VAL_PTYP_LOAD_COMPLETE           = 8'h94                ,
        VAL_PTYP_LOAD_COMPLETE_REPLY     = 8'h95                ,

        VAL_PTYP_DELETE_COMPLETE         = 8'h96                , 
        VAL_PTYP_DELETE_COMPLETE_REPLY   = 8'h97                , 

        VAL_PTYP_FLUSH_REQ               = 8'ha6                ,
        VAL_PTYP_FLUSH_REQ_REPLY         = 8'ha7                ,

        VAL_PTYP_TBL_POL                 = 8'ha8                ,
        VAL_PTYP_TBL_POL_REPLY           = 8'ha9                ,

        VAL_PTYP_LOAD_REQ                = 8'haa                ,
        VAL_PTYP_LOAD_REQ_REPLY          = 8'hab                ,

        VAL_PTYP_CPU_CFG                 = 8'hb0                , 
        VAL_PTYP_LMT_NEW_4M              = 8'hb1                ,
        VAL_PTYP_LMT_DELETE_4M           = 8'hb2                ,
////ftl cache bd type defination
        VAL_PTYP_FTLCLOAD_REQ             = 8'hd0                ,//load bd from ftl cache to a9
        VAL_PTYP_FTLCLOAD_CPL             = 8'hd1                ,//load bd cpl from a9 to ftl cache
        VAL_PTYP_FTLCFLUSH_REQ            = 8'hd2                ,//flush bd from ftl cache to a9
        VAL_PTYP_FTLCFLUSH_CPL            = 8'hd3                ,//flush cpl bd from a9 to ftl cache
        VAL_PTYP_FTLC16KDEL               = 8'hd4                ,//del bd from ftl cache to a9
        VAL_PTYP_FTLC16KDEL_CPL           = 8'hd5                ,//del cpl bd from a9 to ftlc cache


        VAL_PTYP_FTLCDEL_CPU              = 8'hd6                ,
        VAL_PTYP_FTLCDEL_USR              = 8'hd7                ,
        VAL_PTYP_FTLCDEL_POL              = 8'hd8                ,

        VAL_PTYP_FTLCREADCPL_REQ          = 8'hd9                ,//bng to ftlc's read cpl bd
        VAL_PTYP_FTLCREADCPL_CPL          = 8'hda                ,//ftlc to bng's read cpl bd 's cpl

        VAL_PTYP_FTLCPOL                  = 8'hdb                ,
        VAL_PTYP_READWAIT                 = 8'hdc                , 
        VAL_PTYP_POWERDOWN                = 8'hdd                 
/////
        //VAL_TYP_SYN           =  8'h01 , 
        //VAL_TYP_ACK           =  8'h02 , 
        //VAL_TYP_FIN           =  8'h03 , 
        //VAL_TYP_RST           =  8'h04 , 
        //VAL_TYP_FIRST_ACK     =  8'h05 , 
        //VAL_TYP_LAST_ACK      =  8'h06 , 
        //VAL_TYP_DUP_ACK       =  8'h07 , 
        //VAL_TYP_READ          =  8'h80 , 
        //VAL_TYP_READ_HDR      =  8'h81 , 
        //VAL_TYP_WRITE         =  8'h82 ,
        //VAL_TYP_WRITE_HDR     =  8'h83 ,
        //VAL_TYP_WRITE_BAK     =  8'h84 ,
        //VAL_TYP_WRITE_BAK_HDR =  8'h85 ,
        //VAL_TYP_RSV           =  8'h00      
} E_BD_TYP ;    //the value for type of buffer descriptor

typedef enum logic [7:0] 
{ 
//        VAL_ST_OK                 = 8'h00, 
//        VAL_ST_OK_WO_DATA         = 8'h01, //write message without data or read reply message without data
//        VAL_ST_RETRY              = 8'h08, 
//        VAL_ST_FAIL               = 8'h03, 
//        VAL_ST_ERR                = 8'h04, 
//        VAL_ST_MSG_RX_TBL_INVLD   = 8'h05,
//        VAL_ST_RETRY_CAR          = 8'h06, 
//        VAL_ST_WAIT_HDR           = 8'h09
        VAL_BST_REPLY_OK          = 8'h00 ,
        VAL_BST_REPLY_POK         = 8'h01 ,
        VAL_BST_REPLY_ERR         = 8'h02 ,
        VAL_BST_REPLY_MISS        = 8'h03 ,
        VAL_BST_REPLY_DELETE      = 8'h04 ,
        VAL_BST_REPLY_FLUSH       = 8'h05 ,
        VAL_BST_REPLY_LOAD        = 8'h06 ,
        VAL_BST_REPLY_WRITE       = 8'h07 ,
        VAL_BST_RETRY_WAIT        = 8'h08 ,
        VAL_BST_RETRY_LOAD        = 8'h09 ,
        VAL_BST_RETRY_DELETE      = 8'h0a ,
        VAL_BST_RETRY_OTHER       = 8'h0b ,
        VAL_BST_DROP_OK           = 8'h0c ,
        VAL_BST_DROP_ERR          = 8'h0d ,
        VAL_BST_RETRY_CAR         = 8'h0e ,
        VAL_BST_REPLY_RST         = 8'h0f ,
        VAL_BST_RETRY_MSG_ID      = 8'h10 ,  
        VAL_BST_RETRY_WBD         = 8'h11 ,  
        VAL_BST_RETRY_DMA0        = 8'h12 ,
        VAL_BST_RETRY_DMA1        = 8'h13 ,
        VAL_BST_RETRY_DMA2        = 8'h14 ,
        VAL_BST_RETRY_DMA3        = 8'h15 ,
        VAL_BST_RETRY_DMA4        = 8'h16 ,
        VAL_BST_RETRY_DMA5        = 8'h17 ,
        VAL_BST_RETRY_DMA6        = 8'h18 ,
        VAL_BST_RETRY_DMA7        = 8'h19 ,
        VAL_BST_WAIT_DIST_RDY     = 8'h1a ,
        VAL_BST_MSG_TBL_INVLD     = 8'h1b ,
        VAL_BST_MAGIC_ERR         = 8'h1c ,  
        VAL_BST_DAT_LEN_ERR       = 8'h1d ,
        VAL_BST_MSG_TYP_ERR       = 8'h1e ,
        VAL_BST_WR_LEN_ERR        = 8'h1f ,
        VAL_BST_RD_NLBA_ERR       = 8'h20 ,
        VAL_BST_TRIM_ERR          = 8'h21 ,
        
        VAL_LMT_REPLY_OK          = 8'h22 ,
        VAL_LMT_NCS1              = 8'h23 ,
        VAL_LMT_NCS2              = 8'h24 ,
        VAL_LMT_ACS1              = 8'h25 ,
        VAL_LMT_ACS2              = 8'h26 ,
        VAL_LMT_REPLY_FULL        = 8'h27 ,
        VAL_LMT_REPLY_FULL_WAIT_OK= 8'h28 ,
        VAL_LMT_RDNF              = 8'h29 ,
        VAL_LMT_RDNF_WAIT_OK      = 8'h2a ,
        
        VAL_LMT_RDS1              = 8'h2b ,
        VAL_LMT_RDERR             = 8'h2c ,
        VAL_LMT_POLNF             = 8'h2d ,
        
        VAL_LMT_DHS1              = 8'h31 ,
        VAL_LMT_DHS2              = 8'h32 ,
        VAL_LMT_DCS1              = 8'h34 ,
        VAL_LMT_DCS2              = 8'h35 ,
        VAL_LMT_DEL               = 8'h36 ,
        VAL_LMT_DEL_WAIT_OK       = 8'h37 ,
        VAL_LMT_DELNF             = 8'h38 ,
        VAL_LMT_DELNF_WAIT_OK     = 8'h39 ,
        
        VAL_LMT_WAIT_OK           = 8'h3a ,
        //VAL_LMT_WRITE_WAIT_OK   = 8'h33 ,
        VAL_LMT_POL_DROP          = 8'h3b ,
        VAL_LMT_POL_DROP_WAIT_OK  = 8'h3c ,
        VAL_LMT_RETRY             = 8'h3d ,
        VAL_LMT_RETRY_WAIT_OK     = 8'h3e ,
        VAL_BST_REPLY_OK_WAIT_OK  = 8'h3f ,
 
        VAL_BUF_WR_RETRY          = 8'h40 ,
        
        VAL_BST_RETRY_ARR         = 8'h41 ,
        VAL_BST_RETRY_AGE         = 8'h42 ,//tray send age
        VAL_BST_RETRY_TRAY        = 8'h43 ,
        VAL_BUF_RD_RETRY          = 8'h44 ,

        /////ftlc internal bd status defination
        VAL_LISTST_START         = 8'h60  ,
        VAL_LISTST_NCS1          = 8'h61  ,
        VAL_LISTST_NCS2          = 8'h62  ,
        VAL_LISTST_NCS3          = 8'h63  ,
        VAL_LISTST_ACS1          = 8'h64  ,
        VAL_LISTST_ACS2          = 8'h65  ,
        VAL_LISTST_ACS3          = 8'h66  ,

        VAL_LISTST_RDNF          = 8'h6a  ,
        VAL_LISTST_RDS1          = 8'h6b  ,

        VAL_LISTST_DELNF         = 8'h6c  ,
        VAL_LISTST_DEL           = 8'h6d  ,
        VAL_LISTST_DHS1          = 8'h6e  ,
        VAL_LISTST_DHS2          = 8'h6f  ,

        VAL_LISTST_DCS1          = 8'h70  ,
        VAL_LISTST_DCS2          = 8'h71  ,
        VAL_LISTST_DCS3          = 8'h72  ,

        VAL_LISTST_HIT           = 8'h73  ,
        VAL_LISTST_LERR          = 8'h74  ,
        VAL_LISTST_LERR_DCS1     = 8'h75  ,
        VAL_LISTST_LERR_DEL      = 8'h76  ,
        VAL_LISTST_RSV           = 8'h7f  ,
        ////
        ///////////////////////////////ftlc reply or retry bd status defination
        VAL_FTLC_REPLY_OK              = 8'h80  , //the ftlc reply ok st
        ////write bd 's reply st
        VAL_FTLC_RETRY_NFTL            = 8'h81  ,//st simulation and software related
        VAL_FTLC_RETRY_TNFTL           = 8'h82  ,//st simulation and software related
        VAL_FTLC_RETRY_FTLNDDR         = 8'h83  ,//st simulation and software related
        VAL_FTLC_RETRY_FTLTNDDR        = 8'h84  ,//st simulation and software related
        VAL_FTLC_RETRY_NDDR            = 8'h85  ,//st simulation and software related
        VAL_FTLC_RETRY_TNDDR           = 8'h86  ,//st simulation and software related

        VAL_FTLC_RETRY_NWACS1          = 8'h87  ,
        VAL_FTLC_RETRY_NWNCS1          = 8'h88  ,
        VAL_FTLC_RETRY_NWACS2          = 8'h89  ,
        VAL_LISTST_NWNCS2              = 8'h8a  ,
       
        //VAL_FTLC_REPLY_OK                      //the sub-entry is 00             ,it is created               ,    a new fptr is get
        VAL_FTLC_REPLY_OK_OW           = 8'h8b  ,//the sub-entry is 11 and pening 0,it is overwrite             ,no  a new fptr is get
        VAL_FTLC_REPLY_OK_OWPENDING    = 8'h8c  ,//the sub-entry is 11 and pening 1,it is overwrite             ,but a new fptr is get
        VAL_FTLC_REPLY_OK_OWFL         = 8'h8d  ,//the sub-entry is 11 and flushing,it is overwirte             ,no  a new fptr is get
        VAL_FTLC_REPLY_OK_OWFLPENDING  = 8'h8e  ,//the sub-entry is 11 and flushing and pengin1,it is overwirte ,but a new fptr is get

        VAL_FTLC_RETRY_LOADING         = 8'h8f  ,//st simulation and software related
        VAL_FTLC_RETRY_DELBAD          = 8'h90  ,//st simulation and software related
        VAL_FTLC_RETRY_BAD             = 8'h91  ,//st simulation and software related
        VAL_FTLC_RETRY_DEL             = 8'h92  ,//st simulation and software related
        VAL_FTLC_RETRY_BUGERR          = 8'h93  ,
        VAL_FTLC_RETRY_LISTERR         = 8'h94  ,      
        VAL_FTLC_REPLY_OK_NEWNHEAD     = 8'h95  , 
        VAL_FTLC_REPLY_OK_NEWHEAD      = 8'h96  ,
 
        ///////////////////////////////read   bd 's reply st
        //VAL_FTLC_RETRY_NFTL
        //VAL_FTLC_RETRY_TNFTL
        //VAL_FTLC_RETRY_FTLNDDR 
        //VAL_FTLC_RETRY_FTLTNDDR 
        //VAL_FTLC_RETRY_NWACS1 
        //VAL_FTLC_RETRY_NWNCS1
        //VAL_FTLC_RETRY_NWACS2
        VAL_FTLC_RETRY_NEWLOAD         = 8'h97  ,//st simulation and software related.the ftlc sub-entry is 001.the sub-entry will be created
        //VAL_FTLC_RETRY_DELBAD 
        //VAL_FTLC_RETRY_BAD 
        //VAL_FTLC_RETRY_DEL 
        VAL_FTLC_RETRY_PENDING         = 8'h98  ,//st simulation and software related.the ftlc entry is no flusing and the sub-entry 's pendingcnt is not 0 ,and sub is clean
        VAL_FTLC_RETRY_DPENDING_LD     = 8'h99  ,//st simulation and software related.the fltc entry is no flusing and the sub-entry 's pendingnct is not 0 ,and sub is dirty ,other sub can load
        VAL_FTLC_RETRY_DPENDING_FL     = 8'h9a  ,//st simulation and software related.the ftlc entry is no flusing and the sub-entry 's pendingcnt is not 0 ,and sub is dirty ,the entry can flush
        VAL_FTLC_RETRY_DPENDING_NA     = 8'h9b  ,//st simulation and software related.the ftlc entry is no flusing and the sub-entry 's pendingcnt is not 0 ,and sub it dirty ,the entry can no flush or load
        //VAL_FTLC_RETRY_LOADING         = 8'h92  ,//the ftcl entry is loading,the read can not be execute
        VAL_FTLC_RETRY_FLUSHPENDING    = 8'h9c  ,//st simulation and software related.the ftlc entry is flusing and the sub-entry 's pendingcn is not 0
        //VAL_FTLC_RETRY_BUGERR 
        //VAL_FTLC_RETRY_LISTERR
        VAL_FTLC_RETRY_NEWNHEAD        = 8'h9d  ,//st simulation and software related.a new ftlc node entry is created and it is not the list head
        VAL_FTLC_RETRY_NEWHEAD         = 8'h9e  ,//st simulation and software related.a new ftlc node entry is created and it is     the list head
        //////////////////////////////read cpl bd 's reply st
        //VAL_FTLC_RETRY_TNDDR       //cbfifo is just afaull,the ddr buf addr can not callback
        VAL_FTLC_RETRY_LBAERR          = 8'h9f ,//when dir lookup,slba is not the same,it is not a err ,entry may be released
        VAL_FTLC_RCPL_NDATA            = 8'ha0  ,//no flusing ,data and addr is all no valid
        VAL_FTLC_RCPL_P0SAMEERR        = 8'ha1  ,//no flusing /flusing ,pending cnt == 0 and ddr_addr is the same    ,it is     a  err
        VAL_FTLC_RETRY_NWRDS1          = 8'ha2  ,
        VAL_FTLC_RCPL_NOPENDING        = 8'ha3  ,//no flusing /flusing ,pending cnt == 0 and ddr_addr is not the same,it is not a err,the sub_entry have been write or reload
        //VAL_FTLC_REPLY_OK          //no flusing /flusing ,pending cnt != 0 and ddr_addr is     the same, sub_entry will be changed 
        VAL_FTLC_RCPL_PENDING          = 8'ha4  ,//no flusing /flusing ,pending cnt != 0 and ddr_addr is not the same,it is not a err,the sub_entry have been write or reload
        VAL_FTLC_RCPL_LSAMEERR         = 8'ha5  ,//no flusing ,loading          and ddr_addr is     the same         ,it is     a err
        VAL_FTLC_RCPL_LOADING          = 8'ha6  ,//no flusing ,loading          and ddr_addr is not the same
        //VAL_FTLC_RETRY_BUGERR 
        //VAL_FTLC_RETRY_LISTERR 
        VAL_FTLC_RETRY_NOFIND          = 8'ha7  ,
        //////////////////////////////flush and load req bd 's reply st
        //VAL_FTLC_RETRY_LBAERR 
        //VAL_FTLC_REPLY_OK 
        VAL_FTLC_RETRY_NODONE          = 8'ha8  ,
        //VAL_FTLC_RETRY_NDDR 
        //VAL_FTLC_RETRY_TNDDR
        //VAL_FTLC_RETRY_BUGERR 
        //VAL_FTLC_RETRY_LISTERR
        //VAL_FTLC_RETRY_NOFIND
        /////////////////////////////load cpl bd 's reply st
        //VAL_FTLC_RETRY_LBAERR
        VAL_FTLC_RETRY_LDCPLERR        = 8'ha9 ,
        //VAL_FTLC_RETRY_NWRDS1 
        VAL_FTLC_REPLY_OKPE            = 8'haa  ,
        VAL_FTLC_REPLY_OKTE            = 8'hab  ,
        //VAL_FTLC_RETRY_TNDDR 
        VAL_FTLC_RETRY_LDFLERR         = 8'hac  ,
        //VAL_FTLC_RETRY_BUGERR 
        //VAL_FTLC_RETRY_LISTERR 
        //VAL_FTLC_RETRY_NOFIND
        ////////////////////////////flush cpl bd 's reply st
        //VAL_FTLC_RETRY_LBAERR
        VAL_FTLC_RETRY_FLCPLERR        = 8'had  ,
        //VAL_FTLC_RETRY_NWRDS1 
        //VAL_FTLC_REPLY_OKPE 
        //VAL_FTLC_REPLY_OKTE
        //VAL_FTLC_RETRY_TNDDR 
        //VAL_FTLC_RETRY_LDFLERR         = 8'ha4  ,
        //VAL_FTLC_RETRY_BUGERR 
        //VAL_FTLC_RETRY_LISTERR 
        //VAL_FTLC_RETRY_NOFIND 
        ///////////////////////////del16k and delpol bd 's reply st
        //VAL_FTLC_RETRY_TNFTL
        //VAL_FTLC_RETRY_FTLTNDDR
        VAL_FTLC_RETRY_NWDCS1          = 8'hae  ,
        VAL_FTLC_RETRY_NWDEL           = 8'haf  ,
        VAL_LISTST_NWDHS1              = 8'hb0  ,
        //VAL_FTLC_RETRY_NODONE          
        VAL_FTLC_RETRY_NODONE_DELING   = 8'hb1  ,
        VAL_FTLC_RETRY_NODONE_DELFLING = 8'hb2  ,
        VAL_FTLC_RETRY_NODONE_FLING    = 8'hb3  ,
        //VAL_FTLC_RETRY_BUGERR
        VAL_FTLC_REPLY_OK_NHEAD        = 8'hb4  ,
        VAL_FTLC_RETRY_NWDCS2          = 8'hb5  ,
        VAL_FTLC_REPLY_OK_HEAD         = 8'hb6  ,
        //VAL_FTLC_RETRY_LISTERR
        //VAL_FTLC_RETRY_NOFIND
        //added for two direction list
        VAL_LISTST_DCS4                = 8'hb8  , //in dcs4,it will be change to OK_NHEAD,and the deled nxtptr's bak_index will be changed
        VAL_FTLC_RETRY_NWDCS3          = 8'hb9  ,
        VAL_FTLC_RETRY_NWDHS1          = 8'hba  ,
        /////////////////////////pol bd ,it is changed because of two direction list
        VAL_FTLC_POL_NODONE            = 8'hbb  ,

        /////////////////////////the a9 cpl bd unnormal st defination
        VAL_FTLC_A9CPL_PERMAERR        = 8'hbc  ,//the flush /load cpl bd from a9 is data permanent err
        VAL_FTLC_A9CPL_TEMPERR         = 8'hbd  ,//the flush /load cpl bd from a9 is data temp err
        
        ////////////////////////the read wait bd 's st defination,5 new bd_sts is added
        //VAL_FTLC_RETRY_LBAERR           
        VAL_FTLC_RETRY_NORWAIT           = 8'hbe , //st simulation and software related,a readwait bd find the entry is no waitflag.
        VAL_FTLC_RETRY_RWAIT_NODATA      = 8'hbf , //st simulation and software related,a readwait bd find the entry is no data.
        VAL_FTLC_RETRY_RWAIT_ROTHER      = 8'hc0 , //st simulation and software related,a readwait bd find the entry is pendingcnt == 1'b1
        //VAL_FTLC_RETRY_DELBAD    
        //VAL_FTLC_RETRY_BAD          
        //VAL_FTLC_RETRY_DEL          
        //VAL_FTLC_RETRY_FLUSHPENDING  
        //VAL_FTLC_RETRY_BUGERR     
        VAL_FTLC_RETRY_EXCEPTION         = 8'hc1 , //st simulation and software related,a readwait bd 's st become a exception st
        VAL_FTLC_RETRY_RWAIT_MAX         = 8'hc2 , //st simulation and software related,a readwait bd is round max
        //VAL_FTLC_REPLY_OK 
        //VAL_FTLC_RETRY_LOADING
        VAL_FTLC_RETRY_NWOK              = 8'hc3 ,

        ///////////////////////the read bd's new st defination (read wait related ),
        VAL_FTLC_RETRY_NEWLOAD_WAIT      = 8'hc4 , 
        VAL_FTLC_RETRY_RWAITING_ND       = 8'hc5 , //st simulation and software related.when a entry is rwaiting (nodata  ),the new read access it .
        VAL_FTLC_RETRY_PENDING_WAIT      = 8'hc6 ,
        VAL_FTLC_RETRY_RWAITING_P1       = 8'hc7 , //st simulation and software related.when a entry is rwaiting (pcnt=1  ),the new read access it .
        VAL_FTLC_RETRY_LOADING_WAIT      = 8'hc8 , 
        VAL_FTLC_RETRY_RWAITING_LOADING  = 8'hc9 , //st simulation and software related.when a entry is rwaiting (loading ),the new read access it .
        VAL_FTLC_RETRY_ACS2_WAIT         = 8'hca , 
        VAL_FTLC_RETRY_NCS2_WAIT         = 8'hcb ,
        VAL_FTLC_RETRY_NEWHEAD_WAIT      = 8'hcc ,
        VAL_FTLC_RETRY_NEWNHEAD_WAIT     = 8'hcd ,
        ///////////////////////the read bd retry when the a9 is fc ,the read can not gen load or flush
        VAL_FTLC_RETRY_A9BP              = 8'hce , //st simulation and software related.when a9 gives ftlc bp ,the read will be retry
        ///////////////////////the new bd st of read bd or read_wait bd in WFIRST mode
        VAL_FTLC_REPLY_OK_PCNT           = 8'hcf , //
        VAL_FTLC_REPLY_OK_FLPCNT         = 8'hd0 , //
        VAL_FTLC_RETRY_PCNTMAX           = 8'hd1 , //
        ///////////////////////the new bd st of read bd or read_wait bd for allf data
        VAL_FTLC_RDNF                    = 8'hd2 , //st simulation and software related.when the 4k data in cache is allf ,it will be RDNF

        VAL_BST_RSV           = 8'hff
} E_BD_ST ;         //the value for status of message


//msg_status
typedef enum logic [7:0] 
{ 
      
       VAL_MST_REPLY_OK               = 8'h0 ,  
       VAL_MST_REPLY_AUTH_ERROR       = 8'h1 ,
       VAL_MST_REPLY_VER_MISMATCH     = 8'h2 ,
       VAL_MST_RETRY_DELAY            = 8'h3 ,
       VAL_MST_REPLY_CANCEL           = 8'h4 ,
       VAL_MST_REPLY_CRC_ERR          = 8'h5 ,
       VAL_MST_REPLY_OPEN_IMAGE_ERROR = 8'h6 ,
       VAL_MST_REPLY_NOT_FOUND        = 8'h7 ,
       VAL_MST_REPLY_LMT_NO_SPACE     = 8'h8 ,
       VAL_MST_REPLY_ERR              = 8'hff


} E_MSG_ST ;         //the value for status of message

typedef enum logic [7:0] 
{ 

        VAL_MTYP_READ                    = 8'h0 , 
        VAL_MTYP_READ_REPLY              = 8'h1 , 
        VAL_MTYP_WRITE                   = 8'h2 , 
        VAL_MTYP_WRITE_REPLY             = 8'h3 , 
        VAL_MTYP_LOAD_WRITE              = 8'h4 , 
        VAL_MTYP_LOAD_WRITE_REPLY        = 8'h5 , 
        VAL_MTYP_FLUSH_COMPLETE          = 8'h6 , 
        VAL_MTYP_FLUSH_COMPLETE_REPLY    = 8'h7 , 
        VAL_MTYP_CACHE_DELETE            = 8'h8 , 
        VAL_MTYP_CACHE_DELETE_REPLY      = 8'h9 , 
        VAL_MTYP_KEEP_ALIVE              = 8'ha , 
        VAL_MTYP_KEEP_ALIVE_REPLY        = 8'hb , 
        VAL_MTYP_CACHE_FIND              = 8'hc , 
        VAL_MTYP_CACHE_FIND_REPLY        = 8'hd , 
        VAL_MTYP_FLUSH_READ              = 8'he , 
        VAL_MTYP_FLUSH_READ_REPLY        = 8'hf   
        
} USELESS_VALUE1;
///// typedef enum logic [7:0] 
//{ 
//
//       
//        VAL_MST_REPLY_OK               = 4'h0 ,  
//        VAL_MST_REPLY_AUTH_ERROR       = 4'h1 , 
//        VAL_MST_REPLY_VER_MISMATCH     = 4'h2 , 
//        VAL_MST_RETRY_DELAY            = 4'h3 ,  
//        VAL_MST_REPLY_CANCEL           = 4'h4 ,  
//        VAL_MST_REPLY_CRC_ERR          = 4'h5 ,  
//        VAL_MST_REPLY_OPEN_IMAGE_ERROR = 4'h6 ,  
//        VAL_MST_REPLY_NOT_FOUND        = 4'h7 ,  
//        VAL_MST_REPLY_ERR              = 4'hf   
//         
//} USELESS_VALUE2;




typedef enum logic [2:0] 
{ 
        VAL_ACT_WORK              , 
        VAL_ACT_RETRY             , 
        VAL_ACT_DROP                
} E_MSG_ACT;    //the value for action of message

/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
typedef union packed {
        logic [12-1:0]  buf_seq    ;  
        logic [12-1:0]  buf_num    ;  
} U_BUF_SEQ_NUM;

typedef union packed {
        logic [12-1:0]  buf_id     ;  
        logic [12-1:0]  msg_tos    ;  
} U_BUF_ID_TOS;

typedef struct packed {
        E_BD_TYP        bd_typ      ;
        E_BD_ST         bd_st       ;
        logic [12-1:0]  msg_id      ;
        U_BUF_ID_TOS    buf_id_tos  ;  //buf id or msg tos
        U_BUF_SEQ_NUM   buf_seq_num ;  //buf num or buf seqn
        logic [16-1:0]  dat_crc     ;
        logic [16-1:0]  fid         ;
        logic [32-1:0]  trans_id    ;
        logic [08-1:0]  cur_tray_id ;
        logic [08-1:0]  bak_tray_id ;
} S_RX_BD;
parameter RX_BD_WID = $bits(S_RX_BD);   //136b


/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
typedef struct packed {
    E_BD_TYP        bd_typ      ;
    E_BD_ST         bd_st       ;
    logic [32-1:0]  img_id      ;
    logic [40-1:0]  slba        ;
    logic [32-1:0]  snap_seqn   ;
    logic [12-1:0]  msg_id      ;
    U_BUF_ID_TOS    buf_id_tos  ;  //buf id or msg tos
    U_BUF_SEQ_NUM   buf_seq_num ;  //buf num or buf seqn
    logic [02-1:0]  rge_id      ;
    logic [02-1:0]  blk_num     ;
    logic [04-1:0]  msg_tos     ;
    logic [16-1:0]  dat_crc     ;
    logic [04-1:0]  bd_crc      ;
    logic [16-1:0]  fid         ;
    logic [32-1:0]  trans_id    ;
    logic [16-1:0]  hit_time    ;
    logic [08-1:0]  bak_tray_id ;
} S_TRAY_BD;
parameter TRAY_BD_WID = $bits(S_TRAY_BD);  //256b

/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
typedef struct packed {
    E_BD_TYP        bd_typ       ;
    E_BD_ST         bd_st        ;
    logic [12-1:0]  msg_id       ;
    logic [12-1:0]  buf_id       ;
    logic [12-1:0]  buf_seq      ;
    logic [16-1:0]  dat_crc      ;
    logic [16-1:0]  fid          ;
    logic [32-1:0]  trans_id     ;
    logic [08-1:0]  cur_tray_id  ;
    logic [32-1:0]  tcp_seqn     ;
    logic [32-1:0]  tcp_ackn     ;
    logic           flag_rls_msg ;
    logic           flag_rls_buf ;
    logic           flag_drop    ;
    logic           flag_rsnd    ;
} S_TX_BD;
parameter TX_BD_WID = $bits(S_TX_BD);  //144b

typedef struct packed {
        E_BD_TYP        bd_typ      ;
        E_BD_ST         bd_st       ;
        logic [12-1:0]  msg_id      ;
        U_BUF_ID_TOS    buf_id_tos  ;  //buf id or msg tos
        U_BUF_SEQ_NUM   buf_seq_num ;  //buf num or buf seqn
        logic [16-1:0]  dat_crc     ;
        logic [16-1:0]  fid         ;
        logic [32-1:0]  trans_id    ;
        logic [08-1:0]  cur_tray_id ;
        logic [08-1:0]  bak_tray_id ;
        logic [16-1:0]  car_id0     ;
        logic [16-1:0]  car_id1     ;
        logic [16-1:0]  car_id2     ;
        logic [08-1:0]  car_tmp_id0 ;
        logic [08-1:0]  car_tmp_id1 ;
        logic [08-1:0]  car_tmp_id2 ;
        logic [01-1:0]  car_vld     ;
        logic [01-1:0]  bd_car_flag ; //0-permit transmit, 1-forbit
        logic [02-1:0]  bd_car_idx  ; //indicate which car_proc
} S_CAR_BD;
parameter CAR_BD_WID = $bits(S_CAR_BD);   //136b

typedef struct packed {
        logic [01-1:0]  car_vld     ;
        logic [08-1:0]  car_tmp_id2 ;
        logic [08-1:0]  car_tmp_id1 ;
        logic [08-1:0]  car_tmp_id0 ;
        logic [16-1:0]  car_id2     ;
        logic [16-1:0]  car_id1     ;
        logic [16-1:0]  car_id0     ;
} S_CAR_ID_TBL;
parameter CAR_ID_TBL_DWID = $bits(S_CAR_ID_TBL); //73
parameter CAR_ID_TBL_AWID = 16; //73

typedef struct packed {
        logic [16-1:0]  cbs     ;
        logic [16-1:0]  cir     ;
} S_CAR_TMP_TBL;
parameter CAR_TMP_TBL_DWID = $bits(S_CAR_TMP_TBL); //32
parameter CAR_TMP_TBL_AWID = 8; //73

typedef struct packed {
        logic [24-1:0]  hit_time    ;
        logic [24-1:0]  token       ;
} S_CAR_TOKEN_TBL;
parameter CAR_TOKEN_TBL_DWID = $bits(S_CAR_TOKEN_TBL); //48
parameter CAR_TOKEN_TBL_AWID = 16;

typedef struct packed {
    E_BD_TYP        bd_typ          ;
    E_BD_ST         bd_st           ;
    logic [12-1:0]  msg_id          ;
    logic [12-1:0]  buf_id          ;
    logic [12-1:0]  buf_seq         ;
    logic [16-1:0]  dat_crc         ;
    logic [16-1:0]  fid             ;
    logic [32-1:0]  trans_id        ;
    logic [08-1:0]  cur_tray_id     ;
    logic [32-1:0]  tcp_seqn        ;
    logic           flag_rls_msg    ;
    logic           flag_rls_buf    ;
    logic           flag_drop       ;
    logic           flag_rsnd       ;
    logic [32-1:0]  bd_hit_time     ;
    logic [8-1:0]   bd_ack_sent_cnt ;
    logic [8-1:0]   bd_sent_cnt     ;
    logic [1-1:0]   bd_new_flag     ;
    logic [1-1:0]   last_rsd_typ    ;
} S_RSD_BD;
parameter TX_RSD_WID = $bits(S_RSD_BD);  //tx_bd + 50b

typedef struct packed {
        logic [032-1:0]  acked_seqn    ; //bit  255-224
        logic [032-1:0]  tx_seqn       ; //bit  223-192
        logic [032-1:0]  rx_seqn       ; //bit  191-160
        logic [032-1:0]  hit_time      ; //bit  159-128
        logic [016-1:0]  last_rate     ; //bit  127-112
        logic [008-1:0]  bp_rsd_cnt    ; //bit  111-104
        logic [008-1:0]  dup_rsd_cnt   ; //bit  103-096
        logic [008-1:0]  age_rsd_cnt   ; //bit  095-088
        logic [008-1:0]  last_dup_cnt  ; //bit  087-080
        logic [024-1:0]  rls_bd_cnt    ; //bit  079-056
        logic [024-1:0]  tx_bd_cnt     ; //bit  055-032
        logic [016-1:0]  rslt_ssth     ; //bit  031-016
        logic [016-1:0]  rslt_cwnd     ; //bit  015-000
        logic [158-1:0]  rsv           ;
        logic [001-1:0]  rsd_proc_flag ; //bit  353-353
        logic [001-1:0]  timer_vld     ; //bit  352-352
        logic [032-1:0]  rsd_end_seqn  ; //bit  351-320
        logic [016-1:0]  timer         ; //bit  319-304
        logic [016-1:0]  curr_rtt      ; //bit  303-288
        logic [032-1:0]  timer_seqn    ; //bit  287-256
} S_RSD_SEQ_TBL;
parameter RSD_SEQ_TBL_DWID = $bits(S_RSD_SEQ_TBL); //256
parameter RSD_SEQ_TBL_AWID = 8; //73

/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
typedef struct packed {
    logic [01-1:0]  tbl_vld     ;
    E_MSG_ACT       msg_act     ;
    logic [24-1:0]  msg_pos     ;
    logic [24-1:0]  msg_len     ;
    E_BD_TYP        msg_typ     ;
    logic [12-1:0]  msg_id      ;
} S_MOE_TBL ;
parameter    MOE_TBL_AWID = 7                ;
parameter    MOE_TBL_DWID = $bits(S_MOE_TBL) ;



/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
typedef struct packed {
    logic [01-1:0]  tbl_vld     ;
    E_MSG_RX_ST     msg_rx_st   ;
    logic [08-1:0]  msg_typ     ;
    logic [16-1:0]  fid         ;
    logic [32-1:0]  trans_id    ;
    logic [32-1:0]  pool_id     ;
    logic [12-1:0]  dat_len     ;  //4K unit
    logic [32-1:0]  img_id      ;
    logic [40-1:0]  slba        ;
    logic [12-1:0]  nlba        ;
    logic [32-1:0]  snap_seqn   ;
    logic [04-1:0]  blk_num     ;
    logic [03-1:0]  tos         ;
    logic [08-1:0]  cur_tray_id ;
    logic [08-1:0]  bak_tray_id ;
    logic [12-1:0]  buf_id      ;
    logic [24-1:0]  hit_time    ;
    logic [04-1:0]  dat_crc     ;
} S_MSG_RX_TBL;
parameter    MSG_RX_TBL_AWID = 10;
parameter    MSG_RX_TBL_DWID = $bits(S_MSG_RX_TBL); //256b

/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
typedef struct packed {
    logic [01-1:0]  tbl_vld     ;
    logic [08-1:0]  cur_tray_id ;
    logic [08-1:0]  bak_tray_id ;
} S_TRAY_MAP_TBL;
parameter    TRAY_MAP_TBL_AWID = 10;
parameter    TRAY_MAP_TBL_DWID = $bits(S_TRAY_MAP_TBL);

/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
typedef struct packed {
    logic [01-1:0]  tbl_vld     ;
    logic [08-1:0]  hdr_tray_id ;
} S_MSG_TX_TBL;
parameter    MSG_TX_TBL_AWID = 10;
parameter    MSG_TX_TBL_DWID = $bits(S_MSG_TX_TBL);

/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
typedef struct packed {
    logic [01-1:0]  tbl_vld     ;
    logic [01-1:0]  flag_bak_en ;
    logic [10-1:0]  rsv         ;
    E_BD_ST         dist_st     ;
    logic [12-1:0]  dist_num    ;
    logic [12-1:0]  dist_cnt    ;
    logic [12-1:0]  bak_cnt     ;
    logic [08-1:0]  msg_tos     ;
} S_BD_DIST_TBL;
parameter    BD_DIST_TBL_AWID = 10;
parameter    BD_DIST_TBL_DWID = $bits(S_BD_DIST_TBL); //64

/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
typedef struct packed {
    logic [01-1:0]  tbl_vld     ;
    logic [01-1:0]  flag_bak_en ;
    logic [02-1:0]  rsv         ;
    logic [08-1:0]  coll_st     ;
    logic [12-1:0]  coll_num    ;
    logic [12-1:0]  coll_cnt    ;
    logic [12-1:0]  bak_cnt     ;
    logic [08-1:0]  msg_tos     ;
    logic [08-1:0]  tray_id     ;
    logic [12-1:0]  buf_id      ;
} S_BD_COLL_TBL;
parameter    BD_COLL_TBL_AWID = 10;
parameter    BD_COLL_TBL_DWID = $bits(S_BD_COLL_TBL);

/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////
typedef struct packed {
    logic [32-1:0]  wptr        ;
} S_TRAY_WPTR_TBL;
parameter    TRAY_WPTR_TBL_AWID = 9;
parameter    TRAY_WPTR_TBL_DWID = $bits(S_TRAY_WPTR_TBL); //13b

typedef struct packed {
    logic [32-1:0]  rptr        ;
} S_TRAY_RPTR_TBL;
parameter    TRAY_RPTR_TBL_AWID = 9;
parameter    TRAY_RPTR_TBL_DWID = $bits(S_TRAY_RPTR_TBL); //13b

/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////

function automatic logic bd_typ_equ_toe( input E_BD_TYP bd_typ );
        if( bd_typ==VAL_PTYP_PKT_SYN || bd_typ==VAL_PTYP_PKT_ACK 
                || bd_typ==VAL_PTYP_PKT_FIN || bd_typ==VAL_PTYP_PKT_RST  
                || bd_typ==VAL_PTYP_PKT_SYNACK || bd_typ==VAL_PTYP_PKT_FIRST_ACK  
                || bd_typ==VAL_PTYP_PKT_LAST_ACK || bd_typ==VAL_PTYP_PKT_DUP_ACK 
                || bd_typ==VAL_PTYP_DROP_FIRST_ACK 
                || bd_typ==VAL_PTYP_DROP_LAST_ACK
                || bd_typ==VAL_PTYP_AGE_MID
                || bd_typ==VAL_PTYP_AGE_WBD
                || bd_typ==VAL_PTYP_AGE_RBD
                || bd_typ==VAL_PTYP_MOE_RST
        )begin
                return 1'b1;
        end
        else begin
                return 1'b0;
        end
endfunction

function automatic logic bd_typ_equ_hdr( input E_BD_TYP bd_typ );
        if( 
                bd_typ==VAL_PTYP_WRITE_HDR 
                || bd_typ==VAL_PTYP_READ_HDR 
                || bd_typ==VAL_PTYP_WRITE_BAK_HDR 
        )begin
                return 1'b1;
        end
        else begin
                return 1'b0;
        end
endfunction

function automatic logic bd_typ_equ_dat( input E_BD_TYP bd_typ );
        if( 
                bd_typ==VAL_PTYP_WRITE 
                || bd_typ==VAL_PTYP_READ 
        )begin
                return 1'b1;
        end
        else begin
                return 1'b0;
        end
endfunction


function automatic logic bd_typ_equ_bak( input E_BD_TYP bd_typ );
        if( 
                bd_typ==VAL_PTYP_LOADW_BAK 
                || bd_typ==VAL_PTYP_WRITE_BAK
        )begin
                return 1'b1;
        end
        else begin
                return 1'b0;
        end
endfunction


function automatic logic bd_typ_equ_msg( input E_BD_TYP bd_typ );
        if( 
                bd_typ==VAL_PTYP_WRITE_HDR 
                || bd_typ==VAL_PTYP_READ_HDR 
                || bd_typ==VAL_PTYP_WRITE_BAK_HDR 
                || bd_typ==VAL_PTYP_READ 
                || bd_typ==VAL_PTYP_WRITE 
                || bd_typ==VAL_PTYP_WRITE_BAK
        )begin
                return 1'b1;
        end
        else begin
                return 1'b0;
        end
endfunction

function automatic E_BD_TYP bd_typ_changeto_dat( input E_BD_TYP bd_typ );
        if( 
                bd_typ==VAL_PTYP_WRITE_HDR 
        )begin
                return VAL_PTYP_WRITE;
        end
        else if( 
                bd_typ==VAL_PTYP_READ_HDR 
        )begin
                return VAL_PTYP_READ;
        end
        else if( 
                bd_typ==VAL_PTYP_WRITE_BAK_HDR 
        )begin
                return VAL_PTYP_WRITE_BAK;
        end
        else begin
                return bd_typ;
        end
endfunction

function automatic logic bd_typ_equ_car( input E_BD_TYP bd_typ );
    if(  bd_typ==VAL_PTYP_READ_HDR
      || bd_typ==VAL_PTYP_WRITE_HDR
      || bd_typ==VAL_PTYP_WRITE_BAK_HDR
      || bd_typ==VAL_PTYP_LOAD_WRITE_HDR
      || bd_typ==VAL_PTYP_FLUSH_READ_HDR
    )begin
        return 1'b1;
    end
    else begin
        return 1'b0;
    end
endfunction

function automatic logic bd_st_error( input E_BD_ST bd_st );
    if(  bd_st==VAL_BST_MAGIC_ERR 
      || bd_st==VAL_BST_DAT_LEN_ERR
      || bd_st==VAL_BST_MSG_TYP_ERR
      || bd_st==VAL_BST_WR_LEN_ERR 
      || bd_st==VAL_BST_RD_NLBA_ERR
    )begin
        return 1'b1;
    end
    else begin
        return 1'b0;
    end
endfunction

//function integer addr_idx;
//        //input [CBUS_AWID-1:0] addr;
//        input logic[16-1:0    ] addr     ;
//        input logic[16*256-1:0] reg_addr ;
//        input logic[16-1:0    ] reg_num  ;
//        integer          i;
//        begin
//                addr_idx='h0;
//                for( i=0; i<reg_num; i=i+1 )begin
//                        if( reg_addr[i*16+:16]==addr[16-1:0] )begin
//                                //addr_idx=i;
//                                return i;
//                        end
//                end
//        end
//endfunction


function automatic logic bd_typ_att_dat( input E_BD_TYP bd_typ );
    if(  bd_typ==VAL_PTYP_WRITE
      || bd_typ==VAL_PTYP_LOAD_WRITE
    )begin
        return 1'b1;
    end
    else begin
        return 1'b0;
    end
endfunction

function automatic logic bd_toe_to_cpu( input E_BD_TYP bd_typ );
        if( //bd_typ==VAL_PTYP_PKT_SYN || bd_typ==VAL_PTYP_PKT_ACK 
//          || bd_typ==VAL_PTYP_PKT_FIN || bd_typ==VAL_PTYP_PKT_RST  
//          || bd_typ==VAL_PTYP_PKT_SYNACK || bd_typ==VAL_PTYP_PKT_FIRST_ACK  
//          || bd_typ==VAL_PTYP_PKT_LAST_ACK || bd_typ==VAL_PTYP_PKT_DUP_ACK 
               bd_typ==VAL_PTYP_DROP_FIRST_ACK || bd_typ==VAL_PTYP_DROP_LAST_ACK
//          || bd_typ==VAL_PTYP_AGE_MID
//          || bd_typ==VAL_PTYP_AGE_WBD
//          || bd_typ==VAL_PTYP_AGE_RBD
        )begin
                return 1'b1;
        end
        else begin
                return 1'b0;
        end
endfunction
function automatic logic bd_lmt_to_cpu( input E_BD_TYP bd_typ );
        if(bd_typ==VAL_PTYP_LMT_NEW_4M || bd_typ==VAL_PTYP_LMT_DELETE_4M   
        )begin
                return 1'b1;
        end
        else begin
                return 1'b0;
        end
endfunction

function automatic logic[3:0] gen_bd_crc( input logic[256-1:0] tray_bd );
        gen_bd_crc[0] = tray_bd[000*4+00+0] ^ tray_bd[000*4+64+0] ^ tray_bd[000*4+128+0] ^ tray_bd[000*4+192+0] ^ 
                        tray_bd[001*4+00+0] ^ tray_bd[001*4+64+0] ^ tray_bd[001*4+128+0] ^ tray_bd[001*4+192+0] ^ 
                        tray_bd[002*4+00+0] ^ tray_bd[002*4+64+0] ^ tray_bd[002*4+128+0] ^ tray_bd[002*4+192+0] ^ 
                        tray_bd[003*4+00+0] ^ tray_bd[003*4+64+0] ^ tray_bd[003*4+128+0] ^ tray_bd[003*4+192+0] ^ 
                        tray_bd[004*4+00+0] ^ tray_bd[004*4+64+0] ^ tray_bd[004*4+128+0] ^ tray_bd[004*4+192+0] ^ 
                        tray_bd[005*4+00+0] ^ tray_bd[005*4+64+0] ^ tray_bd[005*4+128+0] ^ tray_bd[005*4+192+0] ^ 
                        tray_bd[006*4+00+0] ^ tray_bd[006*4+64+0] ^ tray_bd[006*4+128+0] ^ tray_bd[006*4+192+0] ^ 
                        tray_bd[007*4+00+0] ^ tray_bd[007*4+64+0] ^ tray_bd[007*4+128+0] ^ tray_bd[007*4+192+0] ^ 
                        tray_bd[008*4+00+0] ^ tray_bd[008*4+64+0] ^ tray_bd[008*4+128+0] ^ tray_bd[008*4+192+0] ^ 
                        tray_bd[009*4+00+0] ^ tray_bd[009*4+64+0] ^ tray_bd[009*4+128+0] ^ tray_bd[009*4+192+0] ^ 
                        tray_bd[010*4+00+0] ^ tray_bd[010*4+64+0] ^ tray_bd[010*4+128+0] ^ tray_bd[010*4+192+0] ^ 
                        tray_bd[011*4+00+0] ^ tray_bd[011*4+64+0] ^ tray_bd[011*4+128+0] ^ tray_bd[011*4+192+0] ^ 
                        tray_bd[012*4+00+0] ^ tray_bd[012*4+64+0] ^ tray_bd[012*4+128+0] ^ tray_bd[012*4+192+0] ^ 
                        tray_bd[013*4+00+0] ^ tray_bd[013*4+64+0] ^ tray_bd[013*4+128+0] ^ tray_bd[013*4+192+0] ^ 
                        tray_bd[014*4+00+0] ^ tray_bd[014*4+64+0] ^ tray_bd[014*4+128+0] ^ tray_bd[014*4+192+0] ^ 
                        tray_bd[015*4+00+0] ^ tray_bd[015*4+64+0] ^ tray_bd[015*4+128+0] ^ tray_bd[015*4+192+0] ; 
 
        gen_bd_crc[1] = tray_bd[000*4+00+1] ^ tray_bd[000*4+64+1] ^ tray_bd[000*4+128+1] ^ tray_bd[000*4+192+1] ^ 
                        tray_bd[001*4+00+1] ^ tray_bd[001*4+64+1] ^ tray_bd[001*4+128+1] ^ tray_bd[001*4+192+1] ^ 
                        tray_bd[002*4+00+1] ^ tray_bd[002*4+64+1] ^ tray_bd[002*4+128+1] ^ tray_bd[002*4+192+1] ^ 
                        tray_bd[003*4+00+1] ^ tray_bd[003*4+64+1] ^ tray_bd[003*4+128+1] ^ tray_bd[003*4+192+1] ^ 
                        tray_bd[004*4+00+1] ^ tray_bd[004*4+64+1] ^ tray_bd[004*4+128+1] ^ tray_bd[004*4+192+1] ^ 
                        tray_bd[005*4+00+1] ^ tray_bd[005*4+64+1] ^ tray_bd[005*4+128+1] ^ tray_bd[005*4+192+1] ^ 
                        tray_bd[006*4+00+1] ^ tray_bd[006*4+64+1] ^ tray_bd[006*4+128+1] ^ tray_bd[006*4+192+1] ^ 
                        tray_bd[007*4+00+1] ^ tray_bd[007*4+64+1] ^ tray_bd[007*4+128+1] ^ tray_bd[007*4+192+1] ^ 
                        tray_bd[008*4+00+1] ^ tray_bd[008*4+64+1] ^ tray_bd[008*4+128+1] ^ tray_bd[008*4+192+1] ^ 
                        tray_bd[009*4+00+1] ^ tray_bd[009*4+64+1] ^ tray_bd[009*4+128+1] ^ tray_bd[009*4+192+1] ^ 
                        tray_bd[010*4+00+1] ^ tray_bd[010*4+64+1] ^ tray_bd[010*4+128+1] ^ tray_bd[010*4+192+1] ^ 
                        tray_bd[011*4+00+1] ^ tray_bd[011*4+64+1] ^ tray_bd[011*4+128+1] ^ tray_bd[011*4+192+1] ^ 
                        tray_bd[012*4+00+1] ^ tray_bd[012*4+64+1] ^ tray_bd[012*4+128+1] ^ tray_bd[012*4+192+1] ^ 
                        tray_bd[013*4+00+1] ^ tray_bd[013*4+64+1] ^ tray_bd[013*4+128+1] ^ tray_bd[013*4+192+1] ^ 
                        tray_bd[014*4+00+1] ^ tray_bd[014*4+64+1] ^ tray_bd[014*4+128+1] ^ tray_bd[014*4+192+1] ^ 
                        tray_bd[015*4+00+1] ^ tray_bd[015*4+64+1] ^ tray_bd[015*4+128+1] ^ tray_bd[015*4+192+1] ; 
         
        gen_bd_crc[2] = tray_bd[000*4+00+2] ^ tray_bd[000*4+64+2] ^ tray_bd[000*4+128+2] ^ tray_bd[000*4+192+2] ^ 
                        tray_bd[001*4+00+2] ^ tray_bd[001*4+64+2] ^ tray_bd[001*4+128+2] ^ tray_bd[001*4+192+2] ^ 
                        tray_bd[002*4+00+2] ^ tray_bd[002*4+64+2] ^ tray_bd[002*4+128+2] ^ tray_bd[002*4+192+2] ^ 
                        tray_bd[003*4+00+2] ^ tray_bd[003*4+64+2] ^ tray_bd[003*4+128+2] ^ tray_bd[003*4+192+2] ^ 
                        tray_bd[004*4+00+2] ^ tray_bd[004*4+64+2] ^ tray_bd[004*4+128+2] ^ tray_bd[004*4+192+2] ^ 
                        tray_bd[005*4+00+2] ^ tray_bd[005*4+64+2] ^ tray_bd[005*4+128+2] ^ tray_bd[005*4+192+2] ^ 
                        tray_bd[006*4+00+2] ^ tray_bd[006*4+64+2] ^ tray_bd[006*4+128+2] ^ tray_bd[006*4+192+2] ^ 
                        tray_bd[007*4+00+2] ^ tray_bd[007*4+64+2] ^ tray_bd[007*4+128+2] ^ tray_bd[007*4+192+2] ^ 
                        tray_bd[008*4+00+2] ^ tray_bd[008*4+64+2] ^ tray_bd[008*4+128+2] ^ tray_bd[008*4+192+2] ^ 
                        tray_bd[009*4+00+2] ^ tray_bd[009*4+64+2] ^ tray_bd[009*4+128+2] ^ tray_bd[009*4+192+2] ^ 
                        tray_bd[010*4+00+2] ^ tray_bd[010*4+64+2] ^ tray_bd[010*4+128+2] ^ tray_bd[010*4+192+2] ^ 
                        tray_bd[011*4+00+2] ^ tray_bd[011*4+64+2] ^ tray_bd[011*4+128+2] ^ tray_bd[011*4+192+2] ^ 
                        tray_bd[012*4+00+2] ^ tray_bd[012*4+64+2] ^ tray_bd[012*4+128+2] ^ tray_bd[012*4+192+2] ^ 
                        tray_bd[013*4+00+2] ^ tray_bd[013*4+64+2] ^ tray_bd[013*4+128+2] ^ tray_bd[013*4+192+2] ^ 
                        tray_bd[014*4+00+2] ^ tray_bd[014*4+64+2] ^ tray_bd[014*4+128+2] ^ tray_bd[014*4+192+2] ^ 
                        tray_bd[015*4+00+2] ^ tray_bd[015*4+64+2] ^ tray_bd[015*4+128+2] ^ tray_bd[015*4+192+2] ; 
         
        gen_bd_crc[3] = tray_bd[000*4+00+3] ^ tray_bd[000*4+64+3] ^ tray_bd[000*4+128+3] ^ tray_bd[000*4+192+3] ^ 
                        tray_bd[001*4+00+3] ^ tray_bd[001*4+64+3] ^ tray_bd[001*4+128+3] ^ tray_bd[001*4+192+3] ^ 
                        tray_bd[002*4+00+3] ^ tray_bd[002*4+64+3] ^ tray_bd[002*4+128+3] ^ tray_bd[002*4+192+3] ^ 
                        tray_bd[003*4+00+3] ^ tray_bd[003*4+64+3] ^ tray_bd[003*4+128+3] ^ tray_bd[003*4+192+3] ^ 
                        tray_bd[004*4+00+3] ^ tray_bd[004*4+64+3] ^ tray_bd[004*4+128+3] ^ tray_bd[004*4+192+3] ^ 
                        tray_bd[005*4+00+3] ^ tray_bd[005*4+64+3] ^ tray_bd[005*4+128+3] ^ tray_bd[005*4+192+3] ^ 
                        tray_bd[006*4+00+3] ^ tray_bd[006*4+64+3] ^ tray_bd[006*4+128+3] ^ tray_bd[006*4+192+3] ^ 
                        tray_bd[007*4+00+3] ^ tray_bd[007*4+64+3] ^ tray_bd[007*4+128+3] ^ tray_bd[007*4+192+3] ^ 
                        tray_bd[008*4+00+3] ^ tray_bd[008*4+64+3] ^ tray_bd[008*4+128+3] ^ tray_bd[008*4+192+3] ^ 
                        tray_bd[009*4+00+3] ^ tray_bd[009*4+64+3] ^ tray_bd[009*4+128+3] ^ tray_bd[009*4+192+3] ^ 
                        tray_bd[010*4+00+3] ^ tray_bd[010*4+64+3] ^ tray_bd[010*4+128+3] ^ tray_bd[010*4+192+3] ^ 
                        tray_bd[011*4+00+3] ^ tray_bd[011*4+64+3] ^ tray_bd[011*4+128+3] ^ tray_bd[011*4+192+3] ^ 
                        tray_bd[012*4+00+3] ^ tray_bd[012*4+64+3] ^ tray_bd[012*4+128+3] ^ tray_bd[012*4+192+3] ^ 
                        tray_bd[013*4+00+3] ^ tray_bd[013*4+64+3] ^ tray_bd[013*4+128+3] ^ tray_bd[013*4+192+3] ^ 
                        tray_bd[014*4+00+3] ^ tray_bd[014*4+64+3] ^ tray_bd[014*4+128+3] ^ tray_bd[014*4+192+3] ^ 
                        tray_bd[015*4+00+3] ^ tray_bd[015*4+64+3] ^ tray_bd[015*4+128+3] ^ tray_bd[015*4+192+3] ; 
endfunction


endpackage : nic_top_define


