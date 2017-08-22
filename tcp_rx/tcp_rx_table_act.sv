import nic_top_define::*;
import toe_top_define::*;
`timescale 1ns / 1ps
module tcp_rx_table_act #(
        parameter    PDWID        = 128       ,       
        parameter    PDSZ         = 4           ,       
        parameter    REQ_WID      = 12         ,     
        parameter    REQ_SZ       = 1         ,     
        parameter    RSLT_SZ    = 2          ,     
        parameter    UPDATE_WID   = 256       ,     
        parameter    UPDATE_SZ    = 2          ,     
        parameter    TAB_INFO_WID = 16         ,     
        parameter    TAB_AWID     = 8           ,       
        parameter    TAB_DWID     = 128          ,       
        parameter    LOOP_FIFO_AWID = 9          ,       
        parameter    DBG_WID      = 32          
) (
        input  wire          clk        ,
        input   wire        rst        ,
        if_tcp_reg_toe.sink u_if_tcp_reg_toe        ,
        if_dbg_reg_toe      u_if_dbg_reg_toe        ,
        input   wire              fptr_fifo_naempty ,           
        input   wire              out_pkt_rdy       ,           
        input   wire [1-1:0]       sync_msg_vld      ,           
        output  wire [1-1:0]       sync_msg_rdy      ,           
        input   wire [TAB_INFO_WID-1:0]   sync_msg_dat      ,           
        input   wire [1-1:0]        sync_rslt_vld      ,           
        output  wire [1-1:0]        sync_rslt_rdy      ,           
        input   wire [TAB_DWID-1:0] sync_rslt_dat      ,           
        input   wire [1-1:0]        sync_pd_vld      ,           
        output  wire [1-1:0]        sync_pd_rdy      ,           
        input   wire [PDWID-1:0]    sync_pd_dat      ,           
        output  reg  [1-1:0]        out_pd_vld      ,           
        input   wire [1-1:0]        out_pd_rdy      ,           
        input   wire [6-1:0]        ec_msg_fifo_cnt_used , 
        input   wire [1-1:0]        out_pmem_rdy    ,           
        output  reg  [PDWID-1:0]    out_pd_dat      ,           
        output  reg     [1-1:0]     out_ack_vld      ,           
        input   wire    [1-1:0]     out_ack_rdy      ,           
        output  S_TX_BD             out_ack_dat      ,           
        output   reg  [1-1:0]       loop_pd_vld      ,           
        input    wire [1-1:0]       loop_pd_rdy      ,           
        output   reg  [PDWID-1:0]   loop_pd_dat      ,           
        input    wire [LOOP_FIFO_AWID:0]   loop_fifo_cnt_free      ,  
        output  reg  [1-1:0]       tab_wr_fifo_wen     ,           
        input   wire [1-1:0]       tab_wr_fifo_nafull     ,           
        output   reg  [TAB_AWID-1:0]     tab_wr_fifo_wdata     ,           
        output   reg  [1-1:0]       tab_wdat_fifo_wen     ,           
        input   wire [1-1:0]       tab_wdat_fifo_nafull     ,           
        output   reg  [TAB_DWID-1:0]     tab_wdat_fifo_wdata     ,           
        input   wire [31:0]       gbl_sec_cnt       ,           
        input   wire [47:0]       cfg_sys_mac0       ,           
        input   wire [47:0]       cfg_sys_mac1       ,           
        input   wire [31:0]       cfg_sys_ip0       ,           
        input   wire [31:0]       cfg_sys_ip1       ,           
        input   wire [15:0]       cfg_toe_port0     ,           
        input   wire [15:0]       cfg_toe_port1     ,           
        input   wire [31:0]       cfg_tcp_age_time   ,           
        input   wire [31:0]       cfg_moe_bd_th     ,           
        input   S_MOE_RX_FIFO_ST  moe_rx_fifo_st     ,
        input   wire [15:0]         cnt_read_bd_num     ,
        output   wire [32*2-1:0]     dbg_sig1        ,               
        output   wire [DBG_WID-1:0]     dbg_sig               
);
localparam  VAL_TBL_ACT_NEW    = 0 ;
localparam  VAL_TBL_ACT_DEL    = 1 ;
localparam  VAL_TBL_ACT_UPDATE  = 2 ;
localparam  VAL_TBL_ACT_NUL    = 3 ;
localparam  VAL_TBL_ACT_UPDATE_ACK  = 4 ;
wire  [15:0]  cfg_write_bd_th;
wire  [15:0]  cfg_read_bd_th;
reg    [003  :000]    new_pd_fwd        ;
reg    [007  :000]    new_pd_opcode     ;
reg    [007  :000]    new_pd_ptyp       ;
reg    [000  :000]    new_pd_rls_flag   ;
reg    [015  :000]    new_pd_tcp_fid    ;
reg    [007  :000]    new_pd_ip_ttl     ;
logic                 drop_pkt_rdy      ;
`include "common_define_value.v"
wire  [1-1:0]     total_pd_vld ;
wire  [PDWID*PDSZ-1:0]   total_pd_dat ;
fix_cpkt_unf #(
        .DWID      ( PDWID    ),
        .CELL_SZ    ( PDSZ       ),
        .CELL_GAP    ( PDSZ       )
)inst_pd_unf(
        .clk         ( clk      ), 
        .rst        ( rst       ),
        .cpkt_vld     ( sync_pd_vld    ),  
        .cpkt_dat     ( sync_pd_dat    ),  
        .total_cpkt_vld ( total_pd_vld    ), 
        .total_cpkt_dat ( total_pd_dat    )
);
`include "pkt_des_unpack.v"
wire [TAB_DWID*RSLT_SZ-1:0] total_rslt_dat;
fix_cpkt_unf #(
        .DWID      ( TAB_DWID  ),
        .CELL_SZ    ( RSLT_SZ   ),
        .CELL_GAP    ( PDSZ       )
)inst_rslt_unf(
        .clk         ( clk      ), 
        .rst        ( rst       ),
        .cpkt_vld     ( sync_rslt_vld    ),  
        .cpkt_dat     ( sync_rslt_dat    ),  
        .total_cpkt_vld ( total_rslt_vld    ), 
        .total_cpkt_dat ( total_rslt_dat    )
);



wire  [001 -1:000] tcp_rx_table_vld            ;
wire  [001 -1:000] tcp_rx_table_syn            ;
wire  [001 -1:000] tcp_rx_table_synack        ;
wire  [001 -1:000] tcp_rx_table_ack            ;
wire  [001 -1:000] tcp_rx_table_fin            ;
wire  [001 -1:000] tcp_rx_table_rst            ;
wire  [004 -1:000] tcp_rx_table_win_scale      ;
wire  [008 -1:000] tcp_rx_table_outorder_cnt   ;
wire  [016 -1:000] tcp_rx_table_rx_pkt_hittm  ;
wire  [032 -1:000] tcp_rx_table_key_sip          ;
wire  [016 -1:000] tcp_rx_table_key_sp          ;
wire  [048 -1:000] tcp_rx_table_key_smac        ;
wire  [032 -1:000] tcp_rx_table_ini_remote_seq    ;
wire  [032 -1:000] tcp_rx_table_exp_remote_seq    ;
wire  [032 -1:000] tcp_rx_table_rcv_local_ackn    ;
wire  [016 -1:000] tcp_rx_table_rcv_remote_win    ;
wire  [004 -1:000] tcp_rx_table_snd_dup_ack_cnt    ; 
wire  [004 -1:000] tcp_rx_table_rcv_dup_ack_cnt    ; 
wire  [008 -1:000] tcp_rx_table_rcv_local_win         ;



reg   [001 -1:000] new_rx_table_vld            ;
reg   [001 -1:000] new_rx_table_syn            ;
reg   [001 -1:000] new_rx_table_synack        ;
reg   [001 -1:000] new_rx_table_ack            ;
reg   [001 -1:000] new_rx_table_fin            ;
reg   [001 -1:000] new_rx_table_rst            ;
reg   [004 -1:000] new_rx_table_win_scale      ;
reg   [008 -1:000] new_rx_table_outorder_cnt   ;
reg   [016 -1:000] new_rx_table_rx_pkt_hittm  ;
reg   [032 -1:000] new_rx_table_key_sip          ;
reg   [016 -1:000] new_rx_table_key_sp          ;
reg   [048 -1:000] new_rx_table_key_smac        ;
reg   [032 -1:000] new_rx_table_ini_remote_seq    ;
reg   [032 -1:000] new_rx_table_exp_remote_seq    ;
reg   [032 -1:000] new_rx_table_rcv_local_ackn    ;
reg   [016 -1:000] new_rx_table_rcv_remote_win    ;
reg   [004 -1:000] new_rx_table_snd_dup_ack_cnt    ; 
reg   [004 -1:000] new_rx_table_rcv_dup_ack_cnt    ; 
reg   [008 -1:000] new_rx_table_rcv_local_win     ;

assign tcp_rx_table_vld                    = total_rslt_dat[ TAB_DWID*1+127 +: 001 ];
assign tcp_rx_table_syn                    = tcp_rx_table_vld;
assign tcp_rx_table_ack                    = total_rslt_dat[ TAB_DWID*1+126 +: 001 ];
assign tcp_rx_table_fin                    = total_rslt_dat[ TAB_DWID*1+125 +: 001 ];
assign tcp_rx_table_rst                    = total_rslt_dat[ TAB_DWID*1+124 +: 001 ];
assign tcp_rx_table_win_scale              = total_rslt_dat[ TAB_DWID*1+120 +: 004 ];
assign tcp_rx_table_outorder_cnt           = total_rslt_dat[ TAB_DWID*1+112 +: 008 ];
assign tcp_rx_table_rx_pkt_hittm           = total_rslt_dat[ TAB_DWID*1+096 +: 016 ];
assign tcp_rx_table_key_sip                = total_rslt_dat[ TAB_DWID*1+064 +: 032 ];
assign tcp_rx_table_key_sp                 = total_rslt_dat[ TAB_DWID*1+048 +: 016 ];

assign tcp_rx_table_key_smac               = total_rslt_dat[ TAB_DWID*1+000 +: 048 ];
assign tcp_rx_table_ini_remote_seq         = total_rslt_dat[ TAB_DWID*0+096 +: 032 ];
assign tcp_rx_table_exp_remote_seq         = total_rslt_dat[ TAB_DWID*0+064 +: 032 ];
assign tcp_rx_table_rcv_local_ackn         = total_rslt_dat[ TAB_DWID*0+032 +: 032 ];   
assign tcp_rx_table_rcv_remote_win         = total_rslt_dat[ TAB_DWID*0+016 +: 016 ];   

assign tcp_rx_table_snd_dup_ack_cnt        = total_rslt_dat[ TAB_DWID*0+012 +: 004 ];   
assign tcp_rx_table_rcv_dup_ack_cnt        = total_rslt_dat[ TAB_DWID*0+008 +: 004 ];   
assign tcp_rx_table_rcv_local_win          = total_rslt_dat[ TAB_DWID*0+000 +: 008 ];  
  
wire  [1-1:0]       total_info_vld ;
wire  [TAB_INFO_WID-1:0]   total_info_dat ;
wire  [14-1:0]       info_rslt_fid ;
wire  [ 1-1:0]       info_rslt_vld ;
fix_cpkt_unf #(
        .DWID      ( TAB_INFO_WID  ),
        .CELL_SZ    ( 1         ),
        .CELL_GAP    ( PDSZ       )
)inst_info_unf(
        .clk         ( clk      ), 
        .rst        ( rst       ),
        .cpkt_vld     ( sync_msg_vld    ),  
        .cpkt_dat     ( sync_msg_dat    ),  
        .total_cpkt_vld ( total_info_vld    ), 
        .total_cpkt_dat ( total_info_dat    )
);
assign  info_rslt_fid   = total_info_dat[15:2] ; 
assign  info_rslt_vld   = total_info_dat[1]    ;
assign  info_pd_vld     = total_info_dat[0]    ;
reg  [47:0]       nic_mac     ;           
reg  [31:0]       nic_ip       ;           
reg  [15:0]       nic_port     ;           
always @ ( * ) begin
        if( pd_chn_id[3:0]==0 ) begin
                nic_mac  = cfg_sys_mac0  ;
                nic_ip   = cfg_sys_ip0   ;
                nic_port = cfg_toe_port0 ;
        end
        else if( pd_chn_id[3:0]==1 ) begin
                nic_mac  = cfg_sys_mac1  ;
                nic_ip   = cfg_sys_ip1   ;
                nic_port = cfg_toe_port1 ;
        end
        else begin
                nic_mac  = cfg_sys_mac1  ;
                nic_ip   = cfg_sys_ip1   ;
                nic_port = cfg_toe_port1 ;
        end
end
reg      flag_sess_vld    ;
reg      flag_sess_hit    ;
reg      flag_seq_hit    ;
reg      flag_seq_less1  ;
reg      flag_seq_hit_win    ;
reg      flag_seq_out_order  ;
reg      flag_seq_miss  ;  
reg      flag_cpu_syn    ;
reg      flag_cpu_fin    ;
reg      flag_pkt_syn    ;
reg      flag_pkt_ack    ;
reg      flag_pkt_dat    ;
reg      flag_pkt_fin    ;
reg      flag_pkt_rst    ;
reg      flag_pkt_ack_inc;
reg  [15:0]  tcp_payload_len         ;
wire      add_reorder_cnt ;
wire      sub_reorder_cnt ;
reg [7:0] reorder_cnt     ;
reg [7:0] reorder_cnt_reg ;
always@(posedge clk or posedge rst ) begin
        if( rst==1'b1 )begin
                flag_sess_vld    <= 1'b0  ; 
                flag_sess_hit    <= 1'b0  ; 
                flag_seq_hit    <= 1'b0  ; 
                flag_seq_less1  <= 1'b0  ; 
                flag_seq_hit_win    <= 1'b0  ; 
                flag_seq_out_order    <= 1'b0  ; 
                flag_seq_miss  <= 1'b0  ; 
                flag_cpu_syn    <= 1'b0  ; 
                flag_cpu_fin     <= 1'b0  ; 
                flag_pkt_syn     <= 1'b0  ; 
                flag_pkt_fin     <= 1'b0  ; 
                flag_pkt_rst     <= 1'b0  ; 
                flag_pkt_ack     <= 1'b0  ; 
                flag_pkt_ack_inc<= 1'b0  ; 
                flag_pkt_dat     <= 1'b0  ; 
                tcp_payload_len         <= 0     ; 
        end
        else begin
                flag_sess_vld    <= ( (pd_chn_id[1:0]==2'h2||pd_chn_id[1:0]==2'h3) || (pd_fwd==VAL_FWD_TBD && pd_ip_prtl==VAL_PRTL_TCP && pd_tcp_dp[15:14]==nic_port[15:14]) ) ? 1'b1 : 1'b0;
                flag_sess_hit    <= ( (pd_chn_id[1:0]==2'h2||pd_chn_id[1:0]==2'h3)
                        ||( pd_fwd==VAL_FWD_TBD && pd_ip_prtl==VAL_PRTL_TCP 
                                && tcp_rx_table_vld==1'b1
                                && pd_smac==tcp_rx_table_key_smac
                                && pd_ip_sip==tcp_rx_table_key_sip
                                && pd_ip_dip==nic_ip
                                && pd_tcp_sp==tcp_rx_table_key_sp
                                && pd_tcp_dp=={nic_port[15:14], pd_tcp_fid[13:0]} 
                        ) ) ? 1'b1 : 1'b0  ;
                        flag_seq_hit    <= ( (pd_chn_id[1:0]==2'h2||pd_chn_id[1:0]==2'h3) || pd_tcp_seqn==tcp_rx_table_exp_remote_seq ) ? 1'b1 : 1'b0;
                        flag_seq_less1  <= ( (pd_chn_id[1:0]==2'h2||pd_chn_id[1:0]==2'h3) || pd_tcp_seqn==(tcp_rx_table_exp_remote_seq-1'b1) ) ? 1'b1 : 1'b0;
                        flag_seq_hit_win    <= ( (pd_chn_id[1:0]==2'h2||pd_chn_id[1:0]==2'h3) || (pd_tcp_seqn-tcp_rx_table_exp_remote_seq)<32'hf000 || (tcp_rx_table_exp_remote_seq-pd_tcp_seqn)<32'hf000 ) ? 1'b1 : 1'b0;
                        flag_seq_out_order  <= ( flag_sess_vld==1'b1 && pd_fwd==VAL_FWD_TBD && u_if_tcp_reg_toe.cfg_toe_mode_reorder==1'b0 && (pd_chn_id[1:0]==2'h0||pd_chn_id[1:0]==2'h1) && reorder_cnt_reg<8'd20 
                        && tcp_payload_len!='0 && (pd_tcp_seqn!=tcp_rx_table_exp_remote_seq) && (pd_tcp_seqn-tcp_rx_table_exp_remote_seq)<32'h4000 && pd_ip_ttl>8'h1) ? 1'b1 : 1'b0;
                        flag_seq_miss  <= ( pd_tcp_seqn!=tcp_rx_table_exp_remote_seq ) ? 1'b1 : 1'b0; 
                        flag_cpu_syn    <= flag_pkt_syn;
                        flag_cpu_fin     <= flag_pkt_fin;
                        flag_pkt_syn     <= ( pd_fwd==VAL_FWD_TBD && pd_ip_prtl==VAL_PRTL_TCP && {pd_tcp_urg, pd_tcp_ack, pd_tcp_psh, pd_tcp_rst, pd_tcp_syn, pd_tcp_fin}==6'h02 
                        && flag_sess_vld==1'b1 ) ? 1'b1 : 1'b0;
                        flag_pkt_fin     <= ( pd_fwd==VAL_FWD_TBD && pd_ip_prtl==VAL_PRTL_TCP && pd_tcp_fin==1'b1 
                        && flag_sess_hit==1'b1 && (flag_seq_hit==1'b1||(tcp_rx_table_fin==1'b1 && flag_seq_less1==1'b1)) ) ? 1'b1 : 1'b0;  
                        flag_pkt_rst     <= ( pd_fwd==VAL_FWD_TBD && pd_ip_prtl==VAL_PRTL_TCP && pd_tcp_rst==1'b1 
                        && flag_sess_hit==1'b1 && flag_seq_hit==1'b1 ) ? 1'b1 : 1'b0;
                        flag_pkt_ack     <= ( pd_fwd==VAL_FWD_TBD && pd_ip_prtl==VAL_PRTL_TCP && {pd_tcp_urg, pd_tcp_ack, pd_tcp_psh, pd_tcp_rst, pd_tcp_syn, pd_tcp_fin}==6'h10 
                        && flag_sess_vld==1'b1 && (flag_seq_hit==1'b1||flag_seq_hit_win==1'b1) && pd_ip_len==({10'h0,pd_ip_ihl[3:0],2'h0} + {10'h0,pd_tcp_do[3:0],2'h0}) ) ? 1'b1 : 1'b0;
                        flag_pkt_ack_inc <= ((new_rx_table_rcv_local_ackn - tcp_rx_table_rcv_local_ackn) == 32'h1) ? 1'b1 : 1'b0;
                        flag_pkt_dat     <= ( pd_fwd==VAL_FWD_TBD && pd_ip_prtl==VAL_PRTL_TCP && {pd_tcp_urg, pd_tcp_ack, pd_tcp_psh, pd_tcp_rst, pd_tcp_syn, pd_tcp_fin}==6'h10 
                        && flag_sess_vld==1'b1 && flag_seq_hit==1'b1 && pd_ip_len>({10'h0,pd_ip_ihl[3:0],2'h0} + {10'h0,pd_tcp_do[3:0],2'h0}) ) ? 1'b1 : 1'b0;
                        tcp_payload_len         <= ( pd_ip_len-({10'h0,pd_ip_ihl[3:0],2'h0} + {10'h0,pd_tcp_do[3:0],2'h0}) );
                end
        end
        reg   [3:0]   tbl_act    ;
        reg   [3:0]  tbl_act_reg  ;
        wire          flag_tcp_age ;
        reg           flag_app_rdy ;
        reg           flag_loop_rdy ;
        reg           flag_app_bp  ; 
        always @ ( posedge clk or posedge rst ) begin
                if( rst==1'b1 )begin
                        flag_app_bp <= 1'b0;
                end
                else begin
                        if( moe_rx_fifo_st.free_rcv_msg_id_cnt < u_if_tcp_reg_toe.cfg_msg_bd_low_th ) begin
                                flag_app_bp <= 1'b1;
                        end
                        else if( moe_rx_fifo_st.free_rcv_msg_id_cnt > u_if_tcp_reg_toe.cfg_msg_bd_high_th ) begin
                                flag_app_bp <= 1'b0;
                        end
                end
        end
        always @ ( posedge clk or posedge rst ) begin
                if( rst==1'b1 )begin
                        flag_app_rdy <= 1'b0;
                        flag_loop_rdy <= 1'b0;
                end
                else begin
                        if( total_pd_vld==1'b1 )begin
                                flag_app_rdy <= (drop_pkt_rdy==1'b1 || flag_app_bp==1'b1 || u_if_tcp_reg_toe.cfg_toe_mode_ins_bp==1'b1) ? 1'b0 : 1'b1; 
                                flag_loop_rdy <= loop_pd_rdy; 
                        end
                end
        end
        always @ ( * ) begin
                if( flag_pkt_rst==1'b1 && tcp_rx_table_vld==1'b1 ) begin 
                        tbl_act      = VAL_TBL_ACT_DEL;
                end
                else if( flag_app_rdy==1'b0 && flag_sess_hit==1'b1 && (flag_seq_hit==1'b1||flag_seq_hit_win==1'b1) ) begin
                        tbl_act      = VAL_TBL_ACT_UPDATE_ACK;
                end
                else if( flag_app_rdy==1'b0 ) begin
                        tbl_act      = VAL_TBL_ACT_NUL;
                end
                else if( flag_cpu_syn==1'b1 && tcp_rx_table_vld==1'b0 ) begin
                        tbl_act      = VAL_TBL_ACT_NEW;
                end
                else if( flag_cpu_syn==1'b1 && tcp_rx_table_vld==1'b1 && ((gbl_sec_cnt[15:0]-tcp_rx_table_rx_pkt_hittm[15:0])>cfg_tcp_age_time[15:0]) && cfg_tcp_age_time!=0 ) begin  
                        tbl_act      = VAL_TBL_ACT_DEL;
                end
                else if( flag_pkt_ack==1'b1 && tcp_rx_table_vld==1'b1 && tcp_rx_table_fin==1'b1 ) begin 
                        tbl_act      = VAL_TBL_ACT_DEL;
                end
                else if( pd_chn_id[1:0]==2'h2 || pd_chn_id[1:0]==2'h3 ) begin  
                        tbl_act      = VAL_TBL_ACT_NUL;
                end
                else if( flag_sess_hit==1'b1 && flag_seq_hit==1'b1 ) begin
                        tbl_act      = VAL_TBL_ACT_UPDATE;
                end
                else if( flag_sess_hit==1'b1 && flag_seq_hit_win==1'b1 ) begin
                        tbl_act      = VAL_TBL_ACT_UPDATE_ACK;
                end
                else if( flag_pkt_syn==1'b1 && tcp_rx_table_syn==1'b1 ) begin  
                        tbl_act      = VAL_TBL_ACT_NUL;
                end
                else begin
                        tbl_act      = VAL_TBL_ACT_NUL;
                end
        end
        always @ ( posedge clk or posedge rst ) begin
                if( rst==1'b1 )begin
                        tbl_act_reg <= 0;
                end
                else begin
                        tbl_act_reg <= tbl_act;
                end
        end
        wire  [31:0] new_rcv_local_ackn      ;
        wire  [31:0] new_exp_remote_seq     ;
        reg   [31:0] new_rcv_local_ackn_reg  ;
        reg   [31:0] new_exp_remote_seq_reg ;
        wire         out_ack_vld_tmp1        ;
        assign new_rcv_local_ackn = ( pd_tcp_ack==1'b0 ) ? 32'hf000_0000 : ( pd_tcp_ack==1'b1 && tcp_rx_table_ack==1'b0 ) ? pd_tcp_ackn : 
        ( pd_tcp_ack==1'b1 && tcp_rx_table_ack==1'b1 && (pd_tcp_ackn-tcp_rx_table_rcv_local_ackn)<32'h1000_0000 ) ? pd_tcp_ackn : tcp_rx_table_rcv_local_ackn  ;
        assign new_exp_remote_seq = ( pd_tcp_syn==1'b1 )             ? ( pd_tcp_seqn + 1'b1 ) : 
        ( pd_tcp_seqn==tcp_rx_table_exp_remote_seq && flag_pkt_fin==1'b1 )  ? ( pd_tcp_seqn + 1'b1 ) : 
        ( pd_tcp_seqn==tcp_rx_table_exp_remote_seq )  ? ( tcp_rx_table_exp_remote_seq + pd_plen - pd_hdr_len - pd_tail_len ) 
        : tcp_rx_table_exp_remote_seq ;
        always @ ( posedge clk or posedge rst ) begin
                if( rst==1'b1 )begin
                        new_rcv_local_ackn_reg  <= 0 ;
                        new_exp_remote_seq_reg <= 0 ;
                end
                else begin
                        new_rcv_local_ackn_reg  <= new_rcv_local_ackn  ;
                        new_exp_remote_seq_reg <= new_exp_remote_seq ;
                end
        end
        wire flag_allow_snd_dup_ack;
        assign flag_allow_snd_dup_ack = ( (flag_sess_hit==1'b1) && ( tcp_rx_table_snd_dup_ack_cnt<1 || (gbl_sec_cnt[16-1:0] - tcp_rx_table_rx_pkt_hittm)>2 ) ) ? 1'b1 : 1'b0;
        wire [7:0] min_win_unit ; 
        assign min_win_unit = (u_if_tcp_reg_toe.cfg_toe_mode[5]==1'b1 && tcp_rx_table_win_scale!=4'h0) ? 8'h01 : (u_if_tcp_reg_toe.cfg_toe_mode[4]==1'b1 && tcp_rx_table_win_scale!=4'h0) ? 8'h04 : 8'h08  ; 
        always @ ( * ) begin
                if( tbl_act_reg==VAL_TBL_ACT_NEW ) begin
                        new_rx_table_vld          = 1'b1                ;
                        new_rx_table_syn          = 1'b1                ;
                        new_rx_table_synack       = 1'b0                ;
                        new_rx_table_ack          = 1'b0                ;
                        new_rx_table_fin          = 1'b0      ;
                        new_rx_table_rst          = 1'b0  ;
                        new_rx_table_win_scale    = ( u_if_tcp_reg_toe.cfg_toe_mode[4]==1'b0&&u_if_tcp_reg_toe.cfg_toe_mode[5]==1'b0) ? 4'h0 : pd_win_scale[3:0];
                        new_rx_table_outorder_cnt         = 0                              ;
                        new_rx_table_rx_pkt_hittm         = gbl_sec_cnt[16-1:0]            ;
                        new_rx_table_key_sip              = pd_ip_sip              ;
                        new_rx_table_key_sp               = pd_tcp_sp              ;
                        new_rx_table_key_smac             = pd_smac              ;
                        new_rx_table_ini_remote_seq      = pd_tcp_seqn              ;
                        new_rx_table_exp_remote_seq      = new_exp_remote_seq_reg        ;
                        new_rx_table_rcv_local_ackn       = new_rcv_local_ackn_reg        ;
                        new_rx_table_rcv_remote_win       = pd_tcp_win             ;  
                        new_rx_table_snd_dup_ack_cnt      = 0                     ;  
                        new_rx_table_rcv_dup_ack_cnt      = 0                     ;  
                        new_rx_table_rcv_local_win        = 8'hf0;
                end
                else if( tbl_act_reg==VAL_TBL_ACT_UPDATE ) begin
                        new_rx_table_vld                  = 1'b1                                                            ;
                        new_rx_table_syn                  = (flag_pkt_syn==1'b1 || tcp_rx_table_syn==1'b1) ? 1'b1 : 1'b0        ;
                        new_rx_table_synack               = 1'b0                                                            ;
                        new_rx_table_ack                  = (flag_pkt_ack==1'b1 || flag_pkt_dat==1'b1 || tcp_rx_table_ack==1'b1 ) ? 1'b1 : 1'b0          ;
                        new_rx_table_fin                  = (flag_pkt_fin==1'b1 || tcp_rx_table_fin==1'b1) ? 1'b1 : 1'b0        ;
                        new_rx_table_rst                  = (flag_pkt_rst==1'b1 || tcp_rx_table_rst==1'b1) ? 1'b1 : 1'b0        ;
                        new_rx_table_win_scale            = tcp_rx_table_win_scale                ;
                        new_rx_table_outorder_cnt         = (out_ack_vld_tmp1==1'b1) ? (tcp_rx_table_outorder_cnt + 1'b1) : tcp_rx_table_outorder_cnt ;
                        new_rx_table_rx_pkt_hittm         = ( flag_seq_hit==1'b1 || out_ack_vld_tmp1==1'b1) ? gbl_sec_cnt[16-1:0] : tcp_rx_table_rx_pkt_hittm   ;
                        new_rx_table_key_sip              = pd_ip_sip                                                        ;
                        new_rx_table_key_sp               = pd_tcp_sp                                                         ;
                        new_rx_table_key_smac             = pd_smac                                                          ;
                        new_rx_table_ini_remote_seq      = tcp_rx_table_ini_remote_seq                                        ;
                        new_rx_table_exp_remote_seq      = ( flag_seq_hit==1'b1 ) ? new_exp_remote_seq_reg  :  tcp_rx_table_exp_remote_seq                               ;
                        new_rx_table_rcv_local_ackn       = ( flag_seq_hit==1'b1 || flag_seq_hit_win==1'b1 ) ? new_rcv_local_ackn_reg : tcp_rx_table_rcv_local_ackn                                 ;
                        new_rx_table_rcv_remote_win        = ( flag_seq_hit==1'b1 || flag_seq_hit_win==1'b1 ) ? pd_tcp_win : tcp_rx_table_rcv_remote_win                                              ;  
                        new_rx_table_snd_dup_ack_cnt      = ( flag_seq_hit==1'b1 ) ? 4'h0 : (out_ack_vld_tmp1==1'b1) ? (tcp_rx_table_snd_dup_ack_cnt + 1'b1) : tcp_rx_table_snd_dup_ack_cnt ;
                        new_rx_table_rcv_dup_ack_cnt      = ( flag_pkt_ack==1'b1 && pd_tcp_win==tcp_rx_table_rcv_remote_win && pd_tcp_ackn==tcp_rx_table_rcv_local_ackn ) ? tcp_rx_table_rcv_dup_ack_cnt + 1'b1 :
                        ( pd_tcp_ackn==tcp_rx_table_rcv_local_ackn ) ? tcp_rx_table_rcv_dup_ack_cnt : 4'h0;  
                        new_rx_table_rcv_local_win         = ( flag_seq_hit==1'b1 && tcp_rx_table_rcv_local_win==8'hf0 ) ? 8'hf0 : (flag_seq_hit==1'b1) ? (tcp_rx_table_rcv_local_win + min_win_unit) : min_win_unit; 
                end
                else if( tbl_act_reg==VAL_TBL_ACT_UPDATE_ACK ) begin
                        new_rx_table_vld                  = 1'b1                                                            ;
                        new_rx_table_syn                  = tcp_rx_table_syn                                                    ;
                        new_rx_table_synack               = 1'b0                                                            ;
                        new_rx_table_ack                  = (flag_pkt_ack==1'b1 || flag_pkt_dat==1'b1 || tcp_rx_table_ack==1'b1 ) ? 1'b1 : 1'b0          ;
                        new_rx_table_fin                  = (flag_pkt_fin==1'b1 || tcp_rx_table_fin==1'b1) ? 1'b1 : 1'b0        ;
                        new_rx_table_rst                  = (flag_pkt_rst==1'b1 || tcp_rx_table_rst==1'b1) ? 1'b1 : 1'b0        ;
                        new_rx_table_win_scale            = tcp_rx_table_win_scale                ;
                        new_rx_table_outorder_cnt         = (out_ack_vld_tmp1==1'b1) ? (tcp_rx_table_outorder_cnt + 1'b1) : tcp_rx_table_outorder_cnt ;
                        new_rx_table_rx_pkt_hittm         = ( flag_seq_hit==1'b1 || out_ack_vld_tmp1==1'b1) ? gbl_sec_cnt[16-1:0] : tcp_rx_table_rx_pkt_hittm   ;
                        new_rx_table_key_sip              = pd_ip_sip                                                        ;
                        new_rx_table_key_sp               = pd_tcp_sp                                                         ;
                        new_rx_table_key_smac             = pd_smac                                                          ;
                        new_rx_table_ini_remote_seq      = tcp_rx_table_ini_remote_seq                                        ;
                        new_rx_table_exp_remote_seq      = tcp_rx_table_exp_remote_seq                               ;
                        new_rx_table_rcv_local_ackn       = ( flag_seq_hit==1'b1 || flag_seq_hit_win==1'b1 ) ? new_rcv_local_ackn_reg : tcp_rx_table_rcv_local_ackn                                 ;
                        new_rx_table_rcv_remote_win       = ( flag_seq_hit==1'b1 || flag_seq_hit_win==1'b1 ) ? pd_tcp_win : tcp_rx_table_rcv_remote_win                                              ;  
                        new_rx_table_snd_dup_ack_cnt      = ( flag_seq_hit==1'b1 ) ? 4'h0 : (out_ack_vld_tmp1==1'b1) ? (tcp_rx_table_snd_dup_ack_cnt + 1'b1) : tcp_rx_table_snd_dup_ack_cnt ;
                        new_rx_table_rcv_dup_ack_cnt      = ( flag_pkt_ack==1'b1 && pd_tcp_win==tcp_rx_table_rcv_remote_win && pd_tcp_ackn==tcp_rx_table_rcv_local_ackn ) ? tcp_rx_table_rcv_dup_ack_cnt + 1'b1 :
                        ( pd_tcp_ackn==tcp_rx_table_rcv_local_ackn ) ? tcp_rx_table_rcv_dup_ack_cnt : 4'h0;  
                        new_rx_table_rcv_local_win         = ( flag_seq_hit==1'b1 && tcp_rx_table_rcv_local_win==8'hf0 ) ? 8'hf0 : (flag_seq_hit==1'b1) ? (tcp_rx_table_rcv_local_win + min_win_unit) : min_win_unit; 
                end
                else begin 
                        new_rx_table_vld                  = 1'b0                                ;
                        new_rx_table_syn                  = tcp_rx_table_syn                        ;
                        new_rx_table_synack               = 1'b0                     ;
                        new_rx_table_ack                  = tcp_rx_table_ack                        ;
                        new_rx_table_fin                  = tcp_rx_table_fin                        ;
                        new_rx_table_rst                  = tcp_rx_table_rst                        ;
                        new_rx_table_win_scale            = tcp_rx_table_win_scale                  ;
                        new_rx_table_outorder_cnt         = tcp_rx_table_outorder_cnt               ;
                        new_rx_table_rx_pkt_hittm         = gbl_sec_cnt[16-1:0]                 ;
                        new_rx_table_key_sip              = pd_ip_sip                           ;
                        new_rx_table_key_sp               = pd_tcp_sp                           ;
                        new_rx_table_key_smac             = pd_smac                             ;
                        new_rx_table_ini_remote_seq      = tcp_rx_table_ini_remote_seq            ;
                        new_rx_table_exp_remote_seq      = new_exp_remote_seq_reg             ;
                        new_rx_table_rcv_local_ackn       = new_rcv_local_ackn_reg              ;
                        new_rx_table_rcv_remote_win       = pd_tcp_win                          ;  
                        new_rx_table_snd_dup_ack_cnt      = 0                                   ;  
                        new_rx_table_rcv_dup_ack_cnt      = 0                                   ;  
                        new_rx_table_rcv_local_win        = ( flag_seq_hit==1'b1 && tcp_rx_table_rcv_local_win==8'hf0 ) ? 8'hf0 : (flag_seq_hit==1'b1) ? (tcp_rx_table_rcv_local_win + min_win_unit) : min_win_unit; 
                end
        end
        wire [TAB_DWID*RSLT_SZ-1:0] all_new_rslt_dat;
        assign     all_new_rslt_dat[ TAB_DWID*1+127 +: 001 ]    =  new_rx_table_vld                ;
        assign     all_new_rslt_dat[ TAB_DWID*1+126 +: 001 ]    =  new_rx_table_ack                ;
        assign     all_new_rslt_dat[ TAB_DWID*1+125 +: 001 ]    =  new_rx_table_fin                ;
        assign     all_new_rslt_dat[ TAB_DWID*1+124 +: 001 ]    =  new_rx_table_rst                ;
        assign     all_new_rslt_dat[ TAB_DWID*1+120 +: 004 ]    =  new_rx_table_win_scale          ;
        assign     all_new_rslt_dat[ TAB_DWID*1+112 +: 008 ]    =  new_rx_table_outorder_cnt      ;
        assign     all_new_rslt_dat[ TAB_DWID*1+096 +: 016 ]    =  new_rx_table_rx_pkt_hittm      ;
        assign     all_new_rslt_dat[ TAB_DWID*1+064 +: 032 ]    =  new_rx_table_key_sip            ;
        assign     all_new_rslt_dat[ TAB_DWID*1+048 +: 016 ]    =  new_rx_table_key_sp            ;
        assign     all_new_rslt_dat[ TAB_DWID*1+000 +: 048 ]    =  new_rx_table_key_smac          ;
        assign     all_new_rslt_dat[ TAB_DWID*0+096 +: 032 ]    =  new_rx_table_ini_remote_seq    ;
        assign     all_new_rslt_dat[ TAB_DWID*0+064 +: 032 ]    =  new_rx_table_exp_remote_seq    ;
        assign     all_new_rslt_dat[ TAB_DWID*0+032 +: 032 ]    =  new_rx_table_rcv_local_ackn    ;
        assign     all_new_rslt_dat[ TAB_DWID*0+016 +: 016 ]    =  new_rx_table_rcv_remote_win    ;
        assign     all_new_rslt_dat[ TAB_DWID*0+012 +: 004 ]    =  new_rx_table_snd_dup_ack_cnt    ;
        assign     all_new_rslt_dat[ TAB_DWID*0+008 +: 004 ]    =  new_rx_table_rcv_dup_ack_cnt    ;
        assign     all_new_rslt_dat[ TAB_DWID*0+000 +: 008 ]    =  new_rx_table_rcv_local_win      ;
        reg [TAB_DWID*RSLT_SZ-1:0] all_new_rslt_dat_reg;
        always @ ( posedge clk or posedge rst ) begin
                if( rst==1'b1 )begin
                        all_new_rslt_dat_reg <= 0;
                end
                else begin
                        if( flag_step[3]==1'b1 )begin
                                all_new_rslt_dat_reg <= all_new_rslt_dat;
                        end
                end
        end
        always @ ( posedge clk or posedge rst ) begin
                if( rst==1'b1 )begin
                        tab_wdat_fifo_wdata <= 0;
                        tab_wr_fifo_wdata <= 0;
                end
                else begin
                        if( flag_out_step[2]==1'b1 ) begin
                                tab_wdat_fifo_wdata <= all_new_rslt_dat_reg[ TAB_DWID*1+000 +: 128 ]  ;
                                tab_wr_fifo_wdata <= {pd_tcp_fid[0+:(TAB_AWID-1)],1'b0};
                        end
                        else begin
                                tab_wdat_fifo_wdata <= all_new_rslt_dat_reg[ TAB_DWID*0+000 +: 128 ]  ;
                        end
                end
        end
        always @ ( posedge clk or posedge rst ) begin
                if( rst==1'b1 )begin
                        tab_wdat_fifo_wen <= 0;
                        tab_wr_fifo_wen <= 0;
                end
                else begin
                        if( flag_out_step[2]==1'b1 && tbl_act_reg!=VAL_TBL_ACT_NUL ) begin
                                tab_wdat_fifo_wen <= 1'b1;
                                tab_wr_fifo_wen <= 1'b1;
                        end
                        else if( flag_out_step[3]==1'b1 && tbl_act_reg!=VAL_TBL_ACT_NUL ) begin
                                tab_wdat_fifo_wen <= 1'b1;
                                tab_wr_fifo_wen <= 1'b0;
                        end
                        else begin
                                tab_wdat_fifo_wen <= 1'b0;
                                tab_wr_fifo_wen <= 1'b0;
                        end
                end
        end
assign  cfg_write_bd_th  = cfg_moe_bd_th[31:16];
assign  cfg_read_bd_th   = cfg_moe_bd_th[15:00];
wire   [3:0]   pd_act    ;
reg    [3:0]   pd_act_reg  ;
assign flag_tcp_age = ( pd_chn_id[1:0]==2'h2 ) ? 1'b1 : 1'b0 ;
always @ ( * ) begin
        new_pd_tcp_fid = pd_tcp_fid;
        new_pd_fwd     = VAL_FWD_DROP    ;
        new_pd_ptyp    = VAL_PTYP_DROP_APP_BP ;
        if( flag_app_rdy==1'b0 ) begin    
                new_pd_fwd    = VAL_FWD_DROP         ;
                new_pd_ptyp   = VAL_PTYP_DROP_APP_BP ;
        end
        else if( pd_fwd==VAL_FWD_TBD ) begin
                if(pd_chn_id[1:0]==2'h2 ) begin 
                        new_pd_fwd    = VAL_FWD_TOE    ;
                        if(pd_tcp_seqn[31:30] == 2'h1)
                        begin
                                new_pd_ptyp    = VAL_PTYP_AGE_MID ;
                        end
                        else if(pd_tcp_seqn[31:30] == 2'h2)
                        begin
                                new_pd_ptyp    = VAL_PTYP_AGE_WBD ;
                        end
                        else if(pd_tcp_seqn[31:30] == 2'h3)
                        begin
                                new_pd_ptyp    = VAL_PTYP_AGE_RBD ;
                        end
                end
                else if ( pd_chn_id[1:0]==2'h3 && flag_pkt_dat==1'b1 ) begin
                        new_pd_fwd    = VAL_FWD_APP    ;
                        new_pd_ptyp   = VAL_PTYP_PKT_MSG  ;
                end
                else if( flag_cpu_syn==1'b1 && tcp_rx_table_vld==1'b1 && ((gbl_sec_cnt[15:0]-tcp_rx_table_rx_pkt_hittm[15:0])>cfg_tcp_age_time[15:0]) && cfg_tcp_age_time!=0 ) begin  
                        new_pd_fwd    = VAL_FWD_TOE    ;
                        new_pd_ptyp   = VAL_PTYP_PKT_RST  ;
                end
                else if( flag_pkt_syn==1'b1 && tcp_rx_table_syn==1'b1 ) begin
                        new_pd_fwd    = VAL_FWD_DROP    ;
                        new_pd_ptyp    = VAL_PTYP_DROP_SYN_REPEAT;
                end
                else if( flag_pkt_syn==1'b1 ) begin
                        new_pd_fwd    = VAL_FWD_TOE    ;
                        new_pd_ptyp    = VAL_PTYP_PKT_SYN  ;
                end
                else if( flag_pkt_fin==1'b1 ) begin
                        new_pd_fwd    = VAL_FWD_TOE    ;
                        new_pd_ptyp    = VAL_PTYP_PKT_FIN  ;
                end
                else if( flag_pkt_rst==1'b1 ) begin
                        new_pd_fwd    = VAL_FWD_TOE    ;
                        new_pd_ptyp    = VAL_PTYP_PKT_RST  ;
                end
                else if( flag_pkt_ack==1'b1 && tcp_rx_table_syn==1'b1 && tcp_rx_table_ack==1'b1 && tcp_rx_table_fin==1'b0 ) begin
                        new_pd_fwd    = VAL_FWD_DROP    ;
                        new_pd_ptyp    = VAL_PTYP_DROP_ACK  ;
                end
                else if( flag_pkt_ack==1'b1 && tcp_rx_table_syn==1'b1 && tcp_rx_table_ack==1'b0 && tcp_rx_table_fin==1'b0 ) begin
                        new_pd_fwd    = VAL_FWD_TOE    ;
                        new_pd_ptyp    = VAL_PTYP_DROP_FIRST_ACK;
                end
                else if( flag_pkt_ack==1'b1 && tcp_rx_table_vld==1'b1 && tcp_rx_table_fin==1'b1 ) begin 
                        new_pd_fwd    = VAL_FWD_TOE    ;
                        new_pd_ptyp    = VAL_PTYP_DROP_LAST_ACK ;
                end
                else if( flag_sess_hit==1'b1 && flag_seq_hit==1'b1 ) begin
                        new_pd_fwd    = VAL_FWD_APP    ;
                        new_pd_ptyp    = VAL_PTYP_PKT_MSG  ;
                end
                else if( flag_sess_hit==1'b1 && flag_seq_hit_win==1'b1 ) begin 
                        if( pd_ptyp!=VAL_PTYP_PKT_OUT_ORDER && flag_allow_snd_dup_ack==1'b1 ) begin
                                new_pd_fwd    = VAL_FWD_DROP  ;
                                new_pd_ptyp   = VAL_PTYP_DROP_DUP_ACK  ;  
                        end
                        else begin
                                new_pd_fwd    = VAL_FWD_DROP  ;
                                new_pd_ptyp   = VAL_PTYP_DROP_DUP_ACK  ;
                        end
                end
                else if( flag_sess_hit==1'b1 && flag_seq_miss==1'b1 ) begin 
                        if( pd_ptyp!=VAL_PTYP_PKT_OUT_ORDER && flag_allow_snd_dup_ack==1'b1 ) begin
                                new_pd_fwd    = VAL_FWD_DROP  ;
                                new_pd_ptyp   = VAL_PTYP_DROP_DUP_ACK  ;  
                        end
                        else begin
                                new_pd_fwd    = VAL_FWD_DROP  ;
                                new_pd_ptyp    = VAL_PTYP_DROP_DUP_ACK  ;
                        end
                end
                else if( flag_sess_hit==1'b1 && flag_seq_hit==1'b0 ) begin
                        new_pd_fwd    = VAL_FWD_DROP    ;
                        new_pd_ptyp    = VAL_PTYP_DROP_SEQN_ERR  ;
                end
                else if( flag_sess_hit==1'b1 && flag_seq_hit==1'b0 ) begin
                        new_pd_fwd    = VAL_FWD_DROP    ;
                        new_pd_ptyp    = VAL_PTYP_DROP_SEQN_ERR  ;
                end
                else if( flag_sess_vld==1'b1 && u_if_tcp_reg_toe.cfg_toe_mode_sess_ne==1'b0 ) begin
                        new_pd_fwd    = VAL_FWD_DROP    ;
                        new_pd_ptyp    = VAL_PTYP_DROP_SESS_NOTEXIST  ;
                end
                else begin
                        new_pd_fwd    = VAL_FWD_MAC    ;
                        new_pd_ptyp    = VAL_PTYP_MAC     ;
                end
        end
        else begin
                new_pd_fwd    = pd_fwd    ;
                new_pd_ptyp    = pd_ptyp     ;
        end
end
        wire  [1-1:0]       dly_pd_vld   ;         
        wire  [PDWID-1:0]     dly_pd_dat   ;         
        data_dly #(
                .DWID    ( PDWID+1   ),
                .DLY_NUM ( 7         )
        )
        inst_data_pipe(
                .clk     ( clk  ),
                .rst     ( rst  ),
                .din     ( { sync_pd_vld, sync_pd_dat } ),
                .dout    ( { dly_pd_vld , dly_pd_dat  } )
        );
        reg [3:0] cnt_pd_vld;
        always @ ( posedge clk or posedge rst ) begin
                if( rst==1'b1 )begin
                        cnt_pd_vld <= 0;
                end
                else begin
                        if( dly_pd_vld==1'b1 ) begin
                                cnt_pd_vld <= cnt_pd_vld + 1'b1;
                        end
                end
        end
        reg [PDWID-1:0] new_pd_dat;
        always @ ( * ) begin
                if( cnt_pd_vld[1:0]==0 ) begin
                        new_pd_dat             = dly_pd_dat;
                        new_pd_dat[124 +: 004] = new_pd_fwd;
                        new_pd_dat[116 +: 008] = new_pd_ptyp;
                        new_pd_dat[112 +: 001] = new_pd_rls_flag;
                        new_pd_dat[096 +: 016] = new_pd_tcp_fid;  
                end
                else if( cnt_pd_vld[1:0]==1 ) begin
                        new_pd_dat             = dly_pd_dat;
                        new_pd_dat[72 +: 8]    = new_pd_ip_ttl;
                end
                else begin
                        new_pd_dat = dly_pd_dat;
                end
        end
        always @ ( posedge clk or posedge rst ) begin
                if( rst==1'b1 )begin
                        out_pd_vld <= 0;
                        out_pd_dat <= 0;
                end
                else begin
                        out_pd_vld <= dly_pd_vld;
                        out_pd_dat <= new_pd_dat;
                end
        end
        reg [PDWID-1:0] new_loop_pd_dat;
        always @ ( posedge clk or posedge rst ) begin
                if( rst==1'b1 )begin
                        loop_pd_vld <= 0;
                        loop_pd_dat <= 0;
                        new_pd_rls_flag <= 0;
                        new_pd_ip_ttl <= 0;
                end
                else begin
                        if( flag_seq_out_order==1'b1 && flag_loop_rdy==1'b1 && flag_app_rdy==1'b1 ) begin
                                loop_pd_vld <= dly_pd_vld;
                                new_pd_rls_flag <= 1'b0;
                                new_pd_ip_ttl <= pd_ip_ttl - 1'b1;
                        end
                        else begin
                                loop_pd_vld <= 1'b0;
                                new_pd_rls_flag <= 1'b1;
                                new_pd_ip_ttl <= pd_ip_ttl;
                        end
                        loop_pd_dat <= new_loop_pd_dat;
                end
        end
        always @ ( * ) begin
                if( cnt_pd_vld[1:0]==0 ) begin
                        new_loop_pd_dat             = dly_pd_dat;
                        new_loop_pd_dat[116 +: 008] = VAL_PTYP_PKT_OUT_ORDER  ;
                end
                else begin
                        new_loop_pd_dat = dly_pd_dat;
                end
        end
        assign add_reorder_cnt = (flag_step[3]==1'b1&&loop_pd_vld==1'b1 && pd_ptyp==VAL_PTYP_RSV) ? 1'b1 : 1'b0;
        assign sub_reorder_cnt = (flag_step[3]==1'b1&&loop_pd_vld==1'b0 && pd_ptyp==VAL_PTYP_PKT_OUT_ORDER) ? 1'b1 : 1'b0;
        always @ (posedge clk or posedge rst)begin
                if(rst==1'b1)begin;
                        reorder_cnt <= 0;
                        reorder_cnt_reg <= 0;
                end
                else begin
                        if( add_reorder_cnt==1'b1 ) begin
                                reorder_cnt <= reorder_cnt + 1'b1;
                        end
                        else if( sub_reorder_cnt==1'b1 ) begin
                                reorder_cnt <= reorder_cnt - 1'b1;
                        end
                        if( total_pd_vld==1'b1 ) begin
                                reorder_cnt_reg <= reorder_cnt;
                        end
                end
        end
        always@(posedge clk or posedge rst) begin
                if( rst==1'b1 ) begin
                        drop_pkt_rdy <= 1'b0;
                end
                else begin
                        if( out_pkt_rdy==1'b0 )begin
                                drop_pkt_rdy <= 1'b1;
                        end
                        else if( ec_msg_fifo_cnt_used<4 )begin
                                drop_pkt_rdy <= 1'b0;
                        end
                end
        end
assign sync_msg_rdy = (out_pd_rdy==1'b1 || drop_pkt_rdy==1'b1) & out_pmem_rdy==1'b1 & tab_wr_fifo_nafull & tab_wdat_fifo_nafull & (~u_if_tcp_reg_toe.cfg_toe_mode_ins_bp1);
assign sync_rslt_rdy = (out_pd_rdy==1'b1 || drop_pkt_rdy==1'b1) & out_pmem_rdy==1'b1 & tab_wr_fifo_nafull & tab_wdat_fifo_nafull & (~u_if_tcp_reg_toe.cfg_toe_mode_ins_bp1);
assign sync_pd_rdy   = (out_pd_rdy==1'b1 || drop_pkt_rdy==1'b1) & out_pmem_rdy==1'b1 & tab_wr_fifo_nafull & tab_wdat_fifo_nafull & (~u_if_tcp_reg_toe.cfg_toe_mode_ins_bp1);
reg             out_ack_vld_d1  ;
reg             out_ack_vld_d2  ;
reg [3:0]       cnt_ack_vld     ;
reg [15:00]     pd_tcp_fid_latch;
wire            out_ack_vld_tmp ;
assign out_ack_vld_tmp1 = ( flag_allow_snd_dup_ack==1'b1 && (new_pd_ptyp==VAL_PTYP_DROP_DUP_ACK||new_pd_ptyp==VAL_PTYP_PKT_DUP_ACK||new_pd_ptyp==VAL_PTYP_DROP_APP_BP||new_pd_ptyp==VAL_PTYP_DROP_SEQN_ERR) ) ? 1'b1 : 1'b0;
assign out_ack_vld_tmp = ( out_pd_vld==1'b1 && out_ack_vld_tmp1==1'b1 ) ? 1'b1 : 1'b0;
always@( posedge clk or posedge rst ) begin
        if( rst==1'b1 ) begin
                cnt_ack_vld <= 4'h0;
        end
        else begin
                if(cnt_ack_vld==u_if_tcp_reg_toe.cfg_dupack_mode[3:0])begin
                        cnt_ack_vld <= 4'h0;
                end
                else if( out_ack_vld==1'b1 ) begin
                        cnt_ack_vld <= cnt_ack_vld + 1'b1;
                end
        end
end
always@( posedge clk or posedge rst ) begin
        if( rst==1'b1 ) begin
                out_ack_vld <= 1'b0;
        end
        else begin
                if(cnt_ack_vld==u_if_tcp_reg_toe.cfg_dupack_mode[3:0])begin
                        out_ack_vld <= 1'b0;
                end
                else if( out_ack_vld_tmp==1'b1 && out_ack_rdy==1'b1 && u_if_tcp_reg_toe.cfg_toe_mode_dupack_en==1'b1 ) begin
                        out_ack_vld <= 1'b1;
                end
        end
end
always@( posedge clk ) begin
        if( out_pd_vld==1'b1 ) begin
                pd_tcp_fid_latch <= pd_tcp_fid;
        end
end
always@( * ) begin
        out_ack_dat = 0                           ;
        out_ack_dat.bd_typ = VAL_PTYP_PKT_DUP_ACK ;
        out_ack_dat.fid    = pd_tcp_fid_latch     ;
end
        wire [31:0]    in_pd_cnt       ;
        wire [31:0]    in_pd_cnt_fid0  ;
        wire [31:0]    in_pd_cnt_fid1  ;
        wire [31:0]    pkt_drop_cnt    ;
        wire [31:0]    pkt_bp_drop_cnt ;
        wire [31:0]    pkt_mac_cnt     ;
        wire [31:0]    pkt_toe_cnt     ;
        wire [31:0]    pkt_app_cnt     ;
        wire [31:0]    in_syn_cnt      ;
        wire [31:0]    in_ack_cnt      ;
        wire [31:0]    in_fin_cnt      ;
        wire [31:0]    in_rep_fin_cnt  ;
        wire [31:0]    in_rst_cnt      ;
        wire [31:0]    in_dat_cnt      ;
        wire [31:0]    tbl_new_cnt     ;
        wire [31:0]    tbl_del_cnt     ;
        wire [31:0]    dup_ack_cnt     ;
        wire [31:0]    bp_dup_ack_cnt  ;
        wire [31:0]    drop_dup_ack_cnt;
        wire [31:0]    seq_err_cnt    ;
        wire [31:0]    out_syn_cnt     ;
        wire [31:0]    syn2rst_cnt     ;
        wire [31:0]    out_order_drop_cnt ;
        reg  [032 -1:000] max_tcp_rx_table_exp_remote_seq    ;
        always @ ( posedge clk or posedge rst ) begin
                if( rst==1'b1 )begin
                        max_tcp_rx_table_exp_remote_seq  <= 0;
                end
                else if( flag_step[3]==1'b1 && max_tcp_rx_table_exp_remote_seq<tcp_rx_table_exp_remote_seq )begin
                        max_tcp_rx_table_exp_remote_seq <= tcp_rx_table_exp_remote_seq;
                end
        end
 //       dbg_cnt #( .DWID(32), .LEVEL_EDGE(1) ) u_dbg_in_pd_cnt   ( .clk(clk), .rst(rst), .clr_cnt(u_if_tcp_reg_toe.cfg_clr_cnt ), .add_cnt( total_pd_vld==1'b1 ),                                      .dbg_cnt( in_pd_cnt    ) );
 //      dbg_cnt #( .DWID(32), .LEVEL_EDGE(1) ) u_dbg_in_pd_cnt_fid0 ( .clk(clk), .rst(rst), .clr_cnt(u_if_tcp_reg_toe.cfg_clr_cnt ), .add_cnt( total_pd_vld==1'b1&&pd_tcp_fid==16'h000a ),                .dbg_cnt( in_pd_cnt_fid0 ) );
 //       dbg_cnt #( .DWID(32), .LEVEL_EDGE(1) ) u_dbg_in_pd_cnt_fid1 ( .clk(clk), .rst(rst), .clr_cnt(u_if_tcp_reg_toe.cfg_clr_cnt ), .add_cnt( total_pd_vld==1'b1&&pd_tcp_fid==16'h000b ),                .dbg_cnt( in_pd_cnt_fid1 ) );
 //       dbg_cnt #( .DWID(32), .LEVEL_EDGE(1) ) u_dbg_bp_drop_cnt    ( .clk(clk), .rst(rst), .clr_cnt(u_if_tcp_reg_toe.cfg_clr_cnt ), .add_cnt( out_pd_vld==1'b1 && new_pd_ptyp==VAL_PTYP_DROP_APP_BP ),          .dbg_cnt( pkt_bp_drop_cnt ) );
 //       dbg_cnt #( .DWID(32), .LEVEL_EDGE(1) ) u_dbg_drop_cnt    ( .clk(clk), .rst(rst), .clr_cnt(u_if_tcp_reg_toe.cfg_clr_cnt ), .add_cnt( out_pd_vld==1'b1 && new_pd_fwd==VAL_FWD_DROP  && new_pd_ptyp!= VAL_PTYP_DROP_ACK ),          .dbg_cnt( pkt_drop_cnt ) );
 //       dbg_cnt #( .DWID(32), .LEVEL_EDGE(1) ) u_dbg_mac_cnt    ( .clk(clk), .rst(rst), .clr_cnt(u_if_tcp_reg_toe.cfg_clr_cnt ), .add_cnt( out_pd_vld==1'b1 && new_pd_fwd==VAL_FWD_MAC  ),          .dbg_cnt( pkt_mac_cnt ) );
 //       dbg_cnt #( .DWID(32), .LEVEL_EDGE(1) ) u_dbg_toe_cnt    ( .clk(clk), .rst(rst), .clr_cnt(u_if_tcp_reg_toe.cfg_clr_cnt ), .add_cnt( out_pd_vld==1'b1 && new_pd_fwd==VAL_FWD_TOE ),          .dbg_cnt( pkt_toe_cnt ) );
 //       dbg_cnt #( .DWID(32), .LEVEL_EDGE(1) ) u_dbg_app_cnt    ( .clk(clk), .rst(rst), .clr_cnt(u_if_tcp_reg_toe.cfg_clr_cnt ), .add_cnt( out_pd_vld==1'b1 && new_pd_fwd==VAL_FWD_APP ),          .dbg_cnt( pkt_app_cnt ) );
 //       dbg_cnt #( .DWID(32), .LEVEL_EDGE(1) ) u_dbg_in_syn_cnt  ( .clk(clk), .rst(rst), .clr_cnt(u_if_tcp_reg_toe.cfg_clr_cnt ), .add_cnt( flag_step[3] & flag_pkt_syn ),                             .dbg_cnt( in_syn_cnt   ) );
 //       dbg_cnt #( .DWID(32), .LEVEL_EDGE(1) ) u_dbg_in_ack_cnt  ( .clk(clk), .rst(rst), .clr_cnt(u_if_tcp_reg_toe.cfg_clr_cnt ), .add_cnt( flag_step[3] & flag_pkt_ack ),                             .dbg_cnt( in_ack_cnt   ) );
 //       dbg_cnt #( .DWID(32), .LEVEL_EDGE(1) ) u_dbg_in_fin_cnt  ( .clk(clk), .rst(rst), .clr_cnt(u_if_tcp_reg_toe.cfg_clr_cnt ), .add_cnt( flag_step[3] & flag_pkt_fin ),                             .dbg_cnt( in_fin_cnt   ) );
 //       dbg_cnt #( .DWID(32), .LEVEL_EDGE(1) ) u_dbg_in_rep_fin_cnt  ( .clk(clk), .rst(rst), .clr_cnt(u_if_tcp_reg_toe.cfg_clr_cnt ), .add_cnt( flag_step[3] & flag_pkt_fin & flag_seq_less1 ),                             .dbg_cnt( in_rep_fin_cnt   ) );
 //       dbg_cnt #( .DWID(32), .LEVEL_EDGE(1) ) u_dbg_in_rst_cnt  ( .clk(clk), .rst(rst), .clr_cnt(u_if_tcp_reg_toe.cfg_clr_cnt ), .add_cnt( flag_step[3] & flag_pkt_rst ),                             .dbg_cnt( in_rst_cnt   ) );
 //       dbg_cnt #( .DWID(32), .LEVEL_EDGE(1) ) u_dbg_in_dat_cnt  ( .clk(clk), .rst(rst), .clr_cnt(u_if_tcp_reg_toe.cfg_clr_cnt ), .add_cnt( flag_step[3] & flag_pkt_dat ),                             .dbg_cnt( in_dat_cnt   ) );
 //       dbg_cnt #( .DWID(32), .LEVEL_EDGE(1) ) u_dbg_tbl_new_cnt ( .clk(clk), .rst(rst), .clr_cnt(u_if_tcp_reg_toe.cfg_clr_cnt ), .add_cnt( tab_wr_fifo_wen==1'b1 && tbl_act_reg==VAL_TBL_ACT_NEW ), .dbg_cnt( tbl_new_cnt  ) );
 //       dbg_cnt #( .DWID(32), .LEVEL_EDGE(1) ) u_dbg_tbl_del_cnt ( .clk(clk), .rst(rst), .clr_cnt(u_if_tcp_reg_toe.cfg_clr_cnt ), .add_cnt( tab_wr_fifo_wen==1'b1 && tbl_act_reg==VAL_TBL_ACT_DEL ), .dbg_cnt( tbl_del_cnt  ) );
 //       dbg_cnt #( .DWID(32), .LEVEL_EDGE(1) ) u_dbg_dup_ack_cnt ( .clk(clk), .rst(rst), .clr_cnt(u_if_tcp_reg_toe.cfg_clr_cnt ), .add_cnt( out_pd_vld==1'b1 && new_pd_ptyp==VAL_PTYP_PKT_DUP_ACK ),   .dbg_cnt( dup_ack_cnt  ) );
 //       dbg_cnt #( .DWID(32), .LEVEL_EDGE(0) ) u_dbg_bp_dup_ack_cnt    ( .clk(clk), .rst(rst), .clr_cnt(u_if_tcp_reg_toe.cfg_clr_cnt ), .add_cnt( out_ack_vld==1'b1 ),          .dbg_cnt( bp_dup_ack_cnt ) );
 //       dbg_cnt #( .DWID(32), .LEVEL_EDGE(1) ) u_dbg_drop_dup_ack_cnt    ( .clk(clk), .rst(rst), .clr_cnt(u_if_tcp_reg_toe.cfg_clr_cnt ), .add_cnt( out_ack_vld_tmp==1'b1 && out_ack_rdy==1'b0 ),          .dbg_cnt( drop_dup_ack_cnt ) );
 //       dbg_cnt #( .DWID(32), .LEVEL_EDGE(1) ) u_dbg_seq_err_cnt    ( .clk(clk), .rst(rst), .clr_cnt(u_if_tcp_reg_toe.cfg_clr_cnt ), .add_cnt( out_pd_vld==1'b1 && new_pd_ptyp==VAL_PTYP_DROP_SEQN_ERR ),          .dbg_cnt( seq_err_cnt ) );
 //       dbg_cnt #( .DWID(32), .LEVEL_EDGE(1) ) u_dbg_out_order_drop_cnt    ( .clk(clk), .rst(rst), .clr_cnt(u_if_tcp_reg_toe.cfg_clr_cnt ), .add_cnt( out_pd_vld==1'b1 && new_pd_ptyp==VAL_PTYP_DROP_DUP_ACK ),          .dbg_cnt( out_order_drop_cnt ) );
 //       dbg_cnt #( .DWID(32), .LEVEL_EDGE(1) ) u_dbg_out_syn_cnt    ( .clk(clk), .rst(rst), .clr_cnt(u_if_tcp_reg_toe.cfg_clr_cnt ), .add_cnt( out_pd_vld==1'b1 && new_pd_ptyp==VAL_PTYP_PKT_SYN ),          .dbg_cnt( out_syn_cnt ) );
 //       dbg_cnt #( .DWID(32), .LEVEL_EDGE(1) ) u_dbg_syn2rst_cnt    ( .clk(clk), .rst(rst), .clr_cnt(u_if_tcp_reg_toe.cfg_clr_cnt ), .add_cnt( flag_cpu_syn==1'b1 && out_pd_vld==1'b1 && new_pd_ptyp==VAL_PTYP_PKT_RST ),          .dbg_cnt( syn2rst_cnt ) );
        assign dbg_sig = { max_tcp_rx_table_exp_remote_seq };
        assign dbg_sig1 = { tbl_new_cnt[31:00], tbl_del_cnt[31:00] };
        assign u_if_dbg_reg_toe.tcpr_in_pd_cnt          = in_pd_cnt              ;
        assign u_if_dbg_reg_toe.tcpr_in_pd_cnt_fid0     = in_pd_cnt_fid0         ;
        assign u_if_dbg_reg_toe.tcpr_in_pd_cnt_fid1     = in_pd_cnt_fid1         ;
        assign u_if_dbg_reg_toe.tcpr_pkt_bp_drop_cnt    = pkt_bp_drop_cnt        ;
        assign u_if_dbg_reg_toe.tcpr_pkt_drop_cnt       = pkt_drop_cnt           ;
        assign u_if_dbg_reg_toe.tcpr_pkt_mac_cnt        = pkt_mac_cnt            ;
        assign u_if_dbg_reg_toe.tcpr_pkt_toe_cnt        = pkt_toe_cnt            ;
        assign u_if_dbg_reg_toe.tcpr_pkt_app_cnt        = pkt_app_cnt            ;
        assign u_if_dbg_reg_toe.tcpr_in_syn_cnt         = in_syn_cnt             ;
        assign u_if_dbg_reg_toe.tcpr_in_ack_cnt         = in_ack_cnt             ;
        assign u_if_dbg_reg_toe.tcpr_in_fin_cnt         = in_fin_cnt             ;
        assign u_if_dbg_reg_toe.tcpr_in_rep_fin_cnt     = in_rep_fin_cnt         ;
        assign u_if_dbg_reg_toe.tcpr_in_rst_cnt         = in_rst_cnt             ;
        assign u_if_dbg_reg_toe.tcpr_in_dat_cnt         = in_dat_cnt             ;
        assign u_if_dbg_reg_toe.tcpr_tbl_new_cnt        = tbl_new_cnt            ;
        assign u_if_dbg_reg_toe.tcpr_tbl_del_cnt        = tbl_del_cnt            ;
        assign u_if_dbg_reg_toe.tcpr_dup_ack_cnt        = dup_ack_cnt            ;
        assign u_if_dbg_reg_toe.tcpr_bp_dup_ack_cnt     = bp_dup_ack_cnt         ;
        assign u_if_dbg_reg_toe.tcpr_drop_dup_ack_cnt   = drop_dup_ack_cnt       ;
        assign u_if_dbg_reg_toe.tcpr_seqn_err_cnt       = seq_err_cnt           ;
        assign u_if_dbg_reg_toe.tcpr_reorder_cnt        = reorder_cnt_reg        ;
        assign u_if_dbg_reg_toe.tcpr_out_order_drop_cnt = out_order_drop_cnt     ;
        assign u_if_dbg_reg_toe.tcpr_out_syn_cnt        = out_syn_cnt            ;
        assign u_if_dbg_reg_toe.tcpr_syn2rst_cnt        = syn2rst_cnt            ;
endmodule
