`timescale 1ns / 1ps

`include "pkt_des_unpack.v"
module pkt_proc#(
		parameter    DWID         = 256 		    	,   		
		parameter    MSG_WID      = 20  		    	,   		
		parameter    FCMWID       = 50              		,			
		parameter    KEY_WID      = 144              		,			
		parameter    CELL_SZ      = 4 				    				
) (
		input	wire					 clk  				,
		input 	wire					 rst				,
	if_cfg_reg_toe.sink  u_if_cfg_reg_toe ,
	if_dbg_reg_toe       u_if_dbg_reg_toe ,
		input   wire  [1-1:0]            total_cpkt_vld 	,			
		input   wire  [DWID*CELL_SZ-1:0] total_cpkt_dat 	,			
		input   wire  [FCMWID-1:0]       total_cpkt_msg     ,			
		input 	wire [31:0] 		cfg_toe_mode 		,           
		input 	wire [47:0] 		cfg_sys_mac0 		,           
		input 	wire [47:0] 		cfg_sys_mac1 		,           
		input 	wire [31:0] 		cfg_sys_ip0 		,           
		input 	wire [31:0] 		cfg_sys_ip1 		,           
 		output  wire  				 new_key_vld      	,
		output  reg   [KEY_WID-1:0] 		 new_key_dat      	            
);

wire [31:00] in_pd_cnt;
reg 	[CELL_SZ-1:0] 	flag_step	;
wire    [048-1:000] 	pkt_dmac    	;
wire    [048-1:000] 	pkt_smac    	;
wire    [016-1:000] 	pkt_eth_typ 	;
wire    [004-1:000] 	pkt_ip_ver  	;
wire    [004-1:000] 	pkt_ip_ihl  	;
wire    [008-1:000] 	pkt_ip_tos  	;
wire    [016-1:000] 	pkt_ip_len  	;
wire    [016-1:000] 	pkt_ip_id   	;
wire    [001-1:000] 	pkt_ip_rsv0  	;
wire    [001-1:000] 	pkt_ip_df   	;
wire    [001-1:000] 	pkt_ip_mf   	;
wire    [013-1:000] 	pkt_ip_fo   	;
wire    [008-1:000] 	pkt_ip_ttl  	;
wire    [008-1:000] 	pkt_ip_prtl 	;
wire    [016-1:000] 	pkt_ip_cks  	;
wire    [032-1:000] 	pkt_ip_sip  	;
wire    [032-1:000] 	pkt_ip_dip  	;
wire    [016-1:000] 	pkt_tcp_sp  	;
wire    [016-1:000] 	pkt_tcp_dp  	;
wire    [032-1:000] 	pkt_tcp_seqn 	;
wire    [032-1:000] 	pkt_tcp_ackn 	;
wire    [004-1:000] 	pkt_tcp_do 		;
wire    [006-1:000] 	pkt_tcp_rsv0 	;
wire    [001-1:000] 	pkt_tcp_urg 	;
wire    [001-1:000] 	pkt_tcp_ack 	;
wire    [001-1:000] 	pkt_tcp_psh 	;
wire    [001-1:000] 	pkt_tcp_rst 	;
wire    [001-1:000] 	pkt_tcp_syn 	;
wire    [001-1:000] 	pkt_tcp_fin 	;
wire    [016-1:000] 	pkt_tcp_win 	;
wire    [016-1:000] 	pkt_tcp_cks 	;
wire    [016-1:000] 	pkt_tcp_uptr 	;
wire    [080-1:000] 	pkt_tcp_opt 	;
wire    [001-1:000] 	msg_eoc    		; 
wire    [001-1:000] 	msg_soc     	; 
wire    [004-1:000] 	msg_chn_id  	; 
wire    [001-1:000] 	msg_err     	; 
wire    [016-1:000] 	msg_cks     	; 
wire    [016-1:000] 	msg_plen    	; 
wire    [012-1:000] 	msg_pptr    	; 
wire [003:000]  pd_fwd 	    		;
wire [007:000]  pd_ptyp 			;
wire [011:000]  pd_pptr 			;
wire [015:000]  pd_plen 			;
wire [003:000]  pd_chn_id 			;
wire [007:000]  pd_hdr_len 			;
wire [015:000]  pd_tail_len_tmp 		;
wire [007:000]  pd_tail_len 		;
wire [015:000]  pd_tmp_cks  		;
wire [015:000]  pd_tcp_fid  		;
reg  [007:000]  pd_win_scale  		;
wire [KEY_WID-1:000]  new_key_dat_tmp  	;
reg  [007:000]  new_key_dat_pdtyp  ;
wire            short_err_add      ;
wire            iplen_err_add      ;
wire            ipcks_err_add      ;
wire            tcpcks_err_add     ;
assign  pkt_dmac    	= total_cpkt_dat[128*15+080 +: 048];
assign  pkt_smac    	= total_cpkt_dat[128*15+032 +: 048];
assign  pkt_eth_typ 	= total_cpkt_dat[128*15+016 +: 016];
assign  pkt_ip_ver  	= total_cpkt_dat[128*15+012 +: 004];
assign  pkt_ip_ihl  	= total_cpkt_dat[128*15+008 +: 004];
assign  pkt_ip_tos  	= total_cpkt_dat[128*15+000 +: 008];
assign  pkt_ip_len  	= total_cpkt_dat[128*14+112 +: 016];
assign  pkt_ip_id   	= total_cpkt_dat[128*14+096 +: 016];
assign  pkt_ip_rsv0  	= total_cpkt_dat[128*14+095 +: 001];
assign  pkt_ip_df   	= total_cpkt_dat[128*14+094 +: 001];
assign  pkt_ip_mf   	= total_cpkt_dat[128*14+093 +: 001];
assign  pkt_ip_fo   	= total_cpkt_dat[128*14+080 +: 013];
assign  pkt_ip_ttl  	= total_cpkt_dat[128*14+072 +: 008];
assign  pkt_ip_prtl 	= total_cpkt_dat[128*14+064 +: 008];
assign  pkt_ip_cks  	= total_cpkt_dat[128*14+048 +: 016];
assign  pkt_ip_sip  	= total_cpkt_dat[128*14+016 +: 032];
assign  pkt_ip_dip  	={total_cpkt_dat[128*14+000 +: 016], 
						  total_cpkt_dat[128*13+112 +: 016] };
assign  pkt_tcp_sp  	= total_cpkt_dat[128*13+096 +: 016];
assign  pkt_tcp_dp  	= total_cpkt_dat[128*13+080 +: 016];
assign  pkt_tcp_seqn 	= total_cpkt_dat[128*13+048 +: 032];
assign  pkt_tcp_ackn 	= total_cpkt_dat[128*13+016 +: 032];
assign  pkt_tcp_do 	= total_cpkt_dat[128*13+012 +: 004];
assign  pkt_tcp_rsv0 	= total_cpkt_dat[128*13+006 +: 006];
assign  pkt_tcp_urg 	= total_cpkt_dat[128*13+005 +: 001];
assign  pkt_tcp_ack 	= total_cpkt_dat[128*13+004 +: 001];
assign  pkt_tcp_psh 	= total_cpkt_dat[128*13+003 +: 001];
assign  pkt_tcp_rst 	= total_cpkt_dat[128*13+002 +: 001];
assign  pkt_tcp_syn 	= total_cpkt_dat[128*13+001 +: 001];
assign  pkt_tcp_fin 	= total_cpkt_dat[128*13+000 +: 001];
assign  pkt_tcp_win 	= total_cpkt_dat[128*12+112 +: 016];
assign  pkt_tcp_cks 	= total_cpkt_dat[128*12+096 +: 016];
assign  pkt_tcp_uptr 	= total_cpkt_dat[128*12+080 +: 016];
assign  pkt_tcp_opt 	= total_cpkt_dat[128*12+000 +: 080];
assign  msg_pptr    	= total_cpkt_msg[MSG_WID+32 +: 012]; 
assign  msg_plen    	= total_cpkt_msg[MSG_WID+16 +: 016]; 
assign  msg_cks     	= total_cpkt_msg[MSG_WID    +: 016]; 
assign  msg_chn_id  	= total_cpkt_msg[012 +: 004]; 
assign  msg_err     	= total_cpkt_msg[011 +: 001]; 
assign  msg_eoc    	= total_cpkt_msg[003 +: 001]; 
assign  msg_soc     	= total_cpkt_msg[002 +: 001]; 
wire [20*8-1:0] tcp_option ;
integer i;
assign  tcp_option = total_cpkt_dat[32*8*8-(54+20)*8 +: 20*8 ];
always@( * ) begin
        pd_win_scale = 8'h0;
        for(i=0;i<5;i=i+1) begin
                if( tcp_option[i*32+8+:24]==24'h010303 ) begin
                        pd_win_scale = tcp_option[i*32+:8];
                end
        end
end
wire   flag_dmac_match	;
wire   flag_ipv4_pkt	;
wire   flag_tcp_pkt	;
wire   flag_frag_pkt	;
wire   flag_tcp_fg_pkt  ;  
wire   flag_tcp_nf_pkt  ;  
wire   flag_other_pkt   ;  
wire   flag_dp_hit_pkt  ;  
wire   flag_toe_pkt     ;  
wire   flag_tcphead_crt ; 
assign flag_dmac_match 	= ( pkt_dmac==cfg_sys_mac0 || pkt_dmac==cfg_sys_mac1 ) ? 1'b1 : 1'b0;
assign flag_ipv4_pkt 	= ( pkt_eth_typ==16'h0800 && pkt_ip_ver==4'h4 ) ? 1'b1 : 1'b0;
assign flag_tcp_pkt 	= ( flag_ipv4_pkt==1'b1 && pkt_ip_prtl==8'h06 ) ? 1'b1 : 1'b0;
assign flag_frag_pkt 	= ( flag_ipv4_pkt==1'b1 && (pkt_ip_mf==1'b1 || pkt_ip_fo!=0) ) ? 1'b1 : 1'b0;
assign flag_tcp_fg_pkt 	= ( flag_tcp_pkt==1'b1 && flag_frag_pkt==1'b1 ) ? 1'b1 : 1'b0;
assign flag_tcp_nf_pkt 	= ( flag_tcp_pkt==1'b1 && flag_frag_pkt==1'b0 ) ? 1'b1 : 1'b0;
assign flag_dp_hit_pkt 	= ( pkt_tcp_dp[13:0]<14'h80 && pkt_tcp_dp[13:0]>14'h9) ? 1'b1 : 1'b0;
assign flag_other_pkt 	= ( flag_tcp_fg_pkt==1'b0 && flag_tcp_nf_pkt==1'b0 ) ? 1'b1 : 1'b0;
assign flag_toe_pkt 	  = ( flag_dmac_match==1'b1 && flag_ipv4_pkt==1'b1 && pkt_ip_ihl==4'h5 && flag_tcp_pkt==1'b1 && flag_dp_hit_pkt==1'b1 ) ? 1'b1 : 1'b0;
reg  [07:00] cks_cout_tmp0	;
reg  [07:00] cks_cout_tmp1	;
reg  [07:00] cks_cout_tmp2	;
reg  [15:00] cks_sum_tmp0	;
reg  [15:00] cks_sum_tmp1	;
reg  [15:00] cks_sum_tmp2	;
reg  [47:00] cks_data		;
reg  [19:00] cks_in		;
wire [19:00] cks_out		;
reg  [19:00] cks_out_reg	;
reg  [16:00] cks_out_step1	;
reg  [15:00] cks_out_step2	;
always @ ( * ) begin
	cks_data = { pkt_ip_ttl[7:0], pkt_ip_tos[7:0], pkt_ip_len[15:0], pkt_ip_id[15:0] };
	cks_in   = 20'h0 ;
	if( flag_step[0]==1'b1 ) begin
		cks_data = { pkt_ip_ttl[7:0], pkt_ip_tos[7:0], pkt_ip_len[15:0], pkt_ip_id[15:0] };
		cks_in   = 20'h0 ;
	end
	else if( flag_step[1]==1'b1 ) begin
		cks_data = { pkt_ip_rsv0[0], pkt_ip_df[0], pkt_ip_mf[0], pkt_ip_fo[12:0], pkt_ip_sip };
		cks_in   = cks_out_reg ;
	end
	else if( flag_step[2]==1'b1 ) begin
		cks_data = { pkt_ip_dip, pkt_ip_cks[15:0] };
		cks_in   = cks_out_reg ;
	end
end
always @ ( posedge clk or posedge rst ) begin
	if( rst==1'b1 )begin
		cks_out_reg   <= 0;
		cks_out_step1 <= 0;
		cks_out_step2 <= 0;
	end
	else begin
		cks_out_reg   <= cks_out;
		cks_out_step1 <= {1'b0, cks_out_reg[15:0]} + {13'h0, cks_out_reg[19:16]};
	        if( flag_step[4]==1'b1 ) begin
		    cks_out_step2 <= cks_out_step1[15:0] + cks_out_step1[16];
                end
	end
end
cks_64b inst_cks_64b( .din(cks_data), .cks_in(cks_in), .cks_out(cks_out) );
reg 		flag_drop;
reg 	[7:0]	ptyp_drop;
always @ ( * ) begin
	if( (msg_err==1'b1 ) && (pd_chn_id==2'h0 || pd_chn_id==2'h1)) begin  					
		flag_drop = 1'b1;
		ptyp_drop = VAL_PTYP_DROP_MAC_ERR;
	end
	else if( pd_plen<=32 ) begin  					
		flag_drop = 1'b1;
		ptyp_drop = VAL_PTYP_DROP_SHORT_PKT;
	end
  else if( (( u_if_cfg_reg_toe.cfg_toe_mode_ins_err==1'b1 && in_pd_cnt[3:0]==32'ha ) || ( u_if_cfg_reg_toe.cfg_toe_mode_ins_err1==1'b1 )) 
         && (pd_chn_id==2'h0 || pd_chn_id==2'h1)) begin  					
		flag_drop = 1'b1;
		ptyp_drop = VAL_PTYP_DROP_INSERT_ERR;
	end
	else if( flag_ipv4_pkt==1'b1 && (pkt_ip_len+16'd14)>msg_plen ) begin  
		flag_drop = 1'b1;
		ptyp_drop = VAL_PTYP_DROP_IP_LEN_ERR;
	end
	else if( flag_ipv4_pkt==1'b1 && pkt_ip_ihl==4'h5 && !(cks_out_step2==~(16'h4506)) && (pd_chn_id==2'h0 || pd_chn_id==2'h1) && u_if_cfg_reg_toe.cfg_ckserr_drop_en[0] == 1'b1 ) begin  
		flag_drop = 1'b1;
		ptyp_drop = VAL_PTYP_DROP_IPCKS_ERR;
	end
	else if( flag_ipv4_pkt==1'b1 && pkt_ip_ihl==4'h5 && (pd_tmp_cks != 16'hffff ) && (pd_chn_id==2'h0 || pd_chn_id==2'h1) && u_if_cfg_reg_toe.cfg_ckserr_drop_en[1] == 1'b1 ) begin  
		flag_drop = 1'b1;
		ptyp_drop = VAL_PTYP_DROP_TCPCKS_ERR;
	end
	else begin 
		flag_drop = 1'b0;
		ptyp_drop = 0;
	end
end
reg		flag_tocpu;
reg 	[7:0]	ptyp_tocpu;
always @ ( * ) begin
	if( flag_toe_pkt==1'b1 ) begin  
		flag_tocpu = 1'b0;
		ptyp_tocpu = 1;
	end
	else begin  
		flag_tocpu = 1'b1;
		ptyp_tocpu = 0;
	end
end
assign  pd_fwd 		=   ( pd_chn_id[1:0]==2'h2||pd_chn_id[1:0]==2'h3) ? VAL_FWD_TBD :
   	                  ( flag_drop ==1'b1 && ptyp_drop==VAL_PTYP_DROP_SHORT_PKT) ? VAL_FWD_DROP : 
                      ( flag_tocpu==1'b1 ) ? VAL_FWD_MAC :
   	                  ( flag_drop ==1'b1 ) ? VAL_FWD_DROP : VAL_FWD_TBD ;
assign  pd_ptyp 	= ( pd_chn_id[1:0]==2'h2||pd_chn_id[1:0]==2'h3 ) ? 0 :
   	                ( flag_drop ==1'b1 && ptyp_drop==VAL_PTYP_DROP_SHORT_PKT) ? ptyp_drop : 
                    ( flag_tocpu==1'b1 ) ? ptyp_tocpu :
   	                ( flag_drop ==1'b1 ) ? ptyp_drop  : 0 ;
assign  pd_pptr 	= msg_pptr								;
assign  pd_plen 	= msg_plen								;
assign  pd_chn_id 	= msg_chn_id							        ;
assign  pd_hdr_len 	= 8'd14 + {2'h0,pkt_ip_ihl[3:0],2'h0} + {2'h0,pkt_tcp_do[3:0],2'h0}     ;
assign  pd_tail_len_tmp	= msg_plen - 16'd14 - pkt_ip_len 			;
assign  pd_tail_len	= pd_tail_len_tmp[7:0]					;
assign  pd_tmp_cks  	= msg_cks								;
assign  pd_tcp_fid      = { pd_chn_id[1:0], pkt_tcp_dp[13:0] };
assign  new_key_dat_tmp = { pd_fwd, pd_ptyp, pd_pptr, pd_plen, pd_chn_id, pd_hdr_len, pd_tail_len, pd_tmp_cks, pkt_smac[47:0], pd_tcp_fid[15:0], pd_win_scale[3:0] };
always @ ( posedge clk or posedge rst ) begin
	if( rst==1'b1 )begin
		flag_step <= 0;
	end
	else begin
		flag_step <= { flag_step[CELL_SZ-2:0], total_cpkt_vld };
	end
end
assign new_key_vld = flag_step[CELL_SZ-1];
always @ ( posedge clk or posedge rst ) begin
	if( rst==1'b1 )begin
		new_key_dat <= 0;
	end
	else if( flag_step[CELL_SZ-2]==1'b1 ) begin
		new_key_dat <= new_key_dat_tmp;
	end
end
dbg_cnt #( .DWID(32), .LEVEL_EDGE(1) ) u_dbg_pd_cnt   ( .clk(clk), .rst(rst), .clr_cnt(u_if_cfg_reg_toe.cfg_clr_cnt ), .add_cnt( total_cpkt_vld==1'b1 ),                                      .dbg_cnt( in_pd_cnt    ) );
always @ ( posedge clk  ) begin
	  new_key_dat_pdtyp <= pd_ptyp ;
end
assign   short_err_add  = (new_key_vld == 1'b1 && new_key_dat_pdtyp == VAL_PTYP_DROP_SHORT_PKT ) ? 1'b1 : 1'b0 ;
assign   iplen_err_add  = (new_key_vld == 1'b1 && new_key_dat_pdtyp == VAL_PTYP_DROP_IP_LEN_ERR) ? 1'b1 : 1'b0 ;
assign   ipcks_err_add  = (new_key_vld == 1'b1 && new_key_dat_pdtyp == VAL_PTYP_DROP_IPCKS_ERR ) ? 1'b1 : 1'b0 ;
assign   tcpcks_err_add = (new_key_vld == 1'b1 && new_key_dat_pdtyp == VAL_PTYP_DROP_TCPCKS_ERR) ? 1'b1 : 1'b0 ;
dbg_cnt #( .DWID(16), .LEVEL_EDGE(1) ) u_dbg_shorterr_cnt   ( .clk(clk), .rst(rst), .clr_cnt(u_if_cfg_reg_toe.cfg_clr_cnt ), .add_cnt( short_err_add  ),                                     
.dbg_cnt( u_if_dbg_reg_toe.rx_pktlen_ecnt[15:0]    ) );
dbg_cnt #( .DWID(16), .LEVEL_EDGE(1) ) u_dbg_iplenerr_cnt   ( .clk(clk), .rst(rst), .clr_cnt(u_if_cfg_reg_toe.cfg_clr_cnt ), .add_cnt( iplen_err_add  ),                                     
.dbg_cnt( u_if_dbg_reg_toe.rx_pktlen_ecnt[31:16]    ) );
dbg_cnt #( .DWID(16), .LEVEL_EDGE(1) ) u_dbg_ipckserr_cnt   ( .clk(clk), .rst(rst), .clr_cnt(u_if_cfg_reg_toe.cfg_clr_cnt ), .add_cnt( ipcks_err_add  ),                                     
.dbg_cnt( u_if_dbg_reg_toe.rx_cks_ecnt[15:0]    ) );
dbg_cnt #( .DWID(16), .LEVEL_EDGE(1) ) u_dbg_tcpckserr_cnt   ( .clk(clk), .rst(rst), .clr_cnt(u_if_cfg_reg_toe.cfg_clr_cnt ), .add_cnt( tcpcks_err_add ),                                     
.dbg_cnt( u_if_dbg_reg_toe.rx_cks_ecnt[31:16]    ) );
endmodule

module cks_64b (
	input 	[47:0] 	din 		,
	input 	[19:0] 	cks_in		,
	output 	[19:0] 	cks_out	
);
	assign cks_out = { {4'h0,din[15:00]} + {4'h0,din[31:16]} + {4'h0,din[47:32]} + cks_in[19:0] };
endmodule


module pkt_pd_gen #(
		parameter    DWID         = 256 				,           
		parameter    KEY_WID      = 140 				,           
		parameter    PDWID        = 128 				            
) (
		input	wire				clk  				,
		input 	wire				rst					,
		input 	wire [1-1:0] 		new_key_vld			,           
		input 	wire [KEY_WID-1:0] 	new_key_dat			,           
		input 	wire [1-1:0] 		fst_cell_vld		,           
		input 	wire [DWID-1:0] 	fst_cell_dat		,           
		output  reg  [1-1:0]        out_pd_vld 			,			
		output  reg  [PDWID-1:0]    out_pd_dat 						
);
reg 				new_key_vld_dly	;
reg [DWID-1:0] 		fst_cell_dat0	;
reg [DWID-1:0] 		fst_cell_dat1	;
always @ ( posedge clk or posedge rst ) begin
	if( rst==1'b1 )begin
		new_key_vld_dly <= 0;
		fst_cell_dat0 <= 0;
		fst_cell_dat1 <= 0;
	end
	else begin
		new_key_vld_dly <= new_key_vld;
		if( new_key_vld==1'b1 )begin
			fst_cell_dat0 <= fst_cell_dat;
		end
		if( new_key_vld_dly==1'b1 )begin
			fst_cell_dat1 <= fst_cell_dat;
		end
	end
end
wire [003:000]  pd_fwd 	    		;
wire [007:000]  pd_ptyp 			;
wire [003:000]  pd_rsv0    		;
wire [015:000]  pd_tcp_fid 			;
wire [001:000]  pd_l5typ 			;
wire [001:000]  pd_credit 			;
wire [011:000]  pd_pptr 			;
wire [015:000]  pd_plen 			;
wire [003:000]  pd_chn_id 			;
wire [007:000]  pd_hdr_len 			;
wire [007:000]  pd_tail_len 		;
wire [015:000]  pd_tmp_cks  		;
wire [003:000]  pd_oport_id  		;
wire [007:000]  pd_frag_fid  		;
wire [047:000]  pkt_smac  		;
wire [003:000]  pd_win_scale  		;
assign { pd_fwd, pd_ptyp, pd_pptr, pd_plen, pd_chn_id, pd_hdr_len, pd_tail_len, pd_tmp_cks, pkt_smac, pd_tcp_fid, pd_win_scale } = new_key_dat;
assign  pd_rsv0    = 4'h0 			;
assign  pd_l5typ     = 2'h0 			;
assign  pd_credit    = 2'h0 			;
assign  pd_oport_id  = 4'h0 			;
assign  pd_frag_fid  = 8'h0 			;
wire [127:0] pd_dat0;
assign pd_dat0 = { pd_fwd[3:0], pd_ptyp[7:0], pd_win_scale[2:0], 1'b0, 
					pd_tcp_fid[15:0], 
					pd_win_scale[3], pd_l5typ[0], pd_credit[1:0], pd_pptr[11:0],  pd_plen[15:0], 
					pd_chn_id[3:0], pd_hdr_len[7:0], pd_tail_len[7:0], 
					pd_tmp_cks[15:0], pd_oport_id[3:0], pd_frag_fid[7:0], 
					16'h0};
reg [1:0] cnt_pd_vld;
always@(posedge clk or posedge rst)begin
	if( rst==1'b1 ) begin
		cnt_pd_vld <= 0;
	end
	else begin
		if( new_key_vld==1'b1 )begin
			cnt_pd_vld <= 2'h1;
		end
		else if( cnt_pd_vld!=2'h0 ) begin
			cnt_pd_vld <= cnt_pd_vld + 1'b1;
		end
	end
end
reg [127:0] pd_dat_tmp;
always@( * )begin
	case( cnt_pd_vld )
		2'h0: pd_dat_tmp = { pd_dat0[127:16], fst_cell_dat[128 +: 16] };
		2'h1: pd_dat_tmp = { fst_cell_dat0[ 0   +: 128] };
		2'h2: pd_dat_tmp = { fst_cell_dat1[ 128 +: 128] };
		2'h3: pd_dat_tmp = { fst_cell_dat1[ 48   +: 80], pkt_smac[47:0] };
		default: pd_dat_tmp = { fst_cell_dat0[ 0 +: 128] };
	endcase
end
always@(posedge clk or posedge rst)begin
	if( rst==1'b1 ) begin
		out_pd_dat <= 0;
	end
	else begin
		out_pd_dat <= pd_dat_tmp;
	end
end
reg [2:0] pd_vld;
always@(posedge clk or posedge rst)begin
	if( rst==1'b1 ) begin
		pd_vld <= 0;
	end
	else begin
		pd_vld <= { pd_vld[1:0], new_key_vld};
	end
end
always@(posedge clk or posedge rst)begin
	if( rst==1'b1 ) begin
		out_pd_vld <= 0;
	end
	else begin
		out_pd_vld <= |{new_key_vld, pd_vld[2:0]};
	end
end
endmodule