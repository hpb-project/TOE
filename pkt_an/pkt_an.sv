`timescale 1ns / 1ps
module pkt_an #(
		parameter    DWID         = 256 			,                               
		parameter    MSG_WID      = 20   			,                               
		parameter    FCMWID       = 50     			,				
		parameter    PDWID        = 128 			,                               
		parameter    CELL_SZ      = 8 				,                           	
		parameter    DBG_WID      = 32 				                           	
) (
		input	wire			clk  					,
		input 	wire			rst						,
	if_cfg_reg_toe.sink  u_if_cfg_reg_toe ,
	if_dbg_reg_toe       u_if_dbg_reg_toe ,
		input 	wire [1-1:0] 		fst_cell_vld		,                       
		output 	wire [1-1:0] 		fst_cell_rdy		,                       
		input 	wire [DWID-1:0] 	fst_cell_dat		,                       
		input 	wire [FCMWID-1:0] 	fst_cell_msg		,                       
		output  wire [1-1:0]            out_pd_vld 		,			
		input   wire [1-1:0]            out_pd_rdy 		, 			
		output  wire [PDWID-1:0]        out_pd_dat 		,			
		input 	wire [31:0] 		cfg_toe_mode 		,           
		input 	wire [47:0] 		cfg_sys_mac0 		,           
		input 	wire [47:0] 		cfg_sys_mac1 		,           
		input 	wire [31:0] 		cfg_sys_ip0 		,           
		input 	wire [31:0] 		cfg_sys_ip1 		,           
		output  wire [DBG_WID-1:0]      dbg_sig  					
);
localparam EOC_MSB = 2;
localparam EOC_LSB = 2;
localparam SOC_MSB = 3;
localparam SOC_LSB = 3;
localparam KEY_WID = 144;
assign fst_cell_rdy = out_pd_rdy;
wire 			fst_cell_vld_16dly	;
wire [DWID-1:0] 	fst_cell_dat_16dly	;
data_dly #(
		.DWID 		( DWID+1	),
		.DLY_NUM	( 16 		)     
)
inst_data_pipe (
		.clk     	( clk   	),
		.rst     	( rst   	),
		.din     	( { fst_cell_vld, fst_cell_dat }           ),
		.dout    	( { fst_cell_vld_16dly, fst_cell_dat_16dly } )
);
wire 				total_cpkt_vld		;
wire [DWID*CELL_SZ-1:0] 	total_cpkt_dat		;
wire [FCMWID-1:0]		total_cpkt_msg		;
cpkt_unf #(
	.DWID			( DWID 		),
	.FCMWID			( FCMWID 	),
	.EOC_MSB		( EOC_MSB 	),
	.EOC_LSB		( EOC_LSB 	),
	.SOC_MSB		( SOC_MSB 	),
	.SOC_LSB		( SOC_LSB 	),
	.CELL_SZ		( CELL_SZ 	)
)inst_cpkt_unf(
	.clk     		( clk  				), 
	.rst    		( rst				),
	.cell_vld 		( fst_cell_vld		),	
	.cell_dat 		( fst_cell_dat		),	
	.cell_msg 		( fst_cell_msg		),	
     total_cpkt_vld 	( total_cpkt_vld  	), 
	.total_cpkt_dat 	( total_cpkt_dat  	), 
	.total_cpkt_msg 	( total_cpkt_msg  	)
);
wire [KEY_WID-1:0] new_key_dat; 
wire new_key_vld;

pkt_proc #(
	.DWID		( DWID 	    ),
	.MSG_WID	( MSG_WID   ),
	.FCMWID		( FCMWID    ),
	.KEY_WID	( KEY_WID   ),
	.CELL_SZ	( CELL_SZ 	)
)inst_eth_proc(
	.clk     		( clk  					), 
	.rst    		( rst					),
	   .u_if_cfg_reg_toe    (u_if_cfg_reg_toe   ),
	   .u_if_dbg_reg_toe    (u_if_dbg_reg_toe   ),
        .total_cpkt_vld ( total_cpkt_vld		), 
	.total_cpkt_dat ( total_cpkt_dat		), 
	.total_cpkt_msg ( total_cpkt_msg		), 
	.cfg_toe_mode 		( cfg_toe_mode 		),           
	.cfg_sys_mac0 		( cfg_sys_mac0 		),           
	.cfg_sys_mac1 		( cfg_sys_mac1 		),           
	.cfg_sys_ip0 		( cfg_sys_ip0 		),           
	.cfg_sys_ip1 		( cfg_sys_ip1 		),            
	.new_key_vld    ( new_key_vld    		),
	.new_key_dat    ( new_key_dat    		)
);

pkt_pd_gen #(
	.DWID		( DWID    ),
	.PDWID		( PDWID   ),
	.KEY_WID	( KEY_WID )
)inst_eth_pd_gen(
	.clk     			( clk  				), 
	.rst    			( rst				),
	.new_key_vld    	( new_key_vld      	), 
	.new_key_dat    	( new_key_dat		),
	.fst_cell_vld   	( fst_cell_vld_16dly ),
	.fst_cell_dat   	( fst_cell_dat_16dly ),
	.out_pd_vld     	( out_pd_vld       	),			
	.out_pd_dat     	( out_pd_dat       	)
);
assign dbg_sig = 32'h0;
endmodule
