`timescale 1ns / 1ps
module tcp_rx_tcpkt_mix #(
		parameter    PDWID        = 128 			,               
		parameter    PDSZ         = 4 			  ,               
		parameter    DBG_WID      = 32 				 		            
) (
		input	  wire				           clk		 	                          ,
		input 	wire				           rst			                          ,
    if_tcp_reg_toe.sink            u_if_tcp_reg_toe ,
		input 	wire				           in_pd_vld		                      ,
		input 	wire	[PDWID-1:0]		       in_pd_dat		                      ,
		output 	wire				           in_pd_rdy 		                      ,
		output 	wire 				           out_pd_vld                             ,
		output 	wire	[PDWID-1:0]		       out_pd_dat     	                      ,
		input 	wire				           out_pd_rdy	    	                  ,
		output  wire	[DBG_WID-1:0]		   dbg_sig			
);
wire  [1-1:0] total_pd_vld;
wire  [PDWID*PDSZ-1:0] total_pd_dat;
cpkt_unf #(
	.DWID			( PDWID		),
	.FCMWID			( 1 		),
	.SOC_MSB		( 0 		),
	.SOC_LSB		( 0 		),
	.EOC_MSB		( 0 		),
	.EOC_LSB		( 0 		),
	.CELL_SZ		( PDSZ     	)
)inst_cpkt_unf(
	.clk     		      ( clk			        ), 
	.rst    		      ( rst	 		        ),
	.cell_vld 		    ( in_pd_vld		    ),	
	.cell_dat 		    ( in_pd_dat		    ),	
	.cell_msg 		    ( 1'b0			      ),	
 	.total_cpkt_vld 	( total_pd_vld  	), 
	.total_cpkt_dat 	( total_pd_dat  	), 
	.total_cpkt_msg 	(       		      ) 
);
`include "common_define_value.v"
`include "pkt_des_unpack.v"
wire				           in_pd_vld_d4		                      ;
wire	[PDWID-1:0]		   in_pd_dat_d4		                      ;
ctrl_dly #( .DWID(1)    , .DLY_NUM(PDSZ) ) u_ctrl_in_pd_vld( .clk(clk), .rst(rst), .din( in_pd_vld ), .dout( in_pd_vld_d4 ) );
data_dly #( .DWID(PDWID), .DLY_NUM(PDSZ) ) u_ctrl_in_pd_dat( .clk(clk), .rst(rst), .din( in_pd_dat ), .dout( in_pd_dat_d4 ) );
wire [15:0]    pkt_fid;
assign pkt_fid = (pd_fwd==VAL_FWD_MAC) ? {12'h0, pd_chn_id[3:0]} : pd_tcp_fid;
cpkt_mix  #(
        .RAM_STYLE   ( "block" ),
        .DWID        ( PDWID   ),   
        .CELL_LEN    ( PDSZ    ),   
        .AWID        ( 5       ),   
        .KEY_WID     ( 16      ),
        .AFULL_TH    ( 16      ),
        .QUE_NUM     ( 8      ),
        .CELL_GAP    ( 6      ),
        .LIMIT_RATE_EN ( 1     ),
        .DBG_WID     ( 32      )
) u_cpkt_mix(
    .clk      ( clk           ),     
    .rst      ( rst           ),     
    .cfg_limit_rate_en ( u_if_tcp_reg_toe.cfg_limit_rate_en ),
    .in_vld   ( in_pd_vld_d4  ),
    .in_data  ( in_pd_dat_d4  ),
    .in_rdy   ( in_pd_rdy     ),
    .in_soc   ( whole_pd_vld  ),
    .in_key   ( pkt_fid       ),
    .out_data ( out_pd_dat    ),
    .out_vld  ( out_pd_vld    ),
    .out_rdy  ( out_pd_rdy    ),
    .dbg_sig  (               )
);
assign dbg_sig = 32'h0;
endmodule
