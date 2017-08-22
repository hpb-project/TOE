`timescale 1ns / 1ps
module work_cpkt_ctrl  #(
        parameter WRK_NUM     = 8       ,
        parameter EN_KEY_VLD  = 0       ,
        parameter EXIT_TYP    = 0       ,
        parameter RAM_STYLE   = "block" ,
        parameter DWID        = 256     ,   
        parameter CELL_LEN    = 4       ,   
        parameter AWID        = 5       ,   
        parameter KEY_WID     = 16      ,
        parameter AFULL_TH    = 8       ,
        parameter DBG_WID     = 32
) (
    input    wire                       clk      ,     
    input    wire                       rst      ,     
    input    wire                       in_vld   ,
    input    wire   [DWID-1:0]          in_data  ,
    input    wire                       in_soc   ,
    input    wire   [KEY_WID:0]         in_key   ,
    output   wire                       in_rdy   ,
    input    wire                       flag_wrk_exit  ,
    output   reg    [DWID-1:0]          out_data ,
    output   reg                        out_vld  ,
    input    wire                       out_rdy  ,
    input    wire   [32-1:0]            cfg_cpkt_gap ,
    output   reg    [32-1:0]            cnt_wrk_nrdy ,
    output   reg    [32-1:0]            cnt_num_nrdy ,
    output   reg    [32-1:0]            cnt_out_nrdy ,
    output   wire   [DBG_WID-1:0]       dbg_sig
);
localparam CELL_WID = clogb2(CELL_LEN) ;
integer i ;
wire  [      1-1:0]          que_fifo_wen    ;
wire  [DWID-1:0]             que_fifo_wdata  ;
wire  [      1-1:0]          que_fifo_nafull ;
reg   [      1-1:0]          que_fifo_ren    ;
wire  [DWID-1:0]             que_fifo_rdata  ;
wire  [      1-1:0]          que_fifo_nempty ;
wire  [DBG_WID-1:0]          que_fifo_dbg    ;
wire  [      1-1:0]          key_fifo_wen    ;
wire  [KEY_WID  :0]          key_fifo_wdata  ;
wire  [      1-1:0]          key_fifo_nafull ;
reg   [      1-1:0]          key_fifo_ren    ;
wire  [KEY_WID  :0]          key_fifo_rdata  ;
wire  [      1-1:0]          key_fifo_nempty ;
wire  [DBG_WID-1:0]          key_fifo_dbg    ;
assign in_rdy          = que_fifo_nafull & key_fifo_nafull;
assign que_fifo_wen    = in_vld  ;
assign que_fifo_wdata  = in_data ;
assign key_fifo_wen    = in_vld & in_soc ;
assign key_fifo_wdata  = in_key  ;
reg  [7:0] cnt_wrk                   ;
reg  [31:0] cnt_gap                   ;
reg  [(KEY_WID+1)*WRK_NUM-1:0]  key_wrk  ;
reg        flag_wrk_enable           ;  
reg        flag_wrk_exit_d1          ;
wire       flag_wrk_exit_trigger     ;
always @ ( posedge clk or posedge rst ) begin
    if( rst==1'b1 ) begin
        flag_wrk_exit_d1 <= 0;
    end
    else begin
        flag_wrk_exit_d1 <= flag_wrk_exit;
    end
end
generate
if(EXIT_TYP==0) begin
        assign flag_wrk_exit_trigger = (flag_wrk_exit==1'b1 && flag_wrk_exit_d1==1'b0) ? 1'b1 : 1'b0;
end
else begin
        assign flag_wrk_exit_trigger = (flag_wrk_exit==1'b1) ? 1'b1 : 1'b0;
end
endgenerate
always @ ( posedge clk or posedge rst ) begin
    if( rst==1'b1 ) begin
        cnt_wrk <= 0;
    end
    else begin
        if( key_fifo_ren==1'b1 && flag_wrk_exit_trigger==1'b0 ) begin
             cnt_wrk <= cnt_wrk + 1'b1;
        end
        else if( flag_wrk_exit_trigger==1'b1 && key_fifo_ren==1'b0 ) begin
             cnt_wrk <= cnt_wrk - 1'b1;
        end
    end
end
always @ ( posedge clk or posedge rst ) begin
    if( rst==1'b1 ) begin
        key_wrk <= 0;
    end
    else begin
        if( key_fifo_ren==1'b1 ) begin
          key_wrk <= { key_wrk[(KEY_WID+1)*(WRK_NUM-1)-1 : 0], key_fifo_rdata[KEY_WID:0] };
        end
    end
end
generate 
  if(EN_KEY_VLD == 0) begin  
    always @ ( * ) begin
      flag_wrk_enable = 0 ;
      if( cnt_wrk<WRK_NUM ) begin
        flag_wrk_enable = 1 ;
        for( i=0; i<WRK_NUM; i=i+1 ) begin
          if( key_wrk[i*(KEY_WID+1)+:KEY_WID]==key_fifo_rdata[KEY_WID-1:0] && i<cnt_wrk ) begin
            flag_wrk_enable = 0 ;
          end
        end
      end
    end
  end
  else begin
    always @ ( * ) begin
      flag_wrk_enable = 0 ;
      if( cnt_wrk<WRK_NUM ) begin
        flag_wrk_enable = 1 ;
        for( i=0; i<WRK_NUM; i=i+1 ) begin
          if( key_wrk[i*(KEY_WID+1)+:KEY_WID]==key_fifo_rdata[KEY_WID-1:0] && i<cnt_wrk
          &&  key_fifo_rdata[KEY_WID] == 1'b1 && key_wrk[(i*(KEY_WID+1)+KEY_WID) +:1] == 1'b1 ) begin
            flag_wrk_enable = 0 ;
          end
        end
      end
    end
  end
endgenerate
always @ ( posedge clk or posedge rst ) begin
   if( rst==1'b1 ) begin
       cnt_gap <= 0;
   end
   else begin
      if( key_fifo_ren==1'b1 )begin
          cnt_gap <= 0;
      end
      else begin
          cnt_gap <= cnt_gap + 1'b1;
      end
   end
end
always @ ( posedge clk or posedge rst ) begin
   if( rst==1'b1 ) begin
       key_fifo_ren <= 0;
   end
   else begin
      if( key_fifo_nempty==1'b1 && key_fifo_ren==1'b0 && flag_wrk_enable==1'b1 && cnt_gap>cfg_cpkt_gap && out_rdy==1'b1 )begin
          key_fifo_ren <= 1'b1;
      end
      else begin
          key_fifo_ren <= 1'b0;
      end
   end
end
always @ ( posedge clk or posedge rst ) begin
   if( rst==1'b1 ) begin
       que_fifo_ren <= 0;
   end
   else begin
      if( key_fifo_ren==1'b1 )begin
          que_fifo_ren <= 1'b1;
      end
      else if( cnt_gap==(CELL_LEN-1) )begin
          que_fifo_ren <= 1'b0;
      end
   end
end
always @ ( posedge clk or posedge rst ) begin
   if( rst==1'b1 ) begin
       out_vld   <= 0;
       out_data  <= 0;
   end
   else begin
       out_vld   <= que_fifo_ren   ;
       out_data  <= que_fifo_rdata ;
   end
end
wire  [AWID-1:0] cnt_key_used ;
reg   [AWID-1:0] cnt_key_lock ;
bfifo #(
  .RAM_STYLE ( RAM_STYLE ) ,
  .DWID      ( DWID      ) ,
  .AWID      ( AWID+CELL_WID ) ,
  .AFULL_TH  ( AFULL_TH  ) ,
  .AEMPTY_TH (           ) ,
  .DBG_WID   ( DBG_WID   )
) u_que_fifo(
  .clk       ( clk             ),
  .rst       ( rst             ),
  .wen       ( que_fifo_wen    ),
  .wdata     ( que_fifo_wdata  ),
  .nfull     (                 ),
  .nafull    ( que_fifo_nafull ),
  .woverflow (                 ),
  .cnt_free  (                 ),
  .ren       ( que_fifo_ren    ),
  .rdata     ( que_fifo_rdata  ),
  .nempty    ( que_fifo_nempty ),
  .naempty   (                 ),
  .roverflow (                 ),
  .cnt_used  (                 ),
  .dbg_sig   ( que_fifo_dbg    ) 
);
bfifo #(
  .RAM_STYLE ( "distributed" ) ,
  .DWID      ( KEY_WID + 1  ) ,
  .AWID      ( AWID      ) ,
  .AFULL_TH  ( AFULL_TH  ) ,
  .AEMPTY_TH (           ) ,
  .DBG_WID   ( DBG_WID   )
) u_key_fifo(
  .clk       ( clk             ),
  .rst       ( rst             ),
  .wen       ( key_fifo_wen    ),
  .wdata     ( key_fifo_wdata  ),
  .nfull     (                 ),
  .nafull    ( key_fifo_nafull ),
  .woverflow (                 ),
  .cnt_free  (                 ),
  .ren       ( key_fifo_ren    ),
  .rdata     ( key_fifo_rdata  ),
  .nempty    ( key_fifo_nempty ),
  .naempty   (                 ),
  .roverflow (                 ),
  .cnt_used  ( cnt_key_used    ),
  .dbg_sig   ( key_fifo_dbg    ) 
);
assign dbg_sig = { que_fifo_dbg[16-1:0],key_fifo_dbg[16-1:0]};
wire  [(KEY_WID+1)*WRK_NUM-1:0]  key_dbg  ;
genvar k;
generate
for( k=0; k<WRK_NUM; k=k+1 ) begin
  assign key_dbg[k*(KEY_WID+1)+:(KEY_WID+1)] = key_wrk[k*(KEY_WID+1)+:(KEY_WID+1)];
end
endgenerate
always@(posedge clk or posedge rst)
begin
  if(rst == 1'b1)
  begin
    cnt_wrk_nrdy <= 32'h0 ;
    cnt_num_nrdy <= 32'h0 ;
    cnt_out_nrdy <= 32'h0 ;
  end
  else
  begin
    if(key_fifo_nempty == 1'b1 && flag_wrk_enable == 1'b0 && cnt_gap>cfg_cpkt_gap)
    begin
      cnt_wrk_nrdy <= cnt_wrk_nrdy + 32'h1 ;
    end
    if(key_fifo_nempty == 1'b1 && flag_wrk_enable == 1'b0 && cnt_wrk >= WRK_NUM && cnt_gap>cfg_cpkt_gap)
    begin
      cnt_num_nrdy <= cnt_num_nrdy + 32'h1 ;
    end
    if(key_fifo_nempty==1'b1 && key_fifo_ren==1'b0 && flag_wrk_enable==1'b1 && cnt_gap>cfg_cpkt_gap && out_rdy==1'b0)
    begin
      cnt_out_nrdy <= cnt_out_nrdy + 1'b1;
    end
  end
end
function integer clogb2;
  input integer depth;
  integer depth_reg;
  begin
        depth_reg = depth;
        for (clogb2=0; depth_reg>0; clogb2=clogb2+1)begin
          depth_reg = depth_reg >> 1;
        end
        if( 2**clogb2 >= depth*2 )begin
          clogb2 = clogb2 - 1;
        end
  end
endfunction
endmodule


module tcp_rx_tcpkt_mix #(
		parameter    PDWID        = 128 			,               
		parameter    PDSZ         = 4 			  ,               
		parameter    DBG_WID      = 32 				 		            
) (
		input	  wire				           clk		 	                          ,
		input 	wire				           rst			                          ,
    if_tcp_cfg_reg.sink            u_if_tcp_cfg_reg ,
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
	.cpkt_vld 		    ( in_pd_vld		    ),	
	.cpkt_dat 		    ( in_pd_dat		    ),	
	.cpkt_msg 		    ( 1'b0			      ),	
 	.total_cpkt_vld 	( total_pd_vld  	), 
	.total_cpkt_dat 	( total_pd_dat  	), 
	.total_cpkt_msg 	(       		      ) 
);
`include "common_define_value.v"
`include "pkt_des_unpack.v"
wire				       in_pd_vld_d4		                      ;
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
    .cfg_limit_rate_en ( u_if_tcp_cfg_reg.cfg_limit_rate_en ),
    .in_vld   ( in_pd_vld_d4  ),
    .in_data  ( in_pd_dat_d4  ),
    .in_rdy   ( in_pd_rdy     ),
    .in_soc   ( total_pd_vld  ),
    .in_key   ( pkt_fid       ),
    .out_data ( out_pd_dat    ),
    .out_vld  ( out_pd_vld    ),
    .out_rdy  ( out_pd_rdy    ),
    .dbg_sig  (               )
);
assign dbg_sig = 32'h0;
endmodule